package expo.modules.nativeemojispopup

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import android.widget.HorizontalScrollView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.view.children
import androidx.dynamicanimation.animation.DynamicAnimation
import androidx.dynamicanimation.animation.SpringAnimation
import androidx.dynamicanimation.animation.SpringForce

class ReactionPopupLayout(
  context: Context,
  private val params: ReactionPopupShowParams,
) : FrameLayout(context) {
  var onSelect: ((String) -> Unit)? = null
  var onPlus: (() -> Unit)? = null

  private data class TargetSpec(
    val view: TextView,
    val baseColor: Int,
    val pressedColor: Int,
    val onActivate: () -> Unit,
  )

  private val targets = mutableListOf<TargetSpec>()
  private val targetNames = mutableMapOf<TargetSpec, String>()
  private var activeTarget: TargetSpec? = null
  private var hoveredTarget: TargetSpec? = null
  private val runningAnimations = mutableMapOf<Pair<View, DynamicAnimation.ViewProperty>, SpringAnimation>()
  private var originalScreenLocations: List<IntArray>? = null
  private lateinit var hoverLabelView: TextView
  val hoveredItemId: String?
    get() = hoveredTarget?.let { target ->
      targets.indexOfFirst { it === target }.let { index ->
        if (index < 0) null
        else if (index < params.items.size) params.items[index].id
        else if (params.plusEnabled && index == targets.lastIndex) "__plus__"
        else null
      }
    }

  init {
    layoutParams = LayoutParams(preferredWidth(), preferredHeight())
    clipChildren = false
    clipToPadding = false
    elevation = params.style.elevation
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
      outlineAmbientShadowColor = params.style.shadowColor
      outlineSpotShadowColor = params.style.shadowColor
    }
    background = GradientDrawable().apply {
      shape = GradientDrawable.RECTANGLE
      cornerRadius = dp(params.style.borderRadius).toFloat()
      setColor(params.style.backgroundColor)
      setStroke(dp(params.style.borderWidth), params.style.borderColor)
    }
    setPadding(
      dp(params.style.paddingHorizontal),
      dp(params.style.paddingVertical),
      dp(params.style.paddingHorizontal),
      dp(params.style.paddingVertical),
    )

    val scrollView = HorizontalScrollView(context).apply {
      isHorizontalScrollBarEnabled = false
      clipChildren = false
      clipToPadding = false
      layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
    }

    val row = LinearLayout(context).apply {
      orientation = LinearLayout.HORIZONTAL
      gravity = Gravity.CENTER_VERTICAL
      clipChildren = false
      clipToPadding = false
      showDividers = LinearLayout.SHOW_DIVIDER_MIDDLE
      dividerDrawable = null
      layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
    }

    scrollView.addView(row)
    addView(scrollView)

    params.items.forEachIndexed { index, item ->
      row.addView(makeEmojiTarget(item))
      if (index != params.items.lastIndex || params.plusEnabled) {
        (row.getChildAt(row.childCount - 1).layoutParams as MarginLayoutParams).marginEnd =
          dp(params.style.gap)
      }
    }

    if (params.plusEnabled) {
      row.addView(makePlusTarget())
    }

    hoverLabelView = TextView(context).apply {
      setTextColor(params.style.hoverLabelColor)
      textSize = params.style.hoverLabelFontSize
      typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
      gravity = Gravity.CENTER
      setPadding(
        dp(params.style.hoverLabelPaddingHorizontal),
        dp(params.style.hoverLabelPaddingVertical),
        dp(params.style.hoverLabelPaddingHorizontal),
        dp(params.style.hoverLabelPaddingVertical),
      )
      background = GradientDrawable().apply {
        shape = GradientDrawable.RECTANGLE
        cornerRadius = dp(params.style.hoverLabelBorderRadius).toFloat()
        setColor(params.style.hoverLabelBackgroundColor)
      }
      alpha = 0f
      layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
    }
    addView(hoverLabelView)

    setupAccessibility()
  }

  fun animateIn() {
    val startScale = params.animation.trayInitialScale
    alpha = 0f
    scaleX = startScale
    scaleY = startScale
    animate()
      .alpha(1f)
      .scaleX(1f)
      .scaleY(1f)
      .setDuration(params.animation.openDurationMs)
      .start()

    val popScale = params.animation.emojiPopScale
    targets.forEachIndexed { index, target ->
      target.view.alpha = 0f
      target.view.translationY = dp(8f).toFloat()
      target.view.scaleX = 0.88f
      target.view.scaleY = 0.88f
      val delay = index * params.animation.itemStaggerMs
      val duration = 160L

      // Phase 1: fade in + scale up to popScale + translate
      target.view.animate()
        .alpha(1f)
        .translationY(0f)
        .scaleX(popScale)
        .scaleY(popScale)
        .setStartDelay(delay)
        .setDuration((duration * 0.68).toLong())
        .withEndAction {
          // Phase 2: settle back to 1.0
          target.view.animate()
            .scaleX(1f)
            .scaleY(1f)
            .setDuration((duration * 0.32).toLong())
            .start()
        }
        .start()
    }
  }

  fun animateOut(onEnd: () -> Unit) {
    animate()
      .alpha(0f)
      .setDuration(150L)
      .withEndAction(onEnd)
      .start()
  }

  fun preferredWidth(): Int {
    val itemCount = params.items.size + if (params.plusEnabled) 1 else 0
    val fullWidth = dp(params.style.paddingHorizontal) * 2 +
      itemCount * dp(params.style.itemSize) +
      (itemCount - 1).coerceAtLeast(0) * dp(params.style.gap)
    val screenWidth = resources.displayMetrics.widthPixels
    val maxWidth = screenWidth - dp(params.edgePadding) * 2
    return fullWidth.coerceAtMost(maxWidth)
  }

  fun preferredHeight(): Int =
    dp(params.style.paddingVertical) * 2 + dp(params.style.itemSize)

  @SuppressLint("ClickableViewAccessibility")
  override fun onTouchEvent(event: MotionEvent): Boolean {
    when (event.actionMasked) {
      MotionEvent.ACTION_DOWN, MotionEvent.ACTION_MOVE -> {
        val target = targetAt(event.rawX, event.rawY)
        updateActiveTarget(target)
        return true
      }

      MotionEvent.ACTION_UP -> {
        val target = targetAt(event.rawX, event.rawY) ?: activeTarget
        updateActiveTarget(null)
        target?.onActivate?.invoke()
        return true
      }

      MotionEvent.ACTION_CANCEL -> {
        updateActiveTarget(null)
        return true
      }
    }

    return super.onTouchEvent(event)
  }

  private fun makeEmojiTarget(item: ReactionPopupItemPayload): TextView {
    val baseColor =
      if (item.id == params.selectedId) {
        params.style.itemSelectedBackgroundColor
      } else {
        params.style.itemBackgroundColor
      }

    return makeTargetView(
      title = item.emoji,
      accessibilityLabel = item.emojiName,
      baseColor = baseColor,
      pressedColor = params.style.itemPressedBackgroundColor,
      textColor = 0xFF000000.toInt(),
      onActivate = { onSelect?.invoke(item.id) },
    )
  }

  private fun makePlusTarget(): TextView =
    makeTargetView(
      title = "+",
      accessibilityLabel = params.plusAccessibilityLabel,
      baseColor = params.style.plusBackgroundColor,
      pressedColor = params.style.plusPressedBackgroundColor,
      textColor = params.style.plusIconColor,
      onActivate = { onPlus?.invoke() },
    )

  private fun makeTargetView(
    title: String,
    accessibilityLabel: String,
    baseColor: Int,
    pressedColor: Int,
    textColor: Int,
    onActivate: () -> Unit,
  ): TextView {
    val view = TextView(context).apply {
      gravity = Gravity.CENTER
      text = title
      textSize = params.style.emojiFontSize
      typeface = Typeface.DEFAULT
      contentDescription = accessibilityLabel
      isFocusable = true
      isClickable = true
      importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
      setTextColor(textColor)
      background = targetBackground(baseColor)
      layoutParams = MarginLayoutParams(dp(params.style.itemSize), dp(params.style.itemSize))
      setOnClickListener { onActivate() }
    }

    val spec = TargetSpec(
      view = view,
      baseColor = baseColor,
      pressedColor = pressedColor,
      onActivate = onActivate,
    )
    targets.add(spec)
    targetNames[spec] = accessibilityLabel

    return view
  }

  fun updateHover(rawX: Float, rawY: Float): String? {
    val target = targetAt(rawX, rawY)
    if (target != null || !isWithinTrayBounds(rawX, rawY)) {
      setHoveredTarget(target)
    }
    return hoveredItemId
  }

  private fun isWithinTrayBounds(rawX: Float, rawY: Float): Boolean {
    val location = IntArray(2)
    getLocationOnScreen(location)
    val margin = dp(12f)
    return rawX >= location[0] - margin &&
      rawX <= location[0] + width + margin &&
      rawY >= location[1] - margin &&
      rawY <= location[1] + height + margin
  }

  fun clearHover() {
    setHoveredTarget(null)
    originalScreenLocations = null
  }

  private fun setHoveredTarget(target: TargetSpec?) {
    if (hoveredTarget === target) return

    val previous = hoveredTarget
    hoveredTarget = target

    if (target != null) {
      performHapticFeedback(HapticFeedbackConstants.CLOCK_TICK)
    }

    val scale = params.style.hoverScale
    val transY = -dp(params.style.hoverTranslationY).toFloat()

    if (previous != null) {
      animateSpring(previous.view, DynamicAnimation.SCALE_X, 1f)
      animateSpring(previous.view, DynamicAnimation.SCALE_Y, 1f)
      animateSpring(previous.view, DynamicAnimation.TRANSLATION_Y, 0f)
    }

    if (target != null) {
      animateSpring(target.view, DynamicAnimation.SCALE_X, scale, stiffness = 600f, damping = 0.55f)
      animateSpring(target.view, DynamicAnimation.SCALE_Y, scale, stiffness = 600f, damping = 0.55f)
      animateSpring(target.view, DynamicAnimation.TRANSLATION_Y, transY, stiffness = 600f, damping = 0.55f)
    }

    updateHoverLabel(target)
  }

  private fun updateHoverLabel(target: TargetSpec?) {
    val name = target?.let { targetNames[it] }
    val isPlusButton = target != null && targets.indexOf(target) == targets.lastIndex && params.plusEnabled

    if (name == null || isPlusButton) {
      hoverLabelView.animate().alpha(0f).setDuration(100).start()
      return
    }

    hoverLabelView.text = name
    hoverLabelView.measure(
      View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
      View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
    )

    val targetView = target.view
    val targetCenterX = targetView.left + targetView.width / 2f
    val targetCenterY = targetView.top + targetView.height / 2f

    val animatedCenterY = targetCenterY - dp(params.style.hoverTranslationY).toFloat()
    // Use emoji font size (not item size) for tighter label-to-glyph spacing
    val scaledHalfGlyph = (dp(params.style.emojiFontSize).toFloat() * params.style.hoverScale) / 2f
    val visualTop = animatedCenterY - scaledHalfGlyph

    hoverLabelView.translationX = targetCenterX - hoverLabelView.measuredWidth / 2f
    hoverLabelView.translationY = visualTop - hoverLabelView.measuredHeight - dp(4f).toFloat()
    hoverLabelView.animate().alpha(1f).setDuration(150).start()
  }

  private fun animateSpring(
    view: View,
    property: DynamicAnimation.ViewProperty,
    targetValue: Float,
    stiffness: Float = 800f,
    damping: Float = 0.7f,
  ) {
    val key = view to property
    runningAnimations[key]?.cancel()

    val durationScale = android.provider.Settings.Global.getFloat(
      context.contentResolver,
      android.provider.Settings.Global.ANIMATOR_DURATION_SCALE,
      1f
    )
    if (durationScale == 0f) {
      property.setValue(view, targetValue)
      runningAnimations.remove(key)
      return
    }

    val anim = SpringAnimation(view, property, targetValue).apply {
      spring = SpringForce(targetValue).apply {
        this.stiffness = stiffness
        this.dampingRatio = damping
      }
      addEndListener { _, _, _, _ -> runningAnimations.remove(key) }
      start()
    }
    runningAnimations[key] = anim
  }

  private fun captureOriginalLocations(): List<IntArray> {
    return targets.map { target ->
      val loc = IntArray(2)
      val parentLoc = IntArray(2)
      (target.view.parent as? View)?.getLocationOnScreen(parentLoc)
      loc[0] = parentLoc[0] + target.view.left
      loc[1] = parentLoc[1] + target.view.top
      loc
    }
  }

  private fun targetAt(rawX: Float, rawY: Float): TargetSpec? {
    val locations = originalScreenLocations ?: captureOriginalLocations().also {
      originalScreenLocations = it
    }

    val margin = dp(4f)
    return targets.indices.firstOrNull { index ->
      val loc = locations[index]
      val target = targets[index]
      rawX >= loc[0] - margin &&
        rawX <= loc[0] + target.view.width + margin &&
        rawY >= loc[1] - margin &&
        rawY <= loc[1] + target.view.height + margin
    }?.let { targets[it] }
  }

  private fun updateActiveTarget(target: TargetSpec?) {
    if (activeTarget === target) {
      return
    }

    activeTarget = target
    targets.forEach { spec ->
      val color = if (spec === target) spec.pressedColor else spec.baseColor
      spec.view.background = targetBackground(color)
    }
  }

  private fun targetBackground(color: Int) =
    GradientDrawable().apply {
      shape = GradientDrawable.RECTANGLE
      cornerRadius = dp(params.style.itemBorderRadius).toFloat()
      setColor(color)
      setStroke(dp(params.style.itemBorderWidth), params.style.itemBorderColor)
    }

  private fun setupAccessibility() {
    children.forEach { it.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO }
  }

  private fun dp(value: Float): Int =
    (value * resources.displayMetrics.density).toInt()
}
