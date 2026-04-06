export type NativeReactionPopupItem = {
  id: string;
  emoji: string;
  emoji_name: string;
};

export type NativeReactionPopupPlacement = 'above' | 'below' | 'auto';

export type NativeReactionPopupHaptics = {
  onOpen?: boolean;
  onPlus?: boolean;
  onSelect?: boolean;
};

export type NativeReactionPopupAnimation = {
  emojiPopScale?: number;
  itemStaggerMs?: number;
  openDurationMs?: number;
  trayInitialScale?: number;
};

export type NativeReactionPopupStyle = {
  backgroundColor?: string;
  backdropColor?: string;
  backdropOpacity?: number;
  borderColor?: string;
  borderRadius?: number;
  borderWidth?: number;
  elevation?: number;
  emojiFontSize?: number;
  emojiPopScale?: number;
  gap?: number;
  itemBackgroundColor?: string;
  itemBorderColor?: string;
  itemBorderRadius?: number;
  itemBorderWidth?: number;
  itemPressedBackgroundColor?: string;
  itemSelectedBackgroundColor?: string;
  itemSize?: number;
  paddingHorizontal?: number;
  paddingVertical?: number;
  plusBackgroundColor?: string;
  plusIconColor?: string;
  plusPressedBackgroundColor?: string;
  shadowColor?: string;
  shadowOffsetX?: number;
  shadowOffsetY?: number;
  shadowOpacity?: number;
  shadowRadius?: number;
  hoverScale?: number;
  hoverTranslationY?: number;
  hoverLabelBackgroundColor?: string;
  hoverLabelBorderRadius?: number;
  hoverLabelColor?: string;
  hoverLabelFontSize?: number;
  hoverLabelPaddingHorizontal?: number;
  hoverLabelPaddingVertical?: number;
};

export type ShowReactionPopupParams = {
  anchorId: string;
  items: NativeReactionPopupItem[];
  selectedId?: string | null;
  centerOnScreen?: boolean;
  dismissOnBackdropPress?: boolean;
  dismissOnDragOut?: boolean;
  edgePadding?: number;
  plusEnabled?: boolean;
  plusAccessibilityLabel?: string;
  preferredPlacement?: NativeReactionPopupPlacement;
  haptics?: NativeReactionPopupHaptics;
  animation?: NativeReactionPopupAnimation;
  style?: NativeReactionPopupStyle;
  onOpen?: () => void;
  onClose?: (result: NativeReactionPopupCloseResult) => void;
};

export type NativeReactionPopupCloseResult =
  | { type: 'select'; id: string; cancelled: false }
  | { type: 'plus'; cancelled: false }
  | { type: 'dismiss'; cancelled: true };

export type NativeReactionPopupResult =
  | { type: 'select'; id: string }
  | { type: 'plus' }
  | { type: 'dismiss' };

export type NativeReactionPopupErrorCode =
  | 'ANCHOR_NOT_FOUND'
  | 'ANCHOR_NOT_MEASURABLE'
  | 'EMPTY_ITEMS'
  | 'INVALID_PARAMS'
  | 'PRESENTATION_FAILED';

export type DragSelectEvent = {
  nativeEvent: { id: string };
};

export type DragPlusEvent = {
  nativeEvent: Record<string, never>;
};

export type DragDismissEvent = {
  nativeEvent: Record<string, never>;
};
