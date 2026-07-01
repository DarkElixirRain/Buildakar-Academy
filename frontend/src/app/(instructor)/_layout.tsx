import React from 'react';
import { Stack } from 'expo-router';
import { useTheme } from '@/context/themeContext';

export default function InstructorLayout() {
  const { colors } = useTheme();

  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: colors.background },
        animation: 'slide_from_right',
      }}
    >
      <Stack.Screen name="courses/[id]" options={{ headerShown: false }} />
      <Stack.Screen name="lesson-video-upload" options={{ headerShown: false, presentation: 'modal' }} />
    </Stack>
  );
}