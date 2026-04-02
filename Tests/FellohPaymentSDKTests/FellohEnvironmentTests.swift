import XCTest
@testable import FellohPaymentSDK

final class FellohEnvironmentTests: XCTestCase {

    func testProductionURL() {
        XCTAssertEqual(FellohEnvironment.production.baseURL, "https://pay.felloh.com/embed/")
    }

    func testSandboxURL() {
        XCTAssertEqual(FellohEnvironment.sandbox.baseURL, "https://pay.sandbox.felloh.com/embed/")
    }

    func testStagingURL() {
        XCTAssertEqual(FellohEnvironment.staging.baseURL, "https://pay.staging.felloh.com/embed/")
    }

    func testDevURL() {
        XCTAssertEqual(FellohEnvironment.dev.baseURL, "http://localhost:3010/embed/")
    }
}
