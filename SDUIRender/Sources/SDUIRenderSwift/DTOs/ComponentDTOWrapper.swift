import Foundation

/// Polymorphic wrapper that decodes the correct component DTO using the global registry.
public struct ComponentDTOWrapper: Decodable {
    public var component: BaseComponentDTO?

    enum CodingKeys: String, CodingKey {
        case componentType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .componentType)
        let componentType = ComponentType(rawValue: typeString) ?? .custom(typeString)
        self.component = try? SDUIRegistry.shared.registry.createComponentDTO(
            type: componentType,
            decoder: decoder
        )
    }
}

// MARK: - Array convenience

public extension Array where Element == ComponentDTOWrapper {

    /// Converts a list of wrapped DTOs to domain `ComponentCommonView` objects,
    /// taking data-source iteration into account.
    func toCommonViews(
        dataSources: [String: [SDUIDataSource]],
        parentDataSourceKey: String? = nil
    ) throws -> [ComponentCommonView] {
        let registry = SDUIRegistry.shared.registry

        // Iterative data-source expansion: repeat the single template item for each data source entry.
        if let items = dataSources[parentDataSourceKey ?? ""],
           items.count > 1,
           let firstComponent = self.first?.component,
           let rootKey = parentDataSourceKey {

            return try items.enumerated().compactMap { index, dataSource in
                var component = firstComponent
                let key = "\(rootKey)_\(index)"
                component.dataSourceKey = key

                var updatedDataSources = dataSources
                updatedDataSources[key] = [dataSource]

                guard let componentType = ComponentType(rawValue: component.componentType),
                      let handler = registry.getProtocol(type: componentType) else { return nil }
                let view = try handler.toCommonView(dto: component, dataSources: updatedDataSources)
                view?.action = ComponentMapper.resolveAction(from: component, dataSources: updatedDataSources)
                return view
            }
        }

        // General case
        return try self.compactMap { element in
            guard var component = element.component else { return nil }
            component.dataSourceKey = component.dataSourceKey ?? parentDataSourceKey

            guard let componentType = ComponentType(rawValue: component.componentType),
                  let handler = registry.getProtocol(type: componentType) else { return nil }
            let view = try handler.toCommonView(dto: component, dataSources: dataSources)
            view?.action = ComponentMapper.resolveAction(from: component, dataSources: dataSources)
            return view
        }
    }
}
