// components/instructor/LessonManager.tsx
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, TextInput, ScrollView, Modal, Alert, KeyboardAvoidingView, Platform, SafeAreaView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Lesson, CreateLessonInput, UpdateLessonInput } from '@/types/instructor';
import { useInstructorStore } from '@/store/instructorStore';
import { StatusBadge, LevelBadge } from './StatusBadge';

interface LessonManagerProps {
  sectionId: string;
  sectionTitle: string;
  courseId: string;
  onClose?: () => void;
}

export const LessonManager: React.FC<LessonManagerProps> = ({ 
  sectionId, 
  sectionTitle, 
  courseId,
  onClose 
}) => {
  const { 
    lessons, 
    lessonsLoading, 
    lessonsError,
    fetchLessonsBySection, 
    createLesson, 
    updateLesson, 
    deleteLesson, 
    reorderLessons,
    uploadVideo,
    deleteVideo,
    getVideoStreamUrl,
    uploadLoading,
    uploadProgress,
    uploadError,
    resetUploadProgress,
    setCurrentLesson,
    clearLessonsError,
  } = useInstructorStore();

  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [showVideoModal, setShowVideoModal] = useState(false);
  const [newLessonTitle, setNewLessonTitle] = useState('');
  const [newLessonDescription, setNewLessonDescription] = useState('');
  const [newLessonDuration, setNewLessonDuration] = useState('');
  const [newLessonIsPreview, setNewLessonIsPreview] = useState(false);
  const [newLessonIsFree, setNewLessonIsFree] = useState(false);
  const [editingLesson, setEditingLesson] = useState<Lesson | null>(null);
  const [editTitle, setEditTitle] = useState('');
  const [editDescription, setEditDescription] = useState('');
  const [editDuration, setEditDuration] = useState('');
  const [editIsPreview, setEditIsPreview] = useState(false);
  const [editIsFree, setEditIsFree] = useState(false);
  const [videoUploadingLessonId, setVideoUploadingLessonId] = useState<string | null>(null);

  useEffect(() => {
    fetchLessonsBySection(sectionId);
    clearLessonsError();
  }, [sectionId]);

  const handleCreateLesson = async () => {
    if (!newLessonTitle.trim()) {
      Alert.alert('Error', 'Lesson title is required');
      return;
    }

    try {
      await createLesson(sectionId, { 
        title: newLessonTitle, 
        description: newLessonDescription,
        duration: newLessonDuration,
        isPreview: newLessonIsPreview,
        isFree: newLessonIsFree,
      });
      setNewLessonTitle('');
      setNewLessonDescription('');
      setNewLessonDuration('');
      setNewLessonIsPreview(false);
      setNewLessonIsFree(false);
      setShowCreateModal(false);
    } catch (error) {
      // Error handled in store
    }
  };

  const handleEditLesson = async (lesson: Lesson) => {
    setEditingLesson(lesson);
    setEditTitle(lesson.title);
    setEditDescription(lesson.description || '');
    setEditDuration(lesson.duration || '');
    setEditIsPreview(lesson.isPreview);
    setEditIsFree(lesson.isFree);
    setShowEditModal(true);
  };

  const handleUpdateLesson = async () => {
    if (!editingLesson || !editTitle.trim()) return;

    try {
      await updateLesson(editingLesson.id, { 
        title: editTitle, 
        description: editDescription,
        duration: editDuration,
        isPreview: editIsPreview,
        isFree: editIsFree,
      });
      setEditingLesson(null);
      setEditTitle('');
      setEditDescription('');
      setEditDuration('');
      setEditIsPreview(false);
      setEditIsFree(false);
      setShowEditModal(false);
    } catch (error) {
      // Error handled in store
    }
  };

  const handleDeleteLesson = (lesson: Lesson) => {
    Alert.alert(
      'Delete Lesson',
      `Are you sure you want to delete "${lesson.title}"?`,
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Delete', 
          style: 'destructive',
          onPress: async () => {
            try {
              await deleteLesson(lesson.id);
            } catch (error) {
              // Error handled in store
            }
          }
        },
      ]
    );
  };

  const handleReorder = async (fromIndex: number, toIndex: number) => {
    const reorderedLessons = [...lessons];
    const [removed] = reorderedLessons.splice(fromIndex, 1);
    reorderedLessons.splice(toIndex, 0, removed);
    
    const updatedLessons = reorderedLessons.map((lesson, index) => ({
      id: lesson.id,
      order: index + 1,
    }));

    try {
      await reorderLessons(sectionId, updatedLessons);
    } catch (error) {
      // Error handled in store
    }
  };

  const handleVideoUpload = async (lesson: Lesson) => {
    setVideoUploadingLessonId(lesson.id);
    setShowVideoModal(true);
    resetUploadProgress();
  };

  const handleVideoDelete = async (lesson: Lesson) => {
    Alert.alert(
      'Delete Video',
      `Are you sure you want to delete the video for "${lesson.title}"?`,
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Delete', 
          style: 'destructive',
          onPress: async () => {
            try {
              await deleteVideo(lesson.id);
            } catch (error) {
              // Error handled in store
            }
          }
        },
      ]
    );
  };

  const renderLessonItem = (lesson: Lesson, index: number) => (
    <View
      key={lesson.id}
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: '#FFFFFF',
        borderRadius: 12,
        padding: 16,
        marginBottom: 12,
        shadowColor: '#0F172A',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
        elevation: 2,
      }}
    >
      {/* Drag handle */}
      <TouchableOpacity
        style={{ padding: 8, marginRight: 12 }}
        activeOpacity={0.7}
      >
        <Ionicons name="reorder-four-outline" size={24} color="#94A3B8" />
      </TouchableOpacity>

      {/* Video thumbnail/placeholder */}
      <View style={{ width: 80, height: 45, borderRadius: 8, backgroundColor: '#F1F5F9', justifyContent: 'center', alignItems: 'center', marginRight: 12 }}>
        {lesson.videoUrl ? (
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
            <Ionicons name="play-circle" size={20} color="#10B981" />
            <Text style={{ fontSize: 10, fontWeight: '600', color: '#10B981' }}>Video</Text>
          </View>
        ) : (
          <Ionicons name="videocam-outline" size={24} color="#94A3B8" />
        )}
      </View>

      {/* Lesson info */}
      <View style={{ flex: 1 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 4 }}>
          <Text style={{ fontSize: 16, fontWeight: '600', color: '#0F172A', flex: 1 }}>
            {lesson.title}
          </Text>
          <Text style={{ fontSize: 12, color: '#94A3B8', fontWeight: '500', marginLeft: 8 }}>
            Lesson {index + 1}
          </Text>
        </View>
        
        {lesson.description && (
          <Text style={{ fontSize: 13, color: '#64748B', marginBottom: 4, flex: 1 }}>
            {lesson.description}
          </Text>
        )}

        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
          {lesson.duration && (
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
              <Ionicons name="time-outline" size={14} color="#94A3B8" />
              <Text style={{ fontSize: 12, color: '#64748B' }}>
                {lesson.duration}
              </Text>
            </View>
          )}
          {lesson.isPreview && (
            <View style={{ backgroundColor: '#EFF6FF', borderRadius: 8, paddingHorizontal: 8, paddingVertical: 2 }}>
              <Text style={{ fontSize: 11, fontWeight: '600', color: '#2563EB' }}>
                Preview
              </Text>
            </View>
          )}
          {lesson.isFree && (
            <View style={{ backgroundColor: '#D1FAE5', borderRadius: 8, paddingHorizontal: 8, paddingVertical: 2 }}>
              <Text style={{ fontSize: 11, fontWeight: '600', color: '#065F46' }}>
                Free
              </Text>
            </View>
          )}
        </View>
      </View>

      {/* Actions */}
      <View style={{ flexDirection: 'row', gap: 8 }}>
        {lesson.videoUrl ? (
          <>
            <TouchableOpacity
              onPress={() => handleVideoDelete(lesson)}
              style={{ padding: 8, backgroundColor: '#FEF2F2', borderRadius: 8 }}
              activeOpacity={0.7}
            >
              <Ionicons name="trash-outline" size={20} color="#EF4444" />
            </TouchableOpacity>
          </>
        ) : (
          <TouchableOpacity
            onPress={() => handleVideoUpload(lesson)}
            style={{ padding: 8, backgroundColor: '#EFF6FF', borderRadius: 8 }}
            activeOpacity={0.7}
          >
            <Ionicons name="cloud-upload-outline" size={20} color="#2563EB" />
          </TouchableOpacity>
        )}
        <TouchableOpacity
          onPress={() => handleEditLesson(lesson)}
          style={{ padding: 8, backgroundColor: '#F1F5F9', borderRadius: 8 }}
          activeOpacity={0.7}
        >
          <Ionicons name="create-outline" size={20} color="#475569" />
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => handleDeleteLesson(lesson)}
          style={{ padding: 8, backgroundColor: '#FEF2F2', borderRadius: 8 }}
          activeOpacity={0.7}
        >
          <Ionicons name="trash-outline" size={20} color="#EF4444" />
        </TouchableOpacity>
      </View>
    </View>
  );

  if (lessonsLoading && lessons.length === 0) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', padding: 32 }}>
        <Ionicons name="document-text-outline" size={64} color="#94A3B8" />
        <Text style={{ fontSize: 18, fontWeight: '600', color: '#0F172A', marginTop: 16 }}>
          Loading lessons...
        </Text>
      </View>
    );
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
      <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false} contentContainerStyle={{ padding: 16 }}>
        {/* Header */}
        <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
            <TouchableOpacity onPress={onClose} activeOpacity={0.7} style={{ padding: 4 }}>
              <Ionicons name="chevron-back" size={28} color="#0F172A" />
            </TouchableOpacity>
            <View>
              <Text style={{ fontSize: 24, fontWeight: '700', color: '#0F172A' }}>
                Lessons
              </Text>
              <Text style={{ fontSize: 14, color: '#64748B' }}>
                {sectionTitle}
              </Text>
            </View>
          </View>
          
          <TouchableOpacity
            onPress={() => setShowCreateModal(true)}
            style={{ flexDirection: 'row', alignItems: 'center', backgroundColor: '#2563EB', borderRadius: 12, paddingHorizontal: 16, paddingVertical: 10 }}
            activeOpacity={0.85}
          >
            <Ionicons name="add" size={20} color="#FFFFFF" style={{ marginRight: 8 }} />
            <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 14 }}>Add Lesson</Text>
          </TouchableOpacity>
        </View>

        {/* Lessons list */}
        {lessons.length === 0 ? (
          <View style={{ alignItems: 'center', paddingVertical: 48, backgroundColor: '#FFFFFF', borderRadius: 16 }}>
            <Ionicons name="document-text-outline" size={64} color="#94A3B8" />
            <Text style={{ fontSize: 18, fontWeight: '600', color: '#0F172A', marginTop: 16 }}>
              No lessons yet
            </Text>
            <Text style={{ fontSize: 14, color: '#64748B', marginTop: 4, textAlign: 'center', paddingHorizontal: 32 }}>
              Add lessons to this section. Each lesson can have a video, description, and duration.
            </Text>
            <TouchableOpacity
              onPress={() => setShowCreateModal(true)}
              style={{ marginTop: 20, backgroundColor: '#2563EB', borderRadius: 12, paddingHorizontal: 24, paddingVertical: 12 }}
              activeOpacity={0.85}
            >
              <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 14 }}>Create First Lesson</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <View style={{ marginBottom: 100 }}>
            {lessons.map((lesson, index) => renderLessonItem(lesson, index))}
          </View>
        )}

        {lessonsError && (
          <View style={{ backgroundColor: '#FEF2F2', borderWidth: 1, borderColor: '#FECACA', borderRadius: 12, padding: 16, marginTop: 16 }}>
            <Text style={{ color: '#DC2626', fontSize: 14 }}>{lessonsError}</Text>
          </View>
        )}
      </ScrollView>

      {/* Create Lesson Modal */}
      <Modal visible={showCreateModal} animationType="slide" transparent={false}>
        <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
          <KeyboardAvoidingView
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
            style={{ flex: 1 }}
            keyboardVerticalOffset={100}
          >
            <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false} contentContainerStyle={{ padding: 24 }}>
              <View style={{ marginBottom: 24 }}>
                <TouchableOpacity onPress={() => setShowCreateModal(false)} activeOpacity={0.7} style={{ padding: 4 }}>
                  <Ionicons name="close" size={28} color="#0F172A" />
                </TouchableOpacity>
              </View>

              <Text style={{ fontSize: 24, fontWeight: '700', color: '#0F172A', marginBottom: 8 }}>
                Create New Lesson
              </Text>
              <Text style={{ fontSize: 14, color: '#64748B', marginBottom: 24 }}>
                Add a lesson to this section
              </Text>

              <View style={{ marginBottom: 16 }}>
                <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                  Lesson Title *
                </Text>
                <TextInput
                  value={newLessonTitle}
                  onChangeText={setNewLessonTitle}
                  placeholder="e.g., Setting up your development environment"
                  style={{
                    backgroundColor: '#FFFFFF',
                    borderWidth: 1,
                    borderColor: '#E2E8F0',
                    borderRadius: 12,
                    paddingHorizontal: 16,
                    paddingVertical: 14,
                    fontSize: 16,
                    color: '#0F172A',
                  }}
                  autoCapitalize="words"
                />
              </View>

              <View style={{ marginBottom: 16 }}>
                <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                  Description (optional)
                </Text>
                <TextInput
                  value={newLessonDescription}
                  onChangeText={setNewLessonDescription}
                  placeholder="What will students learn in this lesson?"
                  style={{
                    backgroundColor: '#FFFFFF',
                    borderWidth: 1,
                    borderColor: '#E2E8F0',
                    borderRadius: 12,
                    paddingHorizontal: 16,
                    paddingVertical: 14,
                    fontSize: 16,
                    color: '#0F172A',
                    textAlignVertical: 'top',
                    minHeight: 80,
                  }}
                  multiline
                  autoCapitalize="sentences"
                />
              </View>

              <View style={{ flexDirection: 'row', gap: 12, marginBottom: 16 }}>
                <View style={{ flex: 1 }}>
                  <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                    Duration (optional)
                  </Text>
                  <TextInput
                    value={newLessonDuration}
                    onChangeText={setNewLessonDuration}
                    placeholder="e.g., 15:30"
                    style={{
                      backgroundColor: '#FFFFFF',
                      borderWidth: 1,
                      borderColor: '#E2E8F0',
                      borderRadius: 12,
                      paddingHorizontal: 16,
                      paddingVertical: 14,
                      fontSize: 16,
                      color: '#0F172A',
                    }}
                  />
                </View>
              </View>

              <View style={{ flexDirection: 'row', gap: 12, marginBottom: 24 }}>
                <TouchableOpacity
                  onPress={() => setNewLessonIsPreview(!newLessonIsPreview)}
                  style={{ 
                    flex: 1, 
                    flexDirection: 'row', 
                    alignItems: 'center', 
                    justifyContent: 'center',
                    backgroundColor: newLessonIsPreview ? '#EFF6FF' : '#F1F5F9', 
                    borderWidth: 1,
                    borderColor: newLessonIsPreview ? '#2563EB' : '#E2E8F0',
                    borderRadius: 12, 
                    paddingVertical: 14 
                  }}
                  activeOpacity={0.7}
                >
                  <Ionicons 
                    name={newLessonIsPreview ? 'checkmark-circle' : 'checkmark-circle-outline'} 
                    size={20} 
                    color={newLessonIsPreview ? '#2563EB' : '#94A3B8'} 
                    style={{ marginRight: 8 }} 
                  />
                  <Text style={{ color: newLessonIsPreview ? '#2563EB' : '#475569', fontWeight: '600', fontSize: 14 }}>
                    Preview Lesson
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity
                  onPress={() => setNewLessonIsFree(!newLessonIsFree)}
                  style={{ 
                    flex: 1, 
                    flexDirection: 'row', 
                    alignItems: 'center', 
                    justifyContent: 'center',
                    backgroundColor: newLessonIsFree ? '#D1FAE5' : '#F1F5F9', 
                    borderWidth: 1,
                    borderColor: newLessonIsFree ? '#10B981' : '#E2E8F0',
                    borderRadius: 12, 
                    paddingVertical: 14 
                  }}
                  activeOpacity={0.7}
                >
                  <Ionicons 
                    name={newLessonIsFree ? 'checkmark-circle' : 'checkmark-circle-outline'} 
                    size={20} 
                    color={newLessonIsFree ? '#10B981' : '#94A3B8'} 
                    style={{ marginRight: 8 }} 
                  />
                  <Text style={{ color: newLessonIsFree ? '#065F46' : '#475569', fontWeight: '600', fontSize: 14 }}>
                    Free Lesson
                  </Text>
                </TouchableOpacity>
              </View>

              <View style={{ flexDirection: 'row', gap: 12, marginTop: 8 }}>
                <TouchableOpacity
                  onPress={() => setShowCreateModal(false)}
                  style={{ flex: 1, backgroundColor: '#F1F5F9', borderRadius: 12, paddingVertical: 14, alignItems: 'center' }}
                  activeOpacity={0.7}
                >
                  <Text style={{ color: '#475569', fontWeight: '600', fontSize: 16 }}>Cancel</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  onPress={handleCreateLesson}
                  disabled={!newLessonTitle.trim()}
                  style={{ flex: 1, backgroundColor: '#2563EB', borderRadius: 12, paddingVertical: 14, alignItems: 'center' }}
                  activeOpacity={0.85}
                >
                  <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 16 }}>Create Lesson</Text>
                </TouchableOpacity>
              </View>
            </ScrollView>
          </KeyboardAvoidingView>
        </SafeAreaView>
      </Modal>

      {/* Edit Lesson Modal */}
      <Modal visible={showEditModal} animationType="slide" transparent={false}>
        <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
          <KeyboardAvoidingView
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
            style={{ flex: 1 }}
            keyboardVerticalOffset={100}
          >
            <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false} contentContainerStyle={{ padding: 24 }}>
              <View style={{ marginBottom: 24 }}>
                <TouchableOpacity onPress={() => setShowEditModal(false)} activeOpacity={0.7} style={{ padding: 4 }}>
                  <Ionicons name="close" size={28} color="#0F172A" />
                </TouchableOpacity>
              </View>

              <Text style={{ fontSize: 24, fontWeight: '700', color: '#0F172A', marginBottom: 8 }}>
                Edit Lesson
              </Text>

              <View style={{ marginBottom: 16 }}>
                <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                  Lesson Title *
                </Text>
                <TextInput
                  value={editTitle}
                  onChangeText={setEditTitle}
                  placeholder="e.g., Setting up your development environment"
                  style={{
                    backgroundColor: '#FFFFFF',
                    borderWidth: 1,
                    borderColor: '#E2E8F0',
                    borderRadius: 12,
                    paddingHorizontal: 16,
                    paddingVertical: 14,
                    fontSize: 16,
                    color: '#0F172A',
                  }}
                  autoCapitalize="words"
                />
              </View>

              <View style={{ marginBottom: 16 }}>
                <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                  Description (optional)
                </Text>
                <TextInput
                  value={editDescription}
                  onChangeText={setEditDescription}
                  placeholder="What will students learn in this lesson?"
                  style={{
                    backgroundColor: '#FFFFFF',
                    borderWidth: 1,
                    borderColor: '#E2E8F0',
                    borderRadius: 12,
                    paddingHorizontal: 16,
                    paddingVertical: 14,
                    fontSize: 16,
                    color: '#0F172A',
                    textAlignVertical: 'top',
                    minHeight: 80,
                  }}
                  multiline
                  autoCapitalize="sentences"
                />
              </View>

              <View style={{ flexDirection: 'row', gap: 12, marginBottom: 16 }}>
                <View style={{ flex: 1 }}>
                  <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                    Duration (optional)
                  </Text>
                  <TextInput
                    value={editDuration}
                    onChangeText={setEditDuration}
                    placeholder="e.g., 15:30"
                    style={{
                      backgroundColor: '#FFFFFF',
                      borderWidth: 1,
                      borderColor: '#E2E8F0',
                      borderRadius: 12,
                      paddingHorizontal: 16,
                      paddingVertical: 14,
                      fontSize: 16,
                      color: '#0F172A',
                    }}
                  />
                </View>
              </View>

              <View style={{ flexDirection: 'row', gap: 12, marginBottom: 24 }}>
                <TouchableOpacity
                  onPress={() => setEditIsPreview(!editIsPreview)}
                  style={{ 
                    flex: 1, 
                    flexDirection: 'row', 
                    alignItems: 'center', 
                    justifyContent: 'center',
                    backgroundColor: editIsPreview ? '#EFF6FF' : '#F1F5F9', 
                    borderWidth: 1,
                    borderColor: editIsPreview ? '#2563EB' : '#E2E8F0',
                    borderRadius: 12, 
                    paddingVertical: 14 
                  }}
                  activeOpacity={0.7}
                >
                  <Ionicons 
                    name={editIsPreview ? 'checkmark-circle' : 'checkmark-circle-outline'} 
                    size={20} 
                    color={editIsPreview ? '#2563EB' : '#94A3B8'} 
                    style={{ marginRight: 8 }} 
                  />
                  <Text style={{ color: editIsPreview ? '#2563EB' : '#475569', fontWeight: '600', fontSize: 14 }}>
                    Preview Lesson
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity
                  onPress={() => setEditIsFree(!editIsFree)}
                  style={{ 
                    flex: 1, 
                    flexDirection: 'row', 
                    alignItems: 'center', 
                    justifyContent: 'center',
                    backgroundColor: editIsFree ? '#D1FAE5' : '#F1F5F9', 
                    borderWidth: 1,
                    borderColor: editIsFree ? '#10B981' : '#E2E8F0',
                    borderRadius: 12, 
                    paddingVertical: 14 
                  }}
                  activeOpacity={0.7}
                >
                  <Ionicons 
                    name={editIsFree ? 'checkmark-circle' : 'checkmark-circle-outline'} 
                    size={20} 
                    color={editIsFree ? '#10B981' : '#94A3B8'} 
                    style={{ marginRight: 8 }} 
                  />
                  <Text style={{ color: editIsFree ? '#065F46' : '#475569', fontWeight: '600', fontSize: 14 }}>
                    Free Lesson
                  </Text>
                </TouchableOpacity>
              </View>

              <View style={{ flexDirection: 'row', gap: 12, marginTop: 8 }}>
                <TouchableOpacity
                  onPress={() => setShowEditModal(false)}
                  style={{ flex: 1, backgroundColor: '#F1F5F9', borderRadius: 12, paddingVertical: 14, alignItems: 'center' }}
                  activeOpacity={0.7}
                >
                  <Text style={{ color: '#475569', fontWeight: '600', fontSize: 16 }}>Cancel</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  onPress={handleUpdateLesson}
                  disabled={!editTitle.trim()}
                  style={{ flex: 1, backgroundColor: '#2563EB', borderRadius: 12, paddingVertical: 14, alignItems: 'center' }}
                  activeOpacity={0.85}
                >
                  <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 16 }}>Save Changes</Text>
                </TouchableOpacity>
              </View>
            </ScrollView>
          </KeyboardAvoidingView>
        </SafeAreaView>
      </Modal>

      {/* Video Upload Modal */}
      <Modal visible={showVideoModal} animationType="slide" transparent={false}>
        <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
          <View style={{ flex: 1, padding: 24 }}>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
              <Text style={{ fontSize: 24, fontWeight: '700', color: '#0F172A' }}>
                Upload Video
              </Text>
              <TouchableOpacity onPress={() => { setShowVideoModal(false); setVideoUploadingLessonId(null); }} activeOpacity={0.7} style={{ padding: 4 }}>
                <Ionicons name="close" size={28} color="#0F172A" />
              </TouchableOpacity>
            </View>

            {videoUploadingLessonId && (
              <View>
                <Text style={{ fontSize: 16, fontWeight: '600', color: '#0F172A', marginBottom: 16 }}>
                  Uploading video for lesson...
                </Text>
                
                {uploadLoading && (
                  <View style={{ marginBottom: 24 }}>
                    <View style={{ height: 8, backgroundColor: '#E2E8F0', borderRadius: 4, overflow: 'hidden' }}>
                      <View 
                        style={{ 
                          height: '100%', 
                          backgroundColor: '#2563EB', 
                          width: `${uploadProgress}%`,
                        }} 
                      />
                    </View>
                    <Text style={{ fontSize: 12, color: '#64748B', marginTop: 8, textAlign: 'center' }}>
                      {uploadProgress > 0 ? `${uploadProgress}%` : 'Preparing upload...'}
                    </Text>
                  </View>
                )}

                {uploadError && (
                  <View style={{ backgroundColor: '#FEF2F2', borderWidth: 1, borderColor: '#FECACA', borderRadius: 12, padding: 16, marginBottom: 16 }}>
                    <Text style={{ color: '#DC2626', fontSize: 14 }}>{uploadError}</Text>
                    <TouchableOpacity
                      onPress={() => { setShowVideoModal(false); setVideoUploadingLessonId(null); }}
                      style={{ marginTop: 12, backgroundColor: '#2563EB', borderRadius: 8, paddingVertical: 10, paddingHorizontal: 16, alignSelf: 'center' }}
                    >
                      <Text style={{ color: '#FFFFFF', fontWeight: '600' }}>Close</Text>
                    </TouchableOpacity>
                  </View>
                )}

                {!uploadLoading && !uploadError && (
                  <View style={{ alignItems: 'center', justifyContent: 'center', paddingVertical: 40 }}>
                    <Ionicons name="checkmark-circle" size={64} color="#10B981" />
                    <Text style={{ fontSize: 18, fontWeight: '600', color: '#0F172A', marginTop: 16 }}>
                      Video uploaded successfully!
                    </Text>
                    <TouchableOpacity
                      onPress={() => { setShowVideoModal(false); setVideoUploadingLessonId(null); }}
                      style={{ marginTop: 20, backgroundColor: '#2563EB', borderRadius: 12, paddingHorizontal: 24, paddingVertical: 12 }}
                      activeOpacity={0.85}
                    >
                      <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 16 }}>Done</Text>
                    </TouchableOpacity>
                  </View>
                )}

                {!uploadLoading && !uploadError && uploadProgress === 0 && (
                  <View style={{ alignItems: 'center', paddingVertical: 40 }}>
                    <Text style={{ fontSize: 16, color: '#64748B', textAlign: 'center', marginBottom: 20 }}>
                      Video upload functionality requires native file picker integration.
                      For now, use the video URL field in the lesson form to add videos.
                    </Text>
                    <TouchableOpacity
                      onPress={() => { setShowVideoModal(false); setVideoUploadingLessonId(null); }}
                      style={{ backgroundColor: '#2563EB', borderRadius: 12, paddingHorizontal: 24, paddingVertical: 12 }}
                      activeOpacity={0.85}
                    >
                      <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 16 }}>Close</Text>
                    </TouchableOpacity>
                  </View>
                )}
              </View>
            )}
          </View>
        </SafeAreaView>
      </Modal>
    </SafeAreaView>
  );
};

export default LessonManager;