import Foundation
import SwiftUI

/// Renders a `CarouselComponentCommonView`.
///
/// - `snap` mode uses a `TabView` with `.page` style for snapping behaviour.
/// - `free` mode uses a horizontal `ScrollView` with `LazyHStack`.
struct CarouselComponentView: View {

    private let component: CarouselComponentCommonView
    private let parentSize: CGSize

    @State private var currentPage: Int = 0

    init(_ component: CarouselComponentCommonView, parentSize: CGSize) {
        self.component = component
        self.parentSize = parentSize
    }

    var body: some View {
        if component.scrollMode == .snap {
            snapCarousel
        } else {
            freeScrollCarousel
        }
    }

    // MARK: - Snap carousel (TabView paging)

    private var snapCarousel: some View {
        TabView(selection: $currentPage) {
            ForEach(Array(component.children.enumerated()), id: \.element.id) { index, child in
                ComponentViewBuilder(component: child, parentSize: itemSize)
                    .tag(index)
            }
        }
        #if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
        #endif
        .frame(height: parentSize.height > 0 ? parentSize.height : nil)
    }

    // MARK: - Free scroll carousel (ScrollView)

    private var freeScrollCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: CGFloat(component.spacing)) {
                ForEach(component.children) { child in
                    ComponentViewBuilder(component: child, parentSize: itemSize)
                }
            }
            .padding(.leading,  CGFloat(component.offsetStart))
            .padding(.trailing, CGFloat(component.offsetEnd))
        }
    }

    // MARK: - Item size

    private var itemSize: CGSize {
        guard let visibleItems = component.visibleItems, visibleItems > 0 else {
            return parentSize
        }
        let totalSpacing = CGFloat(component.spacing) * CGFloat(max(visibleItems - 1, 0))
        let itemWidth = (parentSize.width - totalSpacing) / CGFloat(visibleItems)
        return CGSize(width: max(itemWidth, 0), height: parentSize.height)
    }
}
