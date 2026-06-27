// app/course/_layout.tsx (Note: no parentheses)
import React from 'react';
import { Stack } from 'expo-router';

export default function CourseLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: '#F8FAFC' },
        animation: 'slide_from_right',
      }}
    />
  );
}