import Foundation
import SwiftUI

/// Renders an `ImageComponentCommonView` using `AsyncImage`.
struct ImageComponentView: View {

    private let component: ImageComponentCommonView
    private let availableSize: CGSize

    init(_ component: ImageComponentCommonView, availableSize: CGSize) {
        self.component = component
        self.availableSize = availableSize
    }

    var body: some View {
        if let url = URL(string: component.image.path) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: component.image.objectFit.contentMode)
                        .frame(
                            width: targetWidth,
                            height: targetHeight
                        )
                        .clipped()
                case .failure:
                    placeholderView
                case .empty:
                    placeholderView
                @unknown default:
                    placeholderView
                }
            }
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: targetWidth, height: targetHeight)
    }

    private var targetWidth: CGFloat? {
        if let dim = component.image.dimensions, dim.width > 0 {
            return CGFloat(dim.width)
        }
        if let wp = component.positioning?.widthPercentage {
            return availableSize.width * wp / 100
        }
        return nil
    }

    private var targetHeight: CGFloat? {
        if let dim = component.image.dimensions, dim.height > 0 {
            return CGFloat(dim.height)
        }
        if let hp = component.positioning?.heightPercentage {
            return availableSize.height * hp / 100
        }
        return nil
    }
}
