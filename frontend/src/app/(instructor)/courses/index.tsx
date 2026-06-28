// app/(instructor)/courses/index.tsx
import React, { useEffect, useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView, SafeAreaView, Dimensions, RefreshControl, TextInput, Modal } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useInstructorStore } from '@/store/instructorStore';
import { CourseCard } from '@/components/instructor/CourseCard';
import { StatusBadge, LevelBadge } from '@/components/instructor/StatusBadge';
import { CourseForm } from '@/components/instructor/CourseForm';

const { width } = Dimensions.get('window');

export default function CoursesListScreen() {
  const router = useRouter();
  const { 
    courses, 
    coursesLoading, 
    coursesError, 
    coursesPagination,
    fetchCourses, 
    createCourse, 
    updateCourse, 
    deleteCourse,
    updateCourseStatus,
    duplicateCourse,
    clearCourseError,
    setCurrentCourse,
  } = useInstructorStore();

  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<string | null>(null);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [editingCourseId, setEditingCourseId] = useState<string | null>(null);

  useEffect(() => {
    fetchCourses({ page: 1, limit: 20 });
  }, []);

  const handleRefresh = async () => {
    await fetchCourses({ page: 1, limit: 20, search: searchQuery || undefined, status: statusFilter || undefined });
  };

  const handleLoadMore = async () => {
    if (coursesPagination?.hasMore && !coursesLoading) {
      await fetchCourses({ page: (coursesPagination.page || 1) + 1, limit: 20, search: searchQuery || undefined, status: statusFilter || undefined });
    }
  };

  const handleSearch = (query: string) => {
    setSearchQuery(query);
  };

  const handleSearchSubmit = () => {
    fetchCourses({ page: 1, limit: 20, search: searchQuery || undefined, status: statusFilter || undefined });
  };

  const handleFilterChange = (status: string | null) => {
    setStatusFilter(status);
    fetchCourses({ page: 1, limit: 20, search: searchQuery || undefined, status: status || undefined });
  };

  const handleEdit = (courseId: string) => {
    setEditingCourseId(courseId);
  };

  const handleCloseCreate = () => {
    setShowCreateModal(false);
    setEditingCourseId(null);
  };

  const handleCloseEdit = () => {
    setEditingCourseId(null);
  };

  const handleCreateSuccess = (course: any) => {
    setShowCreateModal(false);
  };

  const handleDuplicate = async (courseId: string) => {
    try {
      await duplicateCourse(courseId);
    } catch (error) {
      // Error handled in store
    }
  };

  const handleStatusChange = async (courseId: string, status: 'DRAFT' | 'UNDER_REVIEW' | 'PUBLISHED') => {
    try {
      await updateCourseStatus(courseId, status);
    } catch (error) {
      // Error handled in store
    }
  };

  const handleDelete = async (courseId: string) => {
    const confirm = window.confirm('Are you sure you want to delete this course? This action cannot be undone.');
    if (confirm) {
      try {
        await deleteCourse(courseId);
      } catch (error) {
        // Error handled in store
      }
    }
  };

  const renderCourseItem = (course: any) => (
    <CourseCard
      key={course.id}
      course={course}
      onPress={() => router.push(`/instructor/courses/${course.id}/sections`)}
      onEdit={() => handleEdit(course.id)}
      onDuplicate={() => handleDuplicate(course.id)}
      onDelete={() => handleDelete(course.id)}
      showActions
    />
  );

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
      <ScrollView
        style={{ flex: 1 }}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={coursesLoading}
            onRefresh={handleRefresh}
            tintColor="#2563EB"
            colors={['#2563EB']}
          />
        }
        contentContainerStyle={{ paddingBottom: 100 }}
      >
        <View className="px-4 space-y-6 pt-4">
          {/* Header */}
          <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
            <View>
              <Text style={{ fontSize: 28, fontWeight: '700', color: '#0F172A' }}>My Courses</Text>
              <Text style={{ fontSize: 14, color: '#64748B', marginTop: 2 }}>Manage and create your courses</Text>
            </View>
            <TouchableOpacity
              onPress={() => setShowCreateModal(true)}
              style={{ flexDirection: 'row', alignItems: 'center', backgroundColor: '#2563EB', borderRadius: 12, paddingHorizontal: 16, paddingVertical: 10 }}
              activeOpacity={0.85}
            >
              <Ionicons name="add" size={20} color="#FFFFFF" style={{ marginRight: 8 }} />
              <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 14 }}>Create Course</Text>
            </TouchableOpacity>
          </View>

          {/* Search & Filter */}
          <View className="bg-white rounded-2xl p-4 shadow-sm" style={{ shadowColor: '#0F172A', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.05, shadowRadius: 4, elevation: 2 }}>
            <View style={{ flexDirection: 'row', gap: 12, marginBottom: 12 }}>
              <View style={{ flex: 1, position: 'relative' }}>
                <Ionicons name="search" size={20} color="#94A3B8" style={{ position: 'absolute', left: 16, top: 14, zIndex: 1 }} />
                <TextInput
                  value={searchQuery}
                  onChangeText={handleSearch}
                  onSubmitEditing={handleSearchSubmit}
                  placeholder="Search courses..."
                  style={{
                    backgroundColor: '#F8FAFC',
                    borderWidth: 1,
                    borderColor: '#E2E8F0',
                    borderRadius: 12,
                    paddingHorizontal: 44,
                    paddingVertical: 14,
                    fontSize: 16,
                    color: '#0F172A',
                    paddingRight: 16,
                  }}
                />
              </View>
            </View>
            
            <View style={{ flexDirection: 'row', gap: 8, flexWrap: 'wrap' }}>
              {['ALL', 'DRAFT', 'UNDER_REVIEW', 'PUBLISHED'].map((status) => (
                <TouchableOpacity
                  key={status}
                  onPress={() => handleFilterChange(status === 'ALL' ? null : status)}
                  style={{
                    flexDirection: 'row',
                    alignItems: 'center',
                    backgroundColor: statusFilter === (status === 'ALL' ? null : status) ? '#2563EB' : '#F1F5F9',
                    borderRadius: 20,
                    paddingHorizontal: 16,
                    paddingVertical: 8,
                  }}
                  activeOpacity={0.7}
                >
                  {status !== 'ALL' && (
                    <View
                      style={{
                        width: 8,
                        height: 8,
                        borderRadius: 4,
                        backgroundColor: statusFilter === status ? '#FFFFFF' : 
                          status === 'DRAFT' ? '#F59E0B' : status === 'UNDER_REVIEW' ? '#3B82F6' : '#10B981',
                        marginRight: 8,
                      }}
                    />
                  )}
                  <Text
                    style={{
                      color: statusFilter === (status === 'ALL' ? null : status) ? '#FFFFFF' : '#475569',
                      fontWeight: '600',
                      fontSize: 13,
                    }}
                  >
                    {status}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          {/* Courses List */}
          {coursesLoading && courses.length === 0 ? (
            <View style={{ alignItems: 'center', paddingVertical: 48 }}>
              <Ionicons name="refresh" size={48} color="#94A3B8" />
              <Text style={{ fontSize: 16, color: '#64748B', marginTop: 12 }}>Loading courses...</Text>
            </View>
          ) : courses.length === 0 ? (
            <View style={{ alignItems: 'center', paddingVertical: 48, backgroundColor: '#FFFFFF', borderRadius: 16, marginHorizontal: 4 }}>
              <Ionicons name="document-text-outline" size={64} color="#94A3B8" />
              <Text style={{ fontSize: 18, fontWeight: '600', color: '#0F172A', marginTop: 16 }}>
                No courses found
              </Text>
              <Text style={{ fontSize: 14, color: '#64748B', marginTop: 4, textAlign: 'center', paddingHorizontal: 32 }}>
                {searchQuery || statusFilter ? 'Try adjusting your search or filters' : 'Create your first course to get started'}
              </Text>
              {!searchQuery && !statusFilter && (
                <TouchableOpacity
                  onPress={() => setShowCreateModal(true)}
                  style={{ marginTop: 20, backgroundColor: '#2563EB', borderRadius: 12, paddingHorizontal: 24, paddingVertical: 12 }}
                  activeOpacity={0.85}
                >
                  <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 14 }}>Create Your First Course</Text>
                </TouchableOpacity>
              )}
            </View>
          ) : (
            <>
              <View style={{ marginBottom: 100 }}>
                {courses.map(renderCourseItem)}
              </View>

              {coursesPagination?.hasMore && (
                <TouchableOpacity
                  onPress={handleLoadMore}
                  disabled={coursesLoading}
                  style={{ 
                    backgroundColor: coursesLoading ? '#E2E8F0' : '#2563EB', 
                    borderRadius: 12, 
                    paddingVertical: 14, 
                    alignItems: 'center',
                    marginTop: 16,
                  }}
                  activeOpacity={0.85}
                >
                  {coursesLoading ? (
                    <Ionicons name="refresh" size={20} color="#FFFFFF" />
                  ) : (
                    <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 14 }}>Load More Courses</Text>
                  )}
                </TouchableOpacity>
              )}

              {coursesError && (
                <View style={{ backgroundColor: '#FEF2F2', borderWidth: 1, borderColor: '#FECACA', borderRadius: 12, padding: 16, marginTop: 16 }}>
                  <Text style={{ color: '#DC2626', fontSize: 14 }}>{coursesError}</Text>
                </View>
              )}
            </>
          )}
        </View>
      </ScrollView>

      {/* Create Course Modal */}
      <Modal visible={showCreateModal} animationType="slide" transparent={false}>
        <CourseForm onClose={handleCloseCreate} onSuccess={handleCreateSuccess} />
      </Modal>

      {/* Edit Course Modal */}
      {editingCourseId && (
        <Modal visible={!!editingCourseId} animationType="slide" transparent={false}>
          <CourseForm 
            course={courses.find(c => c.id === editingCourseId) || null} 
            onClose={handleCloseEdit} 
            onSuccess={handleCreateSuccess} 
          />
        </Modal>
      )}
    </SafeAreaView>
  );
}