import { StyleSheet } from 'react-native';

export const sharedStyles = StyleSheet.create({
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
