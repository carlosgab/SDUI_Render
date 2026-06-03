import Foundation

/// Root page domain model.
public struct PageBO: Sendable {
    public let id: String?
    public var component: ComponentCommonView?

    public init(id: String?, component: ComponentCommonView?) {
        self.id = id
        self.component = component
    }
}
