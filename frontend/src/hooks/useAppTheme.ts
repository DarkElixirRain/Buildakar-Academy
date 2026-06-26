// hooks/useAppTheme.ts
import { useColorScheme } from 'react-native';

export const useAppTheme = () => {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  return {
    isDark,
    colors: {
      background: isDark ? '#0F172A' : '#F8FAFC',
      surface: isDark ? '#1E293B' : '#FFFFFF',
      surfaceLight: isDark ? '#334155' : '#F1F5F9',
      text: isDark ? '#F8FAFC' : '#0F172A',
      textSecondary: isDark ? '#94A3B8' : '#64748B',
      textMuted: isDark ? '#64748B' : '#94A3B8',
      border: isDark ? '#334155' : '#E2E8F0',
      primary: '#2563EB',
      primaryLight: isDark ? '#1D4ED8' : '#EFF6FF',
      success: '#10B981',
      warning: '#F59E0B',
      error: '#EF4444',
      shadow: isDark ? 'rgba(0,0,0,0.3)' : 'rgba(0,0,0,0.05)',
    }
  };
};