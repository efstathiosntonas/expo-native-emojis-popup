package expo.modules.nativeemojispopup

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout

class ReactionPopupOverlayView(
  context: Context,
  private val params: ReactionPopupShowParams,
  val contentView: ReactionPopupLayout,
) : FrameLayout(context) {
  var onBackdropTap: (() -> Unit)? = null

  private val backdropView =
    View(context).apply {
      setBackgroundColor(
        Color.argb(
          (params.style.backdropOpacity * 255).toInt().coerceIn(0, 255),
          Color.red(params.style.backdropColor),
          Color.green(params.style.backdropColor),
          Color.blue(params.style.backdropColor),
        ),
      )
      // Start non-interactive; enabled after animateIn() to avoid stray touch-ups
      // dismissing the popup immediately (matches iOS behaviour).
      isClickable = false
      importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
      setOnClickListener { onBackdropTap?.invoke() }
      layoutParams =
        LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
    }

  init {
    layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
    clipChildren = false
    clipToPadding = false
    addView(backdropView)
    addView(contentView)
  }

  fun enableBackdropDismiss(handler: () -> Unit) {
    onBackdropTap = handler
    backdropView.isClickable = true
    backdropView.contentDescription = "Dismiss reactions"
    backdropView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
  }

  fun setTrayPosition(left: Int, top: Int) {
    contentView.layoutParams =
      LayoutParams(contentView.preferredWidth(), contentView.preferredHeight()).apply {
        this.leftMargin = left
        this.topMargin = top
      }
  }

  fun animateIn() {
    alpha = 0f
    animate()
      .alpha(1f)
      .setDuration(params.animation.openDurationMs)
      .withEndAction {
        if (params.dismissOnBackdropPress) {
          backdropView.isClickable = true
          backdropView.contentDescription = "Dismiss reactions"
          backdropView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        }
      }
      .start()
    contentView.animateIn()
  }

  fun animateOut(onEnd: () -> Unit) {
    backdropView.isClickable = false
    contentView.isEnabled = false
    animate()
      .alpha(0f)
      .setDuration(150L)
      .withEndAction(onEnd)
      .start()
    contentView.animateOut {}
  }
}
