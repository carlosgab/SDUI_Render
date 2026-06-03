import Foundation

/// Global singleton registry. Registers built-in component protocols
/// and lets the host app extend the registry with custom components.
public final class SDUIRegistry: @unchecked Sendable {

    public static let shared = SDUIRegistry()

    public let registry: ComponentProtocolsRegistry

    private init() {
        registry = ComponentProtocolsRegistry()
        registerDefaultProtocols()
    }

    private func registerDefaultProtocols() {
        registry.register(ContainerComponentProtocol(), forKey: .container)
        registry.register(TextComponentProtocol(),      forKey: .text)
        registry.register(ImageComponentProtocol(),     forKey: .image)
        registry.register(CarouselComponentProtocol(),  forKey: .carousel)
        registry.register(XMediaComponentProtocol(),    forKey: .xmedia)
    }

    /// Register a custom component protocol for app-specific component types.
    public func register(_ protocol_: SDUIProtocol, forKey key: ComponentType) {
        registry.register(protocol_, forKey: key)
    }
}
