import Foundation

/// A `Codable` wrapper that can represent any JSON value (object, array, string,
/// number, bool, or null). Used to round-trip opaque JSON payloads like
/// `storeFrontMedia` so they can be preserved as raw strings for platform layers
/// that receive them later (e.g. Android/Skip → `StoreFrontMediaDTO.toXMedia()`).
public enum SDUIAnyJSON: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: SDUIAnyJSON])
    case array([SDUIAnyJSON])
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let v = try? container.decode(Bool.self) {
            self = .bool(v)
        } else if let v = try? container.decode(Int.self) {
            self = .int(v)
        } else if let v = try? container.decode(Double.self) {
            self = .double(v)
        } else if let v = try? container.decode([String: SDUIAnyJSON].self) {
            // Object must be tried before String: on Skip/Kotlin, decode(String)
            // succeeds on JSON objects by calling Map.toString(), producing
            // "{key=value}" format instead of valid JSON.
            self = .object(v)
        } else if let v = try? container.decode([SDUIAnyJSON].self) {
            self = .array(v)
        } else if let v = try? container.decode(String.self) {
            self = .string(v)
        } else {
            self = .null
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let v):  try container.encode(v)
        case .int(let v):     try container.encode(v)
        case .double(let v):  try container.encode(v)
        case .bool(let v):    try container.encode(v)
        case .object(let v):  try container.encode(v)
        case .array(let v):   try container.encode(v)
        case .null:           try container.encodeNil()
        }
    }

}

