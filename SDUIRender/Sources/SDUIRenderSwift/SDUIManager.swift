import Foundation
import SwiftUI

// MARK: - Page source

/// Where the SDUI JSON payload comes from.
public enum SDUIPageSource {
    case jsonString(String)
    case data(Data)
}

// MARK: - SDUIManager

/// Main entry point for decoding a JSON payload into a renderable `PageBO`.
public final class SDUIManager: @unchecked Sendable {

    public static let shared = SDUIManager()

    private init() {}

    // MARK: - Decoding

    public func decode(from source: SDUIPageSource) throws -> PageBO {
        let data: Data
        switch source {
        case .jsonString(let string):
            guard let d = string.data(using: .utf8) else {
                throw SDUIError.invalidJSON
            }
            data = d
        case .data(let d):
            data = d
        }
        let pageDTO = try JSONDecoder().decode(PageDTO.self, from: data)
        return try pageDTO.toDomain()
    }

    // MARK: - View factory

    /// Creates the top-level SwiftUI view for the decoded page.
    @MainActor
    public func makeView(from source: SDUIPageSource, eventsHandler: (any SDUIEventsHandler)? = nil) -> some View {
        SDUIPageView(source: source, eventsHandler: eventsHandler)
    }
}

// MARK: - Errors

public enum SDUIError: Error {
    case invalidJSON
    case decodingFailed(Error)
    case componentNotFound(String)
}
