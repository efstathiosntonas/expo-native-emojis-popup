package expo.modules.nativeemojispopup

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.ViewConfiguration
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.viewevent.EventDispatcher
import expo.modules.kotlin.views.ExpoView
import java.lang.ref.WeakReference

class EmojisPopupWrapper(
  context: Context,
  appContext: AppContext,
) : ExpoView(context, appContext) {
  private val moduleAppContext = appContext

  init {
    clipChildren = false
    clipToPadding = false
  }

  var anchorId: String = ""
    set(value) {
      if (field == value) {
        return
      }

      field = value
      refreshRegistration()
    }

  var gestureMode: String = "none"

  var dragParams: Map<String, Any?>? = null
    set(value) {
      field = value
      parsedDragParams = value?.let {
        try { ReactionPopupShowParams.fromMap(it) } catch (_: Exception) { null }
      }
    }

  private val onDragSelect by EventDispatcher()
  private val onDragPlus by EventDispatcher()
  private val onDragDismiss by EventDispatcher()
  private val onTap by EventDispatcher()

  private var parsedDragParams: ReactionPopupShowParams? = null
  private var isDragging = false
  private var pendingLongPress = false
  private var dragStartX = 0f
  private var dragStartY = 0f
  private val longPressHandler = Handler(Looper.getMainLooper())
  private val touchSlop by lazy { ViewConfiguration.get(context).scaledTouchSlop }

  private var registeredAnchorId: String? = null

  private val longPressRunnable = Runnable {
    val params = parsedDragParams ?: return@Runnable
    isDragging = true
    pendingLongPress = false

    setParentInterceptionDisabled(true)

    val activity = moduleAppContext.currentActivity
    ReactionPopupPresenter.showForDrag(activity, params)

    val cancel = MotionEvent.obtain(
      SystemClock.uptimeMillis(), SystemClock.uptimeMillis(),
      MotionEvent.ACTION_CANCEL, 0f, 0f, 0
    )
    for (i in 0 until childCount) {
      getChildAt(i).dispatchTouchEvent(cancel)
    }
    cancel.recycle()
  }

  override fun onInterceptTouchEvent(ev: MotionEvent): Boolean {
    if (gestureMode != "longPressDrag" || parsedDragParams == null) return false

    when (ev.actionMasked) {
      MotionEvent.ACTION_DOWN -> {
        dragStartX = ev.rawX
        dragStartY = ev.rawY
        pendingLongPress = true
        isDragging = false
        longPressHandler.postDelayed(longPressRunnable, LONG_PRESS_TIMEOUT)
        return false
      }

      MotionEvent.ACTION_MOVE -> {
        if (isDragging) return true

        if (pendingLongPress) {
          val dx = ev.rawX - dragStartX
          val dy = ev.rawY - dragStartY
          if (dx * dx + dy * dy > touchSlop * touchSlop) {
            longPressHandler.removeCallbacks(longPressRunnable)
            pendingLongPress = false
          }
        }
        return false
      }

      MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
        longPressHandler.removeCallbacks(longPressRunnable)
        // User released before the long-press threshold fired = tap.
        // Notify JS so it can open the modal popup without relying on
        // Pressable's onPress timing.
        if (pendingLongPress && ev.actionMasked == MotionEvent.ACTION_UP) {
          onTap(emptyMap())
        }
        pendingLongPress = false
        if (isDragging) return true
        return false
      }
    }
    return false
  }

  override fun onTouchEvent(ev: MotionEvent): Boolean {
    if (!isDragging) return false

    when (ev.actionMasked) {
      MotionEvent.ACTION_MOVE -> {
        ReactionPopupPresenter.updateDragPosition(ev.rawX, ev.rawY)
      }

      MotionEvent.ACTION_UP -> {
        val params = parsedDragParams
        if (params != null) {
          ReactionPopupPresenter.updateDragPosition(ev.rawX, ev.rawY)
          val result = ReactionPopupPresenter.endDrag(params)
          when (result.type) {
            "select" -> result.id?.let { onDragSelect(mapOf("id" to it)) } ?: onDragDismiss(emptyMap())
            "plus" -> onDragPlus(emptyMap())
            "stayOpen" -> ReactionPopupPresenter.convertDragToTapMode(
              params = params,
              onSelect = { id -> onDragSelect(mapOf("id" to id)) },
              onPlus = { onDragPlus(emptyMap()) },
              onDismiss = { onDragDismiss(emptyMap()) },
            )
            else -> onDragDismiss(emptyMap())
          }
        } else {
          ReactionPopupPresenter.cancelDrag()
          onDragDismiss(emptyMap())
        }
        setParentInterceptionDisabled(false)
        isDragging = false
      }

      MotionEvent.ACTION_CANCEL -> {
        ReactionPopupPresenter.cancelDrag()
        onDragDismiss(emptyMap())
        setParentInterceptionDisabled(false)
        isDragging = false
      }
    }
    return true
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    refreshRegistration()
  }

  override fun onDetachedFromWindow() {
    longPressHandler.removeCallbacks(longPressRunnable)
    pendingLongPress = false
    if (isDragging) {
      ReactionPopupPresenter.cancelDrag()
      setParentInterceptionDisabled(false)
      isDragging = false
    }
    unregisterCurrentAnchor()
    super.onDetachedFromWindow()
  }

  private fun setParentInterceptionDisabled(disabled: Boolean) {
    parent?.requestDisallowInterceptTouchEvent(disabled)
  }

  private fun refreshRegistration() {
    val nextRegisteredAnchorId = anchorId.takeIf { it.isNotEmpty() && isAttachedToWindow }
    if (registeredAnchorId == nextRegisteredAnchorId) {
      return
    }

    unregisterCurrentAnchor()

    if (nextRegisteredAnchorId != null) {
      registeredAnchorId = nextRegisteredAnchorId
      registerAnchor(nextRegisteredAnchorId, this)
    }
  }

  private fun unregisterCurrentAnchor() {
    val currentAnchorId = registeredAnchorId ?: return
    unregisterAnchor(currentAnchorId, this)
    registeredAnchorId = null
  }

  companion object {
    private const val LONG_PRESS_TIMEOUT = 350L
    private val registryLock = Any()
    private val anchorsById = mutableMapOf<String, MutableList<WeakReference<EmojisPopupWrapper>>>()

    internal fun anchorView(anchorId: String): EmojisPopupWrapper? {
      synchronized(registryLock) {
        val liveViews = cleanedLiveViews(anchorId)
        return liveViews.lastOrNull()
      }
    }

    private fun registerAnchor(anchorId: String, view: EmojisPopupWrapper) {
      synchronized(registryLock) {
        val liveViews = cleanedLiveViews(anchorId).toMutableList()
        liveViews.removeAll { it === view }
        liveViews.add(view)
        anchorsById[anchorId] = liveViews.mapTo(mutableListOf()) { WeakReference(it) }
      }
    }

    private fun unregisterAnchor(anchorId: String, view: EmojisPopupWrapper) {
      synchronized(registryLock) {
        val liveViews = cleanedLiveViews(anchorId).toMutableList()
        liveViews.removeAll { it === view }

        if (liveViews.isEmpty()) {
          anchorsById.remove(anchorId)
        } else {
          anchorsById[anchorId] = liveViews.mapTo(mutableListOf()) { WeakReference(it) }
        }
      }
    }

    private fun cleanedLiveViews(anchorId: String): List<EmojisPopupWrapper> {
      val liveViews = anchorsById[anchorId]?.mapNotNull { it.get() } ?: emptyList()

      if (liveViews.isEmpty()) {
        anchorsById.remove(anchorId)
      } else {
        anchorsById[anchorId] = liveViews.mapTo(mutableListOf()) { WeakReference(it) }
      }

      return liveViews
    }
  }
}
