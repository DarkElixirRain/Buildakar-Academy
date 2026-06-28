// app/course/_layout.tsx (Note: no parentheses)
import React from 'react';
import { Stack } from 'expo-router';
import { useTheme } from '@/context/themeContext';

export default function CourseLayout() {
  const { colors } = useTheme();

  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: colors.background },
        animation: 'slide_from_right',
      }}
    />
  );
}