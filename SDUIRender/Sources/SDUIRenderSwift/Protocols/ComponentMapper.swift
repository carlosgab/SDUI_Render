import Foundation

/// Maps base DTOs to the shared `ComponentCommonView` base, and resolves actions from data sources.
public struct ComponentMapper {

    /// Creates a `ComponentCommonView` from a DTO's shared fields.
    public static func map(from dto: BaseComponentDTO) -> ComponentCommonView {
        ComponentCommonView(
            componentID: dto.id,
            componentType: dto.componentType,
            styles: dto.styles?.toDomain(),
            positioning: dto.positioning?.toDomain(),
            action: dto.action?.toDomain()
        )
    }

    /// Resolves the action for a component, taking data-source context into account.
    public static func resolveAction(
        from dto: BaseComponentDTO,
        dataSources: [String: [SDUIDataSource]]
    ) -> SDUIAction? {
        guard let wrapper = dto.action else { return nil }

        if wrapper.action is NavigateActionDTO {
            return resolveNavigateAction(key: dto.dataSourceKey, dataSources: dataSources)
        }
        if wrapper.action is AddToCartActionDTO {
            return resolveAddToCartAction(key: dto.dataSourceKey, dataSources: dataSources)
        }
        return wrapper.toDomain()
    }

    // MARK: - Private

    private static func resolveNavigateAction(
        key: String?,
        dataSources: [String: [SDUIDataSource]]
    ) -> SDUIAction? {
        guard let key, let dataSource = dataSources[key]?.first else { return nil }
        switch dataSource.type {
        case DataSourceDataTypeConstant.navigateToProduct:
            guard let product = dataSource as? ProductDataSource, let id = product.id else { return nil }
            return ActionNavigateToProduct(productId: id)
        case DataSourceDataTypeConstant.navigateToCategory:
            guard let category = dataSource as? CategoryDataSource, let id = category.id else { return nil }
            return ActionNavigateToCategory(categoryId: id, redirectionScreenName: category.redirectionScreenName)
        default:
            return nil
        }
    }

    private static func resolveAddToCartAction(
        key: String?,
        dataSources: [String: [SDUIDataSource]]
    ) -> SDUIAction? {
        guard let key,
              let product = dataSources[key]?.first as? ProductDataSource,
              let id = product.id
        else { return nil }
        return ActionAddToCart(productId: id)
    }
}
