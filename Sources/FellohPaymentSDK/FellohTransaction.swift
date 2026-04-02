import Foundation

/// A Felloh payment transaction returned in event callbacks.
public struct FellohTransaction {
    /// The unique transaction identifier.
    public let id: String

    public init(id: String) {
        self.id = id
    }
}
