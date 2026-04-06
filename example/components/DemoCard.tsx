import React from 'react';
import { Text, View } from 'react-native';
import { sharedStyles } from './sharedStyles';

interface DemoCardProps {
  children: React.ReactNode;
  description: string;
  dark: boolean;
  resultLabel: string;
  title: string;
}

export function DemoCard({ children, description, dark, resultLabel, title }: DemoCardProps) {
  const cardBg = dark ? '#1C1C1E' : '#FFFFFF';
  const resultBg = dark ? '#2C2C2E' : '#F0F0F5';
  const subtitleColor = dark ? '#ABABAB' : '#6E6E73';
  const textColor = dark ? '#FFFFFF' : '#000000';

  return (
    <View style={[sharedStyles.card, { backgroundColor: cardBg }]}>
      <Text style={[sharedStyles.cardTitle, { color: textColor }]}>{title}</Text>
      <Text style={[sharedStyles.cardDescription, { color: subtitleColor }]}>
        {description}
      </Text>

      {children}

      <View style={[sharedStyles.resultBox, { backgroundColor: resultBg }]}>
        <Text style={[sharedStyles.resultLabel, { color: subtitleColor }]}>Result</Text>
        <Text style={[sharedStyles.resultValue, { color: textColor }]}>{resultLabel}</Text>
      </View>
    </View>
  );
}
