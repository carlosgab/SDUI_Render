import Foundation
import SwiftUI

/// Renders a `TextComponentCommonView` applying all text-level styles.
struct TextComponentView: View {

    private let component: TextComponentCommonView

    init(_ component: TextComponentCommonView) {
        self.component = component
    }

    var body: some View {
        Text(component.textContent)
            .font(resolvedFont)
            .foregroundColor(resolvedColor)
            .multilineTextAlignment(resolvedAlignment)
            .applyIf(component.styles?.textStyles?.maxLines != nil) { text in
                text.lineLimit(component.styles?.textStyles?.maxLines ?? 0)
            }
            #if !SKIP
            .applyIf(component.styles?.textStyles?.letterSpacing != nil) { text in
                text.kerning(CGFloat(component.styles?.textStyles?.letterSpacing ?? 0))
            }
            #endif
            .applyIf(component.styles?.textStyles?.lineHeight != nil) { text in
                text.lineSpacing(CGFloat(component.styles?.textStyles?.lineHeight ?? 0))
            }
    }

    // MARK: - Style helpers

    private var resolvedFont: Font {
        let styles = component.styles?.textStyles
        var font: Font

        if let size = styles?.fontSize {
            font = .system(size: CGFloat(size))
        } else if let relative = styles?.fontSizeRelative {
            font = .system(size: CGFloat(relative))
        } else {
            font = .body
        }

        if let weight = styles?.fontWeight {
            font = font.weight(weight.swiftUIWeight)
        }

        if let family = styles?.fontFamily, !family.isEmpty {
            font = .custom(family, size: CGFloat(styles?.fontSize ?? 16))
        }

        return font
    }

    private var resolvedColor: Color {
        colorFromHex(component.styles?.textStyles?.textColor ?? "") ?? .primary
    }

    private var resolvedAlignment: TextAlignment {
        switch component.styles?.textStyles?.textAlign {
        case "center": return .center
        case "end":    return .trailing
        default:       return .leading
        }
    }
}
