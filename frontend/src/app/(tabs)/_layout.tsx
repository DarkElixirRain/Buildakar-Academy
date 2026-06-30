// app/(tabs)/_layout.tsx
import React from 'react';
import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { View, Platform, Dimensions } from 'react-native';
import { useTheme } from '@/context/themeContext';
import { useAuthStore } from '@/store/authStore';

const { width, height } = Dimensions.get('window');

export default function TabsLayout() {
  const insets = useSafeAreaInsets();
  const { isDarkMode, colors } = useTheme();
  const user = useAuthStore(state => state.user);
  const isInstructor = user?.role === 'INSTRUCTOR' || user?.role === 'ADMIN';

  // Calculate responsive tab bar height
  const getTabBarHeight = () => {
    const baseHeight = Platform.OS === 'ios' ? 85 : 75;
    const bottomInset = insets.bottom > 0 ? insets.bottom : 10;
    return baseHeight + bottomInset;
  };

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: colors.background,
          borderTopWidth: 1,
          borderTopColor: colors.backgroundElement,
          height: getTabBarHeight(),
          paddingTop: 8,
          paddingBottom: insets.bottom > 0 ? insets.bottom : 10,
          paddingHorizontal: 4,
          shadowColor: colors.text,
          shadowOffset: { width: 0, height: -2 },
          shadowOpacity: isDarkMode ? 0.3 : 0.05,
          shadowRadius: 4,
          elevation: 4,
          position: 'relative',
          bottom: 0,
        },
        tabBarActiveTintColor: colors.text,
        tabBarInactiveTintColor: colors.textSecondary,
        tabBarLabelStyle: {
          fontSize: 10,
          fontWeight: '500',
          marginTop: 2,
          marginBottom: 4,
        },
        tabBarIconStyle: {
          marginTop: 2,
          marginBottom: 0,
        },
        tabBarItemStyle: {
          paddingVertical: 0,
          paddingHorizontal: 0,
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, size, focused }) => (
            <Ionicons
              name={focused ? 'home' : 'home-outline'}
              size={size || 24}
              color={color}
            />
          ),
        }}
      />

      <Tabs.Screen
        name="explore"
        options={{
          title: 'Explore',
          tabBarIcon: ({ color, size, focused }) => (
            <Ionicons
              name={focused ? 'compass' : 'compass-outline'}
              size={size || 24}
              color={color}
            />
          ),
        }}
      />

      <Tabs.Screen
        name="live"
        options={{
          title: 'Live',
          tabBarIcon: ({ color, size, focused }) => (
            <View className="relative">
              <Ionicons
                name={focused ? 'videocam' : 'videocam-outline'}
                size={size || 24}
                color={color}
              />
              {/* Live indicator dot */}
              <View
                className="absolute -top-1 -right-1 w-2.5 h-2.5 bg-[#EF4444] rounded-full border-2"
                style={{ borderColor: colors.background }}
              >
                <View className="absolute inset-0 rounded-full animate-pulse" />
              </View>
            </View>
          ),
        }}
      />

      {isInstructor && (
        <Tabs.Screen
          name="instructor"
          options={{
            title: 'Instructor',
            tabBarIcon: ({ color, size, focused }) => (
              <Ionicons
                name={focused ? 'school' : 'school-outline'}
                size={size || 24}
                color={color}
              />
            ),
          }}
        />
      )}

      <Tabs.Screen
        name="setting"
        options={{
          title: 'Settings',
          tabBarIcon: ({ color, size, focused }) => (
            <Ionicons
              name={focused ? 'settings' : 'settings-outline'}
              size={size || 24}
              color={color}
            />
          ),
        }}
      />
    </Tabs>
  );
}