import Foundation
import SwiftUI

// MARK: - Image domain model

public struct ImageBO {
    public let path: String
    public let objectFit: ObjectFit
    public let objectPosition: ObjectPosition
    public let dimensions: CGSize?

    public init(path: String, objectFit: String, objectPosition: String, dimensions: CGSize? = nil) {
        self.path = path
        self.objectFit = ObjectFit(rawValue: objectFit) ?? .contain
        self.objectPosition = ObjectPosition(rawValue: objectPosition) ?? .center
        self.dimensions = dimensions
    }
}

public enum ObjectFit: String {
    case contain
    case cover

    public var contentMode: ContentMode {
        switch self {
        case .cover:    return .fill
        case .contain:  return .fit
        }
    }
}

public enum ObjectPosition: String {
    case center
    case top
    case bottom

    public var alignment: Alignment {
        switch self {
        case .center: return .center
        case .top:    return .top
        case .bottom: return .bottom
        }
    }
}

// MARK: - Spacing domain model

public enum SpacingBO {
    /// Fixed value in points.
    case absolute(value: Double)
    /// Percentage of the parent container width.
    case relative(value: Double)
}
