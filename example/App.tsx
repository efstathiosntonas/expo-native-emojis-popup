import React, { useState } from 'react';
import { SafeAreaView, ScrollView, StyleSheet, Text, useColorScheme } from 'react-native';
import { CenteredDemo } from './components/CenteredDemo';
import { ColorfulDemo } from './components/ColorfulDemo';
import { DarkMinimalDemo } from './components/DarkMinimalDemo';
import { DualModeDemo } from './components/DualModeDemo';
import { FacebookStyleDemo } from './components/FacebookStyleDemo';
import { ThemeToggle } from './components/ThemeToggle';

export default function App() {
  const systemScheme = useColorScheme();
  const [dark, setDark] = useState(systemScheme === 'dark');

  const bg = dark ? '#121212' : '#F2F2F7';
  const subtitleColor = dark ? '#ABABAB' : '#6E6E73';
  const textColor = dark ? '#FFFFFF' : '#000000';

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: bg }]}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <Text style={[styles.title, { color: textColor }]}>expo-native-emojis-popup</Text>
        <Text style={[styles.subtitle, { color: subtitleColor }]}>
          Native emoji reaction popup demos
        </Text>

        <ThemeToggle dark={dark} onToggle={() => setDark((d) => !d)} />

        <DualModeDemo dark={dark} />
        <FacebookStyleDemo dark={dark} />
        <DarkMinimalDemo dark={dark} />
        <ColorfulDemo dark={dark} />
        <CenteredDemo dark={dark} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
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
  title: {
    fontSize: 24,
    fontWeight: '700',
    textAlign: 'center',
  },
});
