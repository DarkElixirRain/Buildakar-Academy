import React, { useCallback, useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Modal,
  RefreshControl,
  SafeAreaView,
  ScrollView,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useTheme } from '@/context/themeContext';
import { useInstructorStore } from '@/store/instructorStore';
import { CourseCard } from '@/components/instructor/CourseCard';
import { CourseForm } from '@/components/instructor/CourseForm';

const statusTabs = ['ALL', 'DRAFT', 'UNDER_REVIEW', 'PUBLISHED'] as const;

type StatusTab = (typeof statusTabs)[number];

export default function InstructorCoursesScreen() {
  const router = useRouter();
  const { colors, isDarkMode } = useTheme();

  const {
    courses,
    coursesLoading,
    coursesError,
    stats,
    statsLoading,
    fetchCourses,
    fetchStats,
    clearCourseError,
  } = useInstructorStore();

  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<StatusTab>('ALL');
  const [showCreateModal, setShowCreateModal] = useState(false);

  const loadData = useCallback(async () => {
    await Promise.all([fetchCourses({ page: 1, limit: 10 }), fetchStats()]);
  }, [fetchCourses, fetchStats]);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  useEffect(() => {
    if (coursesError) {
      clearCourseError();
    }
  }, [coursesError, clearCourseError]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  }, [loadData]);

  const filteredCourses = useMemo(() => {
    const query = searchQuery.trim().toLowerCase();

    return courses.filter((course) => {
      const matchesQuery =
        !query ||
        course.title.toLowerCase().includes(query) ||
        (course.description || '').toLowerCase().includes(query);

      const matchesStatus = statusFilter === 'ALL' || course.status === statusFilter;
      return matchesQuery && matchesStatus;
    });
  }, [courses, searchQuery, statusFilter]);

  const handleCoursePress = (courseId: string) => {
    router.push(`/courses/${courseId}` as any);
  };

  const handleCreateSuccess = async () => {
    setShowCreateModal(false);
    await loadData();
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <ScrollView
        contentContainerStyle={{ paddingBottom: 32 }}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.primary}
            colors={[colors.primary]}
          />
        }
      >
        <View
          style={{
            paddingHorizontal: 20,
            paddingTop: 20,
            paddingBottom: 16,
            backgroundColor: colors.backgroundElement,
            borderBottomWidth: 1,
            borderBottomColor: colors.backgroundSelected,
          }}
        >
          <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
            <View style={{ flex: 1 }}>
              <Text style={{ color: colors.text, fontSize: 24, fontWeight: '700' }}>
                Instructor studio
              </Text>
              <Text style={{ color: colors.textSecondary, fontSize: 13, marginTop: 4 }}>
                Manage your courses and track their progress from the backend dashboard.
              </Text>
            </View>
            <TouchableOpacity
              onPress={() => setShowCreateModal(true)}
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                backgroundColor: colors.primary,
                borderRadius: 999,
                paddingHorizontal: 14,
                paddingVertical: 10,
              }}
            >
              <Ionicons name="add" size={18} color="#FFFFFF" />
              <Text style={{ color: '#FFFFFF', fontWeight: '600', marginLeft: 6 }}>Create</Text>
            </TouchableOpacity>
          </View>
        </View>

        <View style={{ padding: 20 }}>
          <View style={{ flexDirection: 'row', gap: 12, marginBottom: 16 }}>
            {[
              { label: 'Total', value: stats?.totalCourses ?? 0, icon: 'school-outline' },
              { label: 'Published', value: stats?.publishedCourses ?? 0, icon: 'checkmark-circle-outline' },
              { label: 'Students', value: stats?.totalStudents ?? 0, icon: 'people-outline' },
            ].map((card) => (
              <View
                key={card.label}
                style={{
                  flex: 1,
                  backgroundColor: colors.backgroundElement,
                  borderRadius: 16,
                  padding: 12,
                  borderWidth: 1,
                  borderColor: colors.backgroundSelected,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 8 }}>
                  <View
                    style={{
                      width: 32,
                      height: 32,
                      borderRadius: 16,
                      backgroundColor: `${colors.primary}20`,
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}
                  >
                    <Ionicons name={card.icon as any} size={16} color={colors.primary} />
                  </View>
                </View>
                <Text style={{ color: colors.text, fontSize: 18, fontWeight: '700' }}>
                  {card.value}
                </Text>
                <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 2 }}>
                  {card.label}
                </Text>
              </View>
            ))}
          </View>

          <View
            style={{
              backgroundColor: colors.backgroundElement,
              borderRadius: 16,
              padding: 14,
              borderWidth: 1,
              borderColor: colors.backgroundSelected,
              marginBottom: 16,
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 10 }}>
              <Ionicons name="search-outline" size={18} color={colors.textSecondary} />
              <Text style={{ color: colors.text, fontSize: 15, fontWeight: '600', marginLeft: 8 }}>
                Search courses
              </Text>
            </View>
            <TextInput
              value={searchQuery}
              onChangeText={setSearchQuery}
              placeholder="Find by title or description"
              placeholderTextColor={colors.textSecondary}
              style={{
                backgroundColor: colors.background,
                color: colors.text,
                borderRadius: 12,
                paddingHorizontal: 12,
                paddingVertical: 10,
                borderWidth: 1,
                borderColor: colors.backgroundSelected,
              }}
            />

            <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 12 }}>
              {statusTabs.map((tab) => {
                const selected = statusFilter === tab;
                return (
                  <TouchableOpacity
                    key={tab}
                    onPress={() => setStatusFilter(tab)}
                    style={{
                      borderRadius: 999,
                      paddingHorizontal: 12,
                      paddingVertical: 8,
                      backgroundColor: selected ? colors.primary : colors.background,
                      borderWidth: 1,
                      borderColor: selected ? colors.primary : colors.backgroundSelected,
                    }}
                  >
                    <Text style={{ color: selected ? '#FFFFFF' : colors.text, fontSize: 12, fontWeight: '600' }}>
                      {tab === 'ALL' ? 'All statuses' : tab.replace('_', ' ')}
                    </Text>
                  </TouchableOpacity>
                );
              })}
            </View>
          </View>

          {coursesLoading && !courses.length ? (
            <View style={{ paddingVertical: 40, alignItems: 'center' }}>
              <ActivityIndicator size="large" color={colors.primary} />
              <Text style={{ color: colors.textSecondary, marginTop: 10 }}>Loading your courses…</Text>
            </View>
          ) : filteredCourses.length === 0 ? (
            <View
              style={{
                borderRadius: 20,
                borderWidth: 1,
                borderColor: colors.backgroundSelected,
                backgroundColor: colors.backgroundElement,
                padding: 24,
                alignItems: 'center',
              }}
            >
              <Ionicons name="book-outline" size={42} color={colors.primary} />
              <Text style={{ color: colors.text, fontSize: 16, fontWeight: '700', marginTop: 12 }}>
                No courses found
              </Text>
              <Text style={{ color: colors.textSecondary, textAlign: 'center', marginTop: 4 }}>
                Create your first course to start building your academy.
              </Text>
            </View>
          ) : (
            <View style={{ gap: 14 }}>
              {filteredCourses.map((course) => (
                <CourseCard
                  key={course.id}
                  course={course}
                  onPress={() => handleCoursePress(course.id)}
                  showActions={false}
                />
              ))}
            </View>
          )}

          {statsLoading && courses.length > 0 ? (
            <View style={{ alignItems: 'center', marginTop: 12 }}>
              <ActivityIndicator size="small" color={colors.primary} />
            </View>
          ) : null}
        </View>
      </ScrollView>

      <Modal visible={showCreateModal} animationType="slide">
        <CourseForm
          onClose={() => setShowCreateModal(false)}
          onSuccess={handleCreateSuccess}
        />
      </Modal>
    </SafeAreaView>
  );
}
