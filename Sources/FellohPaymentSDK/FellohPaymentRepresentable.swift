import SwiftUI

/// A SwiftUI view that wraps `FellohPaymentView` for use in SwiftUI layouts.
///
/// Usage:
/// ```swift
/// FellohPayment(
///     configuration: .init(publicKey: "pk_live_xxx", environment: .sandbox),
///     ecommerceID: "550e8400-e29b-41d4-a716-446655440000",
///     onRender: { print("Rendered") },
///     onSuccess: { tx in print("Success: \(tx.id)") },
///     onDecline: { tx in print("Declined: \(tx.id)") },
///     onProcessing: { tx in print("Processing: \(tx.id)") }
/// )
/// ```
@available(iOS 15.0, *)
public struct FellohPayment: UIViewRepresentable {

    private let configuration: FellohPaymentConfiguration
    private let ecommerceID: String
    private let onRender: (() -> Void)?
    private let onSuccess: ((FellohTransaction) -> Void)?
    private let onDecline: ((FellohTransaction) -> Void)?
    private let onProcessing: ((FellohTransaction) -> Void)?

    /// Create a SwiftUI Felloh payment view.
    ///
    /// - Parameters:
    ///   - configuration: The payment configuration.
    ///   - ecommerceID: The ecommerce instance UUID from the Felloh API.
    ///   - onRender: Called when the payment form finishes loading.
    ///   - onSuccess: Called when payment succeeds.
    ///   - onDecline: Called when payment is declined.
    ///   - onProcessing: Called when payment is being processed.
    public init(
        configuration: FellohPaymentConfiguration,
        ecommerceID: String,
        onRender: (() -> Void)? = nil,
        onSuccess: ((FellohTransaction) -> Void)? = nil,
        onDecline: ((FellohTransaction) -> Void)? = nil,
        onProcessing: ((FellohTransaction) -> Void)? = nil
    ) {
        self.configuration = configuration
        self.ecommerceID = ecommerceID
        self.onRender = onRender
        self.onSuccess = onSuccess
        self.onDecline = onDecline
        self.onProcessing = onProcessing
    }

    public func makeUIView(context: Context) -> FellohPaymentView {
        let view = FellohPaymentView(configuration: configuration)
        view.onRender = onRender
        view.onSuccess = onSuccess
        view.onDecline = onDecline
        view.onProcessing = onProcessing
        try? view.render(ecommerceID: ecommerceID)
        return view
    }

    public func updateUIView(_ uiView: FellohPaymentView, context: Context) {}
}
