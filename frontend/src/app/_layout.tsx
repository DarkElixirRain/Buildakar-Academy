// frontend/src/app/_layout.tsx
import { DarkTheme, DefaultTheme, ThemeProvider as ExpoThemeProvider } from 'expo-router';
import { useColorScheme, View } from 'react-native';
import { useEffect } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { Stack, useRouter, useSegments } from 'expo-router';
import { Text } from 'react-native';
import { AnimatedSplashOverlay } from '@/components/animated-icon';
import { useAuthStore } from '@/store/authStore';
import { ThemeProvider, useTheme } from '@/context/themeContext';
import React from 'react';

// App wrapper that uses the theme context
function AppContent() {
  const { isDarkMode, colors } = useTheme();
  const { isAuthenticated, initialized, user, checkAuth, requiresRoleSelection } = useAuthStore();
  const segments = useSegments();
  const router = useRouter();

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
      hasCompletedOnboarding: user?.hasCompletedOnboarding,
      requiresRoleSelection,
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
      requiresRoleSelection &&
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
  }, [isAuthenticated, initialized, requiresRoleSelection, segments, user?.hasCompletedOnboarding]);

  if (!initialized) {
    return <AnimatedSplashOverlay />;
  }

  return (
    <SafeAreaProvider>
      <StatusBar style={isDarkMode ? 'light' : 'dark'} />
      <Stack
        screenOptions={{
          headerShown: false,
          contentStyle: { backgroundColor: colors.background },
          animation: 'slide_from_right',
        }}
      >
        <Stack.Screen name="(auth)" options={{ headerShown: false }} />
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="(instructor)" options={{ headerShown: false }} />
      </Stack>

      
    </SafeAreaProvider>
  );
}

// Main layout with ThemeProvider
export default function RootLayout() {
  return (
    <ThemeProvider>
      <AppContent />
    </ThemeProvider>
  );
}