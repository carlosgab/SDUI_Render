import Foundation

/// The contract that every component type must implement to participate in the SDUI pipeline.
public protocol SDUIProtocol {
    /// Decodes the component-specific DTO from the JSON decoder.
    func parseDTO(from decoder: Decoder) throws -> BaseComponentDTO
    /// Converts a decoded DTO to the domain view-model, resolving any data-source references.
    func toCommonView(dto: BaseComponentDTO, dataSources: [String: [SDUIDataSource]]) throws -> ComponentCommonView?
}

/// Registry that maps component types to their `SDUIProtocol` implementations.
public final class ComponentProtocolsRegistry {
    private var protocols: [String: SDUIProtocol] = [:]

    public init() {}

    public func register(_ protocol_: SDUIProtocol, forKey key: ComponentType) {
        protocols[key.rawValue] = protocol_
    }

    public func createComponentDTO(type: ComponentType, decoder: Decoder) throws -> BaseComponentDTO? {
        guard let handler = protocols[type.rawValue] else { return nil }
        return try handler.parseDTO(from: decoder)
    }

    public func getProtocol(type: ComponentType) -> SDUIProtocol? {
        protocols[type.rawValue]
    }
}
