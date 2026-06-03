import Foundation

/// Simple string interpolator for `{{key}}` placeholders in SDUI text content.
/// Supported keys come from `ProductDataSource` and `CategoryDataSource` fields.
public struct SDUIInterpolator {

    public static func interpolate(_ template: String, with dataSource: SDUIDataSource) -> String {
        var result = template

        if let product = dataSource as? ProductDataSource {
            result = apply(result, key: "name",                value: product.name)
            result = apply(result, key: "currentPrice",        value: product.currentPrice)
            result = apply(result, key: "oldPrice",            value: product.oldPrice)
            result = apply(result, key: "originalPrice",       value: product.originalPrice)
            result = apply(result, key: "discountPercentage",  value: product.discountPercentage)
            result = apply(result, key: "displayTag",          value: product.displayTag)
            result = apply(result, key: "description",         value: product.description)
            result = apply(result, key: "imageURL",            value: product.imageURL)
        } else if let category = dataSource as? CategoryDataSource {
            result = apply(result, key: "name",    value: category.name)
            result = apply(result, key: "tag",     value: category.tag)
            result = apply(result, key: "imageURL", value: category.imageURL)
        }

        return result
    }

    private static func apply(_ text: String, key: String, value: String?) -> String {
        guard let value else { return text }
        return text.replacingOccurrences(of: "{{\(key)}}", with: value)
    }
}
