import Foundation
import SwiftUI

/// Renders a `ContainerComponentCommonView` as HStack / VStack / ZStack,
/// optionally wrapped in a ScrollView.
struct ContainerComponentView: View {

    @Environment(\.rootAvailableSize) private var rootAvailableSize

    private let component: ContainerComponentCommonView
    private let parentSize: CGSize

    init(_ component: ContainerComponentCommonView, parentSize: CGSize) {
        self.component = component
        self.parentSize = parentSize
    }

    private var childAvailableSize: CGSize {
        component.getAvailableSize(rootAvailableSize: rootAvailableSize, parentSize: parentSize)
    }

    private var spacing: CGFloat {
        CGFloat(component.getSpacing(rootAvailableSize: rootAvailableSize))
    }

    var body: some View {
        if component.children.isEmpty {
            Color.clear
        } else {
            containerContent
                .applyIf(component.scrollable && component.direction == .horizontal) { content in
                    ScrollView(.horizontal, showsIndicators: false) { content }
                }
                .applyIf(component.scrollable && component.direction == .vertical) { content in
                    ScrollView(.vertical, showsIndicators: false) { content }
                }
        }
    }

    @ViewBuilder
    private var containerContent: some View {
        let childSize = childAvailableSize
        switch component.direction {
        case .horizontal:
            HStack(
                alignment: component.positioning?.verticalAlignment?.toSwiftUI() ?? .top,
                spacing: spacing
            ) {
                childViews(childSize: childSize)
            }
        case .vertical:
            VStack(
                alignment: component.positioning?.horizontalAlignment?.toSwiftUI() ?? .leading,
                spacing: spacing
            ) {
                childViews(childSize: childSize)
            }
        case .stack:
            ZStack(alignment: component.positioning?.alignment ?? .topLeading) {
                stackChildren(childSize: childSize)
            }
        }
    }

    @ViewBuilder
    private func childViews(childSize: CGSize) -> some View {
        ForEach(component.children) { child in
            ComponentViewBuilder(
                component: child,
                parentSize: childSize
            )
        }
    }

    @ViewBuilder
    private func stackChildren(childSize: CGSize) -> some View {
        ForEach(component.children) { child in
            ComponentViewBuilder(
                component: child,
                parentSize: childSize,
                isStackedChild: true
            )
        }
    }
}
