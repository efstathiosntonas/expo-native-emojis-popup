import React from 'react';
import { Pressable, StyleSheet, Text } from 'react-native';

interface ThemeToggleProps {
  dark: boolean;
  onToggle: () => void;
}

export function ThemeToggle({ dark, onToggle }: ThemeToggleProps) {
  const textColor = dark ? '#FFFFFF' : '#000000';

  return (
    <Pressable
      onPress={onToggle}
      style={({ pressed }) => [
        styles.themeToggle,
        { backgroundColor: dark ? '#2C2C2E' : '#E5E5EA', opacity: pressed ? 0.7 : 1 },
      ]}
    >
      <Text style={[styles.themeToggleText, { color: textColor }]}>
        {dark ? '\u{1F31C}  Dark Mode' : '\u{1F31E}  Light Mode'}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
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
});
