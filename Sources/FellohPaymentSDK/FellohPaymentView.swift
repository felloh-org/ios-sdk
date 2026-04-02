import UIKit
import WebKit

/// A view that renders a Felloh hosted payment form using WKWebView.
///
/// Usage:
/// ```swift
/// let config = FellohPaymentConfiguration(publicKey: "pk_live_xxx", environment: .sandbox)
/// let paymentView = FellohPaymentView(configuration: config)
/// paymentView.delegate = self
/// view.addSubview(paymentView)
/// paymentView.render(ecommerceID: "550e8400-e29b-41d4-a716-446655440000")
/// ```
public final class FellohPaymentView: UIView {

    // MARK: - Public Properties

    /// The delegate that receives payment form events.
    public weak var delegate: FellohPaymentDelegate?

    /// The current status of the payment form.
    public private(set) var status: FellohPaymentStatus = .preload

    /// The configuration for this payment view.
    public let configuration: FellohPaymentConfiguration

    // MARK: - Closure-Based Callbacks

    /// Called when the payment form has finished loading.
    public var onRender: (() -> Void)?

    /// Called when a payment completes successfully.
    public var onSuccess: ((FellohTransaction) -> Void)?

    /// Called when a payment is declined.
    public var onDecline: ((FellohTransaction) -> Void)?

    /// Called when a payment has been submitted and is being processed.
    public var onProcessing: ((FellohTransaction) -> Void)?

    // MARK: - Private Properties

    private var webView: WKWebView!
    private var currentPaymentID: String?
    private var transactionID: String?
    private var refreshTimer: Timer?
    private static let refreshInterval: TimeInterval = 15 * 60 // 15 minutes

    // MARK: - Initialization

    /// Create a new payment view with the given configuration.
    ///
    /// - Parameter configuration: The payment configuration including public key and environment.
    public init(configuration: FellohPaymentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupWebView()
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(configuration:) instead")
    }

    deinit {
        refreshTimer?.invalidate()
    }

    // MARK: - Public Methods

    /// Render the payment form for the given ecommerce instance ID.
    ///
    /// The ecommerce ID is obtained from the Felloh API server-side.
    ///
    /// - Parameter ecommerceID: A valid UUID identifying the ecommerce payment instance.
    /// - Throws: `FellohError.invalidEcommerceID` if the ID is not a valid UUID.
    @discardableResult
    public func render(ecommerceID: String) throws -> FellohPaymentView {
        guard UUIDValidator.isValid(ecommerceID) else {
            throw FellohError.invalidEcommerceID(ecommerceID)
        }

        guard let url = configuration.buildURL(for: ecommerceID) else {
            throw FellohError.invalidURL
        }

        currentPaymentID = ecommerceID
        status = .preload
        transactionID = nil

        webView.load(URLRequest(url: url))
        startRefreshTimer()

        return self
    }

    /// Manually trigger payment processing.
    ///
    /// Use this when `design.payButton` is set to `false` and you want to trigger
    /// the payment from your own button.
    public func pay() {
        let escapedKey = configuration.publicKey
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
        let script = """
        window.postMessage(JSON.stringify({
            type: 'INITIATE_PAY',
            payload: '\(escapedKey)'
        }), '*');
        """
        webView.evaluateJavaScript(script)
    }

    // MARK: - Private Methods

    private func setupWebView() {
        let contentController = WKUserContentController()
        contentController.add(LeakAvoider(delegate: self), name: "fellohSDK")

        // Inject script to forward postMessage events to the native handler
        let bridgeScript = WKUserScript(
            source: """
            window.addEventListener('message', function(event) {
                try {
                    var data = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
                    window.webkit.messageHandlers.fellohSDK.postMessage(JSON.stringify(data));
                } catch(e) {}
            });
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        contentController.addUserScript(bridgeScript)

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        webView = WKWebView(frame: bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.isScrollEnabled = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
        addSubview(webView)
    }

    private func startRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: Self.refreshInterval,
            repeats: true
        ) { [weak self] _ in
            self?.refreshIfNeeded()
        }
    }

    private func refreshIfNeeded() {
        guard status == .preload || status == .rendered,
              let paymentID = currentPaymentID else {
            return
        }
        try? render(ecommerceID: paymentID)
    }

    private func handleMessage(_ body: [String: Any]) {
        // Handle iframe redirect
        if let redirect = body["iframeRedirect"] as? String,
           let url = URL(string: redirect) {
            webView.load(URLRequest(url: url))
            return
        }

        // Track transaction ID
        if let txID = body["transactionID"] as? String {
            transactionID = txID
        }

        // Handle height adjustment
        if let height = body["iframe_height"] as? CGFloat {
            updateHeight(height)
        }

        // Handle stage changes
        if let stage = body["stage"] as? String {
            handleStageChange(stage)
        }
    }

    private func handleStageChange(_ stage: String) {
        guard let newStatus = FellohPaymentStatus(rawValue: stage) else { return }
        status = newStatus

        let transaction = FellohTransaction(id: transactionID ?? "")

        switch newStatus {
        case .rendered:
            delegate?.fellohPaymentDidRender(self)
            onRender?()
        case .success:
            delegate?.fellohPayment(self, didSucceedWith: transaction)
            onSuccess?(transaction)
        case .declined:
            delegate?.fellohPayment(self, didDeclineWith: transaction)
            onDecline?(transaction)
        case .processing:
            delegate?.fellohPayment(self, isProcessing: transaction)
            onProcessing?(transaction)
        case .preload:
            break
        }
    }

    private func updateHeight(_ height: CGFloat) {
        guard let heightConstraint = constraints.first(where: { $0.firstAttribute == .height && $0.firstItem === self }) else {
            heightAnchor.constraint(equalToConstant: height).isActive = true
            return
        }
        heightConstraint.constant = height
    }
}

// MARK: - WKScriptMessageHandler

extension FellohPaymentView: WKScriptMessageHandler {
    public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == "fellohSDK",
              let bodyString = message.body as? String,
              let data = bodyString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        handleMessage(json)
    }
}

// MARK: - Errors

/// Errors that can be thrown by the Felloh Payment SDK.
public enum FellohError: LocalizedError {
    case invalidEcommerceID(String)
    case invalidURL

    public var errorDescription: String? {
        switch self {
        case .invalidEcommerceID(let id):
            return "Invalid ecommerce ID: '\(id)' is not a valid UUID."
        case .invalidURL:
            return "Failed to construct a valid payment URL."
        }
    }
}

// MARK: - LeakAvoider

/// Prevents a retain cycle between WKUserContentController and the payment view.
private final class LeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
