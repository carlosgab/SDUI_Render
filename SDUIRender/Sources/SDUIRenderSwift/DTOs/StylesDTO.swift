import Foundation

/// General style properties decoded from the JSON payload.
public struct StylesDTO: Decodable {
    public let backgroundColor: String?
    public let border: BorderDTO?
    public let cornerRadius: CornerRadiusDTO?
    public let shadow: ShadowDTO?
    public let opacity: Double?

    // Text styles
    public let fontFamily: String?
    public let fontSize: Int?
    public let fontSizeRelative: Float?
    public let fontWeight: Int?
    public let textColor: String?
    public let letterSpacing: Float?
    public let maxLines: Int?
    public let textAlign: String?
    public let lineHeight: Float?
    public let textOverflow: String?
    public let semanticTypography: String?

    private enum CodingKeys: String, CodingKey {
        case backgroundColor, border, cornerRadius, shadow, opacity
        case fontFamily, fontSize, fontSizeRelative, fontWeight
        case letterSpacing, maxLines, textAlign, lineHeight, textOverflow
        case textColor = "color"
        case semanticTypography = "semantic-typography"
    }

    public func toDomain() -> StylesBO {
        StylesBO(
            backgroundColor: backgroundColor,
            border: border?.toDomain(),
            cornerRadius: cornerRadius?.toDomain(),
            shadow: shadow?.toDomain(),
            opacity: opacity,
            fontFamily: fontFamily,
            fontSize: fontSize,
            fontSizeRelative: fontSizeRelative,
            fontWeight: fontWeight,
            textColor: textColor,
            letterSpacing: letterSpacing,
            maxLines: maxLines,
            textAlign: textAlign,
            lineHeight: lineHeight,
            textOverflow: textOverflow,
            semanticTypography: semanticTypography
        )
    }
}

// MARK: - Border

public struct BorderDTO: Decodable {
    public let global: BorderPropertiesDTO?
    public let top: BorderPropertiesDTO?
    public let right: BorderPropertiesDTO?
    public let bottom: BorderPropertiesDTO?
    public let left: BorderPropertiesDTO?

    public func toDomain() -> BorderBO {
        BorderBO(
            global: global?.toDomain(),
            top: top?.toDomain(),
            right: right?.toDomain(),
            bottom: bottom?.toDomain(),
            left: left?.toDomain()
        )
    }
}

public struct BorderPropertiesDTO: Decodable {
    public let color: String?
    public let style: String?
    public let width: Double?

    public func toDomain() -> BorderPropertiesBO {
        BorderPropertiesBO(color: color, style: style, width: width)
    }
}

// MARK: - Corner radius

public struct CornerRadiusDTO: Decodable {
    public let topLeft: Double?
    public let topRight: Double?
    public let bottomRight: Double?
    public let bottomLeft: Double?

    public func toDomain() -> CornerRadiusBO {
        CornerRadiusBO(
            topLeft: topLeft,
            topRight: topRight,
            bottomRight: bottomRight,
            bottomLeft: bottomLeft
        )
    }
}

// MARK: - Shadow

public struct ShadowDTO: Decodable {
    public let offsetX: Double?
    public let offsetY: Double
    public let radius: Double?
    public let color: String?

    public func toDomain() -> ShadowBO {
        ShadowBO(offsetX: offsetX, offsetY: offsetY, radius: radius, color: color)
    }
}
