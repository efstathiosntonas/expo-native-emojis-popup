import ExpoModulesCore
import Foundation
import UIKit

enum EmojisPopupErrorCode: String {
  case anchorNotFound = "ANCHOR_NOT_FOUND"
  case anchorNotMeasurable = "ANCHOR_NOT_MEASURABLE"
  case emptyItems = "EMPTY_ITEMS"
  case invalidParams = "INVALID_PARAMS"
  case presentationFailed = "PRESENTATION_FAILED"
}

final class EmojisPopupError: Exception, @unchecked Sendable {
  convenience init(_ code: EmojisPopupErrorCode, description: String) {
    self.init(name: "EmojisPopupError", description: description, code: code.rawValue)
  }
}

enum ReactionPopupPlacement: String {
  case above
  case below
  case auto
}

enum ReactionPopupResolvedPlacement {
  case above
  case below
}

struct ReactionPopupItemPayload {
  let id: String
  let emoji: String
  let emojiName: String

  init(dictionary: [String: Any]) throws {
    id = try ReactionPopupParser.requiredString(dictionary["id"], key: "items[].id")
    emoji = try ReactionPopupParser.requiredString(dictionary["emoji"], key: "items[].emoji")
    emojiName = try ReactionPopupParser.requiredString(dictionary["emoji_name"], key: "items[].emoji_name")
  }
}

struct ReactionPopupHaptics {
  let onOpen: Bool
  let onPlus: Bool
  let onSelect: Bool

  init(dictionary: [String: Any]?) throws {
    onOpen = try ReactionPopupParser.bool(dictionary?["onOpen"], key: "haptics.onOpen") ?? false
    onPlus = try ReactionPopupParser.bool(dictionary?["onPlus"], key: "haptics.onPlus") ?? false
    onSelect = try ReactionPopupParser.bool(dictionary?["onSelect"], key: "haptics.onSelect") ?? false
  }
}

struct ReactionPopupStyle {
  let backgroundColor: UIColor
  let backdropColor: UIColor
  let borderColor: UIColor
  let borderRadius: CGFloat
  let borderWidth: CGFloat
  let elevation: CGFloat
  let emojiFontSize: CGFloat
  let emojiPopScale: CGFloat
  let gap: CGFloat
  let itemBackgroundColor: UIColor
  let itemBorderColor: UIColor
  let itemBorderRadius: CGFloat
  let itemBorderWidth: CGFloat
  let itemPressedBackgroundColor: UIColor
  let itemSelectedBackgroundColor: UIColor
  let itemSize: CGFloat
  let paddingHorizontal: CGFloat
  let paddingVertical: CGFloat
  let plusBackgroundColor: UIColor
  let plusIconColor: UIColor
  let plusPressedBackgroundColor: UIColor
  let shadowColor: UIColor
  let shadowOffsetX: CGFloat
  let shadowOffsetY: CGFloat
  let shadowOpacity: Float
  let shadowRadius: CGFloat
  let hoverScale: CGFloat
  let hoverTranslationY: CGFloat
  let hoverLabelBackgroundColor: UIColor
  let hoverLabelBorderRadius: CGFloat
  let hoverLabelColor: UIColor
  let hoverLabelFontSize: CGFloat
  let hoverLabelPaddingHorizontal: CGFloat
  let hoverLabelPaddingVertical: CGFloat

  init(dictionary: [String: Any]?) throws {
    let backdropBaseColor = try ReactionPopupParser.color(
      dictionary?["backdropColor"],
      key: "style.backdropColor"
    ) ?? UIColor.black
    let backdropOpacity = try ReactionPopupParser.cgFloat(
      dictionary?["backdropOpacity"],
      key: "style.backdropOpacity"
    ) ?? 0.16

    backgroundColor = try ReactionPopupParser.color(
      dictionary?["backgroundColor"],
      key: "style.backgroundColor"
    ) ?? UIColor(red: 0x1F/255.0, green: 0x1F/255.0, blue: 0x1F/255.0, alpha: 1)
    backdropColor = backdropBaseColor.withAlphaComponent(max(0, min(1, backdropOpacity)))
    borderColor = try ReactionPopupParser.color(
      dictionary?["borderColor"],
      key: "style.borderColor"
    ) ?? UIColor.clear
    borderRadius = try ReactionPopupParser.cgFloat(
      dictionary?["borderRadius"],
      key: "style.borderRadius"
    ) ?? 28
    borderWidth = try ReactionPopupParser.cgFloat(
      dictionary?["borderWidth"],
      key: "style.borderWidth"
    ) ?? 0
    elevation = try ReactionPopupParser.cgFloat(
      dictionary?["elevation"],
      key: "style.elevation"
    ) ?? 10
    emojiFontSize = try ReactionPopupParser.cgFloat(
      dictionary?["emojiFontSize"],
      key: "style.emojiFontSize"
    ) ?? 26
    emojiPopScale = try ReactionPopupParser.cgFloat(
      dictionary?["emojiPopScale"],
      key: "style.emojiPopScale"
    ) ?? 1.12
    gap = try ReactionPopupParser.cgFloat(
      dictionary?["gap"],
      key: "style.gap"
    ) ?? 10
    itemBackgroundColor = try ReactionPopupParser.color(
      dictionary?["itemBackgroundColor"],
      key: "style.itemBackgroundColor"
    ) ?? UIColor.clear
    itemBorderColor = try ReactionPopupParser.color(
      dictionary?["itemBorderColor"],
      key: "style.itemBorderColor"
    ) ?? UIColor.clear
    itemBorderRadius = try ReactionPopupParser.cgFloat(
      dictionary?["itemBorderRadius"],
      key: "style.itemBorderRadius"
    ) ?? 20
    itemBorderWidth = try ReactionPopupParser.cgFloat(
      dictionary?["itemBorderWidth"],
      key: "style.itemBorderWidth"
    ) ?? 0
    itemSelectedBackgroundColor = try ReactionPopupParser.color(
      dictionary?["itemSelectedBackgroundColor"],
      key: "style.itemSelectedBackgroundColor"
    ) ?? UIColor.tertiarySystemFill
    itemPressedBackgroundColor = try ReactionPopupParser.color(
      dictionary?["itemPressedBackgroundColor"],
      key: "style.itemPressedBackgroundColor"
    ) ?? itemSelectedBackgroundColor.withAlphaComponent(0.8)
    itemSize = try ReactionPopupParser.cgFloat(
      dictionary?["itemSize"],
      key: "style.itemSize"
    ) ?? (emojiFontSize + 16)
    paddingHorizontal = try ReactionPopupParser.cgFloat(
      dictionary?["paddingHorizontal"],
      key: "style.paddingHorizontal"
    ) ?? 12
    paddingVertical = try ReactionPopupParser.cgFloat(
      dictionary?["paddingVertical"],
      key: "style.paddingVertical"
    ) ?? 10
    plusBackgroundColor = try ReactionPopupParser.color(
      dictionary?["plusBackgroundColor"],
      key: "style.plusBackgroundColor"
    ) ?? itemBackgroundColor
    plusIconColor = try ReactionPopupParser.color(
      dictionary?["plusIconColor"],
      key: "style.plusIconColor"
    ) ?? UIColor.secondaryLabel
    plusPressedBackgroundColor = try ReactionPopupParser.color(
      dictionary?["plusPressedBackgroundColor"],
      key: "style.plusPressedBackgroundColor"
    ) ?? itemPressedBackgroundColor
    shadowColor = try ReactionPopupParser.color(
      dictionary?["shadowColor"],
      key: "style.shadowColor"
    ) ?? UIColor.black
    shadowOffsetX = try ReactionPopupParser.cgFloat(
      dictionary?["shadowOffsetX"],
      key: "style.shadowOffsetX"
    ) ?? 0
    shadowOffsetY = try ReactionPopupParser.cgFloat(
      dictionary?["shadowOffsetY"],
      key: "style.shadowOffsetY"
    ) ?? 8
    shadowOpacity = Float(
      max(
        0,
        min(
          1,
          try ReactionPopupParser.cgFloat(dictionary?["shadowOpacity"], key: "style.shadowOpacity") ?? 0.18
        )
      )
    )
    shadowRadius = try ReactionPopupParser.cgFloat(
      dictionary?["shadowRadius"],
      key: "style.shadowRadius"
    ) ?? 16
    hoverScale = try ReactionPopupParser.cgFloat(
      dictionary?["hoverScale"],
      key: "style.hoverScale"
    ) ?? 1.6
    hoverTranslationY = try ReactionPopupParser.cgFloat(
      dictionary?["hoverTranslationY"],
      key: "style.hoverTranslationY"
    ) ?? 14
    hoverLabelBackgroundColor = try ReactionPopupParser.color(
      dictionary?["hoverLabelBackgroundColor"],
      key: "style.hoverLabelBackgroundColor"
    ) ?? UIColor.black.withAlphaComponent(0.75)
    hoverLabelBorderRadius = try ReactionPopupParser.cgFloat(
      dictionary?["hoverLabelBorderRadius"],
      key: "style.hoverLabelBorderRadius"
    ) ?? 10
    hoverLabelColor = try ReactionPopupParser.color(
      dictionary?["hoverLabelColor"],
      key: "style.hoverLabelColor"
    ) ?? UIColor.white
    hoverLabelFontSize = try ReactionPopupParser.cgFloat(
      dictionary?["hoverLabelFontSize"],
      key: "style.hoverLabelFontSize"
    ) ?? 12
    hoverLabelPaddingHorizontal = try ReactionPopupParser.cgFloat(
      dictionary?["hoverLabelPaddingHorizontal"],
      key: "style.hoverLabelPaddingHorizontal"
    ) ?? 8
    hoverLabelPaddingVertical = try ReactionPopupParser.cgFloat(
      dictionary?["hoverLabelPaddingVertical"],
      key: "style.hoverLabelPaddingVertical"
    ) ?? 4
  }
}

struct ReactionPopupAnimation {
  let emojiPopScale: CGFloat
  let itemStagger: TimeInterval
  let openDuration: TimeInterval
  let trayInitialScale: CGFloat

  init(dictionary: [String: Any]?, style: ReactionPopupStyle) throws {
    emojiPopScale = try ReactionPopupParser.cgFloat(
      dictionary?["emojiPopScale"],
      key: "animation.emojiPopScale"
    ) ?? style.emojiPopScale
    itemStagger = TimeInterval(
      (try ReactionPopupParser.cgFloat(dictionary?["itemStaggerMs"], key: "animation.itemStaggerMs") ?? 18) / 1000
    )
    openDuration = TimeInterval(
      (try ReactionPopupParser.cgFloat(dictionary?["openDurationMs"], key: "animation.openDurationMs") ?? 180) / 1000
    )
    trayInitialScale = try ReactionPopupParser.cgFloat(
      dictionary?["trayInitialScale"],
      key: "animation.trayInitialScale"
    ) ?? 0.96
  }
}

struct ReactionPopupShowParams {
  let anchorId: String
  let items: [ReactionPopupItemPayload]
  let selectedId: String?
  let centerOnScreen: Bool
  let dismissOnBackdropPress: Bool
  let dismissOnDragOut: Bool
  let edgePadding: CGFloat
  let plusEnabled: Bool
  let plusAccessibilityLabel: String
  let preferredPlacement: ReactionPopupPlacement
  let showLabels: Bool
  let hideLabelsInSafeArea: Bool
  let haptics: ReactionPopupHaptics
  let animation: ReactionPopupAnimation
  let style: ReactionPopupStyle

  init(dictionary: [String: Any]) throws {
    anchorId = try ReactionPopupParser.requiredString(dictionary["anchorId"], key: "anchorId")

    let rawItems = try ReactionPopupParser.dictionaryArray(dictionary["items"], key: "items")
    guard !rawItems.isEmpty else {
      throw EmojisPopupError(
        .emptyItems,
        description: "items must contain at least one reaction"
      )
    }

    items = try rawItems.map(ReactionPopupItemPayload.init(dictionary:))
    selectedId = try ReactionPopupParser.optionalString(dictionary["selectedId"], key: "selectedId")
    centerOnScreen = try ReactionPopupParser.bool(
      dictionary["centerOnScreen"],
      key: "centerOnScreen"
    ) ?? false
    dismissOnBackdropPress = try ReactionPopupParser.bool(
      dictionary["dismissOnBackdropPress"],
      key: "dismissOnBackdropPress"
    ) ?? true
    dismissOnDragOut = try ReactionPopupParser.bool(
      dictionary["dismissOnDragOut"],
      key: "dismissOnDragOut"
    ) ?? false
    edgePadding = max(
      0,
      try ReactionPopupParser.cgFloat(dictionary["edgePadding"], key: "edgePadding") ?? 12
    )
    plusEnabled = try ReactionPopupParser.bool(dictionary["plusEnabled"], key: "plusEnabled") ?? false
    plusAccessibilityLabel = try ReactionPopupParser.optionalString(
      dictionary["plusAccessibilityLabel"],
      key: "plusAccessibilityLabel"
    ) ?? "More reactions"

    let preferredPlacementString = try ReactionPopupParser.optionalString(
      dictionary["preferredPlacement"],
      key: "preferredPlacement"
    ) ?? ReactionPopupPlacement.auto.rawValue
    guard let preferredPlacement = ReactionPopupPlacement(rawValue: preferredPlacementString) else {
      throw EmojisPopupError(
        .invalidParams,
        description: "preferredPlacement must be one of auto, above, or below"
      )
    }
    self.preferredPlacement = preferredPlacement
    showLabels = try ReactionPopupParser.bool(
      dictionary["showLabels"],
      key: "showLabels"
    ) ?? true
    hideLabelsInSafeArea = try ReactionPopupParser.bool(
      dictionary["hideLabelsInSafeArea"],
      key: "hideLabelsInSafeArea"
    ) ?? true

    style = try ReactionPopupStyle(
      dictionary: try ReactionPopupParser.optionalDictionary(dictionary["style"], key: "style")
    )
    haptics = try ReactionPopupHaptics(
      dictionary: try ReactionPopupParser.optionalDictionary(dictionary["haptics"], key: "haptics")
    )
    animation = try ReactionPopupAnimation(
      dictionary: try ReactionPopupParser.optionalDictionary(dictionary["animation"], key: "animation"),
      style: style
    )
  }
}

private enum ReactionPopupParser {
  static func requiredString(_ value: Any?, key: String) throws -> String {
    guard let string = try optionalString(value, key: key) else {
      throw EmojisPopupError(
        .invalidParams,
        description: "\(key) must be a non-empty string"
      )
    }
    return string
  }

  static func optionalString(_ value: Any?, key: String) throws -> String? {
    guard let value, let string = value as? String else {
      return nil
    }
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }

  static func bool(_ value: Any?, key: String) throws -> Bool? {
    guard let value, !(value is NSNull) else {
      return nil
    }
    if let bool = value as? Bool {
      return bool
    }
    if let number = value as? NSNumber {
      return number.boolValue
    }
    throw EmojisPopupError(
      .invalidParams,
      description: "\(key) must be a boolean"
    )
  }

  static func cgFloat(_ value: Any?, key: String) throws -> CGFloat? {
    guard let value, !(value is NSNull) else {
      return nil
    }

    let number: Double?
    if let value = value as? CGFloat {
      number = Double(value)
    } else if let value = value as? Double {
      number = value
    } else if let value = value as? Float {
      number = Double(value)
    } else if let value = value as? Int {
      number = Double(value)
    } else if let value = value as? NSNumber {
      number = value.doubleValue
    } else {
      number = nil
    }

    guard let number, number.isFinite else {
      throw EmojisPopupError(
        .invalidParams,
        description: "\(key) must be a finite number"
      )
    }
    return CGFloat(number)
  }

  static func dictionaryArray(_ value: Any?, key: String) throws -> [[String: Any]] {
    guard let value else {
      throw EmojisPopupError(
        .invalidParams,
        description: "\(key) must be an array of objects"
      )
    }
    guard let array = value as? [[String: Any]] else {
      throw EmojisPopupError(
        .invalidParams,
        description: "\(key) must be an array of objects"
      )
    }
    return array
  }

  static func optionalDictionary(_ value: Any?, key: String) throws -> [String: Any]? {
    guard let value, !(value is NSNull) else {
      return nil
    }
    guard let dictionary = value as? [String: Any] else {
      throw EmojisPopupError(
        .invalidParams,
        description: "\(key) must be an object"
      )
    }
    return dictionary
  }

  static func color(_ value: Any?, key: String) throws -> UIColor? {
    guard let value, !(value is NSNull) else {
      return nil
    }
    guard let hex = value as? String, let color = UIColor(emojisPopupHexString: hex) else {
      throw EmojisPopupError(
        .invalidParams,
        description: "\(key) must be a valid hex color string"
      )
    }
    return color
  }
}

private extension UIColor {
  convenience init?(emojisPopupHexString: String) {
    let sanitized = emojisPopupHexString
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "#", with: "")

    let expanded: String
    switch sanitized.count {
    case 3:
      expanded = sanitized.map { "\($0)\($0)" }.joined() + "FF"
    case 4:
      expanded = sanitized.map { "\($0)\($0)" }.joined()
    case 6:
      expanded = sanitized + "FF"
    case 8:
      expanded = sanitized
    default:
      return nil
    }

    var rgbaValue: UInt64 = 0
    guard Scanner(string: expanded).scanHexInt64(&rgbaValue) else {
      return nil
    }

    let red = CGFloat((rgbaValue & 0xFF00_0000) >> 24) / 255
    let green = CGFloat((rgbaValue & 0x00FF_0000) >> 16) / 255
    let blue = CGFloat((rgbaValue & 0x0000_FF00) >> 8) / 255
    let alpha = CGFloat(rgbaValue & 0x0000_00FF) / 255

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
