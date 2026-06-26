// app/_layout.tsx
import { DarkTheme, DefaultTheme, ThemeProvider } from 'expo-router';
import { useColorScheme, View } from 'react-native';
import { useEffect } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { Stack, useRouter, useSegments } from 'expo-router';
import { Text } from 'react-native';
import { AnimatedSplashOverlay } from '@/components/animated-icon';
import { useAuthStore } from '@/store/authStore';

// Create a Theme Context for your app
import React, { createContext, useContext } from 'react';

// ✅ Create a proper theme context
const AppThemeContext = createContext({
  background: '#F8FAFC',
  surface: '#FFFFFF',
  text: '#0F172A',
  textSecondary: '#64748B',
  border: '#E2E8F0',
  isDark: false,
});

export const useAppTheme = () => useContext(AppThemeContext);

console.log('RootLayout loading...');

export default function RootLayout() {
  console.log('RootLayout rendering...');
  
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const { isAuthenticated, initialized, checkAuth } = useAuthStore();
  const segments = useSegments();
  const router = useRouter();

  // ✅ Theme values based on system theme
  const themeValues = {
    background: isDark ? '#0F172A' : '#F8FAFC',
    surface: isDark ? '#1E293B' : '#FFFFFF',
    text: isDark ? '#F8FAFC' : '#0F172A',
    textSecondary: isDark ? '#94A3B8' : '#64748B',
    border: isDark ? '#334155' : '#E2E8F0',
    isDark,
  };

  console.log('Auth state:', { isAuthenticated, initialized });

  // Initialize auth on mount
  useEffect(() => {
    console.log('Checking auth...');
    checkAuth().catch(err => {
      console.error('Auth check error:', err);
    });
  }, []);

  // Handle navigation based on auth state
  useEffect(() => {
    console.log('Navigation effect - initialized:', initialized, 'segments:', segments);
    
    if (!initialized) {
      console.log('Not initialized yet, skipping navigation');
      return;
    }

    const currentPath = segments.join('/');
    const isInAuthGroup = currentPath.startsWith('(auth)');
    const isRoot = currentPath === '' || currentPath === 'index';

    console.log('Navigation check:', { 
      currentPath, 
      isAuthenticated, 
      isInAuthGroup,
      isRoot 
    });

    if (!isAuthenticated && !isInAuthGroup) {
      console.log('Redirecting to login...');
      router.replace('/(auth)/login');
      return;
    }

    if (isAuthenticated && (isInAuthGroup || isRoot)) {
      console.log('Redirecting to tabs...');
      router.replace('/(tabs)');
      return;
    }
  }, [isAuthenticated, initialized, segments]);

  // Show splash screen while initializing
  if (!initialized) {
    console.log('Showing splash screen...');
    return (
      <ThemeProvider value={isDark ? DarkTheme : DefaultTheme}>
        <AppThemeContext.Provider value={themeValues}>
          <AnimatedSplashOverlay />
        </AppThemeContext.Provider>
      </ThemeProvider>
    );
  }

  console.log('Rendering main stack...');
  
  try {
    return (
      <SafeAreaProvider>
        <ThemeProvider value={isDark ? DarkTheme : DefaultTheme}>
          {/* ✅ Wrap everything with AppThemeContext */}
          <AppThemeContext.Provider value={themeValues}>
            <StatusBar style={isDark ? "light" : "dark"} />
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
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#F8FAFC' }}>
        <Text style={{ color: '#0F172A' }}>Error loading app</Text>
        <Text style={{ color: '#64748B' }}>{String(error)}</Text>
      </View>
    );
  }
}