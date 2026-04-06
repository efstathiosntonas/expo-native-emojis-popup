import React, { useCallback, useState } from 'react';
import { Pressable, Text } from 'react-native';
import { EmojisPopup, EmojisPopupModule } from 'expo-native-emojis-popup';
import type { NativeReactionPopupItem, NativeReactionPopupStyle } from 'expo-native-emojis-popup';
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

const ANCHOR_ID = 'centered-anchor';

function buildStyle(isDark: boolean): NativeReactionPopupStyle {
  return {
    backdropColor: '#000000',
    backdropOpacity: isDark ? 0.5 : 0.35,
    backgroundColor: isDark ? '#2C2C2E' : '#F5F5F5',
    borderRadius: 24,
    elevation: 10,
    emojiFontSize: 26,
    gap: 6,
    hoverLabelBackgroundColor: isDark ? '#FFFFFFDD' : '#333333',
    hoverLabelBorderRadius: 8,
    hoverLabelColor: isDark ? '#000000' : '#FFFFFF',
    hoverLabelFontSize: 13,
    hoverLabelPaddingHorizontal: 10,
    hoverLabelPaddingVertical: 5,
    hoverScale: 1.8,
    hoverTranslationY: 48,
    itemSize: 44,
    paddingHorizontal: 10,
    paddingVertical: 8,
    shadowColor: '#000000',
    shadowOffsetY: 6,
    shadowOpacity: isDark ? 0.4 : 0.2,
    shadowRadius: 16,
  };
}

type SectionResult = { id: string; type: 'select' } | { type: 'plus' } | null;

function toLabel(result: SectionResult): string {
  if (!result) return 'No selection yet';
  if (result.type === 'plus') return 'Plus tapped';
  const item = EMOJI_ITEMS.find((i) => i.id === result.id);
  return item ? `${item.emoji}  ${item.emoji_name}` : result.id;
}

interface CenteredDemoProps {
  dark: boolean;
}

export function CenteredDemo({ dark }: CenteredDemoProps) {
  const [result, setResult] = useState<SectionResult>(null);

  const handlePress = useCallback(async () => {
    const res = await EmojisPopupModule.show({
      anchorId: ANCHOR_ID,
      animation: {
        emojiPopScale: 1.2,
        itemStaggerMs: 30,
        openDurationMs: 300,
        trayInitialScale: 0.8,
      },
      centerOnScreen: true,
      haptics: { onOpen: true, onSelect: true },
      items: EMOJI_ITEMS,
      style: buildStyle(dark),
    });
    if (res.type !== 'dismiss') {
      setResult(res);
    }
  }, [dark]);

  return (
    <DemoCard
      dark={dark}
      description="Popup appears centered on the screen instead of anchored. Great for comment-level reactions."
      resultLabel={toLabel(result)}
      title="Centered on Screen"
    >
      <EmojisPopup anchorId={ANCHOR_ID}>
        <Pressable
          onPress={handlePress}
          style={({ pressed }) => [
            sharedStyles.triggerButton,
            { backgroundColor: '#7E80B6', opacity: pressed ? 0.85 : 1 },
          ]}
        >
          <Text style={sharedStyles.triggerText}>{'\u{1F3AF}'}  Tap Me</Text>
        </Pressable>
      </EmojisPopup>
    </DemoCard>
  );
}
