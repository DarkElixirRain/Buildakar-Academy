// app/(instructor)/courses/[id]/edit.tsx
import React, { useEffect } from 'react';
import { SafeAreaView, Alert, Text } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useInstructorStore } from '@/store/instructorStore';
import { CourseForm } from '@/components/instructor/CourseForm';

export default function EditCourseScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const { fetchCourseById, courses, coursesLoading, coursesError, clearCourseError } = useInstructorStore();

  const course = courses.find(c => c.id === id);

  useEffect(() => {
    if (id && !course) {
      fetchCourseById(id);
    }
    clearCourseError();
  }, [id]);

  const handleClose = () => {
    router.back();
  };

  const handleSuccess = (updatedCourse: any) => {
    router.back();
  };

  if (!course && coursesLoading) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC', justifyContent: 'center', alignItems: 'center' }}>
        <Text style={{ fontSize: 16, color: '#64748B' }}>Loading course...</Text>
      </SafeAreaView>
    );
  }

  if (!course) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC', justifyContent: 'center', alignItems: 'center', padding: 24 }}>
        <Text style={{ fontSize: 18, fontWeight: '600', color: '#0F172A', marginTop: 16 }}>Course not found</Text>
        <Text style={{ fontSize: 14, color: '#64748B', marginTop: 4 }}>This course may have been deleted or you don't have access to it.</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
      <CourseForm 
        course={course} 
        onClose={handleClose} 
        onSuccess={handleSuccess} 
      />
    </SafeAreaView>
  );
}