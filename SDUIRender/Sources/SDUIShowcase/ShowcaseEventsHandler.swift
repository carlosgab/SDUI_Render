import Foundation
import SwiftUI
import SDUIRenderSwift

/// Simple events handler for the Showcase.
/// Captures the last received action/error and publishes it so the preview view can display it.
public final class ShowcaseEventsHandler: ObservableObject, SDUIEventsHandler {
    @Published public var lastEvent: String = ""

    public init() {}

    public func onAction(_ action: SDUIAction, componentID: String?) {
        lastEvent = "Action: \(action.type)"
    }

    public func onError(_ error: Error, componentID: String?) {
        lastEvent = "Error: \(error.localizedDescription)"
    }
}
