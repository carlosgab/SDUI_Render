import SwiftUI
import SDUIRenderSwift

/// Renders a single SDUI JSON payload and shows a banner with the last received action.
public struct ShowcasePreviewView: View {
    let title: String
    let json: String
    let showActions: Bool
    let showFullScreen: Bool
    let forceRTL: Bool

    @StateObject private var eventsHandler = ShowcaseEventsHandler()

    public init(title: String, json: String, showActions: Bool = true, showFullScreen: Bool = true, forceRTL: Bool = false) {
        self.title = title
        self.json = json
        self.showActions = showActions
        self.showFullScreen = showFullScreen
        self.forceRTL = forceRTL
    }

    public var body: some View {
        Group {
            if showFullScreen {
                sduiContent(preferredSize: CGSize(width: 0, height: 0))
            } else {
                GeometryReader { geo in
                    ScrollView {
                        VStack(spacing: 16) {
                            Text("Headline").font(.headline)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                            sduiContent(preferredSize: geo.size)
                                .frame(width: geo.size.width)
                            Text("Footer").font(.subheadline)
                            HStack(spacing: 8) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 25, height: 25)
                                Text("Signature").font(.footnote)
                            }
                        }
                        .frame(width: geo.size.width)
                    }
                }
            }
        }
        .environment(\.layoutDirection, forceRTL ? LayoutDirection.rightToLeft : LayoutDirection.leftToRight)
        .navigationTitle(title)
        .alert("Action received", isPresented: alertBinding, actions: {
            Button("OK") { eventsHandler.lastEvent = "" }
        }, message: {
            Text(eventsHandler.lastEvent)
        })
    }

    @ViewBuilder
    private func sduiContent(preferredSize: CGSize) -> some View {
        VStack(spacing: 0) {
            if showActions && !eventsHandler.lastEvent.isEmpty {
                Text(eventsHandler.lastEvent)
                    .font(.footnote)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .foregroundStyle(Color.white)
            }
            SDUIPageView(source: .jsonString(json), eventsHandler: eventsHandler, preferredSize: preferredSize)
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { showActions && !eventsHandler.lastEvent.isEmpty },
            set: { if !$0 { eventsHandler.lastEvent = "" } }
        )
    }
}

#Preview {
    NavigationView {
        ShowcasePreviewView(
            title: "Preview",
            json: ShowcaseJsonSample.samples(for: .layout).first?.json ?? ""
        )
    }
}
