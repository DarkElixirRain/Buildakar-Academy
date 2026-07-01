import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { View, Text, TouchableOpacity, SafeAreaView, ActivityIndicator, Modal, ScrollView, RefreshControl } from 'react-native';
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
    fetchAnalytics,
    stats,
    statsLoading,
    analytics,
    analyticsLoading,
  } = useInstructorStore();

  const [isCreatingCourse, setIsCreatingCourse] = useState(false);
  const [editingCourse, setEditingCourse] = useState<Course | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const loadData = useCallback(async () => {
    await Promise.all([fetchCourses({ page: 1, limit: 6 }), fetchStats(), fetchAnalytics()]);
  }, [fetchCourses, fetchStats, fetchAnalytics]);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  }, [loadData]);

  const handleCoursePress = (course: Course) => {
    router.push(`/(instructor)/courses/${course.id}`);
  };

  const quickStats = useMemo(
    () => [
      {
        label: 'Courses',
        value: stats?.totalCourses ?? 0,
        icon: 'school-outline' as const,
        accent: colors.primary,
      },
      {
        label: 'Published',
        value: stats?.publishedCourses ?? 0,
        icon: 'checkmark-circle-outline' as const,
        accent: '#10B981',
      },
      {
        label: 'Students',
        value: stats?.totalStudents ?? 0,
        icon: 'people-outline' as const,
        accent: '#8B5CF6',
      },
      {
        label: 'Revenue',
        value: `$${(stats?.totalEarnings ?? 0).toFixed(2)}`,
        icon: 'cash-outline' as const,
        accent: '#F59E0B',
      },
    ],
    [colors.primary, stats]
  );

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <ScrollView
        contentContainerStyle={{ paddingBottom: 32 }}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.primary} colors={[colors.primary]} />}
      >
        <View style={{ padding: 20 }}>
          <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
            <View style={{ flex: 1, marginRight: 12 }}>
              <Text style={{ color: colors.text, fontSize: 24, fontWeight: '700' }}>Instructor dashboard</Text>
              <Text style={{ color: colors.textSecondary, fontSize: 13, marginTop: 4 }}>
                Review your academy performance, launch new content, and keep learners moving forward.
              </Text>
            </View>
            <TouchableOpacity
              onPress={() => setIsCreatingCourse(true)}
              style={{ backgroundColor: colors.primary, borderRadius: 999, paddingHorizontal: 14, paddingVertical: 10, flexDirection: 'row', alignItems: 'center' }}
            >
              <Ionicons name="add" size={18} color="#FFFFFF" />
              <Text style={{ color: '#FFFFFF', fontWeight: '600', marginLeft: 6 }}>New course</Text>
            </TouchableOpacity>
          </View>

          <View style={{ flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between', marginBottom: 16 }}>
            {quickStats.map((item) => (
              <View
                key={item.label}
                style={{ width: '48%', backgroundColor: colors.backgroundElement, borderRadius: 16, padding: 14, marginBottom: 12, borderWidth: 1, borderColor: colors.backgroundSelected }}
              >
                <View style={{ width: 34, height: 34, borderRadius: 17, alignItems: 'center', justifyContent: 'center', backgroundColor: `${item.accent}20`, marginBottom: 8 }}>
                  <Ionicons name={item.icon} size={16} color={item.accent} />
                </View>
                <Text style={{ color: colors.text, fontSize: 18, fontWeight: '700' }}>{item.value}</Text>
                <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 2 }}>{item.label}</Text>
              </View>
            ))}
          </View>

          <View style={{ backgroundColor: colors.backgroundElement, borderRadius: 18, padding: 16, borderWidth: 1, borderColor: colors.backgroundSelected, marginBottom: 16 }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
              <Text style={{ color: colors.text, fontSize: 16, fontWeight: '700' }}>Learning insights</Text>
              <TouchableOpacity onPress={() => router.push('/(instructor)/courses' as any)}>
                <Text style={{ color: colors.primary, fontWeight: '600' }}>View studio</Text>
              </TouchableOpacity>
            </View>
            {analyticsLoading ? (
              <ActivityIndicator size="small" color={colors.primary} />
            ) : (
              <View style={{ flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between' }}>
                <View style={{ width: '48%', marginBottom: 10 }}>
                  <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Enrolled learners</Text>
                  <Text style={{ color: colors.text, fontSize: 20, fontWeight: '700', marginTop: 4 }}>{analytics?.totalEnrollments ?? 0}</Text>
                </View>
                <View style={{ width: '48%', marginBottom: 10 }}>
                  <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Completion rate</Text>
                  <Text style={{ color: colors.text, fontSize: 20, fontWeight: '700', marginTop: 4 }}>{analytics ? `${analytics.completionRate.toFixed(1)}%` : '0.0%'}</Text>
                </View>
                <View style={{ width: '48%' }}>
                  <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Completed lessons</Text>
                  <Text style={{ color: colors.text, fontSize: 20, fontWeight: '700', marginTop: 4 }}>{analytics?.completedEnrollments ?? 0}</Text>
                </View>
                <View style={{ width: '48%' }}>
                  <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Avg. progress</Text>
                  <Text style={{ color: colors.text, fontSize: 20, fontWeight: '700', marginTop: 4 }}>{analytics ? `${analytics.averageProgress.toFixed(1)}%` : '0.0%'}</Text>
                </View>
              </View>
            )}
          </View>

          {stats?.topCourses && stats.topCourses.length > 0 ? (
            <View style={{ backgroundColor: colors.backgroundElement, borderRadius: 18, padding: 16, borderWidth: 1, borderColor: colors.backgroundSelected, marginBottom: 16 }}>
              <Text style={{ color: colors.text, fontSize: 16, fontWeight: '700', marginBottom: 10 }}>Top courses</Text>
              {stats.topCourses.map((course) => (
                <View key={course.id} style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 8, borderTopWidth: course.id === stats.topCourses?.[0]?.id ? 0 : 1, borderTopColor: colors.backgroundSelected }}>
                  <View style={{ flex: 1, marginRight: 8 }}>
                    <Text style={{ color: colors.text, fontWeight: '600' }} numberOfLines={1}>{course.title}</Text>
                    <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 2 }}>{course.studentsCount} learners</Text>
                  </View>
                  <Text style={{ color: colors.primary, fontWeight: '700' }}>${course.revenue.toFixed(2)}</Text>
                </View>
              ))}
            </View>
          ) : null}

          <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <Text style={{ color: colors.text, fontSize: 18, fontWeight: '700' }}>Your courses</Text>
            <TouchableOpacity onPress={() => router.push('/(instructor)/courses' as any)}>
              <Text style={{ color: colors.primary, fontWeight: '600' }}>See all</Text>
            </TouchableOpacity>
          </View>

          {coursesLoading && courses.length === 0 ? (
            <View style={{ paddingVertical: 40, alignItems: 'center' }}>
              <ActivityIndicator size="large" color={colors.primary} />
            </View>
          ) : courses.length === 0 ? (
            <View style={{ paddingVertical: 36, alignItems: 'center', justifyContent: 'center', backgroundColor: colors.backgroundElement, borderRadius: 18, borderWidth: 1, borderColor: colors.backgroundSelected }}>
              <Ionicons name="document-text-outline" size={64} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, fontWeight: '600', marginTop: 12, textAlign: 'center' }}>
                You haven’t created any courses yet.
              </Text>
              <Text style={{ color: colors.textSecondary, fontSize: 13, marginTop: 4, textAlign: 'center' }}>
                Start with the “New course” button to launch your first lesson plan.
              </Text>
            </View>
          ) : (
            <View>
              {courses.slice(0, 4).map((course) => (
                <TouchableOpacity key={course.id} onPress={() => handleCoursePress(course)} style={{ marginBottom: 12 }}>
                  <CourseCard
                    course={course}
                    onEdit={() => setEditingCourse(course)}
                  />
                </TouchableOpacity>
              ))}
            </View>
          )}
        </View>
      </ScrollView>

      <Modal visible={isCreatingCourse} animationType="slide">
        <CourseForm
          onClose={() => setIsCreatingCourse(false)}
          onSuccess={(course) => {
            setIsCreatingCourse(false);
            router.push(`/(instructor)/courses/${course.id}`);
          }}
        />
      </Modal>

      <Modal visible={!!editingCourse} animationType="slide">
        <CourseForm
          course={editingCourse}
          onClose={() => setEditingCourse(null)}
          onSuccess={async () => {
            setEditingCourse(null);
            await loadData();
          }}
        />
      </Modal>
    </SafeAreaView>
  );
}
