import XCTest
@testable import FellohPaymentSDK

final class FellohTransactionTests: XCTestCase {

    func testTransactionID() {
        let transaction = FellohTransaction(id: "tx-123")
        XCTAssertEqual(transaction.id, "tx-123")
    }
}
