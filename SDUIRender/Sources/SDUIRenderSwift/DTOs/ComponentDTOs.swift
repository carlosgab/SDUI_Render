import Foundation
#if canImport(XMediaPlayer) && !SKIP
import XMediaPlayer
import ITXMediaStoreFront
#endif

/// Common fields every component DTO must provide.
public protocol BaseComponentDTO {
    var id: String? { get }
    var componentType: String { get }
    var styles: StylesDTO? { get }
    var positioning: PositioningDTO? { get }
    var children: [ComponentDTOWrapper]? { get set }
    var action: ActionDTOWrapper? { get set }
    var dataSourceKey: String? { get set }
}

// MARK: - Container

public struct ContainerComponentDTO: BaseComponentDTO, Decodable {
    public let id: String?
    public let componentType: String
    public var styles: StylesDTO?
    public var positioning: PositioningDTO?
    public var children: [ComponentDTOWrapper]?
    public var action: ActionDTOWrapper?
    public var dataSourceKey: String?

    public let direction: String?
    /// Deprecated — use `space` instead.
    public let spacing: Int?
    /// Spacing between children using a percentage value or design token.
    public let space: SDUISpacingDTO?
    /// Enables scrolling in the container's direction axis.
    public let scrollable: Bool?
    /// When `true`, children that overflow the bounds remain visible.
    public let overflowVisible: Bool?
}

// MARK: - Text

public struct TextComponentDTO: BaseComponentDTO, Decodable {
    public let id: String?
    public let componentType: String
    public var styles: StylesDTO?
    public var positioning: PositioningDTO?
    public var children: [ComponentDTOWrapper]?
    public var action: ActionDTOWrapper?
    public var dataSourceKey: String?

    public var textContent: String
}

// MARK: - Image

public struct ImageComponentImageDTO: Decodable {
    public var path: String
    public let objectFit: String
    public let objectPosition: String
    public let dimensions: ImageComponentDimensionsDTO?

    public func toDomain() -> ImageBO {
        ImageBO(
            path: path,
            objectFit: objectFit,
            objectPosition: objectPosition,
            dimensions: dimensions.map { CGSize(width: $0.width, height: $0.height) }
        )
    }
}

public struct ImageComponentDimensionsDTO: Decodable {
    public let width: Double
    public let height: Double
}

public struct ImageComponentDTO: BaseComponentDTO, Decodable {
    public let id: String?
    public let componentType: String
    public var styles: StylesDTO?
    public var positioning: PositioningDTO?
    public var children: [ComponentDTOWrapper]?
    public var action: ActionDTOWrapper?
    public var dataSourceKey: String?

    public var image: ImageComponentImageDTO
}

// MARK: - Carousel

public struct CarouselComponentDTO: BaseComponentDTO, Decodable {
    public let id: String?
    public let componentType: String
    public var styles: StylesDTO?
    public var positioning: PositioningDTO?
    public var children: [ComponentDTOWrapper]?
    public var action: ActionDTOWrapper?
    public var dataSourceKey: String?

    /// Scrolling behaviour: `free` (native scroll) or `snap` (paging).
    public let scrollMode: String?
    /// Number of visible items (can be fractional, e.g., 2.5).
    public let visibleItems: Double?
    public let loop: Bool?
    /// Auto-play interval in milliseconds; `nil` disables auto-play.
    public let autoplay: Int?
    /// Transition effect: `slide`, `fade`, `fade_slide`, `none`.
    public let transition: String?
    public let offsetStart: Int?
    public let offsetEnd: Int?
    /// Deprecated — use `itemSpace` instead.
    public let itemSpacing: Int?
    public let itemSpace: SDUISpacingDTO?
}

// MARK: - XMedia

/// Minimal layout dimensions extracted from the opaque `storeFrontMedia` payload.
/// Used on all platforms to compute component size.
public struct StoreFrontMediaDTO: Decodable {
    public let width: Double?
    public let height: Double?
}

/// DTO for the `xmedia` component type.
///
/// The `storeFrontMedia` sub-object is decoded into the minimal `StoreFrontMediaDTO`
/// for layout on both platforms.  When the `XMediaPlayer` module is available (iOS only)
/// the same key is decoded a second time directly into `StoreFrontITXMediaDTO` so the
/// view layer can pass it straight to `XMediaViewSwiftUI` without re-parsing.
public struct XMediaComponentDTO: BaseComponentDTO, Decodable {
    public let id: String?
    public let componentType: String
    public var styles: StylesDTO?
    public var positioning: PositioningDTO?
    public var children: [ComponentDTOWrapper]?
    public var action: ActionDTOWrapper?
    public var dataSourceKey: String?

    /// Cross-platform layout data (width/height of the media asset).
    public let storeFrontMedia: StoreFrontMediaDTO?

    /// Full `StoreFrontITXMediaDTO` payload decoded from the same `storeFrontMedia` key.
    /// Only available when XMediaPlayer is linked (iOS only).
    #if canImport(XMediaPlayer) && !SKIP
    public let xmedia: StoreFrontITXMediaDTO?
    #else
    /// Raw JSON of the `storeFrontMedia` object, preserved for Android/Skip so
    /// the platform can deserialize it into `StoreFrontMediaDTO` and call `.toXMedia()`.
    public let storeFrontMediaRawJson: String?
    #endif

    enum CodingKeys: String, CodingKey {
        case id, componentType, styles, positioning, action, dataSourceKey
        case storeFrontMedia
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id              = try? container.decode(String.self,          forKey: .id)
        componentType   = (try? container.decode(String.self,         forKey: .componentType)) ?? "xmedia"
        styles          = try? container.decode(StylesDTO.self,       forKey: .styles)
        positioning     = try? container.decode(PositioningDTO.self,  forKey: .positioning)
        action          = try? container.decode(ActionDTOWrapper.self, forKey: .action)
        dataSourceKey   = try? container.decode(String.self,          forKey: .dataSourceKey)
        children        = nil  // xmedia has no children
        storeFrontMedia = try? container.decode(StoreFrontMediaDTO.self, forKey: .storeFrontMedia)
        #if canImport(XMediaPlayer) && !SKIP
        xmedia          = try? container.decode(StoreFrontITXMediaDTO.self, forKey: .storeFrontMedia)
        #elseif SKIP
        // On Android/Skip: decode raw dict and convert to JSON via native Kotlin helper.
        // storeFrontMediaToJSON() is defined in XMediaHelper.kt (same package).
        if let rawDict = try? container.decode([String: SDUIAnyJSON].self, forKey: .storeFrontMedia) {
            storeFrontMediaRawJson = storeFrontMediaToJSON(rawDict: rawDict)
        } else {
            storeFrontMediaRawJson = nil
        }
        #else
        // iOS without XMediaPlayer: storeFrontMediaRawJson not used.
        storeFrontMediaRawJson = nil
        #endif
    }
}
