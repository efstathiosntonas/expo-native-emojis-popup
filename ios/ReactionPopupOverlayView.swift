import UIKit

@MainActor
final class ReactionPopupOverlayView: UIView {
  private let params: ReactionPopupShowParams
  private let anchorFrame: CGRect
  private let backdropButton = UIButton(type: .custom)
  let trayView: ReactionPopupContentView
  private var dismissHandler: () -> Void
  private let reduceMotionEnabled = UIAccessibility.isReduceMotionEnabled

  init(
    params: ReactionPopupShowParams,
    anchorFrame: CGRect,
    onSelect: @escaping (String) -> Void,
    onPlus: @escaping () -> Void,
    onDismiss: @escaping () -> Void
  ) {
    self.params = params
    self.anchorFrame = anchorFrame
    dismissHandler = onDismiss
    trayView = ReactionPopupContentView(params: params) { action in
      switch action {
      case let .select(id):
        onSelect(id)
      case .plus:
        onPlus()
      }
    }

    super.init(frame: .zero)

    backgroundColor = .clear
    isOpaque = false
    accessibilityViewIsModal = true

    backdropButton.backgroundColor = params.style.backdropColor
    backdropButton.isUserInteractionEnabled = false
    backdropButton.addAction(UIAction { [weak self] _ in
      self?.dismissHandler()
    }, for: .touchUpInside)
    if params.dismissOnBackdropPress {
      backdropButton.isAccessibilityElement = true
      backdropButton.accessibilityLabel = "Dismiss reactions"
      backdropButton.accessibilityHint = "Dismisses the reaction popup"
      backdropButton.accessibilityTraits = [.button]
    } else {
      backdropButton.isAccessibilityElement = false
    }

    addSubview(backdropButton)
    addSubview(trayView)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    backdropButton.frame = bounds
    trayView.frame = resolvedTrayFrame()
  }

  func present() {
    setNeedsLayout()
    layoutIfNeeded()

    backdropButton.alpha = 0
    trayView.alpha = 0
    trayView.transform = reduceMotionEnabled
      ? .identity
      : CGAffineTransform(
        scaleX: params.animation.trayInitialScale,
        y: params.animation.trayInitialScale
      )
    trayView.prepareForPresentation(reduceMotion: reduceMotionEnabled)

    let openDuration = reduceMotionEnabled ? min(params.animation.openDuration, 0.14) : params.animation.openDuration

    UIView.animate(
      withDuration: openDuration,
      delay: 0,
      options: [.curveEaseOut, .beginFromCurrentState]
    ) { [self] in
      backdropButton.alpha = 1
      trayView.alpha = 1
      trayView.transform = .identity
    } completion: { [weak self] _ in
      guard let self else {
        return
      }
      self.backdropButton.isUserInteractionEnabled = self.params.dismissOnBackdropPress
      UIAccessibility.post(notification: .screenChanged, argument: self.trayView)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + openDuration * 0.35) { [weak self] in
      guard let self else { return }
      self.trayView.animateEntrance(reduceMotion: self.reduceMotionEnabled)
    }
  }

  func enableInteractiveDismiss(_ handler: @escaping () -> Void) {
    dismissHandler = handler
    backdropButton.isUserInteractionEnabled = true
    backdropButton.isAccessibilityElement = true
    backdropButton.accessibilityLabel = "Dismiss reactions"
    backdropButton.accessibilityHint = "Dismisses the reaction popup"
    backdropButton.accessibilityTraits = [.button]
  }

  func dismiss(animated: Bool, completion: @escaping () -> Void) {
    backdropButton.isUserInteractionEnabled = false

    guard animated else {
      removeFromSuperview()
      completion()
      return
    }

    UIView.animate(
      withDuration: 0.15,
      delay: 0,
      options: [.curveEaseIn]
    ) { [self] in
      backdropButton.alpha = 0
      trayView.alpha = 0
    } completion: { [weak self] _ in
      self?.removeFromSuperview()
      completion()
    }
  }

  private func resolvedTrayFrame() -> CGRect {
    let safeAreaFrame = bounds
      .inset(by: safeAreaInsets)
      .insetBy(dx: params.edgePadding, dy: params.edgePadding)
    let traySize = trayView.preferredContentSize(maxWidth: max(0, safeAreaFrame.width))
    let x: CGFloat
    if params.centerOnScreen {
      x = max(safeAreaFrame.minX, (bounds.width - traySize.width) / 2)
    } else {
      x = min(
        max(anchorFrame.midX - (traySize.width / 2), safeAreaFrame.minX),
        max(safeAreaFrame.minX, safeAreaFrame.maxX - traySize.width)
      )
    }

    let spacing: CGFloat = 8
    let availableAbove = anchorFrame.minY - safeAreaFrame.minY
    let availableBelow = safeAreaFrame.maxY - anchorFrame.maxY
    let fitsAbove = availableAbove >= traySize.height + spacing
    let fitsBelow = availableBelow >= traySize.height + spacing

    let placement: ReactionPopupResolvedPlacement
    switch params.preferredPlacement {
    case .above:
      if fitsAbove {
        placement = .above
      } else if fitsBelow {
        placement = .below
      } else {
        placement = availableAbove >= availableBelow ? .above : .below
      }
    case .below:
      if fitsBelow {
        placement = .below
      } else if fitsAbove {
        placement = .above
      } else {
        placement = availableBelow > availableAbove ? .below : .above
      }
    case .auto:
      if fitsAbove {
        placement = .above
      } else if fitsBelow {
        placement = .below
      } else {
        placement = availableAbove >= availableBelow ? .above : .below
      }
    }

    let y: CGFloat
    switch placement {
    case .above:
      y = max(
        safeAreaFrame.minY,
        min(anchorFrame.minY - spacing - traySize.height, safeAreaFrame.maxY - traySize.height)
      )
    case .below:
      y = max(
        safeAreaFrame.minY,
        min(anchorFrame.maxY + spacing, safeAreaFrame.maxY - traySize.height)
      )
    }

    return CGRect(origin: CGPoint(x: x, y: y), size: traySize)
  }
}
