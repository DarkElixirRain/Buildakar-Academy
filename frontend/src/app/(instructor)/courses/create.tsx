// app/(instructor)/courses/create.tsx
import React from 'react';
import { SafeAreaView } from 'react-native';
import { useRouter } from 'expo-router';
import { CourseForm } from '@/components/instructor/CourseForm';

export default function CreateCourseScreen() {
  const router = useRouter();

  const handleClose = () => {
    router.back();
  };

  const handleSuccess = (course: any) => {
    router.push(`/instructor/courses/${course.id}/sections`);
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
      <CourseForm onClose={handleClose} onSuccess={handleSuccess} />
    </SafeAreaView>
  );
}