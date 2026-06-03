import Foundation

/// Root page DTO decoded from the JSON payload.
public struct PageDTO: Decodable {
    public let id: String?
    public let responsiveLayouts: [ResponsiveLayoutDTO]
    public let dataSources: [String: DataSourceDTOWrapper]?

    public func toDomain() throws -> PageBO {
        let resolvedDataSources: [String: [SDUIDataSource]] = dataSources?
            .compactMapValues { $0.dataSources.isEmpty ? nil : $0.dataSources } ?? [:]
        let component = try responsiveLayouts.first?.componentTree.toCommonView(
            dataSources: resolvedDataSources
        )
        return PageBO(id: id, component: component)
    }
}

/// A single responsive layout that applies from `minWidth` upwards.
public struct ResponsiveLayoutDTO: Decodable {
    public let minWidth: Double?
    public let dimensions: LayoutDimensionsDTO?
    public let componentTree: ComponentDTOWrapper
}

public struct LayoutDimensionsDTO: Decodable {
    public let width: Double?
    public let height: Double?
}

// MARK: - Data source wrapper

/// Polymorphic wrapper for data sources.  Apps can extend `SDUIDataSource` and
/// register their own decoder implementations; this default wrapper supports
/// `product` and `category` types out of the box.
public struct DataSourceDTOWrapper: Decodable {
    public var dataSources: [SDUIDataSource] = []

    enum CodingKeys: String, CodingKey { case type, data }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString: String = (try? container.decode(String.self, forKey: .type)) ?? ""
        switch typeString {
        case DataSourceDataTypeConstant.navigateToProduct:
            let products: [ProductDataSource] = (try? container.decode([ProductDataSource].self, forKey: .data)) ?? []
            dataSources = products.map { $0 as SDUIDataSource }
        case DataSourceDataTypeConstant.navigateToCategory:
            let categories: [CategoryDataSource] = (try? container.decode([CategoryDataSource].self, forKey: .data)) ?? []
            dataSources = categories.map { $0 as SDUIDataSource }
        default:
            break
        }
    }
}

/// A data source that can be decoded from JSON.
public protocol DecodableDataSource: Decodable {
    func toDomain() -> [SDUIDataSource]
}

// MARK: - Convenience extension on ComponentDTOWrapper

public extension ComponentDTOWrapper {
    func toCommonView(dataSources: [String: [SDUIDataSource]]) throws -> ComponentCommonView? {
        guard let component,
              let componentType = ComponentType(rawValue: component.componentType),
              let handler = SDUIRegistry.shared.registry.getProtocol(type: componentType)
        else { return nil }
        let view = try handler.toCommonView(dto: component, dataSources: dataSources)
        view?.action = ComponentMapper.resolveAction(from: component, dataSources: dataSources)
        return view
    }
}
