package sduirender.swift

import android.util.Log
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.requiredHeight
import androidx.compose.foundation.layout.requiredSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.inditex.storefront.core.api.data.models.StoreFrontMediaDTO as LibStoreFrontMediaDTO
import com.inditex.xmpand.core.xmedia.domain.model.XMediaModel
import com.inditex.xmpand.core.xmedia.network.bridge.toXMedia
import com.inditex.xmpand.xmedia.composable.XMedia
import kotlinx.serialization.json.Json
import skip.lib.Dictionary
import kotlin.math.roundToInt

private const val TAG = "SDUIXMedia"

// Reuse a single Json instance with ignoreUnknownKeys — the Kotlin builder DSL
// is not directly expressible from Skip-transpiled Swift, so we keep this logic
// in a native Kotlin file.
private val xMediaJson = Json { ignoreUnknownKeys = true }

internal fun decodeToXMedia(json: String?): XMediaModel? {
    if (json == null) {
        Log.w(TAG, "decodeToXMedia: storeFrontMediaJson is null")
        return null
    }
    val dto = try {
        xMediaJson.decodeFromString(LibStoreFrontMediaDTO.serializer(), json)
    } catch (e: Exception) {
        Log.e(TAG, "decodeToXMedia: JSON decode failed — ${e.javaClass.simpleName}: ${e.message}")
        Log.e(TAG, "  json was: ${json.take(300)}")
        return null
    }
    val xMedia = dto.toXMedia()
    if (xMedia == null) {
        Log.w(TAG, "decodeToXMedia: toXMedia() returned null for asset=${dto.asset?.url}")
    } else {
        Log.d(TAG, "decodeToXMedia: OK — type=${xMedia.type}, url=${xMedia.url}, w=${xMedia.width}, h=${xMedia.height}")
    }
    return xMedia
}

/**
 * Renders an [XMedia] composable following the same sizing logic as sduicefand's
 * SDUIXMediaPlayer.kt.
 *
 * [desiredWidthDp] — available width in dp (logical pixels) from the SwiftUI layout.
 * [desiredHeightDp] — explicit height in dp from positioning, or null if not set.
 *
 * Sizing rules (mirrors sduicefand):
 * - Images / HLS / GIF: adjustToContent=true, provide desiredWidth in px and
 *   desiredHeight in px when available. XMedia fills to desiredWidth and adjusts
 *   height by content aspect ratio.
 * - MP4 with known height: adjustToContent=false + requiredSize modifier so the
 *   composable fills the exact allocated area.
 * - MP4 without explicit height: fall back to xMedia.aspect to compute height.
 */
@Composable
internal fun renderXMedia(json: String?, desiredWidthDp: Int, desiredHeightDp: Int?, hasExplicitWidth: Boolean) {
    val xMedia = decodeToXMedia(json) ?: run {
        Log.w(TAG, "renderXMedia: xMedia is null, skipping render")
        return
    }

    val density = LocalDensity.current
    // Convert dp → px correctly: use `.dp` to create a Dp value, then `.toPx()`.
    // (Float.toDp() inside a density scope converts px→dp — using it here would be a no-op.)
    val desiredWidthPx = with(density) { desiredWidthDp.dp.toPx() }.toInt()
    val desiredHeightPx: Int? = desiredHeightDp?.let { with(density) { it.dp.toPx() }.toInt() }

    val isVideoMp4 = xMedia.type == XMediaModel.Type.VIDEO

    // For MP4 without an explicit height, derive it from xMedia.aspect (width / aspect = height).
    val effectiveDesiredHeight: Int? = if (isVideoMp4 && desiredHeightPx == null) {
        val aspect = xMedia.aspect
        if (aspect > 0f) (desiredWidthPx / aspect).roundToInt() else null
    } else {
        desiredHeightPx
    }

    // When we have an explicit height (from heightPercentage or MP4 aspect calculation),
    // constrain the composable to the exact allocated area so it doesn't overflow.
    // When no height is set, let XMedia adjust by content (fills width, intrinsic ratio).
    val adjustToContent = effectiveDesiredHeight == null

    // When width comes from an explicit widthPercentage, force exact size.
    // When there is no widthPercentage, the parent HStack/Row distributes width equally;
    // use fillMaxWidth() so the composable fills whatever space Compose allocates,
    // and add a height constraint only when needed.
    val sizeModifier: Modifier = when {
        hasExplicitWidth && effectiveDesiredHeight != null && effectiveDesiredHeight > 0 -> {
            with(density) { Modifier.requiredSize(desiredWidthPx.toDp(), effectiveDesiredHeight.toDp()) }
        }
        hasExplicitWidth -> Modifier.fillMaxWidth()
        effectiveDesiredHeight != null && effectiveDesiredHeight > 0 -> {
            with(density) { Modifier.fillMaxWidth().requiredHeight(effectiveDesiredHeight.toDp()) }
        }
        else -> Modifier.fillMaxWidth()
    }

    Log.d(TAG, "renderXMedia: type=${xMedia.type} wPx=$desiredWidthPx hPx=$effectiveDesiredHeight adjustToContent=$adjustToContent")

    XMedia(
        xMedia = xMedia,
        desiredWidth = desiredWidthPx,
        desiredHeight = effectiveDesiredHeight,
        adjustToContent = adjustToContent,
        modifier = sizeModifier
    )
}

// ---------------------------------------------------------------------------
// SDUIAnyJSON → JSON string conversion (native Kotlin, avoids Skip transpilation issues)
// ---------------------------------------------------------------------------

/** Recursively converts a [SDUIAnyJSON] value to a valid JSON string. */
internal fun anyJSONToString(value: SDUIAnyJSON): String {
    return when (value) {
        is SDUIAnyJSON.StringCase -> {
            val escaped = value.associated0
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t")
            "\"${escaped}\""
        }
        is SDUIAnyJSON.IntCase    -> value.associated0.toString()
        is SDUIAnyJSON.DoubleCase -> value.associated0.toString()
        is SDUIAnyJSON.BoolCase   -> if (value.associated0) "true" else "false"
        is SDUIAnyJSON.NullCase   -> "null"
        is SDUIAnyJSON.ObjectCase -> {
            val parts = ArrayList<String>()
            for ((k, v) in value.associated0) {
                parts.add("\"$k\":${anyJSONToString(v)}")
            }
            "{${parts.joinToString(",")}}"
        }
        is SDUIAnyJSON.ArrayCase  -> {
            val parts = ArrayList<String>()
            for (item in value.associated0) {
                parts.add(anyJSONToString(item))
            }
            "[${parts.joinToString(",")}]"
        }
    }
}

/** Converts a [Dictionary]<String, [SDUIAnyJSON]> (from Skip) to a JSON object string. */
internal fun storeFrontMediaToJSON(rawDict: Dictionary<String, SDUIAnyJSON>): String {
    val parts = ArrayList<String>()
    for ((k, v) in rawDict) {
        parts.add("\"$k\":${anyJSONToString(v)}")
    }
    return "{${parts.joinToString(",")}}"
}
