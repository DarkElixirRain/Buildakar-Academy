import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, TouchableOpacity, SafeAreaView, ActivityIndicator, Modal } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';
import { useInstructorStore } from '@/store/instructorStore';
import { CourseCard } from '@/components/instructor/CourseCard';
import { CourseForm } from '@/components/instructor/CourseForm';
import { Course } from '@/types/instructor';

export default function InstructorDashboard() {
  const router = useRouter();
  const { colors } = useTheme();
  const {
    courses,
    coursesLoading,
    fetchCourses,
    fetchStats,
    stats,
    statsLoading,
  } = useInstructorStore();

  const [isCreatingCourse, setIsCreatingCourse] = useState(false);

  useEffect(() => {
    fetchCourses();
    fetchStats();
  }, []);

  const handleCoursePress = (course: Course) => {
    router.push(`/(instructor)/courses/${course.id}`);
  };

  const renderHeader = () => (
    <View style={{ marginBottom: 20 }}>
      <Text style={{ color: colors.text, fontSize: 24, fontWeight: '700', marginBottom: 14 }}>
        Instructor dashboard
      </Text>

      <View style={{ flexDirection: 'row', justifyContent: 'space-between', marginBottom: 14, gap: 10 }}>
        <View style={{ flex: 1, backgroundColor: `${colors.primary}20`, borderRadius: 16, padding: 14 }}>
          <Text style={{ color: colors.primary, fontWeight: '600', fontSize: 12 }}>Total students</Text>
          <Text style={{ color: colors.text, fontSize: 22, fontWeight: '700', marginTop: 4 }}>
            {statsLoading ? '-' : stats?.totalStudents || 0}
          </Text>
        </View>
        <View style={{ flex: 1, backgroundColor: `${colors.primary}10`, borderRadius: 16, padding: 14 }}>
          <Text style={{ color: colors.primary, fontWeight: '600', fontSize: 12 }}>Total earnings</Text>
          <Text style={{ color: colors.text, fontSize: 22, fontWeight: '700', marginTop: 4 }}>
            ${statsLoading ? '-' : stats?.totalEarnings?.toFixed(2) || '0.00'}
          </Text>
        </View>
      </View>

      <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 6 }}>
        <Text style={{ color: colors.text, fontSize: 18, fontWeight: '700' }}>Your courses</Text>
        <TouchableOpacity
          onPress={() => setIsCreatingCourse(true)}
          style={{ backgroundColor: colors.primary, borderRadius: 999, paddingHorizontal: 14, paddingVertical: 10, flexDirection: 'row', alignItems: 'center' }}
        >
          <Ionicons name="add" size={18} color="#FFFFFF" />
          <Text style={{ color: '#FFFFFF', fontWeight: '600', marginLeft: 6 }}>New course</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <View style={{ flex: 1, paddingHorizontal: 16, paddingTop: 16 }}>
        {coursesLoading && courses.length === 0 ? (
          <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
            <ActivityIndicator size="large" color={colors.primary} />
          </View>
        ) : (
          <FlatList
            data={courses}
            keyExtractor={(item) => item.id}
            ListHeaderComponent={renderHeader}
            renderItem={({ item }) => (
              <TouchableOpacity onPress={() => handleCoursePress(item)} style={{ marginBottom: 14 }}>
                <CourseCard course={item} />
              </TouchableOpacity>
            )}
            ListEmptyComponent={() => (
              <View style={{ paddingVertical: 40, alignItems: 'center', justifyContent: 'center' }}>
                <Ionicons name="document-text-outline" size={64} color={colors.textSecondary} />
                <Text style={{ color: colors.textSecondary, fontWeight: '600', marginTop: 12, textAlign: 'center' }}>
                  You haven’t created any courses yet.
                </Text>
                <Text style={{ color: colors.textSecondary, fontSize: 13, marginTop: 4, textAlign: 'center' }}>
                  Start with the “New course” button to launch your first lesson plan.
                </Text>
              </View>
            )}
            showsVerticalScrollIndicator={false}
          />
        )}
      </View>

      <Modal visible={isCreatingCourse} animationType="slide">
        <CourseForm
          onClose={() => setIsCreatingCourse(false)}
          onSuccess={(course) => {
            setIsCreatingCourse(false);
            router.push(`/(instructor)/courses/${course.id}`);
          }}
        />
      </Modal>
    </SafeAreaView>
  );
}
