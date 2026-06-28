// app/(instructor)/dashboard.tsx
import React, { useEffect } from 'react';
import { View, Text, TouchableOpacity, ScrollView, SafeAreaView, Dimensions, RefreshControl } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useAuthStore } from '@/store/authStore';
import { useInstructorStore } from '@/store/instructorStore';
import { CourseCard } from '@/components/instructor/CourseCard';
import { StatusBadge, LevelBadge } from '@/components/instructor/StatusBadge';

const { width } = Dimensions.get('window');

const StatCard: React.FC<{ title: string; value: string | number; icon: React.ComponentProps<typeof Ionicons>['name']; color: string; bg: string }> = ({
  title,
  value,
  icon,
  color,
  bg,
}) => (
  <TouchableOpacity
    style={{
      flex: 1,
      backgroundColor: '#FFFFFF',
      borderRadius: 16,
      padding: 20,
      marginRight: 12,
      shadowColor: '#0F172A',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.05,
      shadowRadius: 8,
      elevation: 4,
    }}
    activeOpacity={0.8}
  >
    <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' }}>
      <View>
        <Text style={{ fontSize: 13, fontWeight: '600', color: '#64748B', marginBottom: 4 }}>
          {title}
        </Text>
        <Text style={{ fontSize: 28, fontWeight: '700', color: '#0F172A' }}>
          {value}
        </Text>
      </View>
      <View style={{ width: 48, height: 48, borderRadius: 14, backgroundColor: bg, justifyContent: 'center', alignItems: 'center' }}>
        <Ionicons name={icon} size={24} color={color} />
      </View>
    </View>
  </TouchableOpacity>
);

export default function InstructorDashboard() {
  const router = useRouter();
  const { user, isAuthenticated } = useAuthStore();
  const { stats, statsLoading, fetchStats, fetchCourses, courses, coursesLoading } = useInstructorStore();

  useEffect(() => {
    if (isAuthenticated) {
      fetchStats();
      fetchCourses();
    }
  }, [isAuthenticated]);

  const handleCreateCourse = () => {
    router.push('/(instructor)/courses/create');
  };

  const handleViewCourse = (courseId: string) => {
    router.push(`/instructor/courses/${courseId}/edit`);
  };

  const handleManageSections = (courseId: string) => {
    router.push(`/instructor/courses/${courseId}/sections`);
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
      <ScrollView
        style={{ flex: 1 }}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={statsLoading}
            onRefresh={() => { fetchStats(); fetchCourses(); }}
            tintColor="#2563EB"
            colors={['#2563EB']}
          />
        }
        contentContainerStyle={{ paddingBottom: 100 }}
      >
        <View className="px-4 space-y-6 pt-4">
          {/* Welcome Header */}
          <View className="flex-row items-center justify-between">
            <View>
              <Text style={{ fontSize: 14, color: '#64748B', fontWeight: '500' }}>
                Welcome back,
              </Text>
              <Text style={{ fontSize: 28, fontWeight: '700', color: '#0F172A', marginTop: 2 }}>
                {user?.firstName || 'Instructor'}
              </Text>
            </View>
            <View style={{ width: 48, height: 48, borderRadius: 24, backgroundColor: '#DBEAFE', justifyContent: 'center', alignItems: 'center' }}>
              <Ionicons name="school-outline" size={24} color="#2563EB" />
            </View>
          </View>

          {/* Stats Grid */}
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 12 }}>
            <StatCard
              title="Total Courses"
              value={stats?.totalCourses || 0}
              icon="document-text-outline"
              color="#2563EB"
              bg="#EFF6FF"
            />
            <StatCard
              title="Published"
              value={stats?.publishedCourses || 0}
              icon="checkmark-circle-outline"
              color="#10B981"
              bg="#D1FAE5"
            />
            <StatCard
              title="Drafts"
              value={stats?.draftCourses || 0}
              icon="pencil-outline"
              color="#F59E0B"
              bg="#FEF3C7"
            />
            <StatCard
              title="Students"
              value={stats?.totalStudents || 0}
              icon="people-outline"
              color="#8B5CF6"
              bg="#F3E8FF"
            />
          </View>

          {/* Quick Actions */}
          <View style={{ backgroundColor: '#FFFFFF', borderRadius: 16, padding: 20 }}>
            <Text style={{ fontSize: 18, fontWeight: '700', color: '#0F172A', marginBottom: 16 }}>
              Quick Actions
            </Text>
            <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap' }}>
              <TouchableOpacity
                onPress={handleCreateCourse}
                style={{ flex: 1, minWidth: 150, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', backgroundColor: '#2563EB', borderRadius: 12, paddingVertical: 14, gap: 8 }}
                activeOpacity={0.85}
              >
                <Ionicons name="add" size={20} color="#FFFFFF" />
                <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 14 }}>Create Course</Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={() => router.push('/(instructor)/courses')}
                style={{ flex: 1, minWidth: 150, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', backgroundColor: '#F1F5F9', borderRadius: 12, paddingVertical: 14, gap: 8 }}
                activeOpacity={0.7}
              >
                <Ionicons name="list-outline" size={20} color="#475569" />
                <Text style={{ color: '#475569', fontWeight: '600', fontSize: 14 }}>View All Courses</Text>
              </TouchableOpacity>
            </View>
          </View>

          {/* Recent Courses */}
          <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
            <Text style={{ fontSize: 18, fontWeight: '700', color: '#0F172A' }}>
              Your Courses
            </Text>
            <TouchableOpacity
              onPress={() => router.push('/(instructor)/courses')}
              style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}
              activeOpacity={0.7}
            >
              <Text style={{ fontSize: 14, fontWeight: '600', color: '#2563EB' }}>View All</Text>
              <Ionicons name="chevron-forward" size={18} color="#2563EB" />
            </TouchableOpacity>
          </View>

          {coursesLoading && courses.length === 0 ? (
            <View style={{ alignItems: 'center', paddingVertical: 48 }}>
              <Ionicons name="refresh" size={48} color="#94A3B8" />
              <Text style={{ fontSize: 16, color: '#64748B', marginTop: 12 }}>Loading courses...</Text>
            </View>
          ) : courses.length === 0 ? (
            <View style={{ backgroundColor: '#FFFFFF', borderRadius: 16, padding: 32, alignItems: 'center' }}>
              <Ionicons name="document-text-outline" size={64} color="#94A3B8" />
              <Text style={{ fontSize: 18, fontWeight: '600', color: '#0F172A', marginTop: 16 }}>
                No courses yet
              </Text>
              <Text style={{ fontSize: 14, color: '#64748B', marginTop: 4, textAlign: 'center' }}>
                Create your first course to start teaching
              </Text>
              <TouchableOpacity
                onPress={handleCreateCourse}
                style={{ marginTop: 20, backgroundColor: '#2563EB', borderRadius: 12, paddingHorizontal: 24, paddingVertical: 12 }}
                activeOpacity={0.85}
              >
                <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 14 }}>Create Your First Course</Text>
              </TouchableOpacity>
            </View>
          ) : (
            <View style={{ marginBottom: 100 }}>
              {courses.slice(0, 5).map((course) => (
                <CourseCard
                  key={course.id}
                  course={course}
                  onPress={() => handleViewCourse(course.id)}
                  onEdit={() => handleViewCourse(course.id)}
                  onDuplicate={() => {}}
                  showActions
                />
              ))}
            </View>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}