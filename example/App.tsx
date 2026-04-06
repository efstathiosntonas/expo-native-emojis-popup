import React, { useCallback, useState } from 'react';
import {
  Pressable,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  useColorScheme,
  View,
} from 'react-native';
import { EmojisPopup, EmojisPopupModule } from 'expo-native-emojis-popup';
import type {
  NativeReactionPopupItem,
  NativeReactionPopupStyle,
  ShowReactionPopupParams,
} from 'expo-native-emojis-popup';

const EMOJI_ITEMS: NativeReactionPopupItem[] = [
  { emoji: '\u{1F44D}', emoji_name: 'Like', id: 'like' },
  { emoji: '\u2764\uFE0F', emoji_name: 'Love', id: 'love' },
  { emoji: '\u{1F602}', emoji_name: 'Haha', id: 'haha' },
  { emoji: '\u{1F62E}', emoji_name: 'Wow', id: 'wow' },
  { emoji: '\u{1F622}', emoji_name: 'Sad', id: 'sad' },
  { emoji: '\u{1F621}', emoji_name: 'Angry', id: 'angry' },
];

type SectionResult = { id: string; type: 'select' } | { type: 'plus' } | null;

// ---------------------------------------------------------------------------
// Theme-aware style builders
// ---------------------------------------------------------------------------
function facebookStyle(isDark: boolean): NativeReactionPopupStyle {
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

function facebookParams(isDark: boolean): ShowReactionPopupParams {
  return {
    anchorId: 'facebook-anchor',
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
    style: facebookStyle(isDark),
  };
}

function darkMinimalStyle(isDark: boolean): NativeReactionPopupStyle {
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

function colorfulStyle(isDark: boolean): NativeReactionPopupStyle {
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

function centeredStyle(isDark: boolean): NativeReactionPopupStyle {
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

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------
function resultLabel(result: SectionResult): string {
  if (!result) return 'No selection yet';
  if (result.type === 'plus') return 'Plus tapped';
  const item = EMOJI_ITEMS.find((i) => i.id === result.id);
  return item ? `${item.emoji}  ${item.emoji_name}` : result.id;
}

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------
export default function App() {
  const systemScheme = useColorScheme();
  const [centeredResult, setCenteredResult] = useState<SectionResult>(null);
  const [colorfulResult, setColorfulResult] = useState<SectionResult>(null);
  const [dark, setDark] = useState(systemScheme === 'dark');
  const [darkResult, setDarkResult] = useState<SectionResult>(null);
  const [facebookResult, setFacebookResult] = useState<SectionResult>(null);

  const bg = dark ? '#121212' : '#F2F2F7';
  const cardBg = dark ? '#1C1C1E' : '#FFFFFF';
  const resultBg = dark ? '#2C2C2E' : '#F0F0F5';
  const subtitleColor = dark ? '#ABABAB' : '#6E6E73';
  const textColor = dark ? '#FFFFFF' : '#000000';

  // -- Facebook (longPressDrag) --
  const handleDragSelect = useCallback(
    (event: { nativeEvent: { id: string } }) => {
      setFacebookResult({ id: event.nativeEvent.id, type: 'select' });
    },
    [],
  );

  const handleDragDismiss = useCallback(() => {
    // keep last result visible on dismiss
  }, []);

  const handleDragPlus = useCallback(() => {
    setFacebookResult({ type: 'plus' });
  }, []);

  // -- Dark Minimal (imperative) --
  const showDarkMinimal = useCallback(async () => {
    const result = await EmojisPopupModule.show({
      anchorId: 'dark-anchor',
      animation: {
        emojiPopScale: 1.05,
        itemStaggerMs: 20,
        openDurationMs: 220,
        trayInitialScale: 0.9,
      },
      haptics: { onOpen: true, onSelect: true },
      items: EMOJI_ITEMS,
      preferredPlacement: 'above',
      style: darkMinimalStyle(dark),
    });
    if (result.type !== 'dismiss') {
      setDarkResult(result);
    }
  }, [dark]);

  // -- Colorful (imperative) --
  const showColorful = useCallback(async () => {
    const result = await EmojisPopupModule.show({
      anchorId: 'colorful-anchor',
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
      style: colorfulStyle(dark),
    });
    if (result.type !== 'dismiss') {
      setColorfulResult(result);
    }
  }, [dark]);

  // -- Centered (imperative) --
  const showCentered = useCallback(async () => {
    const result = await EmojisPopupModule.show({
      anchorId: 'centered-anchor',
      animation: {
        emojiPopScale: 1.2,
        itemStaggerMs: 30,
        openDurationMs: 300,
        trayInitialScale: 0.8,
      },
      centerOnScreen: true,
      haptics: { onOpen: true, onSelect: true },
      items: EMOJI_ITEMS,
      style: centeredStyle(dark),
    });
    if (result.type !== 'dismiss') {
      setCenteredResult(result);
    }
  }, [dark]);

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: bg }]}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <Text style={[styles.title, { color: textColor }]}>
          expo-native-emojis-popup
        </Text>
        <Text style={[styles.subtitle, { color: subtitleColor }]}>
          Native emoji reaction popup demos
        </Text>

        <Pressable
          onPress={() => setDark((d) => !d)}
          style={({ pressed }) => [
            styles.themeToggle,
            { backgroundColor: dark ? '#2C2C2E' : '#E5E5EA', opacity: pressed ? 0.7 : 1 },
          ]}
        >
          <Text style={[styles.themeToggleText, { color: textColor }]}>
            {dark ? '\u{1F31C}  Dark Mode' : '\u{1F31E}  Light Mode'}
          </Text>
        </Pressable>

        {/* Section 1: Facebook-style (longPressDrag) */}
        <View style={[styles.card, { backgroundColor: cardBg }]}>
          <Text style={[styles.cardTitle, { color: textColor }]}>
            Facebook-style
          </Text>
          <Text style={[styles.cardDescription, { color: subtitleColor }]}>
            Long press and drag to select. Large emojis, rounded tray, hover labels, plus button enabled.
          </Text>

          <EmojisPopup
            anchorId="facebook-anchor"
            dragParams={facebookParams(dark)}
            gestureMode="longPressDrag"
            onDragDismiss={handleDragDismiss}
            onDragPlus={handleDragPlus}
            onDragSelect={handleDragSelect}
          >
            <Pressable
              style={({ pressed }) => [
                styles.triggerButton,
                { backgroundColor: '#1877F2', opacity: pressed ? 0.85 : 1 },
              ]}
            >
              <Text style={styles.triggerText}>
                {'\u{1F44D}'}  Long Press Me
              </Text>
            </Pressable>
          </EmojisPopup>

          <View style={[styles.resultBox, { backgroundColor: resultBg }]}>
            <Text style={[styles.resultLabel, { color: subtitleColor }]}>Result</Text>
            <Text style={[styles.resultValue, { color: textColor }]}>
              {resultLabel(facebookResult)}
            </Text>
          </View>
        </View>

        {/* Section 2: Dark Minimal */}
        <View style={[styles.card, { backgroundColor: cardBg }]}>
          <Text style={[styles.cardTitle, { color: textColor }]}>
            Dark Minimal
          </Text>
          <Text style={[styles.cardDescription, { color: subtitleColor }]}>
            Sleek dark tray, smaller emojis, subtle shadow. No plus button. Standard tap trigger.
          </Text>

          <EmojisPopup anchorId="dark-anchor">
            <Pressable
              onPress={showDarkMinimal}
              style={({ pressed }) => [
                styles.triggerButton,
                { backgroundColor: '#1F1F1F', opacity: pressed ? 0.85 : 1 },
              ]}
            >
              <Text style={styles.triggerText}>
                {'\u{1F5A4}'}  Tap Me
              </Text>
            </Pressable>
          </EmojisPopup>

          <View style={[styles.resultBox, { backgroundColor: resultBg }]}>
            <Text style={[styles.resultLabel, { color: subtitleColor }]}>Result</Text>
            <Text style={[styles.resultValue, { color: textColor }]}>
              {resultLabel(darkResult)}
            </Text>
          </View>
        </View>

        {/* Section 3: Colorful / Playful */}
        <View style={[styles.card, { backgroundColor: cardBg }]}>
          <Text style={[styles.cardTitle, { color: textColor }]}>
            Colorful / Playful
          </Text>
          <Text style={[styles.cardDescription, { color: subtitleColor }]}>
            Vibrant pink borders, slow stagger animation, big pop scale. Plus button with custom colors.
          </Text>

          <EmojisPopup anchorId="colorful-anchor">
            <Pressable
              onPress={showColorful}
              style={({ pressed }) => [
                styles.triggerButton,
                { backgroundColor: '#FF69B4', opacity: pressed ? 0.85 : 1 },
              ]}
            >
              <Text style={styles.triggerText}>
                {'\u{1F308}'}  Tap Me
              </Text>
            </Pressable>
          </EmojisPopup>

          <View style={[styles.resultBox, { backgroundColor: resultBg }]}>
            <Text style={[styles.resultLabel, { color: subtitleColor }]}>Result</Text>
            <Text style={[styles.resultValue, { color: textColor }]}>
              {resultLabel(colorfulResult)}
            </Text>
          </View>
        </View>

        {/* Section 4: Centered on Screen */}
        <View style={[styles.card, { backgroundColor: cardBg }]}>
          <Text style={[styles.cardTitle, { color: textColor }]}>
            Centered on Screen
          </Text>
          <Text style={[styles.cardDescription, { color: subtitleColor }]}>
            Popup appears centered on the screen instead of anchored. Great for comment-level reactions.
          </Text>

          <EmojisPopup anchorId="centered-anchor">
            <Pressable
              onPress={showCentered}
              style={({ pressed }) => [
                styles.triggerButton,
                { backgroundColor: '#7E80B6', opacity: pressed ? 0.85 : 1 },
              ]}
            >
              <Text style={styles.triggerText}>
                {'\u{1F3AF}'}  Tap Me
              </Text>
            </Pressable>
          </EmojisPopup>

          <View style={[styles.resultBox, { backgroundColor: resultBg }]}>
            <Text style={[styles.resultLabel, { color: subtitleColor }]}>Result</Text>
            <Text style={[styles.resultValue, { color: textColor }]}>
              {resultLabel(centeredResult)}
            </Text>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 16,
    elevation: 3,
    marginBottom: 20,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
  },
  cardDescription: {
    fontSize: 13,
    lineHeight: 18,
    marginBottom: 16,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 6,
  },
  container: {
    flex: 1,
  },
  resultBox: {
    borderRadius: 10,
    marginTop: 14,
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  resultLabel: {
    fontSize: 11,
    fontWeight: '500',
    letterSpacing: 0.5,
    marginBottom: 4,
    textTransform: 'uppercase',
  },
  resultValue: {
    fontSize: 16,
    fontWeight: '600',
  },
  scrollContent: {
    paddingBottom: 48,
    paddingHorizontal: 20,
    paddingTop: 24,
  },
  subtitle: {
    fontSize: 14,
    marginBottom: 20,
    marginTop: 4,
    textAlign: 'center',
  },
  themeToggle: {
    alignSelf: 'center',
    borderRadius: 20,
    marginBottom: 24,
    paddingHorizontal: 20,
    paddingVertical: 10,
  },
  themeToggleText: {
    fontSize: 15,
    fontWeight: '600',
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    textAlign: 'center',
  },
  triggerButton: {
    alignSelf: 'flex-start',
    borderRadius: 12,
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  triggerText: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '600',
  },
});
