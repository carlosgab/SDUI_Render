import Foundation

/// Identifies the kind of SDUI component described in the JSON payload.
public enum ComponentType: RawRepresentable, Hashable {
    case container
    case image
    case text
    case carousel
    case xmedia
    case custom(String)

    public init?(rawValue: String) {
        switch rawValue {
        case "container": self = .container
        case "image":     self = .image
        case "text":      self = .text
        case "carousel":  self = .carousel
        case "media":    self = .xmedia
        default:          self = .custom(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .container:         return "container"
        case .image:             return "image"
        case .text:              return "text"
        case .carousel:          return "carousel"
        case .xmedia:            return "media"
        case .custom(let value): return value
        }
    }
}
