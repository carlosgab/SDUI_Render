import Foundation
import SwiftUI
#if canImport(XMediaPlayer) && !SKIP
import XMediaPlayer
import ITXMediaStoreFront
#endif
#if SKIP
import com.inditex.xmpand.xmedia.composable.XMedia
#endif

/// Renders the `xmedia` component.
///
/// **iOS** — delegates rendering to `XMediaViewSwiftUI` (ITXMediaPlayer library).
/// Handles impression tracking, and forwards user-control taps via `SDUIEventsHandler`.
///
/// **Android / Skip** — shows a neutral placeholder. XMediaPlayer is iOS-only.
struct XMediaComponentView: View {

    private let component: XMediaComponentCommonView
    private let parentSize: CGSize

    @Environment(\.sduiEvents) private var eventsBox: SDUIEventsBox

    init(_ component: XMediaComponentCommonView, parentSize: CGSize) {
        self.component = component
        self.parentSize = parentSize
    }

    // MARK: - Body

    var body: some View {
        #if SKIP
        xmediaAndroidView
        #elseif canImport(XMediaPlayer)
        xmediaPlayerView
        #else
        placeholderView
        #endif
    }

    // MARK: - iOS player

    #if canImport(XMediaPlayer) && !SKIP
    // XMediaViewSwiftUI requires a Binding<XMediaView> to expose resetImpressionTracker()
    // and the userControlsDelegate. Using @State here keeps it in the view's lifecycle.
    @State private var xmediaViewRef: XMediaView = XMediaView()

    @ViewBuilder
    private var xmediaPlayerView: some View {
        if let storeFrontMedia = component.xmedia,
           let xmediaData = try? storeFrontMedia.toXMediaData() {
            XMediaViewSwiftUI(
                media: xmediaData,
                availableWidth: resolvedWidth,
                xmediaView: $xmediaViewRef
            )
            .onAppear {
                // Spec: resetImpressionTracker on every onAppear so impressions
                // fire each time the view becomes visible again.
                xmediaViewRef.resetImpressionTracker()
                // Wire the user-controls delegate so taps reach the events handler.
                xmediaViewRef.userControlsDelegate = UserControlsHandler(
                    componentID: component.componentID,
                    eventsBox: eventsBox
                )
            }
        } else {
            placeholderView
        }
    }

    /// Bridges `XMediaVideoPlayerUserControlsDelegate` → `SDUIEventsHandler.onXmediaControlTap`.
    private final class UserControlsHandler: NSObject, XMediaVideoPlayerUserControlsDelegate {

        private let componentID: String?
        private let eventsBox: SDUIEventsBox

        func userTapPlay() {

        }
        
        func userTapPause() {

        }

        init(componentID: String?, eventsBox: SDUIEventsBox) {
            self.componentID = componentID
            self.eventsBox   = eventsBox
        }

        func userTapAudio(with isMute: Bool) {
            let controlName = isMute ? "mute" : "unmute"
            eventsBox.handler?.onXmediaControlTap(controlName, componentID: componentID)
        }
    }
    #endif

    // MARK: - Android / Skip player

    #if SKIP
    @ViewBuilder
    private var xmediaAndroidView: some View {
        // renderXMedia is in XMediaHelper.kt — converts dp→px, computes sizing
        // following the same logic as sduicefand's SDUIXMediaPlayer.kt.
        // parentSize is already the percentage-applied available size (computed by
        // ComponentViewBuilder.calculatedAvailableSize via PositioningHelper). Use it
        // directly — do NOT re-apply heightPercentage (resolvedHeight does that and
        // would apply the percentage twice).
        let widthDp: Int = Int(parentSize.width)
        let heightDp: Int? = component.positioning?.heightPercentage != nil ? Int(parentSize.height) : nil
        let hasExplicitWidth: Bool = component.positioning?.widthPercentage != nil
        renderXMedia(json: component.storeFrontMediaJson, desiredWidthDp: widthDp, desiredHeightDp: heightDp, hasExplicitWidth: hasExplicitWidth)
    }
    #endif

    // MARK: - Placeholder (Android fallback + iOS without XMediaPlayer)

    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.12))
            .frame(width: resolvedWidth, height: resolvedHeight)
    }

    // MARK: - Layout helpers

    /// Width passed to `XMediaViewSwiftUI`, per spec:
    /// - `widthPercentage` set → `parentSize.width`
    /// - only `heightPercentage` set → derived from media aspect ratio
    /// - neither → `nil` (player uses intrinsic size)
    private var resolvedWidth: CGFloat? {
        if component.positioning?.widthPercentage != nil {
            return parentSize.width
        }
        if component.positioning?.heightPercentage != nil,
           let mw = component.mediaWidth, let mh = component.mediaHeight, mh > 0 {
            let hp = CGFloat(component.positioning?.heightPercentage ?? 100) / 100.0
            let height = parentSize.height * hp
            return height * CGFloat(mw / mh)
        }
        return nil
    }

    private var resolvedHeight: CGFloat? {
        guard let hp = component.positioning?.heightPercentage else { return nil }
        return parentSize.height * CGFloat(hp) / 100.0
    }
}
