import Foundation

/// The environment in which the Felloh payment form is loaded.
public enum FellohEnvironment {
    case production
    case sandbox
    case staging
    case dev

    var baseURL: String {
        switch self {
        case .production:
            return "https://pay.felloh.com/embed/"
        case .sandbox:
            return "https://pay.sandbox.felloh.com/embed/"
        case .staging:
            return "https://pay.staging.felloh.com/embed/"
        case .dev:
            return "http://localhost:3010/embed/"
        }
    }
}
