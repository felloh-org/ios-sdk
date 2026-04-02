import Foundation

/// Delegate protocol for receiving payment form events.
public protocol FellohPaymentDelegate: AnyObject {
    /// Called when the payment form has finished loading.
    func fellohPaymentDidRender(_ paymentView: FellohPaymentView)

    /// Called when a payment completes successfully.
    func fellohPayment(_ paymentView: FellohPaymentView, didSucceedWith transaction: FellohTransaction)

    /// Called when a payment is declined.
    func fellohPayment(_ paymentView: FellohPaymentView, didDeclineWith transaction: FellohTransaction)

    /// Called when a payment has been submitted and is being processed.
    func fellohPayment(_ paymentView: FellohPaymentView, isProcessing transaction: FellohTransaction)
}

// Default implementations so delegates can opt in to only the events they care about.
public extension FellohPaymentDelegate {
    func fellohPaymentDidRender(_ paymentView: FellohPaymentView) {}
    func fellohPayment(_ paymentView: FellohPaymentView, didSucceedWith transaction: FellohTransaction) {}
    func fellohPayment(_ paymentView: FellohPaymentView, didDeclineWith transaction: FellohTransaction) {}
    func fellohPayment(_ paymentView: FellohPaymentView, isProcessing transaction: FellohTransaction) {}
}
