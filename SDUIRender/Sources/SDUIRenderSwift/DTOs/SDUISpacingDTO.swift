import Foundation

/// Spacing value that can be expressed either as a raw percentage or a design-token key.
public struct SDUISpacingDTO: Decodable, Equatable {
    /// Spacing as a percentage of parent container width (e.g., `4.1` means 4.1 %)
    public var value: Double?
    /// Design-system token key (resolved to a point value by the host app, ignored in this engine)
    public var token: String?

    /// Resolved spacing in points.
    /// In this engine the token is not resolved — only `value` is used.
    public var spacingValue: Double? {
        value
    }

    public func toDomain() -> SpacingBO {
        if let v = spacingValue {
            return .relative(value: v)
        }
        return .absolute(value: 0.0)
    }
}
