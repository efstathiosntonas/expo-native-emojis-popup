package expo.modules.nativeemojispopup

import android.animation.ValueAnimator
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
  private var animationGeneration = 0

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
      setOnClickListener { onBackdropTap?.invoke() }
      // setOnClickListener marks the view clickable, so disable it after
      // attaching the listener. It is enabled only after animateIn() finishes.
      isEnabled = false
      isClickable = false
      contentDescription = null
      importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
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
    setBackdropDismissEnabled(true)
  }

  fun setTrayPosition(left: Int, top: Int) {
    contentView.layoutParams =
      LayoutParams(contentView.preferredWidth(), contentView.preferredHeight()).apply {
        this.leftMargin = left
        this.topMargin = top
      }
  }

  fun animateIn() {
    val generation = ++animationGeneration
    setBackdropDismissEnabled(false)
    alpha = 0f
    animateOverlayAlpha(
      targetAlpha = 1f,
      durationMs = params.animation.openDurationMs,
      generation = generation,
    ) {
      if (generation == animationGeneration) {
        if (params.dismissOnBackdropPress) {
          setBackdropDismissEnabled(true)
        }
      }
    }
    contentView.animateIn()
  }

  fun animateOut(onEnd: () -> Unit) {
    val generation = ++animationGeneration
    setBackdropDismissEnabled(false)
    contentView.isEnabled = false
    animateOverlayAlpha(
      targetAlpha = 0f,
      durationMs = CLOSE_DURATION_MS,
      generation = generation,
      onEnd = onEnd,
    )
    contentView.animateOut {}
  }

  private fun setBackdropDismissEnabled(enabled: Boolean) {
    backdropView.isEnabled = enabled
    backdropView.isClickable = enabled

    if (enabled) {
      backdropView.contentDescription = "Dismiss reactions"
      backdropView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
    } else {
      backdropView.contentDescription = null
      backdropView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }
  }

  private fun animateOverlayAlpha(
    targetAlpha: Float,
    durationMs: Long,
    generation: Int,
    onEnd: () -> Unit,
  ) {
    animate().cancel()

    if (durationMs <= 0L || !ValueAnimator.areAnimatorsEnabled()) {
      alpha = targetAlpha
      onEnd()
      return
    }

    var didEnd = false
    val finishOnce = {
      if (!didEnd && generation == animationGeneration) {
        didEnd = true
        alpha = targetAlpha
        onEnd()
      }
    }

    animate()
      .alpha(targetAlpha)
      .setDuration(durationMs)
      .withEndAction { finishOnce() }
      .start()

    postDelayed({ finishOnce() }, durationMs + ANIMATION_END_FALLBACK_MS)
  }

  companion object {
    private const val CLOSE_DURATION_MS = 150L
    private const val ANIMATION_END_FALLBACK_MS = 80L
  }
}
