package expo.modules.nativeemojispopup

import android.app.Activity
import android.graphics.Rect
import android.os.Build
import android.view.HapticFeedbackConstants
import android.view.View
import android.view.ViewGroup
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.ViewCompat
import kotlinx.coroutines.CancellableContinuation
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext

object ReactionPopupPresenter {
  private var activeOverlayView: ReactionPopupOverlayView? = null
  private var activeContinuation: CancellableContinuation<Map<String, Any?>>? = null

  suspend fun show(
    activity: Activity?,
    params: ReactionPopupShowParams,
  ): Map<String, Any?> =
    withContext(Dispatchers.Main.immediate) {
      dismissCurrent(animated = false, result = mapOf("type" to "dismiss"))

      val currentActivity =
        activity
          ?: throw EmojisPopupException(
            EmojisPopupErrorCode.PRESENTATION_FAILED,
            "Emojis popup requires an active activity.",
          )
      val contentRoot =
        currentActivity.window?.decorView as? ViewGroup
          ?: throw EmojisPopupException(
            EmojisPopupErrorCode.PRESENTATION_FAILED,
            "Emojis popup could not resolve the activity content root.",
          )
      val anchorView =
        EmojisPopupWrapper.anchorView(params.anchorId)
          ?: throw EmojisPopupException(
            EmojisPopupErrorCode.ANCHOR_NOT_FOUND,
            "No emojis popup anchor is registered for ${params.anchorId}.",
          )

      val anchorRect = Rect()
      val isVisible = anchorView.getGlobalVisibleRect(anchorRect)
      if (!isVisible || anchorRect.width() <= 0 || anchorRect.height() <= 0) {
        throw EmojisPopupException(
          EmojisPopupErrorCode.ANCHOR_NOT_MEASURABLE,
          "Emojis popup anchor could not be measured.",
        )
      }

      val contentView = ReactionPopupLayout(contentRoot.context, params)
      val overlayView = ReactionPopupOverlayView(contentRoot.context, params, contentView)
      val trayPosition = computeTrayPosition(contentRoot, contentView, anchorRect, params)
      overlayView.setTrayPosition(trayPosition.first, trayPosition.second)

      contentView.onSelect = { id ->
        triggerHapticIfNeeded(contentView, params, kind = HapticKind.SELECT)
        dismissCurrent(animated = true, result = mapOf("type" to "select", "id" to id))
      }
      contentView.onPlus = {
        triggerHapticIfNeeded(contentView, params, kind = HapticKind.PLUS)
        dismissCurrent(animated = true, result = mapOf("type" to "plus"))
      }
      overlayView.onBackdropTap = {
        if (params.dismissOnBackdropPress) {
          dismissCurrent(animated = true, result = mapOf("type" to "dismiss"))
        }
      }

      contentRoot.addView(overlayView)
      activeOverlayView = overlayView
      triggerHapticIfNeeded(contentView, params, kind = HapticKind.OPEN)
      overlayView.animateIn()

      suspendCancellableCoroutine { continuation ->
        activeContinuation = continuation
        continuation.invokeOnCancellation {
          activeContinuation = null
          activeOverlayView?.let { overlay ->
            activeOverlayView = null
            overlay.post { overlay.removeFromParent() }
          }
        }
      }
    }

  data class DragResult(val type: String, val id: String?)

  fun showForDrag(activity: Activity?, params: ReactionPopupShowParams) {
    dismissCurrent(animated = false, result = mapOf("type" to "dismiss"))

    val currentActivity = activity ?: return
    val contentRoot = currentActivity.window?.decorView as? ViewGroup ?: return
    val anchorView = EmojisPopupWrapper.anchorView(params.anchorId) ?: return

    val anchorRect = Rect()
    val isVisible = anchorView.getGlobalVisibleRect(anchorRect)
    if (!isVisible || anchorRect.width() <= 0 || anchorRect.height() <= 0) return

    val contentView = ReactionPopupLayout(contentRoot.context, params)
    val overlayView = ReactionPopupOverlayView(contentRoot.context, params, contentView)
    val trayPosition = computeTrayPosition(contentRoot, contentView, anchorRect, params)
    overlayView.setTrayPosition(trayPosition.first, trayPosition.second)

    contentView.onSelect = { }
    contentView.onPlus = { }
    overlayView.onBackdropTap = { }

    contentRoot.addView(overlayView)
    activeOverlayView = overlayView
    triggerHapticIfNeeded(contentView, params, kind = HapticKind.OPEN)
    overlayView.animateIn()
  }

  fun updateDragPosition(rawX: Float, rawY: Float): String? {
    val overlayView = activeOverlayView ?: return null
    return overlayView.contentView.updateHover(rawX, rawY)
  }

  fun endDrag(params: ReactionPopupShowParams): DragResult {
    val overlayView = activeOverlayView ?: return DragResult("dismiss", null)
    val hoveredId = overlayView.contentView.hoveredItemId

    overlayView.contentView.clearHover()

    if (hoveredId == "__plus__") {
      triggerHapticIfNeeded(overlayView.contentView, params, kind = HapticKind.PLUS)
      dismissCurrent(animated = true, result = mapOf("type" to "plus"))
      return DragResult("plus", null)
    }

    if (hoveredId != null) {
      triggerHapticIfNeeded(overlayView.contentView, params, kind = HapticKind.SELECT)
      dismissCurrent(animated = true, result = mapOf("type" to "select", "id" to hoveredId))
      return DragResult("select", hoveredId)
    }

    if (params.dismissOnDragOut) {
      dismissCurrent(animated = true, result = mapOf("type" to "dismiss"))
      return DragResult("dismiss", null)
    }

    return DragResult("stayOpen", null)
  }

  fun convertDragToTapMode(
    params: ReactionPopupShowParams,
    onSelect: (String) -> Unit,
    onPlus: () -> Unit,
    onDismiss: () -> Unit,
  ) {
    val overlayView = activeOverlayView ?: run { onDismiss(); return }

    overlayView.contentView.onSelect = { id ->
      if (activeOverlayView != null) {
        triggerHapticIfNeeded(overlayView.contentView, params, kind = HapticKind.SELECT)
        dismissCurrent(animated = true, result = mapOf("type" to "select", "id" to id))
        onSelect(id)
      }
    }
    overlayView.contentView.onPlus = {
      if (activeOverlayView != null) {
        triggerHapticIfNeeded(overlayView.contentView, params, kind = HapticKind.PLUS)
        dismissCurrent(animated = true, result = mapOf("type" to "plus"))
        onPlus()
      }
    }
    overlayView.enableBackdropDismiss {
      if (activeOverlayView != null) {
        dismissCurrent(animated = true, result = mapOf("type" to "dismiss"))
        onDismiss()
      }
    }
  }

  fun cancelDrag() {
    activeOverlayView?.contentView?.clearHover()
    dismissCurrent(animated = true, result = mapOf("type" to "dismiss"))
  }

  suspend fun dismiss() {
    withContext(Dispatchers.Main.immediate) {
      dismissCurrent(animated = true, result = mapOf("type" to "dismiss"))
    }
  }

  private fun dismissCurrent(animated: Boolean, result: Map<String, Any?>) {
    val overlayView = activeOverlayView
    val continuation = activeContinuation

    activeOverlayView = null
    activeContinuation = null

    if (overlayView == null) {
      if (continuation != null && continuation.isActive) {
        continuation.resumeWith(Result.success(result))
      }
      return
    }

    val finish: () -> Unit = {
      overlayView.removeFromParent()
      if (continuation != null && continuation.isActive) {
        continuation.resumeWith(Result.success(result))
      }
    }

    if (animated) {
      overlayView.animateOut(onEnd = finish)
    } else {
      finish()
    }
  }

  private fun computeTrayPosition(
    contentRoot: ViewGroup,
    contentView: ReactionPopupLayout,
    anchorRect: Rect,
    params: ReactionPopupShowParams,
  ): Pair<Int, Int> {
    val insets =
      ViewCompat.getRootWindowInsets(contentRoot)
        ?.getInsets(WindowInsetsCompat.Type.systemBars())
    val leftInset = insets?.left ?: 0
    val topInset = insets?.top ?: 0
    val rightInset = insets?.right ?: 0
    val bottomInset = insets?.bottom ?: 0

    val trayWidth = contentView.preferredWidth()
    val trayHeight = contentView.preferredHeight()
    val edgePadding = dp(contentRoot, params.edgePadding)
    val minLeft = leftInset + edgePadding
    val maxLeft = contentRoot.width - rightInset - edgePadding - trayWidth
    val centeredLeft = if (params.centerOnScreen) {
      (contentRoot.width - trayWidth) / 2
    } else {
      anchorRect.centerX() - trayWidth / 2
    }
    val clampedLeft = centeredLeft.coerceIn(minLeft, maxLeft.coerceAtLeast(minLeft))

    val gap = dp(contentRoot, 8f)
    val availableAbove = anchorRect.top - topInset - edgePadding - gap
    val availableBelow = contentRoot.height - bottomInset - edgePadding - anchorRect.bottom - gap

    val placeAbove =
      when (params.preferredPlacement) {
        ReactionPopupPlacement.ABOVE -> true
        ReactionPopupPlacement.BELOW -> false
        ReactionPopupPlacement.AUTO ->
          when {
            availableAbove >= trayHeight -> true
            availableBelow >= trayHeight -> false
            else -> availableAbove >= availableBelow
          }
      }

    val proposedTop =
      if (placeAbove) {
        anchorRect.top - trayHeight - gap
      } else {
        anchorRect.bottom + gap
      }
    val minTop = topInset + edgePadding
    val maxTop = contentRoot.height - bottomInset - edgePadding - trayHeight
    val clampedTop = proposedTop.coerceIn(minTop, maxTop.coerceAtLeast(minTop))

    return clampedLeft to clampedTop
  }

  private fun triggerHapticIfNeeded(
    view: View,
    params: ReactionPopupShowParams,
    kind: HapticKind,
  ) {
    val enabled =
      when (kind) {
        HapticKind.OPEN -> params.haptics.onOpen
        HapticKind.PLUS -> params.haptics.onPlus
        HapticKind.SELECT -> params.haptics.onSelect
      }

    if (!enabled) {
      return
    }

    val constant =
      when (kind) {
        HapticKind.OPEN -> HapticFeedbackConstants.LONG_PRESS
        HapticKind.PLUS -> HapticFeedbackConstants.KEYBOARD_TAP
        HapticKind.SELECT ->
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            HapticFeedbackConstants.CONFIRM
          } else {
            HapticFeedbackConstants.KEYBOARD_TAP
          }
      }

    view.performHapticFeedback(constant)
  }

  private fun dp(view: View, value: Float): Int =
    (value * view.resources.displayMetrics.density).toInt()

  private enum class HapticKind {
    OPEN,
    PLUS,
    SELECT,
  }
}

private fun View.removeFromParent() {
  (parent as? ViewGroup)?.removeView(this)
}
