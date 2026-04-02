import XCTest
@testable import FellohPaymentSDK

final class FellohPaymentConfigurationTests: XCTestCase {

    private let testKey = "pk_test_abc123"
    private let testPaymentID = "550e8400-e29b-41d4-a716-446655440000"

    func testDefaultConfiguration() {
        let config = FellohPaymentConfiguration(publicKey: testKey)

        XCTAssertEqual(config.publicKey, testKey)
        XCTAssertEqual(config.environment, .production)
        XCTAssertFalse(config.moto)
        XCTAssertTrue(config.design.payButton)
        XCTAssertTrue(config.design.storeCard)
    }

    func testBuildURLProduction() {
        let config = FellohPaymentConfiguration(publicKey: testKey)
        let url = config.buildURL(for: testPaymentID)

        XCTAssertEqual(url?.absoluteString, "https://pay.felloh.com/embed/\(testPaymentID)")
    }

    func testBuildURLSandbox() {
        let config = FellohPaymentConfiguration(publicKey: testKey, environment: .sandbox)
        let url = config.buildURL(for: testPaymentID)

        XCTAssertEqual(url?.absoluteString, "https://pay.sandbox.felloh.com/embed/\(testPaymentID)")
    }

    func testBuildURLWithHiddenPayButton() {
        let design = FellohDesignOptions(payButton: false)
        let config = FellohPaymentConfiguration(publicKey: testKey, design: design)
        let url = config.buildURL(for: testPaymentID)

        XCTAssertTrue(url?.absoluteString.contains("hpb=1") ?? false)
    }

    func testBuildURLWithHiddenStoreCard() {
        let design = FellohDesignOptions(storeCard: false)
        let config = FellohPaymentConfiguration(publicKey: testKey, design: design)
        let url = config.buildURL(for: testPaymentID)

        XCTAssertTrue(url?.absoluteString.contains("hsc=1") ?? false)
    }

    func testBuildURLWithMOTO() {
        let config = FellohPaymentConfiguration(publicKey: testKey, moto: true)
        let url = config.buildURL(for: testPaymentID)

        XCTAssertTrue(url?.absoluteString.contains("method=MOTO_IN_PERSON") ?? false)
    }

    func testBuildURLWithAllOptions() {
        let design = FellohDesignOptions(payButton: false, storeCard: false)
        let config = FellohPaymentConfiguration(
            publicKey: testKey,
            environment: .sandbox,
            moto: true,
            design: design
        )
        let url = config.buildURL(for: testPaymentID)
        let urlString = url?.absoluteString ?? ""

        XCTAssertTrue(urlString.hasPrefix("https://pay.sandbox.felloh.com/embed/\(testPaymentID)?"))
        XCTAssertTrue(urlString.contains("hpb=1"))
        XCTAssertTrue(urlString.contains("hsc=1"))
        XCTAssertTrue(urlString.contains("method=MOTO_IN_PERSON"))
    }

    func testBuildURLNoQueryParamsWhenDefaults() {
        let config = FellohPaymentConfiguration(publicKey: testKey)
        let url = config.buildURL(for: testPaymentID)

        XCTAssertFalse(url?.absoluteString.contains("?") ?? true)
    }
}
