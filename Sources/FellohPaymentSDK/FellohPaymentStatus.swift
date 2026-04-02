import Foundation

/// The current status of the payment form.
public enum FellohPaymentStatus: String {
    case preload = "preload"
    case rendered = "rendered"
    case processing = "processing"
    case success = "success"
    case declined = "declined"
}
