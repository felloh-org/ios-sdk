import Foundation

/// Design options for the payment form.
public struct FellohDesignOptions {
    /// Show the built-in pay button. Defaults to `true`.
    public var payButton: Bool

    /// Show the card storage option. Defaults to `true`.
    public var storeCard: Bool

    public init(payButton: Bool = true, storeCard: Bool = true) {
        self.payButton = payButton
        self.storeCard = storeCard
    }
}

/// Configuration for the Felloh payment form.
public struct FellohPaymentConfiguration {
    /// Your publishable API key from the Felloh Dashboard.
    public let publicKey: String

    /// The environment to use. Defaults to `.production`.
    public var environment: FellohEnvironment

    /// Enable Mail Order/Telephone Order mode. Defaults to `false`.
    public var moto: Bool

    /// Design options for the payment form.
    public var design: FellohDesignOptions

    public init(
        publicKey: String,
        environment: FellohEnvironment = .production,
        moto: Bool = false,
        design: FellohDesignOptions = FellohDesignOptions()
    ) {
        self.publicKey = publicKey
        self.environment = environment
        self.moto = moto
        self.design = design
    }

    /// Build the full URL for a given ecommerce payment ID.
    func buildURL(for paymentID: String) -> URL? {
        var urlString = environment.baseURL + paymentID
        var queryItems: [String] = []

        if !design.payButton {
            queryItems.append("hpb=1")
        }
        if !design.storeCard {
            queryItems.append("hsc=1")
        }
        if moto {
            queryItems.append("method=MOTO_IN_PERSON")
        }

        if !queryItems.isEmpty {
            urlString += "?" + queryItems.joined(separator: "&")
        }

        return URL(string: urlString)
    }
}
