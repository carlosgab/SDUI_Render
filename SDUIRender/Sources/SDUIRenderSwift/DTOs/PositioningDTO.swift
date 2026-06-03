import Foundation

/// Clamps a Float percentage to [0, 100].
private func clampedPct(_ value: Float) -> Float {
    if value < Float(0) { return Float(0) }
    if value > Float(100) { return Float(100) }
    return value
}

/// Padding values as percentages of the responsive layout width.
public struct PaddingPercentageDTO: Decodable {
    public let start: Float?
    public let top: Float?
    public let end: Float?
    public let bottom: Float?

    public func toDomain() -> PaddingPercentageBO? {
        PaddingPercentageBO(
            start: start.map { CGFloat(clampedPct($0)) },
            top: top.map { CGFloat(clampedPct($0)) },
            end: end.map { CGFloat(clampedPct($0)) },
            bottom: bottom.map { CGFloat(clampedPct($0)) }
        )
    }
}

/// Controls the size, spacing, and positioning of the component.
public struct PositioningDTO: Decodable {
    public let widthPercentage: CGFloat?
    public let heightPercentage: CGFloat?
    // Deprecated individual paddings (kept for backwards compatibility)
    public let paddingTop: CGFloat?
    public let paddingBottom: CGFloat?
    public let paddingStart: CGFloat?
    public let paddingEnd: CGFloat?
    /// Padding values as percentages of the responsive layout's dimensions.width
    public let paddingPercentage: PaddingPercentageDTO?
    public let verticalAlignment: String?
    public let horizontalAlignment: String?
    public let aspectRatio: Double?
    /// Absolute top position as a percentage (only for stack containers)
    public let top: CGFloat?
    /// Absolute left position as a percentage (only for stack containers)
    public let left: CGFloat?
    /// Rotation angle in degrees
    public let rotation: Double?

    public func toDomain() -> PositioningBO {
        PositioningBO(
            widthPercentage: widthPercentage,
            heightPercentage: heightPercentage,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
            paddingEnd: paddingEnd,
            paddingStart: paddingStart,
            paddingPercentage: paddingPercentage?.toDomain(),
            verticalAlignment: verticalAlignment,
            horizontalAlignment: horizontalAlignment,
            top: top,
            left: left,
            aspectRatio: aspectRatio,
            rotation: rotation
        )
    }
}
