import Foundation
import SwiftUI

// MARK: - Padding helpers

public struct Padding {
    public let top: CGFloat
    public let bottom: CGFloat
    public let start: CGFloat
    public let end: CGFloat
}

public struct PaddingPercentageBO {
    public let start: CGFloat?
    public let top: CGFloat?
    public let end: CGFloat?
    public let bottom: CGFloat?
}

// MARK: - Absolute positioning

public struct AbsolutePositioning {
    public let top: CGFloat
    public let left: CGFloat

    public init(top: CGFloat, left: CGFloat) {
        self.top = top
        self.left = left
    }
}

// MARK: - Alignment layouts

public enum VerticalAlignmentLayouts: String {
    case start, center, end

    public func toSwiftUI() -> VerticalAlignment {
        switch self {
        case .start:  return .top
        case .end:    return .bottom
        case .center: return .center
        }
    }
}

public enum HorizontalAlignmentLayouts: String {
    case start, center, end

    public func toSwiftUI() -> HorizontalAlignment {
        switch self {
        case .start:  return .leading
        case .end:    return .trailing
        case .center: return .center
        }
    }
}

public enum ContainerDirection: String {
    case horizontal
    case vertical
    case stack
}

// MARK: - Positioning business object

public struct PositioningBO {
    public var widthPercentage: CGFloat?
    public let heightPercentage: CGFloat?
    public let padding: Padding
    public let paddingPercentage: PaddingPercentageBO?
    public let verticalAlignment: VerticalAlignmentLayouts?
    public let horizontalAlignment: HorizontalAlignmentLayouts?
    public let absolutePositioning: AbsolutePositioning?
    public let aspectRatio: Double?
    public let rotation: Double

    public init(
        widthPercentage: CGFloat?,
        heightPercentage: CGFloat?,
        paddingTop: CGFloat?,
        paddingBottom: CGFloat?,
        paddingEnd: CGFloat?,
        paddingStart: CGFloat?,
        paddingPercentage: PaddingPercentageBO?,
        verticalAlignment: String?,
        horizontalAlignment: String?,
        top: CGFloat?,
        left: CGFloat?,
        aspectRatio: Double?,
        rotation: Double?
    ) {
        self.widthPercentage = widthPercentage
        self.heightPercentage = heightPercentage
        self.padding = Padding(
            top: paddingTop ?? 0.0,
            bottom: paddingBottom ?? 0.0,
            start: paddingStart ?? 0.0,
            end: paddingEnd ?? 0.0
        )
        self.paddingPercentage = paddingPercentage
        self.verticalAlignment = VerticalAlignmentLayouts(rawValue: verticalAlignment ?? "")
        self.horizontalAlignment = HorizontalAlignmentLayouts(rawValue: horizontalAlignment ?? "")
        self.absolutePositioning = (top != nil && left != nil)
            ? AbsolutePositioning(top: top!, left: left!)
            : nil
        self.aspectRatio = aspectRatio
        self.rotation = rotation ?? 0.0
    }

    public var alignment: Alignment {
        Alignment(
            horizontal: horizontalAlignment?.toSwiftUI() ?? .leading,
            vertical: verticalAlignment?.toSwiftUI() ?? .top
        )
    }
}

// MARK: - CGFloat helper

extension CGFloat {
    func notNegative() -> CGFloat {
        if self < 0 { return 0.0 }
        return self
    }
}
