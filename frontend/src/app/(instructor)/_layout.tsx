// app/(instructor)/_layout.tsx
import React from 'react';
import { Stack } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';

export default function InstructorLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: '#F8FAFC' },
        animation: 'slide_from_right',
      }}
    >
      <Stack.Screen name="dashboard" options={{ headerShown: false }} />
      <Stack.Screen name="courses" options={{ headerShown: false }} />
      <Stack.Screen name="courses/create" options={{ headerShown: false }} />
      <Stack.Screen name="courses/[id]/edit" options={{ headerShown: false }} />
      <Stack.Screen name="courses/[id]/sections" options={{ headerShown: false }} />
      <Stack.Screen name="sections/[id]/lessons" options={{ headerShown: false }} />
    </Stack>
  );
}