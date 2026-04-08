package expo.modules.nativeemojispopup

import android.graphics.Color
import expo.modules.kotlin.exception.CodedException

enum class EmojisPopupErrorCode(val value: String) {
  ANCHOR_NOT_FOUND("ANCHOR_NOT_FOUND"),
  ANCHOR_NOT_MEASURABLE("ANCHOR_NOT_MEASURABLE"),
  EMPTY_ITEMS("EMPTY_ITEMS"),
  INVALID_PARAMS("INVALID_PARAMS"),
  PRESENTATION_FAILED("PRESENTATION_FAILED"),
}

class EmojisPopupException(
  errorCode: EmojisPopupErrorCode,
  message: String,
) : CodedException(errorCode.value, message, null)

enum class ReactionPopupPlacement {
  ABOVE,
  BELOW,
  AUTO,
  ;

  companion object {
    fun from(value: String?): ReactionPopupPlacement =
      when (value) {
        "above" -> ABOVE
        "below" -> BELOW
        else -> AUTO
      }
  }
}

data class ReactionPopupItemPayload(
  val id: String,
  val emoji: String,
  val emojiName: String,
) {
  companion object {
    fun fromMap(map: Map<String, Any?>): ReactionPopupItemPayload {
      val id = (map["id"] as? String)?.trim().orEmpty()
      val emoji = map["emoji"] as? String ?: ""
      val emojiName = (map["emoji_name"] as? String)?.trim().orEmpty()

      if (id.isEmpty() || emoji.isEmpty() || emojiName.isEmpty()) {
        throw EmojisPopupException(
          EmojisPopupErrorCode.INVALID_PARAMS,
          "Emojis popup items require non-empty id, emoji, and emoji_name.",
        )
      }

      return ReactionPopupItemPayload(
        id = id,
        emoji = emoji,
        emojiName = emojiName,
      )
    }
  }
}

data class ReactionPopupHaptics(
  val onOpen: Boolean = false,
  val onPlus: Boolean = false,
  val onSelect: Boolean = false,
) {
  companion object {
    fun fromMap(map: Map<String, Any?>?): ReactionPopupHaptics =
      ReactionPopupHaptics(
        onOpen = map?.get("onOpen") as? Boolean ?: false,
        onPlus = map?.get("onPlus") as? Boolean ?: false,
        onSelect = map?.get("onSelect") as? Boolean ?: false,
      )
  }
}

data class ReactionPopupAnimation(
  val emojiPopScale: Float = 1.12f,
  val itemStaggerMs: Long = 18L,
  val openDurationMs: Long = 180L,
  val trayInitialScale: Float = 0.96f,
) {
  companion object {
    fun fromMap(map: Map<String, Any?>?): ReactionPopupAnimation =
      ReactionPopupAnimation(
        emojiPopScale = (map?.get("emojiPopScale") as? Number)?.toFloat() ?: 1.12f,
        itemStaggerMs = (map?.get("itemStaggerMs") as? Number)?.toLong() ?: 18L,
        openDurationMs = (map?.get("openDurationMs") as? Number)?.toLong() ?: 180L,
        trayInitialScale = (map?.get("trayInitialScale") as? Number)?.toFloat() ?: 0.96f,
      )
  }
}

data class ReactionPopupStyle(
  val backgroundColor: Int = colorOrNull(null) ?: Color.parseColor("#1F1F1F"),
  val backdropColor: Int = colorOrNull(null) ?: Color.BLACK,
  val backdropOpacity: Float = 0.16f,
  val borderColor: Int = Color.TRANSPARENT,
  val borderRadius: Float = 28f,
  val borderWidth: Float = 0f,
  val elevation: Float = 10f,
  val emojiFontSize: Float = 26f,
  val gap: Float = 10f,
  val itemBackgroundColor: Int = Color.TRANSPARENT,
  val itemBorderColor: Int = Color.TRANSPARENT,
  val itemBorderRadius: Float = 20f,
  val itemBorderWidth: Float = 0f,
  val itemPressedBackgroundColor: Int = Color.argb(31, 255, 255, 255),
  val itemSelectedBackgroundColor: Int = Color.argb(36, 255, 255, 255),
  val itemSize: Float = 40f,
  val paddingHorizontal: Float = 12f,
  val paddingVertical: Float = 10f,
  val plusBackgroundColor: Int = Color.argb(20, 255, 255, 255),
  val plusIconColor: Int = Color.parseColor("#AFAFAF"),
  val plusPressedBackgroundColor: Int = Color.argb(41, 255, 255, 255),
  val shadowColor: Int = Color.BLACK,
  val hoverScale: Float = 1.6f,
  val hoverTranslationY: Float = 14f,
  val hoverLabelBackgroundColor: Int = Color.argb(192, 0, 0, 0),
  val hoverLabelBorderRadius: Float = 10f,
  val hoverLabelColor: Int = Color.WHITE,
  val hoverLabelFontSize: Float = 12f,
  val hoverLabelPaddingHorizontal: Float = 8f,
  val hoverLabelPaddingVertical: Float = 4f,
) {
  companion object {
    fun fromMap(map: Map<String, Any?>?): ReactionPopupStyle {
      val parsedEmojiFontSize = (map?.get("emojiFontSize") as? Number)?.toFloat() ?: 26f
      return ReactionPopupStyle(
        backgroundColor = colorOrNull(map?.get("backgroundColor") as? String)
          ?: Color.parseColor("#1F1F1F"),
        backdropColor = colorOrNull(map?.get("backdropColor") as? String)
          ?: Color.BLACK,
        backdropOpacity = (map?.get("backdropOpacity") as? Number)?.toFloat() ?: 0.16f,
        borderColor = colorOrNull(map?.get("borderColor") as? String) ?: Color.TRANSPARENT,
        borderRadius = (map?.get("borderRadius") as? Number)?.toFloat() ?: 28f,
        borderWidth = (map?.get("borderWidth") as? Number)?.toFloat() ?: 0f,
        elevation = (map?.get("elevation") as? Number)?.toFloat() ?: 10f,
        emojiFontSize = parsedEmojiFontSize,
        gap = (map?.get("gap") as? Number)?.toFloat() ?: 10f,
        itemBackgroundColor = colorOrNull(map?.get("itemBackgroundColor") as? String)
          ?: Color.TRANSPARENT,
        itemBorderColor = colorOrNull(map?.get("itemBorderColor") as? String)
          ?: Color.TRANSPARENT,
        itemBorderRadius = (map?.get("itemBorderRadius") as? Number)?.toFloat() ?: 20f,
        itemBorderWidth = (map?.get("itemBorderWidth") as? Number)?.toFloat() ?: 0f,
        itemPressedBackgroundColor = colorOrNull(map?.get("itemPressedBackgroundColor") as? String)
          ?: Color.argb(31, 255, 255, 255),
        itemSelectedBackgroundColor = colorOrNull(map?.get("itemSelectedBackgroundColor") as? String)
          ?: Color.argb(36, 255, 255, 255),
        itemSize = (map?.get("itemSize") as? Number)?.toFloat() ?: (parsedEmojiFontSize + 16f),
        paddingHorizontal = (map?.get("paddingHorizontal") as? Number)?.toFloat() ?: 12f,
        paddingVertical = (map?.get("paddingVertical") as? Number)?.toFloat() ?: 10f,
        plusBackgroundColor = colorOrNull(map?.get("plusBackgroundColor") as? String)
          ?: Color.argb(20, 255, 255, 255),
        plusIconColor = colorOrNull(map?.get("plusIconColor") as? String)
          ?: Color.parseColor("#AFAFAF"),
        plusPressedBackgroundColor = colorOrNull(map?.get("plusPressedBackgroundColor") as? String)
          ?: Color.argb(41, 255, 255, 255),
        shadowColor = colorOrNull(map?.get("shadowColor") as? String) ?: Color.BLACK,
        hoverScale = (map?.get("hoverScale") as? Number)?.toFloat() ?: 1.6f,
        hoverTranslationY = (map?.get("hoverTranslationY") as? Number)?.toFloat() ?: 14f,
        hoverLabelBackgroundColor = colorOrNull(map?.get("hoverLabelBackgroundColor") as? String)
          ?: Color.argb(192, 0, 0, 0),
        hoverLabelBorderRadius = (map?.get("hoverLabelBorderRadius") as? Number)?.toFloat() ?: 10f,
        hoverLabelColor = colorOrNull(map?.get("hoverLabelColor") as? String) ?: Color.WHITE,
        hoverLabelFontSize = (map?.get("hoverLabelFontSize") as? Number)?.toFloat() ?: 12f,
        hoverLabelPaddingHorizontal = (map?.get("hoverLabelPaddingHorizontal") as? Number)?.toFloat() ?: 8f,
        hoverLabelPaddingVertical = (map?.get("hoverLabelPaddingVertical") as? Number)?.toFloat() ?: 4f,
      )
    }
  }
}

data class ReactionPopupShowParams(
  val anchorId: String,
  val items: List<ReactionPopupItemPayload>,
  val selectedId: String?,
  val centerOnScreen: Boolean,
  val dismissOnBackdropPress: Boolean,
  val dismissOnDragOut: Boolean,
  val edgePadding: Float,
  val plusEnabled: Boolean,
  val plusAccessibilityLabel: String,
  val preferredPlacement: ReactionPopupPlacement,
  val showLabels: Boolean,
  val hideLabelsInSafeArea: Boolean,
  val haptics: ReactionPopupHaptics,
  val animation: ReactionPopupAnimation,
  val style: ReactionPopupStyle,
) {
  companion object {
    fun fromMap(map: Map<String, Any?>): ReactionPopupShowParams {
      val anchorId = (map["anchorId"] as? String)?.trim().orEmpty()
      if (anchorId.isEmpty()) {
        throw EmojisPopupException(
          EmojisPopupErrorCode.INVALID_PARAMS,
          "Emojis popup requires a non-empty anchorId.",
        )
      }

      val rawItems = map["items"] as? List<Map<String, Any?>>
      if (rawItems.isNullOrEmpty()) {
        throw EmojisPopupException(
          EmojisPopupErrorCode.EMPTY_ITEMS,
          "Emojis popup requires at least one item.",
        )
      }

      return ReactionPopupShowParams(
        anchorId = anchorId,
        items = rawItems.map(ReactionPopupItemPayload::fromMap),
        selectedId = map["selectedId"] as? String,
        centerOnScreen = map["centerOnScreen"] as? Boolean ?: false,
        dismissOnBackdropPress = map["dismissOnBackdropPress"] as? Boolean ?: true,
        dismissOnDragOut = map["dismissOnDragOut"] as? Boolean ?: false,
        edgePadding = (map["edgePadding"] as? Number)?.toFloat() ?: 12f,
        plusEnabled = map["plusEnabled"] as? Boolean ?: false,
        plusAccessibilityLabel = ((map["plusAccessibilityLabel"] as? String)?.trim())
          ?.takeIf { it.isNotEmpty() }
          ?: "More reactions",
        preferredPlacement = ReactionPopupPlacement.from(map["preferredPlacement"] as? String),
        showLabels = map["showLabels"] as? Boolean ?: true,
        hideLabelsInSafeArea = map["hideLabelsInSafeArea"] as? Boolean ?: true,
        haptics = ReactionPopupHaptics.fromMap(map["haptics"] as? Map<String, Any?>),
        animation = ReactionPopupAnimation.fromMap(map["animation"] as? Map<String, Any?>),
        style = ReactionPopupStyle.fromMap(map["style"] as? Map<String, Any?>),
      )
    }
  }
}

private fun colorOrNull(value: String?): Int? {
  val normalized = value?.trim()?.takeIf { it.isNotEmpty() } ?: return null
  val hex = normalized.removePrefix("#")
  // All inputs treated as RRGGBB or RRGGBBAA (matching iOS convention).
  // Color.parseColor expects #AARRGGBB, so we reorder when alpha is present.
  val expanded = when (hex.length) {
    3 -> "#FF${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}"
    4 -> "#${hex[3]}${hex[3]}${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}"
    6 -> "#FF$hex"
    8 -> "#${hex.substring(6, 8)}${hex.substring(0, 6)}"
    else -> return null
  }
  return runCatching { Color.parseColor(expanded) }.getOrNull()
}
