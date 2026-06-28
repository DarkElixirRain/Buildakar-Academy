// app/(instructor)/sections/[id]/lessons.tsx
import React, { useEffect } from 'react';
import { SafeAreaView, Text } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { LessonManager } from '@/components/instructor/LessonManager';

export default function SectionLessonsScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();

  if (!id) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC', justifyContent: 'center', alignItems: 'center' }}>
        <Text style={{ fontSize: 16, color: '#64748B' }}>Invalid section ID</Text>
      </SafeAreaView>
    );
  }

  const handleClose = () => {
    router.back();
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
      <LessonManager 
        sectionId={id} 
        sectionTitle="" 
        courseId="" 
        onClose={handleClose} 
      />
    </SafeAreaView>
  );
}