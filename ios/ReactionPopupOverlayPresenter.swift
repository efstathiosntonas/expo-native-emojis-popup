import UIKit

@MainActor
final class ReactionPopupOverlayPresenter {
  static let shared = ReactionPopupOverlayPresenter()

  private var activeOverlayView: ReactionPopupOverlayView?
  private var activeContinuation: CheckedContinuation<[String: Any], Error>?

  private init() {}

  func show(params: ReactionPopupShowParams) async throws -> [String: Any] {
    let anchorView = try resolveAnchorView(for: params.anchorId)
    let window = try resolvePresentationWindow(for: anchorView)
    let anchorFrame = try resolveAnchorFrame(for: anchorView, in: window)

    dismissCurrent(animated: false, result: ["type": "dismiss"])

    return try await withCheckedThrowingContinuation { continuation in
      activeContinuation = continuation

      let overlayView = ReactionPopupOverlayView(
        params: params,
        anchorFrame: anchorFrame,
        onSelect: { [weak self] id in
          self?.performSelectionHapticIfNeeded(params: params)
          self?.dismissCurrent(animated: true, result: ["type": "select", "id": id])
        },
        onPlus: { [weak self] in
          self?.performPlusHapticIfNeeded(params: params)
          self?.dismissCurrent(animated: true, result: ["type": "plus"])
        },
        onDismiss: { [weak self] in
          self?.dismissCurrent(animated: true, result: ["type": "dismiss"])
        }
      )
      overlayView.frame = window.bounds
      overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

      window.addSubview(overlayView)
      activeOverlayView = overlayView
      performOpenHapticIfNeeded(params: params)
      overlayView.present()
    }
  }

  func dismiss() {
    dismissCurrent(animated: true, result: ["type": "dismiss"])
  }

  struct DragResult {
    let type: String
    let id: String?
  }

  func showForDrag(params: ReactionPopupShowParams) throws {
    let anchorView = try resolveAnchorView(for: params.anchorId)
    let window = try resolvePresentationWindow(for: anchorView)
    let anchorFrame = try resolveAnchorFrame(for: anchorView, in: window)

    dismissCurrent(animated: false, result: ["type": "dismiss"])

    let overlayView = ReactionPopupOverlayView(
      params: params,
      anchorFrame: anchorFrame,
      onSelect: { _ in },
      onPlus: { },
      onDismiss: { }
    )
    overlayView.frame = window.bounds
    overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    window.addSubview(overlayView)
    activeOverlayView = overlayView
    performOpenHapticIfNeeded(params: params)
    overlayView.present()
  }

  func updateDragPosition(windowPoint: CGPoint) -> String? {
    guard let overlayView = activeOverlayView else {
      return nil
    }

    return overlayView.trayView.updateHover(at: windowPoint)
  }

  func endDrag(params: ReactionPopupShowParams) -> DragResult {
    guard let overlayView = activeOverlayView else {
      return DragResult(type: "dismiss", id: nil)
    }

    let hoveredId = overlayView.trayView.hoveredItemId

    overlayView.trayView.clearHover()

    if let hoveredId, hoveredId == "__plus__" {
      performPlusHapticIfNeeded(params: params)
      dismissCurrent(animated: true, result: ["type": "plus"])
      return DragResult(type: "plus", id: nil)
    }

    if let hoveredId {
      performSelectionHapticIfNeeded(params: params)
      dismissCurrent(animated: true, result: ["type": "select", "id": hoveredId])
      return DragResult(type: "select", id: hoveredId)
    }

    if params.dismissOnDragOut {
      dismissCurrent(animated: true, result: ["type": "dismiss"])
      return DragResult(type: "dismiss", id: nil)
    }

    return DragResult(type: "stayOpen", id: nil)
  }

  func convertDragToTapMode(
    params: ReactionPopupShowParams,
    onSelect: @escaping (String) -> Void,
    onPlus: @escaping () -> Void,
    onDismiss: @escaping () -> Void
  ) {
    guard let overlayView = activeOverlayView else {
      onDismiss()
      return
    }

    overlayView.trayView.actionHandler = { [weak self] action in
      guard let self, self.activeOverlayView != nil else { return }
      switch action {
      case let .select(id):
        self.performSelectionHapticIfNeeded(params: params)
        self.dismissCurrent(animated: true, result: ["type": "select", "id": id])
        onSelect(id)
      case .plus:
        self.performPlusHapticIfNeeded(params: params)
        self.dismissCurrent(animated: true, result: ["type": "plus"])
        onPlus()
      }
    }

    overlayView.enableInteractiveDismiss { [weak self] in
      guard let self, self.activeOverlayView != nil else { return }
      self.dismissCurrent(animated: true, result: ["type": "dismiss"])
      onDismiss()
    }
  }

  func cancelDrag() {
    activeOverlayView?.trayView.clearHover()
    dismissCurrent(animated: true, result: ["type": "dismiss"])
  }

  private func dismissCurrent(animated: Bool, result: [String: Any]) {
    let overlayView = activeOverlayView
    let continuation = activeContinuation

    activeOverlayView = nil
    activeContinuation = nil

    guard let continuation else {
      overlayView?.dismiss(animated: animated) {}
      return
    }

    guard let overlayView else {
      continuation.resume(returning: result)
      return
    }

    overlayView.dismiss(animated: animated) {
      continuation.resume(returning: result)
    }
  }

  private func resolveAnchorView(for anchorId: String) throws -> ReactionPopupAnchorView {
    guard let anchorView = ReactionPopupAnchorView.anchorView(for: anchorId) else {
      throw EmojisPopupError(
        .anchorNotFound,
        description: "No emojis popup anchor is registered for anchorId '\(anchorId)'"
      )
    }
    return anchorView
  }

  private func resolvePresentationWindow(for anchorView: ReactionPopupAnchorView) throws -> UIWindow {
    guard let window = anchorView.window, !window.isHidden else {
      throw EmojisPopupError(
        .presentationFailed,
        description: "Unable to resolve a presentation host for the emojis popup"
      )
    }
    return window
  }

  private func resolveAnchorFrame(
    for anchorView: ReactionPopupAnchorView,
    in window: UIWindow
  ) throws -> CGRect {
    guard anchorView.window === window, anchorView.superview != nil else {
      throw EmojisPopupError(
        .anchorNotMeasurable,
        description: "The anchor view is detached and cannot be measured"
      )
    }

    guard let frame = anchorView.measurableFrame(in: window) else {
      throw EmojisPopupError(
        .anchorNotMeasurable,
        description: "The anchor view frame could not be measured in window coordinates"
      )
    }
    return frame
  }

  private func performOpenHapticIfNeeded(params: ReactionPopupShowParams) {
    guard params.haptics.onOpen else {
      return
    }
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.prepare()
    generator.impactOccurred(intensity: 0.75)
  }

  private func performSelectionHapticIfNeeded(params: ReactionPopupShowParams) {
    guard params.haptics.onSelect else {
      return
    }
    let generator = UISelectionFeedbackGenerator()
    generator.prepare()
    generator.selectionChanged()
  }

  private func performPlusHapticIfNeeded(params: ReactionPopupShowParams) {
    guard params.haptics.onPlus else {
      return
    }
    let generator = UIImpactFeedbackGenerator(style: .soft)
    generator.prepare()
    generator.impactOccurred(intensity: 0.55)
  }
}
