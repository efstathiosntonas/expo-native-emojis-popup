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

const ANCHOR_ID = 'dark-anchor';

function buildStyle(isDark: boolean): NativeReactionPopupStyle {
  return {
    backdropColor: '#000000',
    backdropOpacity: isDark ? 0.5 : 0.25,
    backgroundColor: '#1F1F1F',
    borderRadius: 14,
    elevation: 4,
    emojiFontSize: 22,
    gap: 4,
    hoverLabelBackgroundColor: '#FFFFFF22',
    hoverLabelBorderRadius: 6,
    hoverLabelColor: '#FFFFFFDD',
    hoverLabelFontSize: 11,
    hoverLabelPaddingHorizontal: 6,
    hoverLabelPaddingVertical: 3,
    hoverScale: 1.6,
    hoverTranslationY: 40,
    itemSize: 38,
    paddingHorizontal: 10,
    paddingVertical: 8,
    shadowColor: '#000000',
    shadowOffsetY: 2,
    shadowOpacity: isDark ? 0.4 : 0.1,
    shadowRadius: 6,
  };
}

type SectionResult = { id: string; type: 'select' } | { type: 'plus' } | null;

function toLabel(result: SectionResult): string {
  if (!result) return 'No selection yet';
  if (result.type === 'plus') return 'Plus tapped';
  const item = EMOJI_ITEMS.find((i) => i.id === result.id);
  return item ? `${item.emoji}  ${item.emoji_name}` : result.id;
}

interface DarkMinimalDemoProps {
  dark: boolean;
}

export function DarkMinimalDemo({ dark }: DarkMinimalDemoProps) {
  const [result, setResult] = useState<SectionResult>(null);

  const handlePress = useCallback(async () => {
    const res = await EmojisPopupModule.show({
      anchorId: ANCHOR_ID,
      animation: {
        emojiPopScale: 1.05,
        itemStaggerMs: 20,
        openDurationMs: 220,
        trayInitialScale: 0.9,
      },
      haptics: { onOpen: true, onSelect: true },
      items: EMOJI_ITEMS,
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
      description="Sleek dark tray, smaller emojis, subtle shadow. No plus button. Standard tap trigger."
      resultLabel={toLabel(result)}
      title="Dark Minimal"
    >
      <EmojisPopup anchorId={ANCHOR_ID}>
        <Pressable
          onPress={handlePress}
          style={({ pressed }) => [
            sharedStyles.triggerButton,
            { backgroundColor: '#1F1F1F', opacity: pressed ? 0.85 : 1 },
          ]}
        >
          <Text style={sharedStyles.triggerText}>{'\u{1F5A4}'}  Tap Me</Text>
        </Pressable>
      </EmojisPopup>
    </DemoCard>
  );
}
