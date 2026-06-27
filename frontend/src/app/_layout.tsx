// app/_layout.tsx
import { DarkTheme, DefaultTheme, ThemeProvider } from 'expo-router';
import { useColorScheme, View } from 'react-native';
import { useEffect, createContext, useContext } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { Stack, useRouter, useSegments } from 'expo-router';
import { Text } from 'react-native';
import { AnimatedSplashOverlay } from '@/components/animated-icon';
import { useAuthStore } from '@/store/authStore';
import React from 'react';

const AppThemeContext = createContext({
  background: '#F8FAFC',
  surface: '#FFFFFF',
  text: '#0F172A',
  textSecondary: '#64748B',
  border: '#E2E8F0',
  isDark: false,
});

export const useAppTheme = () => useContext(AppThemeContext);

export default function RootLayout() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const { isAuthenticated, initialized, user, checkAuth } = useAuthStore();
  const segments = useSegments();
  const router = useRouter();

  const themeValues = {
    background: isDark ? '#0F172A' : '#F8FAFC',
    surface: isDark ? '#1E293B' : '#FFFFFF',
    text: isDark ? '#F8FAFC' : '#0F172A',
    textSecondary: isDark ? '#94A3B8' : '#64748B',
    border: isDark ? '#334155' : '#E2E8F0',
    isDark,
  };

  useEffect(() => {
    checkAuth().catch(err => {
      console.error('Auth check error:', err);
    });
  }, []);

  useEffect(() => {
    if (!initialized) return;

    const currentPath = segments.join('/');
    const isInAuthGroup = currentPath.startsWith('(auth)');
    const isRoleSelection = currentPath.startsWith('(auth)/role-selection');
    const isRoot = currentPath === '' || currentPath === 'index';

    console.log('Navigation check:', {
      currentPath,
      isAuthenticated,
      isInAuthGroup,
      isRoleSelection,
      isRoot,
      hasCompletedOnboarding: user?.hasCompletedOnboarding
    });

    // 1. Not authenticated → login
    if (!isAuthenticated && !isInAuthGroup) {
      router.replace('/login' as const);
      return;
    }

    // 2. Authenticated but not onboarded → role selection
    if (
      isAuthenticated &&
      user &&
      !user.hasCompletedOnboarding &&
      !isRoleSelection
    ) {
      console.log('Redirecting to role-selection...');
      router.replace('/(auth)/role-selection');
      return;
    }

    // 3. Authenticated + onboarded → tabs
    if (
      isAuthenticated &&
      user?.hasCompletedOnboarding &&
      (isInAuthGroup || isRoot)
    ) {
      console.log('Redirecting to tabs...');
      router.replace('/(tabs)' as any);
      return;
    }
  }, [isAuthenticated, initialized, segments, user?.hasCompletedOnboarding]);

  if (!initialized) {
    return (
      <ThemeProvider value={isDark ? DarkTheme : DefaultTheme}>
        <AppThemeContext.Provider value={themeValues}>
          <AnimatedSplashOverlay />
        </AppThemeContext.Provider>
      </ThemeProvider>
    );
  }

  try {
    return (
      <SafeAreaProvider>
        <ThemeProvider value={isDark ? DarkTheme : DefaultTheme}>
          <AppThemeContext.Provider value={themeValues}>
            <StatusBar style={isDark ? 'light' : 'dark'} />

            <Stack
              screenOptions={{
                headerShown: false,
                contentStyle: { backgroundColor: themeValues.background },
                animation: 'slide_from_right',
              }}
            >
              <Stack.Screen name="(auth)" options={{ headerShown: false }} />
              <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
            </Stack>
          </AppThemeContext.Provider>
        </ThemeProvider>
      </SafeAreaProvider>
    );
  } catch (error) {
    console.error('Error rendering stack:', error);
    return (
      <View
        style={{
          flex: 1,
          justifyContent: 'center',
          alignItems: 'center',
          backgroundColor: '#F8FAFC',
        }}
      >
        <Text style={{ color: '#0F172A' }}>Error loading app</Text>
        <Text style={{ color: '#64748B' }}>{String(error)}</Text>
      </View>
    );
  }
}