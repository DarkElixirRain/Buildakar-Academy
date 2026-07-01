import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  SafeAreaView,
  ActivityIndicator,
  ScrollView,
  Modal,
  Alert,
} from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';
import { useInstructorStore } from '@/store/instructorStore';
import { CourseForm } from '@/components/instructor/CourseForm';
import { SectionManager } from '@/components/instructor/SectionManager';
import { StatusBadge } from '@/components/instructor/StatusBadge';

export default function CourseDetailsScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const { colors } = useTheme();

  const {
    currentCourse,
    fetchCourseById,
    coursesLoading,
    deleteCourse,
    updateCourseStatus,
  } = useInstructorStore();

  const [showEditForm, setShowEditForm] = useState(false);
  const [showSectionManager, setShowSectionManager] = useState(false);

  useEffect(() => {
    if (id) {
      fetchCourseById(id);
    }
  }, [id]);

  const handleDelete = () => {
    Alert.alert(
      'Delete Course',
      'Are you sure you want to delete this course? This action cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Delete', 
          style: 'destructive',
          onPress: async () => {
            if (id) {
              await deleteCourse(id);
              router.back();
            }
          }
        }
      ]
    );
  };

  const handlePublishToggle = async () => {
    if (!currentCourse) return;
    
    const newStatus = currentCourse.status === 'PUBLISHED' ? 'DRAFT' : 'PUBLISHED';
    try {
      await updateCourseStatus(currentCourse.id, newStatus);
    } catch (error) {
      // Error handled in store
    }
  };

  if (coursesLoading && !currentCourse) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: colors.background }}>
        <ActivityIndicator size="large" color={colors.primary} />
        <Text style={{ color: colors.textSecondary, marginTop: 12 }}>Loading course details…</Text>
      </View>
    );
  }

  if (!currentCourse) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: colors.background, padding: 24 }}>
        <Ionicons name="alert-circle-outline" size={48} color={colors.primary} />
        <Text style={{ color: colors.text, fontSize: 18, fontWeight: '700', marginTop: 12 }}>Course not found</Text>
        <TouchableOpacity
          onPress={() => router.back()}
          style={{ marginTop: 16, backgroundColor: colors.primary, borderRadius: 999, paddingHorizontal: 16, paddingVertical: 10 }}
        >
          <Text style={{ color: '#FFFFFF', fontWeight: '600' }}>Go back</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <ScrollView style={{ flex: 1 }}>
        <View style={{ padding: 20, borderBottomWidth: 1, borderBottomColor: colors.backgroundSelected, backgroundColor: colors.backgroundElement }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 12 }}>
            <TouchableOpacity onPress={() => router.back()} style={{ marginRight: 12 }}>
              <Ionicons name="arrow-back" size={24} color={colors.text} />
            </TouchableOpacity>
            <Text style={{ color: colors.text, fontSize: 20, fontWeight: '700', flex: 1 }} numberOfLines={1}>
              {currentCourse.title}
            </Text>
          </View>

          <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
            <StatusBadge status={currentCourse.status || 'DRAFT'} />
            <Text style={{ color: colors.textSecondary, fontSize: 13 }}>
              {currentCourse.price === 0 ? 'Free' : `$${currentCourse.price || 0}`}
            </Text>
          </View>
          <Text style={{ color: colors.textSecondary, lineHeight: 20 }} numberOfLines={3}>
            {currentCourse.description || 'No description yet. Add one to help students understand what they will learn.'}
          </Text>
        </View>

        <View style={{ padding: 20 }}>
          <Text style={{ color: colors.text, fontSize: 18, fontWeight: '700', marginBottom: 12 }}>Manage course</Text>

          <View style={{ flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between' }}>
            <TouchableOpacity
              onPress={() => setShowEditForm(true)}
              style={{ width: '48%', backgroundColor: colors.backgroundElement, borderRadius: 16, padding: 16, borderWidth: 1, borderColor: colors.backgroundSelected, marginBottom: 12, alignItems: 'center' }}
            >
              <View style={{ width: 48, height: 48, borderRadius: 24, backgroundColor: `${colors.primary}20`, alignItems: 'center', justifyContent: 'center', marginBottom: 10 }}>
                <Ionicons name="create-outline" size={24} color={colors.primary} />
              </View>
              <Text style={{ color: colors.text, fontWeight: '700' }}>Edit details</Text>
              <Text style={{ color: colors.textSecondary, fontSize: 12, textAlign: 'center', marginTop: 4 }}>Title, description, pricing</Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={() => setShowSectionManager(true)}
              style={{ width: '48%', backgroundColor: colors.backgroundElement, borderRadius: 16, padding: 16, borderWidth: 1, borderColor: colors.backgroundSelected, marginBottom: 12, alignItems: 'center' }}
            >
              <View style={{ width: 48, height: 48, borderRadius: 24, backgroundColor: `${colors.primary}20`, alignItems: 'center', justifyContent: 'center', marginBottom: 10 }}>
                <Ionicons name="list-outline" size={24} color={colors.primary} />
              </View>
              <Text style={{ color: colors.text, fontWeight: '700' }}>Curriculum</Text>
              <Text style={{ color: colors.textSecondary, fontSize: 12, textAlign: 'center', marginTop: 4 }}>Sections and lessons</Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={handlePublishToggle}
              style={{ width: '48%', backgroundColor: colors.backgroundElement, borderRadius: 16, padding: 16, borderWidth: 1, borderColor: colors.backgroundSelected, marginBottom: 12, alignItems: 'center' }}
            >
              <View style={{ width: 48, height: 48, borderRadius: 24, backgroundColor: currentCourse.status === 'PUBLISHED' ? '#FDE68A20' : '#10B98120', alignItems: 'center', justifyContent: 'center', marginBottom: 10 }}>
                <Ionicons name={currentCourse.status === 'PUBLISHED' ? 'eye-off-outline' : 'eye-outline'} size={24} color={currentCourse.status === 'PUBLISHED' ? '#D97706' : '#059669'} />
              </View>
              <Text style={{ color: colors.text, fontWeight: '700' }}>{currentCourse.status === 'PUBLISHED' ? 'Unpublish' : 'Publish'}</Text>
              <Text style={{ color: colors.textSecondary, fontSize: 12, textAlign: 'center', marginTop: 4 }}>Change visibility</Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={handleDelete}
              style={{ width: '48%', backgroundColor: colors.backgroundElement, borderRadius: 16, padding: 16, borderWidth: 1, borderColor: '#FECACA', marginBottom: 12, alignItems: 'center' }}
            >
              <View style={{ width: 48, height: 48, borderRadius: 24, backgroundColor: '#FEE2E220', alignItems: 'center', justifyContent: 'center', marginBottom: 10 }}>
                <Ionicons name="trash-outline" size={24} color="#DC2626" />
              </View>
              <Text style={{ color: '#DC2626', fontWeight: '700' }}>Delete</Text>
              <Text style={{ color: colors.textSecondary, fontSize: 12, textAlign: 'center', marginTop: 4 }}>Permanent action</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>

      <Modal visible={showEditForm} animationType="slide">
        <CourseForm
          course={currentCourse}
          onClose={() => setShowEditForm(false)}
          onSuccess={() => setShowEditForm(false)}
        />
      </Modal>

      <Modal visible={showSectionManager} animationType="slide">
        <SectionManager
          courseId={currentCourse.id}
          courseTitle={currentCourse.title}
          onClose={() => setShowSectionManager(false)}
        />
      </Modal>
    </SafeAreaView>
  );
}
