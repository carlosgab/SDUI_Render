import Foundation
import SwiftUI

/// Central dispatcher that renders any `ComponentCommonView` to the correct SwiftUI view.
struct ComponentViewBuilder: View {

    private let component: ComponentCommonView
    private let parentSize: CGSize
    private let isStackedChild: Bool

    @Environment(\.rootAvailableSize) private var rootAvailableSize
    @Environment(\.sduiEvents) private var eventsBox: SDUIEventsBox

    #if !SKIP
    @State private var measuredSize: CGSize = .zero
    #endif

    init(component: ComponentCommonView, parentSize: CGSize, isStackedChild: Bool = false) {
        self.component = component
        self.parentSize = parentSize
        self.isStackedChild = isStackedChild
    }

    // MARK: - Computed layout

    private var calculatedAvailableSize: CGSize {
        #if !SKIP
        if measuredSize != .zero && needsReadSize {
            return measuredSize
        }
        #endif
        let helper = PositioningHelper(
            positioning: component.positioning,
            rootAvailableSize: rootAvailableSize,
            availableSize: parentSize
        )
        return CGSize(
            width:  helper.width  ?? parentSize.width,
            height: helper.height ?? parentSize.height
        )
    }

    /// Whether the component's real rendered size needs to be measured to
    /// determine its available size (carousel/stack without a fixed `heightPercentage`).
    private var needsReadSize: Bool {
        (component.componentType == .carousel && component.positioning?.heightPercentage == nil) ||
        ((component as? ContainerComponentCommonView)?.direction == .stack
            && component.positioning?.heightPercentage == nil)
    }

    private var clipped: Bool {
        guard let container = component as? ContainerComponentCommonView else { return true }
        return !container.overflowVisible
    }

    private var rotation: Double { component.positioning?.rotation ?? 0.0 }

    /// Whether this component (or its descendants) requires touch interaction.
    /// Non-interactive stacked children have `allowsHitTesting` disabled so
    /// they do not absorb taps intended for content below them in the ZStack.
    private var isInteractive: Bool {
        if component.action != nil { return true }
        if component.componentType == .carousel { return true }
        if let container = component as? ContainerComponentCommonView, container.scrollable { return true }
        return false
    }

    /// Absolute offset (in points) to apply when this component is a direct child of a stack container.
    /// `top` is a percentage of the parent height, `left` of the parent width.
    private var absoluteOffsetX: CGFloat {
        guard isStackedChild, component.positioning?.absolutePositioning != nil else { return 0 }
        return PositioningHelper(
            positioning: component.positioning,
            rootAvailableSize: rootAvailableSize,
            availableSize: parentSize
        ).absolutePositioning.left
    }

    private var absoluteOffsetY: CGFloat {
        guard isStackedChild, component.positioning?.absolutePositioning != nil else { return 0 }
        return PositioningHelper(
            positioning: component.positioning,
            rootAvailableSize: rootAvailableSize,
            availableSize: parentSize
        ).absolutePositioning.top
    }

    // MARK: - Body

    var body: some View {
        renderComponent(availableSize: calculatedAvailableSize)
            .applyPositioning(with: parentSize, component: component)
            #if !SKIP
            .applyIf(needsReadSize) { view in
                view.readSize { size in
                    if size != measuredSize {
                        measuredSize = size
                    }
                }
            }
            #endif
            .applyStyles(
                with: component.styles,
                positioning: component.positioning,
                parentSize: parentSize,
                clipped: clipped
            )
            .offset(x: absoluteOffsetX, y: absoluteOffsetY)
            #if !SKIP
            .applyIf(!isInteractive && isStackedChild) { view in
                view.allowsHitTesting(false)
            }
            #endif
            .applyIf(component.action != nil) { view in
                view.onTapGesture {
                    if let action = component.action {
                        eventsBox.handler?.onAction(action, componentID: component.componentID)
                    }
                }
            }
    }

    // MARK: - Component dispatch

    @ViewBuilder
    private func renderComponent(availableSize: CGSize) -> some View {
        if let container = component as? ContainerComponentCommonView {
            ContainerComponentView(container, parentSize: availableSize)
        } else if let text = component as? TextComponentCommonView {
            TextComponentView(text)
        } else if let image = component as? ImageComponentCommonView {
            ImageComponentView(image, availableSize: availableSize)
        } else if let carousel = component as? CarouselComponentCommonView {
            CarouselComponentView(carousel, parentSize: availableSize)
        } else if let xmedia = component as? XMediaComponentCommonView {
            XMediaComponentView(xmedia, parentSize: availableSize)
        } else {
            EmptyView()
        }
    }
}
