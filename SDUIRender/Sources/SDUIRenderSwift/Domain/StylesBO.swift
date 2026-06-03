import Foundation
import SwiftUI

// MARK: - Styles

public struct StylesBO {
    public let backgroundColor: String?
    public let border: BorderBO?
    public let cornerRadius: CornerRadiusBO?
    public let shadow: ShadowBO?
    public let opacity: Double?
    public let textStyles: TextStylesBO?

    public init(
        backgroundColor: String?,
        border: BorderBO?,
        cornerRadius: CornerRadiusBO?,
        shadow: ShadowBO?,
        opacity: Double?,
        fontFamily: String?,
        fontSize: Int?,
        fontSizeRelative: Float?,
        fontWeight: Int?,
        textColor: String?,
        letterSpacing: Float?,
        maxLines: Int?,
        textAlign: String?,
        lineHeight: Float?,
        textOverflow: String?,
        semanticTypography: String?
    ) {
        self.backgroundColor = backgroundColor
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.opacity = opacity
        let fw: SDUIFontWeight? = fontWeight.flatMap { SDUIFontWeight(rawValue: $0) }
        self.textStyles = TextStylesBO(
            fontFamily: fontFamily,
            fontSize: fontSize,
            fontSizeRelative: fontSizeRelative,
            fontWeight: fw,
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

public struct TextStylesBO {
    public let fontFamily: String?
    public let fontSize: Int?
    public let fontSizeRelative: Float?
    public let fontWeight: SDUIFontWeight?
    public let textColor: String?
    public let letterSpacing: Float?
    public let maxLines: Int?
    public let textAlign: String?
    public let lineHeight: Float?
    public let textOverflow: String?
    public let semanticTypography: String?
}

public enum SDUIFontWeight: Int {
    case w100 = 100, w200 = 200, w300 = 300, w400 = 400
    case w500 = 500, w600 = 600, w700 = 700, w800 = 800, w900 = 900

    public var swiftUIWeight: Font.Weight {
        switch self {
        case .w100: return .ultraLight
        case .w200: return .thin
        case .w300: return .light
        case .w400: return .regular
        case .w500: return .medium
        case .w600: return .semibold
        case .w700: return .bold
        case .w800: return .heavy
        case .w900: return .black
        }
    }
}

// MARK: - Border

public struct BorderBO {
    public let global: BorderPropertiesBO?
    public let top: BorderPropertiesBO?
    public let right: BorderPropertiesBO?
    public let bottom: BorderPropertiesBO?
    public let left: BorderPropertiesBO?
}

public struct BorderPropertiesBO {
    public let color: String?
    public let style: String?
    public let width: Double?
}

// MARK: - Corner radius

public struct CornerRadiusBO {
    public let topLeft: Double?
    public let topRight: Double?
    public let bottomRight: Double?
    public let bottomLeft: Double?

    public var uniform: CGFloat? {
        guard let tl = topLeft, tl == topRight, tl == bottomRight, tl == bottomLeft else {
            return nil
        }
        return CGFloat(tl)
    }
}

// MARK: - Shadow

public struct ShadowBO {
    public let offsetX: Double?
    public let offsetY: Double
    public let radius: Double?
    public let color: String?
}
