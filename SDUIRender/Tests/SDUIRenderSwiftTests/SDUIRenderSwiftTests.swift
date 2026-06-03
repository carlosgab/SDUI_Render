import Testing
import OSLog
import Foundation
@testable import SDUIRenderSwift

let logger: Logger = Logger(subsystem: "SDUIRenderSwift", category: "Tests")

@Suite struct SDUIRenderSwiftTests {

    @Test func basicArithmetic() throws {
        logger.log("running basicArithmetic")
        #expect(1 + 2 == 3, "basic test")
    }

    @Test func decodeSDUIPage() throws {
        let url = try #require(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let page = try SDUIManager.shared.decode(from: .data(data))
        #expect(page.id == "test-page")
        #expect(page.component != nil)
    }

    @Test func containerChildrenDecoded() throws {
        let url = try #require(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let page = try SDUIManager.shared.decode(from: .data(data))
        let container = try #require(page.component as? ContainerComponentCommonView)
        #expect(container.children.count == 2)
        #expect(container.direction == .vertical)
    }

    @Test func textComponentDecoded() throws {
        let url = try #require(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let page = try SDUIManager.shared.decode(from: .data(data))
        let container = try #require(page.component as? ContainerComponentCommonView)
        let textChild = try #require(container.children.first as? TextComponentCommonView)
        #expect(textChild.textContent == "Hello from SDUI!")
    }

    @Test func imageComponentDecoded() throws {
        let url = try #require(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let page = try SDUIManager.shared.decode(from: .data(data))
        let container = try #require(page.component as? ContainerComponentCommonView)
        let imageChild = try #require(container.children.last as? ImageComponentCommonView)
        #expect(imageChild.image.path == "https://via.placeholder.com/300x150")
        #expect(imageChild.image.objectFit == .cover)
    }

    @Test func componentTypeRawValues() {
        #expect(ComponentType(rawValue: "container") == .container)
        #expect(ComponentType(rawValue: "text")      == .text)
        #expect(ComponentType(rawValue: "image")     == .image)
        #expect(ComponentType(rawValue: "carousel")  == .carousel)
        let unknown = ComponentType(rawValue: "unknown")
        #expect(unknown?.rawValue == "unknown")
    }

    @Test func hexColorParsing() throws {
        #expect(colorFromHex("#FF0000") != nil)
        #expect(colorFromHex("00FF00")  != nil)
        #expect(colorFromHex("")        == nil)
        #expect(colorFromHex("XYZ")     == nil)
    }
}
