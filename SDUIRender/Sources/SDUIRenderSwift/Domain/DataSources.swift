import Foundation
#if canImport(XMediaPlayer) && !SKIP
import XMediaPlayer
import ITXMediaStoreFront
#endif

/// Marker protocol for all SDUI data sources that drive dynamic content.
public protocol SDUIDataSource {
    var type: String { get }
}

// MARK: - Data source type enum

enum DataSourceType: String {
    case product  = "product"
    case category = "category"
}

// MARK: - Product

/// A data source that represents a single product.
public struct ProductDataSource: SDUIDataSource {
    public let type: String = DataSourceType.product.rawValue
    public let id: String?
    public let name: String?
    public let reference: String?
    public let currentPrice: String?
    public let oldPrice: String?
    public let originalPrice: String?
    public let discountPercentage: String?
    public let displayTag: String?
    public let description: String?
    public let imageURL: String?
    #if canImport(XMediaPlayer) && !SKIP
    public let storeFrontMedia: StoreFrontITXMediaDTO?
    #else
    /// Raw JSON string of `storeFrontMedia` for Android/Skip rendering.
    public let storeFrontMediaRawJson: String?
    #endif

    #if canImport(XMediaPlayer) && !SKIP
    public init(
        id: String? = nil,
        name: String? = nil,
        reference: String? = nil,
        currentPrice: String? = nil,
        oldPrice: String? = nil,
        originalPrice: String? = nil,
        discountPercentage: String? = nil,
        displayTag: String? = nil,
        description: String? = nil,
        imageURL: String? = nil,
        storeFrontMedia: StoreFrontITXMediaDTO? = nil
    ) {
        self.id = id
        self.name = name
        self.reference = reference
        self.currentPrice = currentPrice
        self.oldPrice = oldPrice
        self.originalPrice = originalPrice
        self.discountPercentage = discountPercentage
        self.displayTag = displayTag
        self.description = description
        self.imageURL = imageURL
        self.storeFrontMedia = storeFrontMedia
    }
    #else
    public init(
        id: String? = nil,
        name: String? = nil,
        reference: String? = nil,
        currentPrice: String? = nil,
        oldPrice: String? = nil,
        originalPrice: String? = nil,
        discountPercentage: String? = nil,
        displayTag: String? = nil,
        description: String? = nil,
        imageURL: String? = nil,
        storeFrontMediaRawJson: String? = nil
    ) {
        self.id = id
        self.name = name
        self.reference = reference
        self.currentPrice = currentPrice
        self.oldPrice = oldPrice
        self.originalPrice = originalPrice
        self.discountPercentage = discountPercentage
        self.displayTag = displayTag
        self.description = description
        self.imageURL = imageURL
        self.storeFrontMediaRawJson = storeFrontMediaRawJson
    }
    #endif
}

/// Decodable DTO for ProductDataSource (used when data sources arrive in the JSON payload).
public struct ProductDataSourceDTO: DecodableDataSource {
    public let id: String?
    public let name: String?
    public let reference: String?
    public let currentPrice: String?
    public let oldPrice: String?
    public let originalPrice: String?
    public let discountPercentage: String?
    public let displayTag: String?
    public let description: String?
    public let imageURL: String?

    public func toDomain() -> [SDUIDataSource] {
        [ProductDataSource(
            id: id,
            name: name,
            reference: reference,
            currentPrice: currentPrice,
            oldPrice: oldPrice,
            originalPrice: originalPrice,
            discountPercentage: discountPercentage,
            displayTag: displayTag,
            description: description,
            imageURL: imageURL
        )]
    }
}

// MARK: - Category

/// A data source that represents a single category.
public struct CategoryDataSource: SDUIDataSource {
    public let type: String = DataSourceType.category.rawValue
    public let id: String?
    public let name: String?
    public let tag: String?
    public let redirectionScreenName: String?
    public let imageURL: String?
    #if canImport(XMediaPlayer) && !SKIP
    public let storeFrontMedia: StoreFrontITXMediaDTO?
    #else
    /// Raw JSON string of `storeFrontMedia` for Android/Skip rendering.
    public let storeFrontMediaRawJson: String?
    #endif

    #if canImport(XMediaPlayer) && !SKIP
    public init(
        id: String? = nil,
        name: String? = nil,
        tag: String? = nil,
        redirectionScreenName: String? = nil,
        imageURL: String? = nil,
        storeFrontMedia: StoreFrontITXMediaDTO? = nil
    ) {
        self.id = id
        self.name = name
        self.tag = tag
        self.redirectionScreenName = redirectionScreenName
        self.imageURL = imageURL
        self.storeFrontMedia = storeFrontMedia
    }
    #else
    public init(
        id: String? = nil,
        name: String? = nil,
        tag: String? = nil,
        redirectionScreenName: String? = nil,
        imageURL: String? = nil,
        storeFrontMediaRawJson: String? = nil
    ) {
        self.id = id
        self.name = name
        self.tag = tag
        self.redirectionScreenName = redirectionScreenName
        self.imageURL = imageURL
        self.storeFrontMediaRawJson = storeFrontMediaRawJson
    }
    #endif
}

public struct CategoryDataSourceDTO: DecodableDataSource {
    public let id: String?
    public let name: String?
    public let tag: String?
    public let redirectionScreenName: String?
    public let imageURL: String?

    public func toDomain() -> [SDUIDataSource] {
        [CategoryDataSource(
            id: id,
            name: name,
            tag: tag,
            redirectionScreenName: redirectionScreenName,
            imageURL: imageURL
        )]
    }
}

// MARK: - Decodable conformances (JSON → domain, used by DataSourceDTOWrapper)

extension ProductDataSource: Decodable {
    enum ProductCodingKeys: String, CodingKey {
        case id, name, reference, currentPrice, oldPrice, originalPrice
        case discountPercentage, displayTag, description, imageURL
        #if canImport(XMediaPlayer) && !SKIP
        case storeFrontMedia
        #elseif SKIP
        case storeFrontMedia
        #endif
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ProductCodingKeys.self)
        // id arrives as an array in the JSON payload
        let idArray = (try? container.decode([String].self, forKey: .id)) ?? []
        self.id = idArray.first
        self.name               = try? container.decode(String.self, forKey: .name)
        self.reference          = try? container.decode(String.self, forKey: .reference)
        self.currentPrice       = try? container.decode(String.self, forKey: .currentPrice)
        self.oldPrice           = try? container.decode(String.self, forKey: .oldPrice)
        self.originalPrice      = try? container.decode(String.self, forKey: .originalPrice)
        self.discountPercentage = try? container.decode(String.self, forKey: .discountPercentage)
        self.displayTag         = try? container.decode(String.self, forKey: .displayTag)
        self.description        = try? container.decode(String.self, forKey: .description)
        self.imageURL           = try? container.decode(String.self, forKey: .imageURL)
        #if canImport(XMediaPlayer) && !SKIP
        self.storeFrontMedia    = try? container.decode(StoreFrontITXMediaDTO.self, forKey: .storeFrontMedia)
        #elseif SKIP
        if let rawDict = try? container.decode([String: SDUIAnyJSON].self, forKey: .storeFrontMedia) {
            self.storeFrontMediaRawJson = storeFrontMediaToJSON(rawDict: rawDict)
        } else {
            self.storeFrontMediaRawJson = nil
        }
        #else
        self.storeFrontMediaRawJson = nil
        #endif
    }
}

extension CategoryDataSource: Decodable {
    enum CategoryCodingKeys: String, CodingKey {
        case id, name, tag, redirectionScreenName, imageURL
        #if canImport(XMediaPlayer) && !SKIP
        case storeFrontMedia
        #elseif SKIP
        case storeFrontMedia
        #endif
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CategoryCodingKeys.self)
        self.id                     = try? container.decode(String.self, forKey: .id)
        self.name                   = try? container.decode(String.self, forKey: .name)
        self.tag                    = try? container.decode(String.self, forKey: .tag)
        self.redirectionScreenName  = try? container.decode(String.self, forKey: .redirectionScreenName)
        self.imageURL               = try? container.decode(String.self, forKey: .imageURL)
        #if canImport(XMediaPlayer) && !SKIP
        self.storeFrontMedia        = try? container.decode(StoreFrontITXMediaDTO.self, forKey: .storeFrontMedia)
        #elseif SKIP
        if let rawDict = try? container.decode([String: SDUIAnyJSON].self, forKey: .storeFrontMedia) {
            self.storeFrontMediaRawJson = storeFrontMediaToJSON(rawDict: rawDict)
        } else {
            self.storeFrontMediaRawJson = nil
        }
        #else
        self.storeFrontMediaRawJson = nil
        #endif
    }
}
