import XCTest
@testable import FellohPaymentSDK

final class FellohDesignOptionsTests: XCTestCase {

    func testDefaults() {
        let options = FellohDesignOptions()
        XCTAssertTrue(options.payButton)
        XCTAssertTrue(options.storeCard)
    }

    func testCustomValues() {
        let options = FellohDesignOptions(payButton: false, storeCard: false)
        XCTAssertFalse(options.payButton)
        XCTAssertFalse(options.storeCard)
    }
}
