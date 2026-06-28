// app/(instructor)/courses/[id]/sections.tsx
import React from 'react';
import { SafeAreaView, Text } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { SectionManager } from '@/components/instructor/SectionManager';

export default function CourseSectionsScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();

  if (!id) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC', justifyContent: 'center', alignItems: 'center' }}>
        <Text style={{ fontSize: 16, color: '#64748B' }}>Invalid course ID</Text>
      </SafeAreaView>
    );
  }

  const handleClose = () => {
    router.back();
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
      <SectionManager 
        courseId={id} 
        courseTitle="" 
        onClose={handleClose} 
      />
    </SafeAreaView>
  );
}