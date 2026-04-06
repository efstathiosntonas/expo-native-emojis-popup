import ExpoModulesCore
import Foundation
import UIKit

private final class ReactionPopupAnchorRegistry {
  static let shared = ReactionPopupAnchorRegistry()

  private final class WeakAnchorReference {
    weak var view: ReactionPopupAnchorView?

    init(_ view: ReactionPopupAnchorView) {
      self.view = view
    }
  }

  private let lock = NSLock()
  private var anchorsById: [String: [WeakAnchorReference]] = [:]

  private init() {}

  func anchorView(for anchorId: String) -> ReactionPopupAnchorView? {
    lock.lock()
    defer { lock.unlock() }
    return cleanedLiveViews(for: anchorId).last
  }

  func register(anchorId: String, view: ReactionPopupAnchorView) {
    lock.lock()
    defer { lock.unlock() }

    var liveViews = cleanedLiveViews(for: anchorId)
    liveViews.removeAll { $0 === view }
    liveViews.append(view)
    anchorsById[anchorId] = liveViews.map(WeakAnchorReference.init)
  }

  func unregister(anchorId: String, matching view: ReactionPopupAnchorView) {
    lock.lock()
    defer { lock.unlock() }

    var liveViews = cleanedLiveViews(for: anchorId)
    liveViews.removeAll { $0 === view }

    if liveViews.isEmpty {
      anchorsById.removeValue(forKey: anchorId)
    } else {
      anchorsById[anchorId] = liveViews.map(WeakAnchorReference.init)
    }
  }

  private func cleanedLiveViews(for anchorId: String) -> [ReactionPopupAnchorView] {
    let liveViews = (anchorsById[anchorId] ?? []).compactMap(\.view)

    if liveViews.isEmpty {
      anchorsById.removeValue(forKey: anchorId)
    } else {
      anchorsById[anchorId] = liveViews.map(WeakAnchorReference.init)
    }

    return liveViews
  }
}

class ReactionPopupAnchorView: ExpoView {
  var anchorId: String = "" {
    didSet {
      refreshRegistration()
    }
  }

  var gestureMode: String = "none" {
    didSet {
      updateGestureRecognizer()
    }
  }

  var dragParams: [String: Any]? {
    didSet {
      parsedDragParams = dragParams.flatMap { try? ReactionPopupShowParams(dictionary: $0) }
    }
  }

  private let onDragSelect = EventDispatcher()
  private let onDragPlus = EventDispatcher()
  private let onDragDismiss = EventDispatcher()

  private var parsedDragParams: ReactionPopupShowParams?
  private var longPressGesture: UILongPressGestureRecognizer?
  private var registeredAnchorId: String?

  override func didMoveToWindow() {
    super.didMoveToWindow()
    refreshRegistration()
  }

  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    refreshRegistration()
  }

  deinit {
    unregisterCurrentAnchor()
    if let gesture = longPressGesture {
      removeGestureRecognizer(gesture)
      longPressGesture = nil
    }
  }

  static func anchorView(for anchorId: String) -> ReactionPopupAnchorView? {
    ReactionPopupAnchorRegistry.shared.anchorView(for: anchorId)
  }

  func measurableFrame(in window: UIWindow) -> CGRect? {
    layoutIfNeeded()

    let ownFrame = convert(bounds, to: window)
    if ownFrame.isFiniteNonEmpty {
      return ownFrame
    }

    let descendantFrames = measurableDescendantFrames(in: window, from: self)
    guard !descendantFrames.isEmpty else {
      return nil
    }

    return descendantFrames.reduce(into: descendantFrames[0]) { partialResult, frame in
      partialResult = partialResult.union(frame)
    }
  }

  private func updateGestureRecognizer() {
    if gestureMode == "longPressDrag" && longPressGesture == nil {
      let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressDrag(_:)))
      gesture.minimumPressDuration = 0.35
      gesture.allowableMovement = 20
      gesture.cancelsTouchesInView = true
      addGestureRecognizer(gesture)
      longPressGesture = gesture
    } else if gestureMode != "longPressDrag", let existing = longPressGesture {
      removeGestureRecognizer(existing)
      longPressGesture = nil
    }
  }

  @objc private func handleLongPressDrag(_ recognizer: UILongPressGestureRecognizer) {
    guard let params = parsedDragParams else {
      return
    }

    let presenter = ReactionPopupOverlayPresenter.shared

    switch recognizer.state {
    case .began:
      do {
        try presenter.showForDrag(params: params)
      } catch {
        #if DEBUG
        print("[NativeReactionPopup] showForDrag failed: \(error)")
        #endif
      }

    case .changed:
      guard let window = self.window else {
        return
      }
      let windowPoint = recognizer.location(in: window)
      _ = presenter.updateDragPosition(windowPoint: windowPoint)

    case .ended:
      guard let window = self.window else {
        presenter.cancelDrag()
        onDragDismiss()
        return
      }
      let windowPoint = recognizer.location(in: window)
      _ = presenter.updateDragPosition(windowPoint: windowPoint)
      let result = presenter.endDrag(params: params)

      switch result.type {
      case "select":
        if let id = result.id {
          onDragSelect(["id": id])
        } else {
          onDragDismiss()
        }
      case "plus":
        onDragPlus()
      case "stayOpen":
        presenter.convertDragToTapMode(
          params: params,
          onSelect: { [weak self] id in self?.onDragSelect(["id": id]) },
          onPlus: { [weak self] in self?.onDragPlus() },
          onDismiss: { [weak self] in self?.onDragDismiss() }
        )
      default:
        onDragDismiss()
      }

    case .cancelled, .failed:
      presenter.cancelDrag()
      onDragDismiss()

    default:
      break
    }
  }

  private func refreshRegistration() {
    let nextRegisteredAnchorId: String?
    if window != nil, superview != nil, !anchorId.isEmpty {
      nextRegisteredAnchorId = anchorId
    } else {
      nextRegisteredAnchorId = nil
    }

    if registeredAnchorId == nextRegisteredAnchorId {
      return
    }

    unregisterCurrentAnchor()

    guard let nextRegisteredAnchorId else {
      return
    }

    registeredAnchorId = nextRegisteredAnchorId
    ReactionPopupAnchorRegistry.shared.register(anchorId: nextRegisteredAnchorId, view: self)
  }

  private func unregisterCurrentAnchor() {
    guard let registeredAnchorId else {
      return
    }

    ReactionPopupAnchorRegistry.shared.unregister(anchorId: registeredAnchorId, matching: self)
    self.registeredAnchorId = nil
  }

  private func measurableDescendantFrames(in window: UIWindow, from view: UIView) -> [CGRect] {
    view.subviews.flatMap { subview -> [CGRect] in
      let frame = subview.convert(subview.bounds, to: window)
      let childFrames = measurableDescendantFrames(in: window, from: subview)

      if frame.isFiniteNonEmpty {
        return [frame] + childFrames
      }

      return childFrames
    }
  }
}

private extension CGRect {
  var isFiniteNonEmpty: Bool {
    !isNull && !isInfinite && !isEmpty && width > 0 && height > 0
  }
}
