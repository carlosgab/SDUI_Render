import Foundation
#if canImport(XMediaPlayer) && !SKIP
import XMediaPlayer
import ITXMediaStoreFront
#endif

// MARK: - Container protocol

final class ContainerComponentProtocol: SDUIProtocol {

    func parseDTO(from decoder: Decoder) throws -> BaseComponentDTO {
        try ContainerComponentDTO(from: decoder)
    }

    func toCommonView(dto: BaseComponentDTO, dataSources: [String: [SDUIDataSource]]) throws -> ComponentCommonView? {
        guard let dto = dto as? ContainerComponentDTO else { return nil }
        let base = ComponentMapper.map(from: dto)
        let spacing: SpacingBO = dto.space?.toDomain()
            ?? .absolute(value: Double(dto.spacing ?? 0))
        let children = try (dto.children ?? []).toCommonViews(
            dataSources: dataSources,
            parentDataSourceKey: dto.dataSourceKey
        )
        return ContainerComponentCommonView(
            from: base,
            children: children,
            direction: dto.direction,
            spacing: spacing,
            scrollable: dto.scrollable ?? false,
            overflowVisible: dto.overflowVisible ?? false
        )
    }
}

// MARK: - Text protocol

final class TextComponentProtocol: SDUIProtocol {

    func parseDTO(from decoder: Decoder) throws -> BaseComponentDTO {
        try TextComponentDTO(from: decoder)
    }

    func toCommonView(dto: BaseComponentDTO, dataSources: [String: [SDUIDataSource]]) throws -> ComponentCommonView? {
        guard let textDTO = dto as? TextComponentDTO else { return nil }
        let base = ComponentMapper.map(from: textDTO)
        let interpolatedText = interpolateText(textDTO, dataSources: dataSources)
        return TextComponentCommonView(from: base, textContent: interpolatedText)
    }

    /// Replaces `{{key}}` placeholders in `textContent` with values from data sources.
    private func interpolateText(_ dto: TextComponentDTO, dataSources: [String: [SDUIDataSource]]) -> String {
        guard let key = dto.dataSourceKey,
              let dataSource = dataSources[key]?.first else { return dto.textContent }
        return SDUIInterpolator.interpolate(dto.textContent, with: dataSource)
    }
}

// MARK: - Image protocol

final class ImageComponentProtocol: SDUIProtocol {

    func parseDTO(from decoder: Decoder) throws -> BaseComponentDTO {
        try ImageComponentDTO(from: decoder)
    }

    func toCommonView(dto: BaseComponentDTO, dataSources: [String: [SDUIDataSource]]) throws -> ComponentCommonView? {
        guard let imageDTO = dto as? ImageComponentDTO else { return nil }
        let base = ComponentMapper.map(from: imageDTO)
        let imagePath = interpolateImagePath(imageDTO, dataSources: dataSources)
        let imageBO = ImageBO(
            path: imagePath,
            objectFit: imageDTO.image.objectFit,
            objectPosition: imageDTO.image.objectPosition,
            dimensions: imageDTO.image.dimensions.map { CGSize(width: $0.width, height: $0.height) }
        )
        return ImageComponentCommonView(from: base, image: imageBO)
    }

    private func interpolateImagePath(_ dto: ImageComponentDTO, dataSources: [String: [SDUIDataSource]]) -> String {
        guard let key = dto.dataSourceKey,
              let dataSource = dataSources[key]?.first else { return dto.image.path }
        return SDUIInterpolator.interpolate(dto.image.path, with: dataSource)
    }
}

// MARK: - Carousel protocol

final class CarouselComponentProtocol: SDUIProtocol {

    func parseDTO(from decoder: Decoder) throws -> BaseComponentDTO {
        try CarouselComponentDTO(from: decoder)
    }

    func toCommonView(dto: BaseComponentDTO, dataSources: [String: [SDUIDataSource]]) throws -> ComponentCommonView? {
        guard let dto = dto as? CarouselComponentDTO else { return nil }
        let base = ComponentMapper.map(from: dto)
        let children = try (dto.children ?? []).toCommonViews(
            dataSources: dataSources,
            parentDataSourceKey: dto.dataSourceKey
        )
        let spacing = dto.itemSpace?.spacingValue ?? Double(dto.itemSpacing ?? 0)
        return CarouselComponentCommonView(
            from: base,
            children: children,
            scrollMode: dto.scrollMode,
            spacing: spacing,
            visibleItems: dto.visibleItems,
            loop: dto.loop,
            autoplay: dto.autoplay,
            transition: dto.transition,
            offsetStart: dto.offsetStart,
            offsetEnd: dto.offsetEnd
        )
    }
}

// MARK: - XMedia protocol

final class XMediaComponentProtocol: SDUIProtocol {

    func parseDTO(from decoder: Decoder) throws -> BaseComponentDTO {
        try XMediaComponentDTO(from: decoder)
    }

    func toCommonView(dto: BaseComponentDTO, dataSources: [String: [SDUIDataSource]]) throws -> ComponentCommonView? {
        guard let dto = dto as? XMediaComponentDTO else { return nil }
        let base = ComponentMapper.map(from: dto)
        #if canImport(XMediaPlayer) && !SKIP
        let resolvedMedia = getMedia(from: dto, with: dataSources)
        return XMediaComponentCommonView(
            from: base,
            mediaWidth: dto.storeFrontMedia?.width,
            mediaHeight: dto.storeFrontMedia?.height,
            xmedia: resolvedMedia
        )
        #else
        // Serialize the raw storeFrontMedia payload to JSON so Android/Skip can
        // deserialize it into the platform's StoreFrontMediaDTO and call .toXMedia().
        // Fall back to the data source if the component's own storeFrontMedia is null.
        let jsonString: String?
        if let ownJson = dto.storeFrontMediaRawJson {
            jsonString = ownJson
        } else if let key = dto.dataSourceKey,
                  let dataSource = dataSources[key]?.first {
            if let category = dataSource as? CategoryDataSource {
                jsonString = category.storeFrontMediaRawJson
            } else if let product = dataSource as? ProductDataSource {
                jsonString = product.storeFrontMediaRawJson
            } else {
                jsonString = nil
            }
        } else {
            jsonString = nil
        }
        return XMediaComponentCommonView(
            from: base,
            mediaWidth: dto.storeFrontMedia?.width,
            mediaHeight: dto.storeFrontMedia?.height,
            storeFrontMediaJson: jsonString
        )
        #endif
    }

    #if canImport(XMediaPlayer) && !SKIP
    /// Returns the `StoreFrontITXMediaDTO` to render.
    /// Priority: component's own `xmedia` field → data source (category or product).
    private func getMedia(from dto: XMediaComponentDTO,
                          with dataSources: [String: [SDUIDataSource]]) -> StoreFrontITXMediaDTO? {
        if let xmedia = dto.xmedia {
            return xmedia
        }
        guard let key = dto.dataSourceKey,
              let dataSource = dataSources[key]?.first else { return nil }
        if let category = dataSource as? CategoryDataSource {
            return category.storeFrontMedia
        }
        if let product = dataSource as? ProductDataSource {
            return product.storeFrontMedia
        }
        return nil
    }
    #endif
}
