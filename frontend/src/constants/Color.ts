// constants/Colors.ts
import '@/global.css';
import { Platform } from 'react-native';

export const Colors = {
  light: {
    text: '#000000',
    background: '#ffffff',
    backgroundElement: '#F0F0F3',
    backgroundSelected: '#E0E1E6',
    textSecondary: '#60646C',
    primary: '#2563EB', // Blue for light mode
    primaryLight: '#60A5FA', // Lighter blue for light mode
    error: '#EF4444', // ✅ Added: Red for errors
    success: '#22C55E', // ✅ Added: Green for success
    warning: '#F59E0B', // ✅ Added: Yellow for warnings
    info: '#3B82F6', // ✅ Added: Blue for info
  },
  dark: {
    text: '#ffffff',
    background: '#000000',
    backgroundElement: '#212225',
    backgroundSelected: '#2E3135',
    textSecondary: '#B0B4BA',
    primary: '#60A5FA', // Blue for dark mode
    primaryLight: '#93C5FD', // Lighter blue for dark mode
    error: '#F87171', // ✅ Added: Red for errors (lighter for dark mode)
    success: '#34D399', // ✅ Added: Green for success (lighter for dark mode)
    warning: '#FBBF24', // ✅ Added: Yellow for warnings (lighter for dark mode)
    info: '#60A5FA', // ✅ Added: Blue for info (lighter for dark mode)
  },
} as const;

export type ThemeColor = keyof typeof Colors.light & keyof typeof Colors.dark;

export const Fonts = Platform.select({
  ios: {
    sans: 'system-ui',
    serif: 'ui-serif',
    rounded: 'ui-rounded',
    mono: 'ui-monospace',
  },
  default: {
    sans: 'normal',
    serif: 'serif',
    rounded: 'normal',
    mono: 'monospace',
  },
  web: {
    sans: 'var(--font-display)',
    serif: 'var(--font-serif)',
    rounded: 'var(--font-rounded)',
    mono: 'var(--font-mono)',
  },
});

export const Spacing = {
  half: 2,
  one: 4,
  two: 8,
  three: 16,
  four: 24,
  five: 32,
  six: 64,
} as const;

export const BottomTabInset = Platform.select({ ios: 50, android: 80 }) ?? 0;
export const MaxContentWidth = 800;