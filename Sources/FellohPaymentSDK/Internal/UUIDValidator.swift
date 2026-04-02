import Foundation

enum UUIDValidator {
    private static let uuidPattern = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"

    static func isValid(_ string: String) -> Bool {
        string.range(of: uuidPattern, options: .regularExpression) != nil
    }
}
