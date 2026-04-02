import XCTest
@testable import FellohPaymentSDK

final class FellohPaymentStatusTests: XCTestCase {

    func testRawValues() {
        XCTAssertEqual(FellohPaymentStatus.preload.rawValue, "preload")
        XCTAssertEqual(FellohPaymentStatus.rendered.rawValue, "rendered")
        XCTAssertEqual(FellohPaymentStatus.processing.rawValue, "processing")
        XCTAssertEqual(FellohPaymentStatus.success.rawValue, "success")
        XCTAssertEqual(FellohPaymentStatus.declined.rawValue, "declined")
    }

    func testInitFromRawValue() {
        XCTAssertEqual(FellohPaymentStatus(rawValue: "preload"), .preload)
        XCTAssertEqual(FellohPaymentStatus(rawValue: "rendered"), .rendered)
        XCTAssertEqual(FellohPaymentStatus(rawValue: "processing"), .processing)
        XCTAssertEqual(FellohPaymentStatus(rawValue: "success"), .success)
        XCTAssertEqual(FellohPaymentStatus(rawValue: "declined"), .declined)
        XCTAssertNil(FellohPaymentStatus(rawValue: "unknown"))
    }
}
