import XCTest
@testable import FellohPaymentSDK

final class UUIDValidatorTests: XCTestCase {

    func testValidUUIDs() {
        XCTAssertTrue(UUIDValidator.isValid("550e8400-e29b-41d4-a716-446655440000"))
        XCTAssertTrue(UUIDValidator.isValid("6ba7b810-9dad-11d1-80b4-00c04fd430c8"))
        XCTAssertTrue(UUIDValidator.isValid("AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"))
        XCTAssertTrue(UUIDValidator.isValid("00000000-0000-0000-0000-000000000000"))
    }

    func testInvalidUUIDs() {
        XCTAssertFalse(UUIDValidator.isValid(""))
        XCTAssertFalse(UUIDValidator.isValid("not-a-uuid"))
        XCTAssertFalse(UUIDValidator.isValid("550e8400-e29b-41d4-a716"))
        XCTAssertFalse(UUIDValidator.isValid("550e8400e29b41d4a716446655440000"))
        XCTAssertFalse(UUIDValidator.isValid("550e8400-e29b-41d4-a716-44665544000g"))
        XCTAssertFalse(UUIDValidator.isValid("550e8400-e29b-41d4-a716-4466554400000")) // too long
    }
}
