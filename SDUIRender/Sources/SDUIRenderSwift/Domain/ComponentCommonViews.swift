import Foundation
import SwiftUI
#if canImport(XMediaPlayer) && !SKIP
import XMediaPlayer
import ITXMediaStoreFront
#endif

// MARK: - ComponentCommonView

/// Base domain model for every rendered SDUI component.
/// Subclasses add component-specific properties.
open class ComponentCommonView: Identifiable, @unchecked Sendable {
    public let id: String
    public let componentID: String?
    public var componentType: ComponentType
    public var styles: StylesBO?
    public var positioning: PositioningBO?
    public var action: SDUIAction?

    public init(
        componentID: String?,
        componentType: String,
        styles: StylesBO?,
        positioning: PositioningBO?,
        action: SDUIAction?
    ) {
        self.id = UUID().uuidString
        self.componentID = componentID
        self.componentType = ComponentType(rawValue: componentType) ?? .custom("unknown")
        self.styles = styles
        self.positioning = positioning
        self.action = action
    }
}

// MARK: - Container

public final class ContainerComponentCommonView: ComponentCommonView, @unchecked Sendable {
    public let children: [ComponentCommonView]
    public let direction: ContainerDirection
    public let scrollable: Bool
    public let overflowVisible: Bool
    private let spacingBO: SpacingBO

    /// Spacing between children in points.
    public func getSpacing(rootAvailableSize: CGSize) -> Double {
        switch spacingBO {
        case .absolute(let value):
            return value
        case .relative(let value):
            return rootAvailableSize.width * (value / 100)
        }
    }

    /// Available size that each child can fill, after subtracting inter-child spacing.
    public func getAvailableSize(rootAvailableSize: CGSize, parentSize: CGSize) -> CGSize {
        let spacing = getSpacing(rootAvailableSize: rootAvailableSize)
        let totalSpacing = spacing * Double(max(children.count - 1, 0))
        switch direction {
        case .horizontal:
            return CGSize(width: parentSize.width - totalSpacing, height: parentSize.height)
        case .vertical:
            return CGSize(width: parentSize.width, height: parentSize.height - totalSpacing)
        case .stack:
            return parentSize
        }
    }

    public init(
        from base: ComponentCommonView,
        children: [ComponentCommonView],
        direction: String?,
        spacing: SpacingBO,
        scrollable: Bool = false,
        overflowVisible: Bool = false
    ) {
        self.children = children
        self.direction = ContainerDirection(rawValue: direction ?? "") ?? .vertical
        self.spacingBO = spacing
        self.scrollable = scrollable
        self.overflowVisible = overflowVisible
        super.init(
            componentID: base.componentID,
            componentType: base.componentType.rawValue,
            styles: base.styles,
            positioning: base.positioning,
            action: base.action
        )
    }
}

// MARK: - Text

public final class TextComponentCommonView: ComponentCommonView, @unchecked Sendable {
    public let textContent: String

    public init(from base: ComponentCommonView, textContent: String) {
        self.textContent = textContent
        super.init(
            componentID: base.componentID,
            componentType: base.componentType.rawValue,
            styles: base.styles,
            positioning: base.positioning,
            action: base.action
        )
    }
}

// MARK: - Image

public final class ImageComponentCommonView: ComponentCommonView, @unchecked Sendable {
    public let image: ImageBO

    public init(from base: ComponentCommonView, image: ImageBO) {
        self.image = image
        super.init(
            componentID: base.componentID,
            componentType: base.componentType.rawValue,
            styles: base.styles,
            positioning: base.positioning,
            action: base.action
        )
    }
}

// MARK: - Carousel

public final class CarouselComponentCommonView: ComponentCommonView, @unchecked Sendable {
    public let children: [ComponentCommonView]
    public let scrollMode: CarouselScrollMode
    public let spacing: Double
    public let visibleItems: Double?
    public let loop: Bool
    public let autoplay: Int
    public let transition: CarouselTransition?
    public let offsetStart: Int
    public let offsetEnd: Int

    public enum CarouselScrollMode: String { case free, snap }
    public enum CarouselTransition: String { case slide, fade, fadeSlide = "fade_slide", none }

    public init(
        from base: ComponentCommonView,
        children: [ComponentCommonView],
        scrollMode: String?,
        spacing: Double?,
        visibleItems: Double?,
        loop: Bool?,
        autoplay: Int?,
        transition: String?,
        offsetStart: Int?,
        offsetEnd: Int?
    ) {
        self.children = children
        self.scrollMode = CarouselScrollMode(rawValue: scrollMode ?? "") ?? .free
        self.spacing = spacing ?? 0.0
        self.visibleItems = visibleItems
        self.loop = loop ?? false
        self.autoplay = autoplay ?? 0
        self.transition = CarouselTransition(rawValue: transition ?? "")
        self.offsetStart = offsetStart ?? 0
        self.offsetEnd = offsetEnd ?? 0
        super.init(
            componentID: base.componentID,
            componentType: base.componentType.rawValue,
            styles: base.styles,
            positioning: base.positioning,
            action: base.action
        )
    }
}

// MARK: - XMedia

/// Domain model for the `xmedia` component.
public final class XMediaComponentCommonView: ComponentCommonView, @unchecked Sendable {
    /// Width of the media asset in logical pixels (from `storeFrontMedia.width`).
    public let mediaWidth: Double?
    /// Height of the media asset in logical pixels (from `storeFrontMedia.height`).
    public let mediaHeight: Double?

    /// Full ITXMediaPlayer payload for iOS rendering.
    #if canImport(XMediaPlayer) && canImport(ITXMediaPlayer) && !SKIP
    public let xmedia: StoreFrontITXMediaDTO?
    #endif

    #if canImport(XMediaPlayer) && !SKIP
    public init(
        from base: ComponentCommonView,
        mediaWidth: Double?,
        mediaHeight: Double?,
        xmedia: StoreFrontITXMediaDTO?
    ) {
        self.mediaWidth  = mediaWidth
        self.mediaHeight = mediaHeight
        self.xmedia      = xmedia
        super.init(
            componentID:   base.componentID,
            componentType: base.componentType.rawValue,
            styles:        base.styles,
            positioning:   base.positioning,
            action:        base.action
        )
    }
    #else
    /// Raw JSON string of `storeFrontMedia` — used by Android/Skip to deserialize
    /// into the platform's `StoreFrontMediaDTO` and call `.toXMedia()`.
    public let storeFrontMediaJson: String?

    public init(
        from base: ComponentCommonView,
        mediaWidth: Double?,
        mediaHeight: Double?,
        storeFrontMediaJson: String? = nil
    ) {
        self.mediaWidth          = mediaWidth
        self.mediaHeight         = mediaHeight
        self.storeFrontMediaJson = storeFrontMediaJson
        super.init(
            componentID:   base.componentID,
            componentType: base.componentType.rawValue,
            styles:        base.styles,
            positioning:   base.positioning,
            action:        base.action
        )
    }
    #endif
}
