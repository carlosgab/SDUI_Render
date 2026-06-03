import Foundation

// MARK: - Action type constants

enum ActionTypeConstant {
    static let addToCart    = "addToCart"
    static let navigateToUrl = "navigateToUrl"
    static let navigate     = "navigate"
}

enum DataSourceDataTypeConstant {
    static let navigateToProduct  = "product"
    static let navigateToCategory = "category"
}

// MARK: - Action type

public enum ActionType: RawRepresentable, Hashable {
    case navigate
    case navigateToUrl
    case addToCart

    public init?(rawValue: String) {
        switch rawValue {
        case ActionTypeConstant.navigate:      self = .navigate
        case ActionTypeConstant.navigateToUrl: self = .navigateToUrl
        case ActionTypeConstant.addToCart:     self = .addToCart
        default: return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .navigate:      return ActionTypeConstant.navigate
        case .navigateToUrl: return ActionTypeConstant.navigateToUrl
        case .addToCart:     return ActionTypeConstant.addToCart
        }
    }
}

// MARK: - Base action DTO

public protocol BaseActionDTO {
    var type: String { get }
    func toDomain() -> SDUIAction?
}

// MARK: - Navigate action

struct NavigateActionDTO: BaseActionDTO, Decodable {
    let type: String
    var payload: [String: String]?

    func toDomain() -> SDUIAction? {
        guard let payload else { return nil }
        if let productId = payload["productId"] {
            return ActionNavigateToProduct(productId: productId)
        }
        if let categoryId = payload["categoryId"] {
            return ActionNavigateToCategory(
                categoryId: categoryId,
                redirectionScreenName: payload["redirectionScreenName"]
            )
        }
        return nil
    }
}

// MARK: - Navigate to URL action

struct NavigateToURLPayloadDTO: Decodable {
    let url: String
    let useExternalBrowser: Bool
}

struct NavigateToURLActionDTO: BaseActionDTO, Decodable {
    let type: String
    let payload: NavigateToURLPayloadDTO

    func toDomain() -> SDUIAction? {
        guard let url = URL(string: payload.url) else { return nil }
        return ActionNavigateToURL(url: url, externalBrowser: payload.useExternalBrowser)
    }
}

// MARK: - Add to cart action

struct AddToCartActionDTO: BaseActionDTO, Decodable {
    let type: String

    func toDomain() -> SDUIAction? {
        // productId is resolved from the component's dataSource via ComponentMapper
        nil
    }
}

// MARK: - Action wrapper

/// Polymorphic action wrapper that decodes the correct DTO based on the `type` field.
public struct ActionDTOWrapper: Decodable {
    public var action: BaseActionDTO?

    enum CodingKeys: String, CodingKey { case type }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .type)
        switch ActionType(rawValue: typeString) {
        case .navigate:
            action = try NavigateActionDTO(from: decoder)
        case .navigateToUrl:
            action = try NavigateToURLActionDTO(from: decoder)
        case .addToCart:
            action = try AddToCartActionDTO(from: decoder)
        case nil:
            action = nil
        }
    }

    public func toDomain() -> SDUIAction? {
        action?.toDomain()
    }
}
