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

const ANCHOR_ID = 'colorful-anchor';

function buildStyle(isDark: boolean): NativeReactionPopupStyle {
  return {
    backgroundColor: isDark ? '#3D1F2B' : '#FFF0F5',
    borderColor: isDark ? '#FF69B4' : '#FF69B4',
    borderRadius: 22,
    borderWidth: 2,
    elevation: 6,
    emojiFontSize: 22,
    emojiPopScale: 1.35,
    gap: 4,
    hoverLabelBackgroundColor: isDark ? '#FFB6C1' : '#FF69B4',
    hoverLabelBorderRadius: 8,
    hoverLabelColor: isDark ? '#1A0A10' : '#FFFFFF',
    hoverLabelFontSize: 13,
    hoverLabelPaddingHorizontal: 10,
    hoverLabelPaddingVertical: 4,
    hoverScale: 2.0,
    hoverTranslationY: 56,
    itemBorderColor: isDark ? '#FF69B480' : '#FFB6C1',
    itemBorderRadius: 14,
    itemBorderWidth: 1.5,
    itemPressedBackgroundColor: '#FF69B4',
    itemSize: 40,
    paddingHorizontal: 8,
    paddingVertical: 8,
    plusBackgroundColor: isDark ? '#5C2D42' : '#FFB6C1',
    plusIconColor: isDark ? '#FF69B4' : '#FF1493',
    plusPressedBackgroundColor: '#FF69B4',
    shadowColor: '#FF1493',
    shadowOffsetY: 3,
    shadowOpacity: isDark ? 0.4 : 0.25,
    shadowRadius: 10,
  };
}

type SectionResult = { id: string; type: 'select' } | { type: 'plus' } | null;

function toLabel(result: SectionResult): string {
  if (!result) return 'No selection yet';
  if (result.type === 'plus') return 'Plus tapped';
  const item = EMOJI_ITEMS.find((i) => i.id === result.id);
  return item ? `${item.emoji}  ${item.emoji_name}` : result.id;
}

interface ColorfulDemoProps {
  dark: boolean;
}

export function ColorfulDemo({ dark }: ColorfulDemoProps) {
  const [result, setResult] = useState<SectionResult>(null);

  const handlePress = useCallback(async () => {
    const res = await EmojisPopupModule.show({
      anchorId: ANCHOR_ID,
      animation: {
        emojiPopScale: 1.35,
        itemStaggerMs: 40,
        openDurationMs: 350,
        trayInitialScale: 0.7,
      },
      haptics: { onOpen: true, onPlus: true, onSelect: true },
      items: EMOJI_ITEMS,
      plusAccessibilityLabel: 'Add custom reaction',
      plusEnabled: true,
      preferredPlacement: 'above',
      style: buildStyle(dark),
    });
    if (res.type !== 'dismiss') {
      setResult(res);
    }
  }, [dark]);

  return (
    <DemoCard
      dark={dark}
      description="Vibrant pink borders, slow stagger animation, big pop scale. Plus button with custom colors."
      resultLabel={toLabel(result)}
      title="Colorful / Playful"
    >
      <EmojisPopup anchorId={ANCHOR_ID}>
        <Pressable
          onPress={handlePress}
          style={({ pressed }) => [
            sharedStyles.triggerButton,
            { backgroundColor: '#FF69B4', opacity: pressed ? 0.85 : 1 },
          ]}
        >
          <Text style={sharedStyles.triggerText}>{'\u{1F308}'}  Tap Me</Text>
        </Pressable>
      </EmojisPopup>
    </DemoCard>
  );
}
