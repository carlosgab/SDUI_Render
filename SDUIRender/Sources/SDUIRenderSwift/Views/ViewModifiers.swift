import Foundation
import SwiftUI

// MARK: - Positioning modifier

/// Applies width, height, padding, and alignment derived from a component's `PositioningBO`.
struct PositioningModifier: ViewModifier {
    let component: ComponentCommonView
    let parentSize: CGSize
    @Environment(\.rootAvailableSize) private var rootAvailableSize

    func body(content: Content) -> some View {
        let helper = PositioningHelper(
            positioning: component.positioning,
            rootAvailableSize: rootAvailableSize,
            availableSize: parentSize
        )

        content
            .frame(width: helper.width, height: helper.height, alignment: component.positioning?.alignment ?? .topLeading)
            .padding(.top,      helper.paddingTop)
            .padding(.bottom,   helper.paddingBottom)
            .padding(.leading,  helper.paddingStart)
            .padding(.trailing, helper.paddingEnd)
    }
}

extension View {
    func applyPositioning(with parentSize: CGSize, component: ComponentCommonView) -> some View {
        modifier(PositioningModifier(component: component, parentSize: parentSize))
    }
}

// MARK: - Styles modifier

/// Applies background colour, corner radius, border, shadow, and opacity.
struct StylesModifier: ViewModifier {
    let styles: StylesBO?
    let positioning: PositioningBO?
    let parentSize: CGSize
    let clipped: Bool

    func body(content: Content) -> some View {
        let radius: CGFloat = styles?.cornerRadius?.uniform ?? 0.0

        // Apply background BEFORE the clip so that clipShape/cornerRadius also clips
        // the background. Using `.background(Color)` is the only form supported by
        // Skip/Compose; `.background(Shape.fill(color))` is NOT translated correctly.
        content
            .background(backgroundColor)
            .applyIf(clipped) { $0.clipShape(RoundedRectangle(cornerRadius: radius)) }
            .applyIf(!clipped) { $0.cornerRadius(radius) }
            .applyIf(borderWidth > 0) {
                // strokeBorder is not supported in Compose; use stroke instead.
                $0.overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
            }
            .applyShadow(styles?.shadow)
            .opacity(styles?.opacity ?? 1.0)
            .rotationEffect(.degrees(positioning?.rotation ?? 0.0))
    }

    private var backgroundColor: Color {
        colorFromHex(styles?.backgroundColor ?? "") ?? .clear
    }

    private var borderColor: Color {
        colorFromHex(styles?.border?.global?.color ?? "") ?? .clear
    }

    private var borderWidth: CGFloat {
        CGFloat(styles?.border?.global?.width ?? 0)
    }
}

extension View {
    func applyStyles(with styles: StylesBO?, positioning: PositioningBO?, parentSize: CGSize, clipped: Bool) -> some View {
        modifier(StylesModifier(styles: styles, positioning: positioning, parentSize: parentSize, clipped: clipped))
    }
}

// MARK: - Shadow helper

extension View {
    @ViewBuilder
    func applyShadow(_ shadow: ShadowBO?) -> some View {
        if let shadow {
            self.shadow(
                color: colorFromHex(shadow.color ?? "") ?? Color.black.opacity(0.2),
                radius: CGFloat(shadow.radius ?? 4),
                x: CGFloat(shadow.offsetX ?? 0),
                y: CGFloat(shadow.offsetY)
            )
        } else {
            self
        }
    }
}

// MARK: - Conditional modifier

extension View {
    @ViewBuilder
    func applyIf<V: View>(_ condition: Bool, transform: (Self) -> V) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Color from hex

/// Returns a `Color` from a CSS hex string (`#RRGGBB` or `#RRGGBBAA`), or `nil` if invalid.
func colorFromHex(_ hex: String) -> Color? {
    let stripped = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                      .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    guard stripped.count == 6 || stripped.count == 8 else { return nil }
    guard let intVal = hexStringToInt(stripped) else { return nil }

    let r, g, b, a: Double
    if stripped.count == 6 {
        r = Double((intVal >> 16) & 0xFF) / 255
        g = Double((intVal >>  8) & 0xFF) / 255
        b = Double( intVal        & 0xFF) / 255
        a = 1
    } else {
        r = Double((intVal >> 24) & 0xFF) / 255
        g = Double((intVal >> 16) & 0xFF) / 255
        b = Double((intVal >>  8) & 0xFF) / 255
        a = Double( intVal        & 0xFF) / 255
    }

    return Color(red: r, green: g, blue: b, opacity: a)
}

/// Parses a hex string (no prefix) to an Int.
private func hexStringToInt(_ hex: String) -> Int? {
    var result = 0
    for char in hex.uppercased() {
        let digit: Int
        switch char {
        case "0": digit = 0
        case "1": digit = 1
        case "2": digit = 2
        case "3": digit = 3
        case "4": digit = 4
        case "5": digit = 5
        case "6": digit = 6
        case "7": digit = 7
        case "8": digit = 8
        case "9": digit = 9
        case "A": digit = 10
        case "B": digit = 11
        case "C": digit = 12
        case "D": digit = 13
        case "E": digit = 14
        case "F": digit = 15
        default:  return nil
        }
        result = result * 16 + digit
    }
    return result
}

// MARK: - Read size helper

#if !SKIP
private struct SizePreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}
#endif
