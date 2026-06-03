import Foundation
import SwiftUI

/// Calculates concrete dimensions and paddings from a `PositioningBO` relative to its parent size.
struct PositioningHelper {
    let positioning: PositioningBO?
    let rootAvailableSize: CGSize
    let availableSize: CGSize

    init(positioning: PositioningBO?, rootAvailableSize: CGSize, availableSize: CGSize = .zero) {
        self.positioning = positioning
        self.rootAvailableSize = rootAvailableSize
        self.availableSize = availableSize
    }

    // MARK: - Dimensions

    /// Height in points, or `nil` if the component should use its intrinsic height.
    var height: CGFloat? {
        guard let p = positioning else { return nil }

        if let ar = p.aspectRatio, p.heightPercentage == nil {
            let w = p.widthPercentage
                .flatMap { percent(of: $0, in: availableSize.width, subtractPaddings: false) }
                ?? availableSize.width
            return w > 0 ? (w / ar).notNegative() : nil
        }

        if let hp = p.heightPercentage {
            return percent(of: hp, in: availableSize.height)
        }

        return nil
    }

    /// Width in points, or `nil` if the component should use its intrinsic width.
    var width: CGFloat? {
        guard let p = positioning else { return nil }

        if let ar = p.aspectRatio, p.widthPercentage == nil {
            let h = p.heightPercentage
                .flatMap { percent(of: $0, in: availableSize.height, subtractPaddings: false) }
                ?? availableSize.height
            return h > 0 ? (h * ar).notNegative() : nil
        }

        if let wp = p.widthPercentage {
            let raw = availableSize.width * (wp / 100)
            return (raw - (paddingStart + paddingEnd)).notNegative()
        }

        return nil
    }

    // MARK: - Paddings

    var paddingTop: CGFloat {
        guard let p = positioning else { return 0 }
        let pct = p.paddingPercentage?.top ?? p.padding.top
        return toPoints(percent: pct, size: paddingWidth)
    }

    var paddingBottom: CGFloat {
        guard let p = positioning else { return 0 }
        let pct = p.paddingPercentage?.bottom ?? p.padding.bottom
        return toPoints(percent: pct, size: paddingWidth)
    }

    var paddingStart: CGFloat {
        guard let p = positioning else { return 0 }
        let pct = p.paddingPercentage?.start ?? p.padding.start
        return toPoints(percent: pct, size: paddingWidth)
    }

    var paddingEnd: CGFloat {
        guard let p = positioning else { return 0 }
        let pct = p.paddingPercentage?.end ?? p.padding.end
        return toPoints(percent: pct, size: paddingWidth)
    }

    // MARK: - Absolute positioning

    var absolutePositioning: AbsolutePositioning {
        let top  = toPoints(percent: positioning?.absolutePositioning?.top  ?? 0.0, size: availableSize.height)
        let left = toPoints(percent: positioning?.absolutePositioning?.left ?? 0.0, size: availableSize.width)
        return AbsolutePositioning(top: top, left: left)
    }

    // MARK: - Private helpers

    private var paddingWidth: CGFloat {
        positioning?.paddingPercentage != nil ? rootAvailableSize.width : availableSize.width
    }

    private func percent(of value: CGFloat, in size: CGFloat, subtractPaddings: Bool = true) -> CGFloat? {
        let raw = size * (value / 100)
        if subtractPaddings {
            return (raw - (paddingTop + paddingBottom)).notNegative()
        }
        return raw.notNegative()
    }

    private func toPoints(percent: CGFloat, size: CGFloat) -> CGFloat {
        size * (percent / 100)
    }
}
