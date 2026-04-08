# expo-native-emojis-popup

[![npm version](https://img.shields.io/npm/v/expo-native-emojis-popup.svg)](https://www.npmjs.com/package/expo-native-emojis-popup)

A fully native emoji reaction popup for React Native. Built entirely in Swift (iOS) and Kotlin (Android) -- every interaction runs at 60+ FPS with zero bridge overhead.

| iOS | Android |
|-|-|
| <video src="https://github.com/user-attachments/assets/148f0923-96dc-45a4-9e28-8ca194037ed3" width="300" /> | <video src="https://github.com/user-attachments/assets/33c2c557-5c7e-4538-9468-f0e5d3ba0db4" width="300" /> |

## Highlights

- **Fully native on both platforms** -- Swift (iOS) and Kotlin (Android), no JavaScript rendering or web views
- **60+ FPS animations** -- spring-based hover effects, staggered emoji entrances, and smooth drag interactions
- **Anchor-based positioning** -- popup appears relative to a trigger element with smart placement
- **Long-press drag-to-select** -- open with long press, drag over emojis to hover, release to select
- **Hover labels** -- emoji names appear above hovered items during drag gestures
- **Haptic feedback** -- configurable per-event (open, select, plus button)
- **Plus button** -- optional "more reactions" button that pairs with [expo-native-sheet-emojis](https://github.com/efstathiosntonas/expo-native-sheet-emojis) for a complete reaction system (see [Companion](#companion-expo-native-sheet-emojis))
- **Selected state** -- highlights the currently active reaction
- **Smart placement** -- auto/above/below with safe area awareness and edge padding
- **Full style customization** -- 30+ style properties covering colors, borders, shadows, and hover labels
- **Animation customization** -- stagger timing, duration, scale, and initial tray scale
- **Accessibility** -- VoiceOver/TalkBack support, respects reduce motion preferences
- **Two APIs** -- imperative `show()`/`dismiss()` and declarative `<EmojisPopup>`

## Installation

```bash
npx expo install expo-native-emojis-popup
```

For bare workflow projects, run `npx expo prebuild` after installation.

For bare React Native projects, you must ensure that you have [installed and configured the `expo` package](https://docs.expo.dev/bare/installing-expo-modules/) before continuing.

```bash
yarn add expo-native-emojis-popup
cd ios && pod install
```

## Quick Start

The imperative API shows a native popup anchored to a view and returns the user's action:

```typescript
import { EmojisPopupModule } from 'expo-native-emojis-popup';

async function showReactions() {
  const result = await EmojisPopupModule.show({
    anchorId: 'message-42',
    items: [
      { emoji: '❤️', emoji_name: 'Red Heart', id: 'heart' },
      { emoji: '👍', emoji_name: 'Thumbs Up', id: 'thumbsup' },
      { emoji: '😂', emoji_name: 'Face with Tears of Joy', id: 'laugh' },
      { emoji: '🔥', emoji_name: 'Fire', id: 'fire' },
      { emoji: '😢', emoji_name: 'Crying Face', id: 'sad' },
    ],
    plusEnabled: true,
    selectedId: 'heart',
  });

  switch (result.type) {
    case 'select':
      console.log('Selected reaction:', result.id);
      break;
    case 'plus':
      console.log('Open full emoji picker');
      break;
    case 'dismiss':
      console.log('Popup dismissed');
      break;
  }
}
```

## Declarative Usage

Wrap a trigger element with `EmojisPopup` for gesture-driven interaction:

```tsx
import { EmojisPopup } from 'expo-native-emojis-popup';
import type { ShowReactionPopupParams } from 'expo-native-emojis-popup';

function MessageBubble({ message }) {
  const anchorId = `message-${message.id}`;
  
  const dragParams: Omit<ShowReactionPopupParams, 'onOpen' | 'onClose'> = {
    anchorId,
    haptics: { onOpen: true, onSelect: true },
    items: [
      { emoji: '❤️', emoji_name: 'Red Heart', id: 'heart' },
      { emoji: '👍', emoji_name: 'Thumbs Up', id: 'thumbsup' },
      { emoji: '😂', emoji_name: 'Face with Tears of Joy', id: 'laugh' },
    ],
    plusEnabled: true,
    selectedId: message.currentReaction,
  };

  return (
    <EmojisPopup
      anchorId={anchorId}
      dragParams={dragParams}
      gestureMode="longPressDrag"
      onDragDismiss={() => console.log('Dismissed')}
      onDragPlus={() => console.log('Open full picker')}
      onDragSelect={(event) => console.log('Selected:', event.nativeEvent.id)}
    >
      <Text>{message.text}</Text>
    </EmojisPopup>
  );
}
```

## Exports

```typescript
import { EmojisPopup, EmojisPopupModule } from 'expo-native-emojis-popup';
import type {
  DragDismissEvent,
  DragPlusEvent,
  DragSelectEvent,
  EmojisPopupModuleType,
  EmojisPopupProps,
  NativeReactionPopupAnimation,
  NativeReactionPopupErrorCode,
  NativeReactionPopupHaptics,
  NativeReactionPopupItem,
  NativeReactionPopupPlacement,
  NativeReactionPopupResult,
  NativeReactionPopupStyle,
  ShowReactionPopupParams,
} from 'expo-native-emojis-popup';
```

## TypeScript Types

### NativeReactionPopupItem

```typescript
type NativeReactionPopupItem = {
  emoji: string;
  emoji_name: string;
  id: string;
};
```

### NativeReactionPopupStyle

```typescript
type NativeReactionPopupStyle = {
  backdropColor?: string;
  backdropOpacity?: number;
  backgroundColor?: string;
  borderColor?: string;
  borderRadius?: number;
  borderWidth?: number;
  elevation?: number;
  emojiFontSize?: number;
  emojiPopScale?: number;
  gap?: number;
  hoverLabelBackgroundColor?: string;
  hoverLabelBorderRadius?: number;
  hoverLabelColor?: string;
  hoverLabelFontSize?: number;
  hoverLabelPaddingHorizontal?: number;
  hoverLabelPaddingVertical?: number;
  hoverScale?: number;
  hoverTranslationY?: number;
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
};
```

### ShowReactionPopupParams

```typescript
type ShowReactionPopupParams = {
  anchorId: string;
  animation?: {
    emojiPopScale?: number;
    itemStaggerMs?: number;
    openDurationMs?: number;
    trayInitialScale?: number;
  };
  centerOnScreen?: boolean;
  dismissOnBackdropPress?: boolean;
  dismissOnDragOut?: boolean;
  edgePadding?: number;
  haptics?: {
    onOpen?: boolean;
    onPlus?: boolean;
    onSelect?: boolean;
  };
  items: NativeReactionPopupItem[];
  onClose?: (result: NativeReactionPopupCloseResult) => void;
  onOpen?: () => void;
  plusAccessibilityLabel?: string;
  plusEnabled?: boolean;
  preferredPlacement?: 'above' | 'below' | 'auto';
  selectedId?: string | null;
  showLabels?: boolean;
  hideLabelsInSafeArea?: boolean;
  style?: NativeReactionPopupStyle;
};
```

### NativeReactionPopupResult

```typescript
type NativeReactionPopupResult =
  | { type: 'select'; id: string }
  | { type: 'plus' }
  | { type: 'dismiss' };
```

### NativeReactionPopupCloseResult

Extended result type with a `cancelled` boolean, passed to the `onClose` callback:

```typescript
type NativeReactionPopupCloseResult =
  | { type: 'select'; id: string; cancelled: false }
  | { type: 'plus'; cancelled: false }
  | { type: 'dismiss'; cancelled: true };
```

### NativeReactionPopupErrorCode

```typescript
type NativeReactionPopupErrorCode =
  | 'ANCHOR_NOT_FOUND'
  | 'ANCHOR_NOT_MEASURABLE'
  | 'EMPTY_ITEMS'
  | 'INVALID_PARAMS'
  | 'PRESENTATION_FAILED';
```

## API Reference

### EmojisPopupModule.show(params)

Presents the reaction popup anchored to a native view. Returns a promise that resolves when the user selects a reaction, taps plus, or dismisses the popup.

**Parameters:**

| Name | Type | Description |
|-|-|-|
| params | `ShowReactionPopupParams` | Configuration object (see below) |

**Returns:** `Promise<NativeReactionPopupResult>`

The result is a discriminated union:
- `{ type: 'select', id: string }` when a reaction is selected
- `{ type: 'plus' }` when the plus button is tapped
- `{ type: 'dismiss' }` when the popup is dismissed without selection

**ShowReactionPopupParams fields:**

| Field | Type | Default | Description |
|-|-|-|-|
| anchorId | `string` | required | ID of the anchor view to position the popup relative to |
| animation | `NativeReactionPopupAnimation` | -- | Animation timing configuration |
| centerOnScreen | `boolean` | `false` | Center popup on screen instead of anchoring |
| dismissOnBackdropPress | `boolean` | `true` | Dismiss when tapping outside the popup |
| dismissOnDragOut | `boolean` | `false` | Dismiss when drag is released outside the popup (by default the popup stays open and converts to tap mode) |
| edgePadding | `number` | `12` | Minimum distance from screen edges |
| haptics | `NativeReactionPopupHaptics` | all `false` | Haptic feedback configuration |
| items | `NativeReactionPopupItem[]` | required | Array of emoji items to display |
| plusAccessibilityLabel | `string` | `'More reactions'` | Accessibility label for the plus button |
| plusEnabled | `boolean` | `false` | Show the plus button for "more reactions" (see [Companion: expo-native-sheet-emojis](#companion-expo-native-sheet-emojis)) |
| preferredPlacement | `'above' \| 'below' \| 'auto'` | `'auto'` | Preferred popup position relative to anchor |
| selectedId | `string \| null` | `null` | ID of the currently selected reaction |
| showLabels | `boolean` | `true` | Show emoji name labels on hover during drag gestures |
| hideLabelsInSafeArea | `boolean` | `true` | Hide hover labels when they would overlap the safe area (notch/status bar). Useful when the popup appears near the top of the screen and the scaled emoji + label would clip under the notch |
| style | `NativeReactionPopupStyle` | -- | Visual style overrides |

### EmojisPopupModule.dismiss()

Programmatically dismisses the reaction popup.

**Returns:** `Promise<void>`

### EmojisPopup

A declarative React component that wraps a trigger element and manages popup presentation via gestures.

**Props:**

| Prop | Type | Default | Description |
|-|-|-|-|
| anchorId | `string` | required | Unique identifier for this wrapper view |
| children | `React.ReactElement` | required | Trigger element to wrap |
| dragParams | `Omit<ShowReactionPopupParams, 'onOpen' \| 'onClose'>` | -- | Popup configuration for drag gesture mode |
| gestureMode | `'none' \| 'longPressDrag'` | `'none'` | Gesture handling mode |
| onDragDismiss | `(event: DragDismissEvent) => void` | -- | Called when drag ends without selection |
| onDragPlus | `(event: DragPlusEvent) => void` | -- | Called when plus button is reached via drag |
| onDragSelect | `(event: DragSelectEvent) => void` | -- | Called when a reaction is selected via drag |

## Gesture Modes

The `gestureMode` prop on `EmojisPopup` controls how the popup is triggered:

- **`none`** (default) -- No gesture handling. Use with the imperative API (`EmojisPopupModule.show()`) for full control over when the popup appears.
- **`longPressDrag`** -- Long press opens the popup, then drag your finger over emojis to hover and preview. Releasing your finger over an emoji selects it. Releasing outside the popup keeps it open and converts to tap mode (set `dismissOnDragOut: true` to dismiss instead). Hover labels showing the emoji name appear above each item during drag.

## Placement

The `preferredPlacement` option controls where the popup appears relative to the anchor view:

- **`auto`** (default) -- Prefers placing the popup above the anchor. Falls back to below if there is not enough space above.
- **`above`** -- Always positions above the anchor if space permits.
- **`below`** -- Always positions below the anchor if space permits.

All placement modes respect safe area insets and the `edgePadding` value to ensure the popup stays within visible bounds.

## Style Presets

### Facebook-like Dark

```typescript
const facebookDarkStyle: NativeReactionPopupStyle = {
  backdropColor: '#000000',
  backdropOpacity: 0.4,
  backgroundColor: '#242526',
  borderRadius: 28,
  elevation: 8,
  emojiFontSize: 28,
  gap: 4,
  hoverLabelBackgroundColor: '#242526',
  hoverLabelBorderRadius: 8,
  hoverLabelColor: '#E4E6EB',
  hoverLabelFontSize: 12,
  hoverLabelPaddingHorizontal: 8,
  hoverLabelPaddingVertical: 4,
  hoverScale: 1.4,
  hoverTranslationY: -8,
  itemBorderRadius: 22,
  itemPressedBackgroundColor: '#3A3B3C',
  itemSelectedBackgroundColor: '#3A3B3C',
  itemSize: 44,
  paddingHorizontal: 8,
  paddingVertical: 6,
  plusBackgroundColor: '#3A3B3C',
  plusIconColor: '#B0B3B8',
  plusPressedBackgroundColor: '#4E4F50',
  shadowColor: '#000000',
  shadowOffsetY: 4,
  shadowOpacity: 0.3,
  shadowRadius: 12,
};
```

### Light Minimal

```typescript
const lightMinimalStyle: NativeReactionPopupStyle = {
  backdropColor: '#000000',
  backdropOpacity: 0.15,
  backgroundColor: '#FFFFFF',
  borderRadius: 24,
  elevation: 4,
  emojiFontSize: 26,
  gap: 2,
  hoverLabelBackgroundColor: '#333333',
  hoverLabelBorderRadius: 6,
  hoverLabelColor: '#FFFFFF',
  hoverLabelFontSize: 11,
  hoverLabelPaddingHorizontal: 6,
  hoverLabelPaddingVertical: 3,
  hoverScale: 1.3,
  hoverTranslationY: -6,
  itemBorderRadius: 20,
  itemPressedBackgroundColor: '#F0F0F0',
  itemSelectedBackgroundColor: '#E8F0FE',
  itemSize: 40,
  paddingHorizontal: 6,
  paddingVertical: 6,
  plusBackgroundColor: '#F5F5F5',
  plusIconColor: '#9E9E9E',
  plusPressedBackgroundColor: '#E0E0E0',
  shadowColor: '#000000',
  shadowOffsetY: 2,
  shadowOpacity: 0.1,
  shadowRadius: 8,
};
```

## Custom Hook Pattern

For apps that use the reaction popup in multiple places, extract a reusable hook to centralize configuration:

```typescript
import { EmojisPopupModule } from 'expo-native-emojis-popup';
import type {
  NativeReactionPopupItem,
  NativeReactionPopupResult,
  ShowReactionPopupParams,
} from 'expo-native-emojis-popup';

const DEFAULT_REACTIONS: NativeReactionPopupItem[] = [
  { emoji: '❤️', emoji_name: 'Red Heart', id: 'heart' },
  { emoji: '👍', emoji_name: 'Thumbs Up', id: 'thumbsup' },
  { emoji: '😂', emoji_name: 'Face with Tears of Joy', id: 'laugh' },
  { emoji: '😮', emoji_name: 'Face with Open Mouth', id: 'surprise' },
  { emoji: '😢', emoji_name: 'Crying Face', id: 'sad' },
  { emoji: '🔥', emoji_name: 'Fire', id: 'fire' },
];

export function useReactionPopup() {
  const theme = useAppTheme();

  const show = async (
    anchorId: string,
    selectedId?: string | null,
    overrides?: Partial<ShowReactionPopupParams>
  ): Promise<NativeReactionPopupResult> => {
    return EmojisPopupModule.show({
      anchorId,
      items: DEFAULT_REACTIONS,
      plusEnabled: true,
      selectedId,
      style: {
        backgroundColor: theme.colors.surface,
        hoverLabelBackgroundColor: theme.colors.tooltip,
        hoverLabelColor: theme.colors.tooltipText,
        itemSelectedBackgroundColor: theme.colors.primaryLight,
        shadowColor: theme.colors.shadow,
      },
      ...overrides,
    });
  };

  return { show };
}
```

Then use it anywhere:

```typescript
const reactionPopup = useReactionPopup();

const result = await reactionPopup.show('message-42', currentReactionId);
if (result.type === 'select') {
  toggleReaction(result.id);
} else if (result.type === 'plus') {
  openFullEmojiPicker();
}
```

## Error Codes

When `EmojisPopupModule.show()` rejects, the error includes a `code` property:

| Code | Description |
|-|-|
| `ANCHOR_NOT_FOUND` | No native view found with the given `anchorId` |
| `ANCHOR_NOT_MEASURABLE` | Anchor view exists but could not be measured (not yet laid out) |
| `EMPTY_ITEMS` | The `items` array is empty |
| `INVALID_PARAMS` | Parameters failed validation (e.g., missing required fields) |
| `PRESENTATION_FAILED` | Native presentation failed (e.g., another popup is already visible) |

## Companion: expo-native-sheet-emojis

The plus button is designed to open a full emoji picker for extended reactions beyond the quick-select tray. The companion module [expo-native-sheet-emojis](https://github.com/efstathiosntonas/expo-native-sheet-emojis) provides exactly this -- a fully native emoji picker bottom sheet with 1900+ emojis, search across 21 languages, skin tone selection, and configurable theming.

Together they form a complete reaction system:

1. User long-presses a message/post -> `expo-native-emojis-popup` shows the quick reaction tray
2. User taps the plus button -> your app presents `expo-native-sheet-emojis` for the full emoji catalog
3. Selected emoji flows back into your reaction system

```typescript
import { EmojisPopupModule } from 'expo-native-emojis-popup';
import { EmojiSheetModule } from 'expo-native-sheet-emojis';

const result = await EmojisPopupModule.show({
  anchorId: 'message:42',
  items: quickReactions,
  plusEnabled: true,
});

if (result.type === 'plus') {
  // Open the full emoji picker
  const sheetResult = await EmojiSheetModule.present({ theme: 'dark' });
  if (!sheetResult.cancelled) {
    handleReaction(sheetResult.emoji);
  }
} else if (result.type === 'select') {
  handleReaction(result.id);
}
```

## Related Projects

- [expo-native-sheet-emojis](https://github.com/efstathiosntonas/expo-native-sheet-emojis) -- Companion full emoji picker bottom sheet (1900+ emojis, multilingual search, skin tones, theming)

## LLM / AI Agent Reference

If you're an AI agent or using an LLM to integrate this module, see [llms.txt](https://raw.githubusercontent.com/efstathiosntonas/expo-native-emojis-popup/refs/heads/main/llms.txt) for a concise, structured reference with all types, APIs, and usage patterns.

## Contributing

Contributions are welcome! Please read the [contributing guide](CONTRIBUTING.md) before submitting a pull request.

## License

MIT
