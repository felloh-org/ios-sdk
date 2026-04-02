import XCTest
@testable import FellohPaymentSDK

final class FellohPaymentViewTests: XCTestCase {

    private var paymentView: FellohPaymentView!

    override func setUp() {
        super.setUp()
        let config = FellohPaymentConfiguration(
            publicKey: "pk_test_abc123",
            environment: .sandbox
        )
        paymentView = FellohPaymentView(configuration: config)
    }

    override func tearDown() {
        paymentView = nil
        super.tearDown()
    }

    func testInitialStatus() {
        XCTAssertEqual(paymentView.status, .preload)
    }

    func testConfigurationIsStored() {
        XCTAssertEqual(paymentView.configuration.publicKey, "pk_test_abc123")
        XCTAssertEqual(paymentView.configuration.environment, .sandbox)
    }

    func testRenderThrowsForInvalidUUID() {
        XCTAssertThrowsError(try paymentView.render(ecommerceID: "not-a-uuid")) { error in
            guard case FellohError.invalidEcommerceID = error else {
                XCTFail("Expected invalidEcommerceID error, got \(error)")
                return
            }
        }
    }

    func testRenderThrowsForEmptyString() {
        XCTAssertThrowsError(try paymentView.render(ecommerceID: "")) { error in
            guard case FellohError.invalidEcommerceID = error else {
                XCTFail("Expected invalidEcommerceID error, got \(error)")
                return
            }
        }
    }

    func testRenderAcceptsValidUUID() {
        XCTAssertNoThrow(try paymentView.render(ecommerceID: "550e8400-e29b-41d4-a716-446655440000"))
    }

    func testRenderReturnsSelf() throws {
        let result = try paymentView.render(ecommerceID: "550e8400-e29b-41d4-a716-446655440000")
        XCTAssertTrue(result === paymentView)
    }

    func testErrorDescriptions() {
        let idError = FellohError.invalidEcommerceID("bad-id")
        XCTAssertTrue(idError.localizedDescription.contains("bad-id"))

        let urlError = FellohError.invalidURL
        XCTAssertTrue(urlError.localizedDescription.contains("URL"))
    }
}

// MARK: - Delegate Tests

final class FellohPaymentDelegateTests: XCTestCase {

    private final class MockDelegate: FellohPaymentDelegate {
        var didRender = false
        var successTransaction: FellohTransaction?
        var declinedTransaction: FellohTransaction?
        var processingTransaction: FellohTransaction?

        func fellohPaymentDidRender(_ paymentView: FellohPaymentView) {
            didRender = true
        }

        func fellohPayment(_ paymentView: FellohPaymentView, didSucceedWith transaction: FellohTransaction) {
            successTransaction = transaction
        }

        func fellohPayment(_ paymentView: FellohPaymentView, didDeclineWith transaction: FellohTransaction) {
            declinedTransaction = transaction
        }

        func fellohPayment(_ paymentView: FellohPaymentView, isProcessing transaction: FellohTransaction) {
            processingTransaction = transaction
        }
    }

    func testDelegateDefaultImplementationsDoNotCrash() {
        // Verifies that the default protocol extension methods exist
        // and can be called without crashing
        final class EmptyDelegate: FellohPaymentDelegate {}

        let delegate = EmptyDelegate()
        let config = FellohPaymentConfiguration(publicKey: "pk_test")
        let view = FellohPaymentView(configuration: config)
        let transaction = FellohTransaction(id: "test-id")

        delegate.fellohPaymentDidRender(view)
        delegate.fellohPayment(view, didSucceedWith: transaction)
        delegate.fellohPayment(view, didDeclineWith: transaction)
        delegate.fellohPayment(view, isProcessing: transaction)
    }
}
