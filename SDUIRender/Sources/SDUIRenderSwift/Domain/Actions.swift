import Foundation

/// Marker protocol for all SDUI domain actions.
public protocol SDUIAction {
    var type: String { get }
}

/// Navigate to a product detail page.
public struct ActionNavigateToProduct: SDUIAction {
    public let type: String = ActionTypeConstant.navigate
    public let subtype: String = "product"
    public let productId: String

    public init(productId: String) {
        self.productId = productId
    }
}

/// Navigate to a category listing page.
public struct ActionNavigateToCategory: SDUIAction {
    public let type: String = ActionTypeConstant.navigate
    public let subtype: String = "category"
    public let categoryId: String
    public let redirectionScreenName: String?

    public init(categoryId: String, redirectionScreenName: String? = nil) {
        self.categoryId = categoryId
        self.redirectionScreenName = redirectionScreenName
    }
}

/// Open a URL in an in-app browser or the system browser.
public struct ActionNavigateToURL: SDUIAction {
    public let type: String = ActionTypeConstant.navigateToUrl
    public let url: URL
    public let externalBrowser: Bool

    public init(url: URL, externalBrowser: Bool) {
        self.url = url
        self.externalBrowser = externalBrowser
    }
}

/// Add a product to the shopping cart.
public struct ActionAddToCart: SDUIAction {
    public let type: String = ActionTypeConstant.addToCart
    public let productId: String

    public init(productId: String) {
        self.productId = productId
    }
}
