import UIKit

@MainActor
final class ReactionPopupContentView: UIView {
  enum Action {
    case select(String)
    case plus
  }

  private let params: ReactionPopupShowParams
  private let scrollView = UIScrollView()
  var actionHandler: (Action) -> Void
  private var orderedButtons: [ReactionPopupActionButton] = []
  private var hoveredButton: ReactionPopupActionButton?
  private(set) var hoveredItemId: String?
  private var buttonIdMap: [ReactionPopupActionButton: String] = [:]
  private var buttonNameMap: [ReactionPopupActionButton: String] = [:]
  private var buttonHitRects: [CGRect] = []
  private let hoverLabel = ReactionPopupHoverLabel()

  init(
    params: ReactionPopupShowParams,
    actionHandler: @escaping (Action) -> Void
  ) {
    self.params = params
    self.actionHandler = actionHandler
    super.init(frame: .zero)

    isOpaque = false
    backgroundColor = params.style.backgroundColor
    layer.cornerRadius = params.style.borderRadius
    layer.borderColor = params.style.borderColor.cgColor
    layer.borderWidth = params.style.borderWidth
    layer.shadowColor = params.style.shadowColor.cgColor
    layer.shadowOpacity = params.style.shadowOpacity
    layer.shadowRadius = params.style.shadowRadius
    layer.shadowOffset = CGSize(
      width: params.style.shadowOffsetX,
      height: params.style.shadowOffsetY
    )
    if params.style.elevation > 0 {
      layer.zPosition = params.style.elevation
    }

    clipsToBounds = false

    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.alwaysBounceHorizontal = false
    scrollView.alwaysBounceVertical = false
    scrollView.bounces = false
    scrollView.clipsToBounds = false
    scrollView.backgroundColor = .clear
    addSubview(scrollView)

    hoverLabel.alpha = 0
    addSubview(hoverLabel)

    buildButtons()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var intrinsicContentSize: CGSize {
    preferredContentSize(maxWidth: nil)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    scrollView.frame = bounds
    let totalWidth = fullContentWidth
    let contentWidth = max(totalWidth, bounds.width)
    scrollView.contentSize = CGSize(width: contentWidth, height: bounds.height)

    let centeredOriginX = max(0, (contentWidth - totalWidth) / 2)
    var nextX = centeredOriginX + params.style.paddingHorizontal
    let y = params.style.paddingVertical

    for button in orderedButtons {
      button.frame = CGRect(
        x: nextX,
        y: y,
        width: params.style.itemSize,
        height: params.style.itemSize
      )
      nextX += params.style.itemSize + params.style.gap
    }

    layer.shadowPath = UIBezierPath(
      roundedRect: bounds,
      cornerRadius: params.style.borderRadius
    ).cgPath

    rebuildHitRects()
  }

  func preferredContentSize(maxWidth: CGFloat?) -> CGSize {
    let width = fullContentWidth
    let height = (params.style.paddingVertical * 2) + params.style.itemSize

    guard let maxWidth else {
      return CGSize(width: width, height: height)
    }

    return CGSize(width: min(width, maxWidth), height: height)
  }

  func prepareForPresentation(reduceMotion: Bool) {
    for button in orderedButtons {
      button.alpha = reduceMotion ? 1 : 0
      if !reduceMotion {
        button.layer.setValue(0.88, forKeyPath: "transform.scale")
        button.layer.setValue(8.0, forKeyPath: "transform.translation.y")
      }
    }
  }

  func animateEntrance(reduceMotion: Bool) {
    guard !reduceMotion else {
      return
    }

    let duration = max(0.18, params.animation.openDuration * 0.9)
    let popScale = params.animation.emojiPopScale
    for (index, button) in orderedButtons.enumerated() {
      let delay = params.animation.itemStagger * Double(index)

      UIView.animate(
        withDuration: duration * 0.68,
        delay: delay,
        options: [.curveEaseOut]
      ) {
        button.alpha = 1
      }

      let scaleUp = CABasicAnimation(keyPath: "transform.scale")
      scaleUp.fromValue = 0.88
      scaleUp.toValue = popScale
      scaleUp.beginTime = CACurrentMediaTime() + delay
      scaleUp.duration = duration * 0.68
      scaleUp.fillMode = .backwards
      scaleUp.timingFunction = CAMediaTimingFunction(name: .easeOut)

      let transReset = CABasicAnimation(keyPath: "transform.translation.y")
      transReset.fromValue = 8.0
      transReset.toValue = 0.0
      transReset.beginTime = CACurrentMediaTime() + delay
      transReset.duration = duration * 0.68
      transReset.fillMode = .backwards
      transReset.timingFunction = CAMediaTimingFunction(name: .easeOut)

      let scaleDown = CABasicAnimation(keyPath: "transform.scale")
      scaleDown.fromValue = popScale
      scaleDown.toValue = 1.0
      scaleDown.beginTime = CACurrentMediaTime() + delay + duration * 0.68
      scaleDown.duration = duration * 0.32
      scaleDown.fillMode = .backwards
      scaleDown.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

      button.layer.setValue(1.0, forKeyPath: "transform.scale")
      button.layer.setValue(0.0, forKeyPath: "transform.translation.y")

      button.layer.add(scaleUp, forKey: "entrance-scale-up-\(index)")
      button.layer.add(transReset, forKey: "entrance-trans-\(index)")
      button.layer.add(scaleDown, forKey: "entrance-scale-down-\(index)")
    }
  }

  func updateHover(at windowPoint: CGPoint) -> String? {
    guard let window = self.window else {
      setHoveredButton(nil)
      return nil
    }

    let localPoint = scrollView.convert(windowPoint, from: window)

    var hitButton: ReactionPopupActionButton?
    for (index, rect) in buttonHitRects.enumerated() where index < orderedButtons.count {
      if rect.contains(localPoint) {
        hitButton = orderedButtons[index]
        break
      }
    }

    if hitButton != nil {
      setHoveredButton(hitButton)
    } else {
      let selfPoint = convert(windowPoint, from: window)
      let trayArea = bounds.insetBy(dx: -12, dy: -12)
      if !trayArea.contains(selfPoint) {
        setHoveredButton(nil)
      }
    }

    return hoveredItemId
  }

  func clearHover() {
    setHoveredButton(nil)
  }

  private lazy var hoverHaptic: UISelectionFeedbackGenerator = {
    let generator = UISelectionFeedbackGenerator()
    generator.prepare()
    return generator
  }()

  private func setHoveredButton(_ button: ReactionPopupActionButton?) {
    guard hoveredButton !== button else {
      return
    }

    let previous = hoveredButton
    hoveredButton = button
    hoveredItemId = button.flatMap { buttonIdMap[$0] }

    if button != nil {
      hoverHaptic.selectionChanged()
      hoverHaptic.prepare()
    }

    if let previous {
      animateLayerProperty(previous.layer, keyPath: "transform.scale", to: 1.0)
      animateLayerProperty(previous.layer, keyPath: "transform.translation.y", to: 0)
    }

    if let button {
      let scale = params.style.hoverScale
      let transY = -params.style.hoverTranslationY
      animateLayerProperty(button.layer, keyPath: "transform.scale", to: scale, stiffness: 600, damping: 28)
      animateLayerProperty(button.layer, keyPath: "transform.translation.y", to: transY, stiffness: 600, damping: 28)
    }

    updateHoverLabel(for: button)
  }

  private func animateLayerProperty(
    _ layer: CALayer,
    keyPath: String,
    to value: CGFloat,
    stiffness: CGFloat = 800,
    damping: CGFloat = 40
  ) {
    let animKey = "\(ObjectIdentifier(layer).hashValue)-\(keyPath)"

    layer.removeAnimation(forKey: animKey)

    layer.setValue(value, forKeyPath: keyPath)

    if UIAccessibility.isReduceMotionEnabled {
      return
    }

    let fromValue = (layer.presentation() ?? layer).value(forKeyPath: keyPath) as? CGFloat ?? 0

    let spring = CASpringAnimation(keyPath: keyPath)
    spring.fromValue = fromValue
    spring.toValue = value
    spring.mass = 1.0
    spring.stiffness = stiffness
    spring.damping = damping
    spring.initialVelocity = 0
    spring.duration = spring.settlingDuration
    spring.fillMode = .forwards
    spring.isRemovedOnCompletion = true

    layer.add(spring, forKey: animKey)
  }

  private func updateHoverLabel(for button: ReactionPopupActionButton?) {
    guard let button, let name = buttonNameMap[button], buttonIdMap[button] != "__plus__" else {
      UIView.animate(withDuration: 0.12) {
        self.hoverLabel.alpha = 0
      }
      return
    }

    hoverLabel.configure(text: name, style: params.style)
    hoverLabel.sizeToFit()

    guard let buttonIndex = orderedButtons.firstIndex(of: button),
          buttonIndex < buttonHitRects.count else { return }

    let hitRect = buttonHitRects[buttonIndex]
    let buttonCenterX = hitRect.midX
    let buttonCenterY = params.style.paddingVertical + params.style.itemSize / 2

    let animatedCenterY = buttonCenterY - params.style.hoverTranslationY
    // Use emoji font size (not itemSize) for tighter label-to-glyph spacing
    let scaledHalfGlyph = (params.style.emojiFontSize * params.style.hoverScale) / 2
    let visualTop = animatedCenterY - scaledHalfGlyph

    hoverLabel.center = CGPoint(
      x: buttonCenterX,
      y: visualTop - 4 - hoverLabel.bounds.height / 2
    )

    UIView.animate(withDuration: 0.12) {
      self.hoverLabel.alpha = 1
    }
  }

  private var fullContentWidth: CGFloat {
    let buttonCount = CGFloat(orderedButtons.count)
    let gaps = max(0, buttonCount - 1)
    return (params.style.paddingHorizontal * 2)
      + (buttonCount * params.style.itemSize)
      + (gaps * params.style.gap)
  }

  private func buildButtons() {
    for item in params.items {
      let button = ReactionPopupActionButton(
        normalBackgroundColor: item.id == params.selectedId
          ? params.style.itemSelectedBackgroundColor
          : params.style.itemBackgroundColor,
        pressedBackgroundColor: params.style.itemPressedBackgroundColor,
        selectedBackgroundColor: params.style.itemSelectedBackgroundColor,
        borderColor: params.style.itemBorderColor,
        borderWidth: params.style.itemBorderWidth,
        cornerRadius: params.style.itemBorderRadius
      )
      button.setTitle(item.emoji, for: .normal)
      button.titleLabel?.font = .systemFont(ofSize: params.style.emojiFontSize)
      button.setTitleColor(.label, for: .normal)
      button.isSelected = item.id == params.selectedId
      button.accessibilityLabel = item.emojiName
      button.accessibilityIdentifier = item.emojiName
      button.accessibilityTraits = button.isSelected ? [.button, .selected] : [.button]
      button.addAction(UIAction { [weak self] _ in
        self?.actionHandler(.select(item.id))
      }, for: .touchUpInside)
      scrollView.addSubview(button)
      orderedButtons.append(button)
      buttonIdMap[button] = item.id
      buttonNameMap[button] = item.emojiName
    }

    guard params.plusEnabled else {
      return
    }

    let plusButton = ReactionPopupActionButton(
      normalBackgroundColor: params.style.plusBackgroundColor,
      pressedBackgroundColor: params.style.plusPressedBackgroundColor,
      selectedBackgroundColor: params.style.plusBackgroundColor,
      borderColor: params.style.itemBorderColor,
      borderWidth: params.style.itemBorderWidth,
      cornerRadius: params.style.itemBorderRadius
    )
    let plusImage = UIImage(
      systemName: "plus",
      withConfiguration: UIImage.SymbolConfiguration(
        pointSize: max(16, params.style.emojiFontSize - 4),
        weight: .semibold
      )
    )
    plusButton.setImage(plusImage, for: .normal)
    plusButton.tintColor = params.style.plusIconColor
    plusButton.accessibilityLabel = params.plusAccessibilityLabel
    plusButton.accessibilityIdentifier = params.plusAccessibilityLabel
    plusButton.accessibilityTraits = [.button]
    plusButton.addAction(UIAction { [weak self] _ in
      self?.actionHandler(.plus)
    }, for: .touchUpInside)
    scrollView.addSubview(plusButton)
    orderedButtons.append(plusButton)
    buttonIdMap[plusButton] = "__plus__"

    rebuildHitRects()
  }

  private func rebuildHitRects() {
    let totalWidth = fullContentWidth
    let contentWidth = max(totalWidth, bounds.width > 0 ? bounds.width : totalWidth)
    let centeredOriginX = max(0, (contentWidth - totalWidth) / 2)
    var nextX = centeredOriginX + params.style.paddingHorizontal
    let y = params.style.paddingVertical

    buttonHitRects = orderedButtons.map { _ in
      let rect = CGRect(x: nextX, y: y, width: params.style.itemSize, height: params.style.itemSize)
        .insetBy(dx: -4, dy: -4)
      nextX += params.style.itemSize + params.style.gap
      return rect
    }
  }
}

private final class ReactionPopupHoverLabel: UIView {
  private let label = UILabel()
  private var paddingH: CGFloat = 8
  private var paddingV: CGFloat = 4

  override init(frame: CGRect) {
    super.init(frame: frame)
    isUserInteractionEnabled = false
    label.textAlignment = .center
    addSubview(label)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(text: String, style: ReactionPopupStyle) {
    label.text = text
    label.textColor = style.hoverLabelColor
    label.font = .systemFont(ofSize: style.hoverLabelFontSize, weight: .semibold)
    backgroundColor = style.hoverLabelBackgroundColor
    layer.cornerRadius = style.hoverLabelBorderRadius
    clipsToBounds = true
    paddingH = style.hoverLabelPaddingHorizontal
    paddingV = style.hoverLabelPaddingVertical
  }

  override func sizeToFit() {
    label.sizeToFit()
    let height: CGFloat = label.intrinsicContentSize.height + paddingV * 2
    let width: CGFloat = label.intrinsicContentSize.width + paddingH * 2
    frame.size = CGSize(width: width, height: height)
    label.frame = bounds
  }
}

private final class ReactionPopupActionButton: UIButton {
  private let normalBackgroundColor: UIColor
  private let pressedBackgroundColor: UIColor
  private let selectedBackgroundColor: UIColor

  init(
    normalBackgroundColor: UIColor,
    pressedBackgroundColor: UIColor,
    selectedBackgroundColor: UIColor,
    borderColor: UIColor,
    borderWidth: CGFloat,
    cornerRadius: CGFloat
  ) {
    self.normalBackgroundColor = normalBackgroundColor
    self.pressedBackgroundColor = pressedBackgroundColor
    self.selectedBackgroundColor = selectedBackgroundColor
    super.init(frame: .zero)

    clipsToBounds = true
    layer.cornerRadius = cornerRadius
    layer.borderColor = borderColor.cgColor
    layer.borderWidth = borderWidth
    titleLabel?.textAlignment = .center
    isAccessibilityElement = true

    updateAppearance()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var isHighlighted: Bool {
    didSet {
      updateAppearance()
    }
  }

  override var isSelected: Bool {
    didSet {
      updateAppearance()
    }
  }

  private func updateAppearance() {
    if isHighlighted {
      backgroundColor = pressedBackgroundColor
      return
    }
    backgroundColor = isSelected ? selectedBackgroundColor : normalBackgroundColor
  }
}
