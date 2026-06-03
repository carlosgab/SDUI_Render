import Foundation
import SwiftUI

// MARK: - Events protocol

/// Implement this protocol to receive SDUI events such as component taps,
/// analytics events, and errors.
public protocol SDUIEventsHandler: AnyObject {
    /// Called when a component with an action is tapped.
    func onAction(_ action: SDUIAction, componentID: String?)
    /// Called for analytics events emitted by components.
    func onAnalyticsEvent(_ event: String, componentID: String?)
    /// Called when a component rendering error occurs.
    func onError(_ error: Error, componentID: String?)
    /// Called when the user taps a control inside an `xmedia` player
    /// (e.g. mute/unmute).  `controlName` identifies which control was tapped.
    func onXmediaControlTap(_ controlName: String, componentID: String?)
}

// Default no-op implementations so conformers only need to override what they care about.
public extension SDUIEventsHandler {
    func onAnalyticsEvent(_ event: String, componentID: String?) {}
    func onError(_ error: Error, componentID: String?) {}
    func onXmediaControlTap(_ controlName: String, componentID: String?) {}
}

// MARK: - SwiftUI environment key

/// Box wrapper so the protocol can be stored in an environment key without Skip issues.
public final class SDUIEventsBox {
    public let handler: (any SDUIEventsHandler)?
    public init(_ handler: (any SDUIEventsHandler)? = nil) {
        self.handler = handler
    }
}

private struct SDUIEventsKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: SDUIEventsBox = SDUIEventsBox()
}

public extension EnvironmentValues {
    var sduiEvents: SDUIEventsBox {
        get { self[SDUIEventsKey.self] }
        set { self[SDUIEventsKey.self] = newValue }
    }
}

// MARK: - Root available size environment key

private struct RootAvailableSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = CGSize(width: 0, height: 0)
}

public extension EnvironmentValues {
    var rootAvailableSize: CGSize {
        get { self[RootAvailableSizeKey.self] }
        set { self[RootAvailableSizeKey.self] = newValue }
    }
}
