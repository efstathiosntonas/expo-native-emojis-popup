import React, { useCallback, useState } from 'react';
import { Pressable, Text } from 'react-native';
import { EmojisPopup } from 'expo-native-emojis-popup';
import type {
  NativeReactionPopupItem,
  NativeReactionPopupStyle,
  ShowReactionPopupParams,
} from 'expo-native-emojis-popup';
import { DemoCard } from './DemoCard';
import { sharedStyles } from './sharedStyles';

const EMOJI_ITEMS: NativeReactionPopupItem[] = [
  { emoji: '\u{1F44D}', emoji_name: 'Like', id: 'like' },
  { emoji: '\u2764\uFE0F', emoji_name: 'Love', id: 'love' },
  { emoji: '\u{1F602}', emoji_name: 'Haha', id: 'haha' },
  { emoji: '\u{1F62E}', emoji_name: 'Wow', id: 'wow' },
  { emoji: '\u{1F622}', emoji_name: 'Sad', id: 'sad' },
  { emoji: '\u{1F621}', emoji_name: 'Angry', id: 'angry' },
];

const ANCHOR_ID = 'facebook-anchor';

function buildStyle(isDark: boolean): NativeReactionPopupStyle {
  return {
    backgroundColor: isDark ? '#242526' : '#FFFFFF',
    borderRadius: 28,
    elevation: 8,
    emojiFontSize: 28,
    gap: 2,
    hoverLabelBackgroundColor: isDark ? '#FFFFFFDD' : '#00000099',
    hoverLabelBorderRadius: 10,
    hoverLabelColor: isDark ? '#000000' : '#FFFFFF',
    hoverLabelFontSize: 12,
    hoverLabelPaddingHorizontal: 8,
    hoverLabelPaddingVertical: 4,
    hoverScale: 2.4,
    hoverTranslationY: 64,
    itemPressedBackgroundColor: isDark ? '#3A3B3C' : '#F0F0F0',
    itemSelectedBackgroundColor: isDark ? '#3A3B3C' : '#E8F0FE',
    itemSize: 46,
    paddingHorizontal: 8,
    paddingVertical: 8,
    plusBackgroundColor: isDark ? '#3A3B3C' : '#F0F0F0',
    plusIconColor: isDark ? '#B0B3B8' : '#65676B',
    plusPressedBackgroundColor: isDark ? '#4E4F50' : '#D8D8D8',
    shadowColor: '#000000',
    shadowOffsetY: 4,
    shadowOpacity: isDark ? 0.3 : 0.15,
    shadowRadius: 12,
  };
}

function buildParams(isDark: boolean): ShowReactionPopupParams {
  return {
    anchorId: ANCHOR_ID,
    animation: {
      emojiPopScale: 1.15,
      itemStaggerMs: 25,
      openDurationMs: 280,
      trayInitialScale: 0.85,
    },
    haptics: { onOpen: true, onPlus: true, onSelect: true },
    items: EMOJI_ITEMS,
    plusAccessibilityLabel: 'More reactions',
    plusEnabled: true,
    preferredPlacement: 'above',
    showLabels: true,
    style: buildStyle(isDark),
  };
}

type SectionResult = { id: string; type: 'select' } | { type: 'plus' } | null;

function toLabel(result: SectionResult): string {
  if (!result) return 'No selection yet';
  if (result.type === 'plus') return 'Plus tapped';
  const item = EMOJI_ITEMS.find((i) => i.id === result.id);
  return item ? `${item.emoji}  ${item.emoji_name}` : result.id;
}

interface FacebookStyleDemoProps {
  dark: boolean;
}

export function FacebookStyleDemo({ dark }: FacebookStyleDemoProps) {
  const [result, setResult] = useState<SectionResult>(null);

  const handleSelect = useCallback(
    (event: { nativeEvent: { id: string } }) => {
      setResult({ id: event.nativeEvent.id, type: 'select' });
    },
    [],
  );

  const handlePlus = useCallback(() => {
    setResult({ type: 'plus' });
  }, []);

  return (
    <DemoCard
      dark={dark}
      description="Long press and drag to select. Large emojis, rounded tray, hover labels, plus button enabled."
      resultLabel={toLabel(result)}
      title="Facebook-style"
    >
      <EmojisPopup
        anchorId={ANCHOR_ID}
        dragParams={buildParams(dark)}
        gestureMode="longPressDrag"
        onDragDismiss={() => {/* keep last result visible on dismiss */}}
        onDragPlus={handlePlus}
        onDragSelect={handleSelect}
      >
        <Pressable
          style={({ pressed }) => [
            sharedStyles.triggerButton,
            { backgroundColor: '#1877F2', opacity: pressed ? 0.85 : 1 },
          ]}
        >
          <Text style={sharedStyles.triggerText}>{'\u{1F44D}'}  Long Press Me</Text>
        </Pressable>
      </EmojisPopup>
    </DemoCard>
  );
}
