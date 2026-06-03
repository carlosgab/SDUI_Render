import Foundation
import SwiftUI

/// Top-level view that decodes a JSON payload and renders it.
/// Wrap this in your app's view hierarchy and provide an events handler via the environment.
public struct SDUIPageView: View {

    private let source: SDUIPageSource
    private let eventsBox: SDUIEventsBox
    private let preferredSize: CGSize

    @State private var page: PageBO?
    @State private var hasError: Bool = false

    /// - parameter preferredSize: When width > 0, use this size directly instead of an
    ///   internal GeometryReader. Useful when embedding inside a ScrollView on Android.
    public init(source: SDUIPageSource, eventsHandler: (any SDUIEventsHandler)? = nil, preferredSize: CGSize = CGSize(width: 0, height: 0)) {
        self.source = source
        self.eventsBox = SDUIEventsBox(eventsHandler)
        self.preferredSize = preferredSize
    }

    public var body: some View {
        pageContent
            .task {
                await loadPage()
            }
    }

    @ViewBuilder
    private var pageContent: some View {
        if hasError {
            Color.clear
        } else if preferredSize.width > 0 {
            Group {
                if let component = page?.component {
                    componentContent(component: component, size: preferredSize)
                } else {
                    Color.clear
                }
            }
        } else {
            GeometryReader { geometry in
                let availableSize = geometry.size
                Group {
                    if let component = page?.component {
                        componentContent(component: component, size: availableSize)
                    } else {
                        Color.clear
                    }
                }
            }
        }
    }

    private func componentContent(component: ComponentCommonView, size: CGSize) -> some View {
        ComponentViewBuilder(component: component, parentSize: size)
            .environment(\.rootAvailableSize, size)
            .environment(\.sduiEvents, eventsBox)
    }

    private func loadPage() async {
        guard page == nil && !hasError else { return }
        do {
            let decoded = try SDUIManager.shared.decode(from: source)
            page = decoded
        } catch let e {
            hasError = true
            eventsBox.handler?.onError(e, componentID: nil)
        }
    }
}
