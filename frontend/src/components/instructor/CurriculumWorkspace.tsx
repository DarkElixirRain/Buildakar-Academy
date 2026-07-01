import React, { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  KeyboardAvoidingView,
  Modal,
  Platform,
  SafeAreaView,
  ScrollView,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import { useTheme } from '@/context/themeContext';
import { useInstructorStore } from '@/store/instructorStore';
import { Lesson, Section } from '@/types/instructor';

interface CurriculumWorkspaceProps {
  courseId: string;
  courseTitle: string;
  onClose?: () => void;
}

export const CurriculumWorkspace: React.FC<CurriculumWorkspaceProps> = ({
  courseId,
  courseTitle,
  onClose,
}) => {
  const { colors } = useTheme();
  const {
    sections,
    sectionsLoading,
    sectionsError,
    lessons,
    lessonsLoading,
    lessonsError,
    uploadLoading,
    uploadError,
    fetchSections,
    createSection,
    updateSection,
    deleteSection,
    fetchLessonsBySection,
    createLesson,
    updateLesson,
    deleteLesson,
    uploadVideo,
    clearSectionsError,
    clearLessonsError,
  } = useInstructorStore();

  const [showSectionModal, setShowSectionModal] = useState(false);
  const [showLessonModal, setShowLessonModal] = useState(false);
  const [editingSection, setEditingSection] = useState<Section | null>(null);
  const [editingLesson, setEditingLesson] = useState<Lesson | null>(null);
  const [sectionTitle, setSectionTitle] = useState('');
  const [sectionDescription, setSectionDescription] = useState('');
  const [lessonTitle, setLessonTitle] = useState('');
  const [lessonDescription, setLessonDescription] = useState('');
  const [lessonDuration, setLessonDuration] = useState('');
  const [lessonIsPreview, setLessonIsPreview] = useState(false);
  const [lessonIsFree, setLessonIsFree] = useState(false);
  const [selectedLessonVideo, setSelectedLessonVideo] = useState<{
    uri: string;
    name: string;
    mimeType: string;
    size: number;
    file?: any;
  } | null>(null);
  const [expandedSectionId, setExpandedSectionId] = useState<string | null>(null);

  useEffect(() => {
    void fetchSections(courseId);
    clearSectionsError();
  }, [courseId, fetchSections, clearSectionsError]);

  const handleCreateSection = async () => {
    if (!sectionTitle.trim()) {
      Alert.alert('Missing title', 'Please add a section title.');
      return;
    }

    try {
      await createSection(courseId, {
        title: sectionTitle.trim(),
        description: sectionDescription.trim() || undefined,
      });
      setSectionTitle('');
      setSectionDescription('');
      setShowSectionModal(false);
      setEditingSection(null);
    } catch {
      // handled by store
    }
  };

  const handleEditSection = (section: Section) => {
    setEditingSection(section);
    setSectionTitle(section.title);
    setSectionDescription(section.description || '');
    setShowSectionModal(true);
  };

  const handleUpdateSection = async () => {
    if (!editingSection || !sectionTitle.trim()) {
      return;
    }

    try {
      await updateSection(editingSection.id, {
        title: sectionTitle.trim(),
        description: sectionDescription.trim() || undefined,
      });
      setSectionTitle('');
      setSectionDescription('');
      setShowSectionModal(false);
      setEditingSection(null);
    } catch {
      // handled by store
    }
  };

  const handleDeleteSection = (section: Section) => {
    Alert.alert('Delete section', `Delete “${section.title}” and all lesson content inside it?`, [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete',
        style: 'destructive',
        onPress: async () => {
          try {
            await deleteSection(section.id);
          } catch {
            // handled by store
          }
        },
      },
    ]);
  };

  const handleToggleSection = async (section: Section) => {
    if (expandedSectionId === section.id) {
      setExpandedSectionId(null);
      return;
    }

    setExpandedSectionId(section.id);
    await fetchLessonsBySection(section.id);
    clearLessonsError();
  };

  const handlePickLessonVideo = async () => {
    try {
      const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (!permission.granted) {
        Alert.alert('Permission needed', 'Please allow photo access to pick a video file.');
        return;
      }

      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ['videos'],
        allowsEditing: false,
        quality: 1,
      });

      if (result.canceled || !result.assets?.length) {
        return;
      }

      const asset = result.assets[0];
      let uri = asset.uri;
      let fileName = asset.fileName || asset.uri.split('/').pop() || `lesson-video-${Date.now()}.mp4`;
      const mimeType = asset.mimeType || 'video/mp4';
      const size = asset.fileSize || 0;
      let fileObj: any = undefined;

      if (Platform.OS === 'web' && asset.uri.startsWith('blob:')) {
        const response = await fetch(asset.uri);
        const blob = await response.blob();
        fileObj = new File([blob], fileName, { type: mimeType });
        uri = URL.createObjectURL(blob);
      }

      setSelectedLessonVideo({ uri, name: fileName, mimeType, size, file: fileObj });
    } catch {
      Alert.alert('Unable to pick video', 'Please try another file or use a smaller video.');
    }
  };

  const handleCreateLesson = async () => {
    if (!editingSection || !lessonTitle.trim()) {
      Alert.alert('Missing title', 'Please add a lesson title.');
      return;
    }

    try {
      const lesson = await createLesson(editingSection.id, {
        title: lessonTitle.trim(),
        description: lessonDescription.trim() || undefined,
        duration: lessonDuration.trim() || undefined,
        isPreview: lessonIsPreview,
        isFree: lessonIsFree,
      });

      if (selectedLessonVideo) {
        try {
          await uploadVideo(lesson.id, {
            uri: selectedLessonVideo.uri,
            name: selectedLessonVideo.name,
            mimeType: selectedLessonVideo.mimeType,
            size: selectedLessonVideo.size,
            file: selectedLessonVideo.file,
          });
        } catch {
          Alert.alert('Video upload failed', 'The lesson was created, but the video upload did not complete.');
        }
      }

      setLessonTitle('');
      setLessonDescription('');
      setLessonDuration('');
      setLessonIsPreview(false);
      setLessonIsFree(false);
      setSelectedLessonVideo(null);
      setShowLessonModal(false);
      setEditingLesson(null);
      setExpandedSectionId(editingSection.id);
      await fetchLessonsBySection(editingSection.id);
    } catch {
      // handled by store
    }
  };

  const handleEditLesson = (lesson: Lesson, sectionId: string) => {
    setEditingLesson(lesson);
    setEditingSection({ id: sectionId, title: '', description: '', order: 0, courseId, createdAt: '', updatedAt: '' } as Section);
    setLessonTitle(lesson.title);
    setLessonDescription(lesson.description || '');
    setLessonDuration(lesson.duration || '');
    setLessonIsPreview(lesson.isPreview);
    setLessonIsFree(lesson.isFree);
    setShowLessonModal(true);
  };

  const handleUpdateLesson = async () => {
    if (!editingLesson || !editingSection || !lessonTitle.trim()) {
      return;
    }

    try {
      const lesson = await updateLesson(editingLesson.id, {
        title: lessonTitle.trim(),
        description: lessonDescription.trim() || undefined,
        duration: lessonDuration.trim() || undefined,
        isPreview: lessonIsPreview,
        isFree: lessonIsFree,
      });

      if (selectedLessonVideo) {
        try {
          await uploadVideo(lesson.id, {
            uri: selectedLessonVideo.uri,
            name: selectedLessonVideo.name,
            mimeType: selectedLessonVideo.mimeType,
            size: selectedLessonVideo.size,
            file: selectedLessonVideo.file,
          });
        } catch {
          Alert.alert('Video upload failed', 'The lesson was updated, but the video upload did not complete.');
        }
      }

      setLessonTitle('');
      setLessonDescription('');
      setLessonDuration('');
      setLessonIsPreview(false);
      setLessonIsFree(false);
      setSelectedLessonVideo(null);
      setShowLessonModal(false);
      setEditingLesson(null);
      setEditingSection(null);
      await fetchLessonsBySection(editingSection.id);
    } catch {
      // handled by store
    }
  };

  const handleDeleteLesson = (lesson: Lesson, sectionId: string) => {
    Alert.alert('Delete lesson', `Delete “${lesson.title}”?`, [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete',
        style: 'destructive',
        onPress: async () => {
          try {
            await deleteLesson(lesson.id);
            await fetchLessonsBySection(sectionId);
          } catch {
            // handled by store
          }
        },
      },
    ]);
  };

  const resetLessonForm = () => {
    setLessonTitle('');
    setLessonDescription('');
    setLessonDuration('');
    setLessonIsPreview(false);
    setLessonIsFree(false);
    setSelectedLessonVideo(null);
    setEditingLesson(null);
    setEditingSection(null);
  };

  const currentLessons = useMemo(() => {
    if (!expandedSectionId) {
      return [];
    }
    return lessons.filter((lesson) => lesson.sectionId === expandedSectionId);
  }, [expandedSectionId, lessons]);

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', paddingHorizontal: 20, paddingTop: 16, paddingBottom: 12 }}>
        <TouchableOpacity onPress={onClose} style={{ marginRight: 10 }}>
          <Ionicons name="arrow-back" size={24} color={colors.text} />
        </TouchableOpacity>
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontSize: 20, fontWeight: '700' }}>Curriculum</Text>
          <Text style={{ color: colors.textSecondary, fontSize: 13, marginTop: 2 }} numberOfLines={1}>
            {courseTitle}
          </Text>
        </View>
      </View>

      <ScrollView contentContainerStyle={{ paddingHorizontal: 20, paddingBottom: 32 }}>
        <TouchableOpacity
          onPress={() => {
            setEditingSection(null);
            setSectionTitle('');
            setSectionDescription('');
            setShowSectionModal(true);
          }}
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: colors.primary,
            borderRadius: 14,
            paddingVertical: 12,
            marginBottom: 16,
          }}
        >
          <Ionicons name="add-circle-outline" size={18} color="#FFFFFF" />
          <Text style={{ color: '#FFFFFF', fontWeight: '700', marginLeft: 8 }}>Add section</Text>
        </TouchableOpacity>

        {sectionsLoading && !sections.length ? (
          <View style={{ alignItems: 'center', paddingVertical: 24 }}>
            <ActivityIndicator size="large" color={colors.primary} />
            <Text style={{ color: colors.textSecondary, marginTop: 10 }}>Loading sections…</Text>
          </View>
        ) : null}

        {sections.length === 0 && !sectionsLoading ? (
          <View style={{ borderRadius: 16, backgroundColor: colors.backgroundElement, padding: 20, alignItems: 'center' }}>
            <Ionicons name="reader-outline" size={34} color={colors.primary} />
            <Text style={{ color: colors.text, fontSize: 16, fontWeight: '700', marginTop: 12 }}>No sections yet</Text>
            <Text style={{ color: colors.textSecondary, textAlign: 'center', marginTop: 4 }}>
              Build your course outline with sections and lesson content from the backend.
            </Text>
          </View>
        ) : null}

        <View style={{ gap: 12 }}>
          {sections.map((section) => {
            const isExpanded = expandedSectionId === section.id;
            return (
              <View key={section.id} style={{ borderRadius: 16, backgroundColor: colors.backgroundElement, borderWidth: 1, borderColor: colors.backgroundSelected }}>
                <TouchableOpacity onPress={() => void handleToggleSection(section)} style={{ padding: 16 }}>
                  <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
                    <View style={{ flex: 1, paddingRight: 10 }}>
                      <Text style={{ color: colors.text, fontSize: 16, fontWeight: '700' }}>{section.title}</Text>
                      {section.description ? (
                        <Text style={{ color: colors.textSecondary, fontSize: 13, marginTop: 4 }} numberOfLines={2}>
                          {section.description}
                        </Text>
                      ) : null}
                    </View>
                    <Ionicons name={isExpanded ? 'chevron-up' : 'chevron-down'} size={20} color={colors.textSecondary} />
                  </View>

                  <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 10, gap: 8 }}>
                    <View style={{ backgroundColor: `${colors.primary}20`, borderRadius: 999, paddingHorizontal: 10, paddingVertical: 4 }}>
                      <Text style={{ color: colors.primary, fontSize: 12, fontWeight: '600' }}>
                        {section._count?.lessons || 0} lessons
                      </Text>
                    </View>
                  </View>
                </TouchableOpacity>

                {isExpanded ? (
                  <View style={{ paddingHorizontal: 16, paddingBottom: 16 }}>
                    <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
                      <Text style={{ color: colors.text, fontWeight: '700' }}>Lessons</Text>
                      <TouchableOpacity
                        onPress={() => {
                          setEditingSection(section);
                          setLessonTitle('');
                          setLessonDescription('');
                          setLessonDuration('');
                          setLessonIsPreview(false);
                          setLessonIsFree(false);
                          setShowLessonModal(true);
                        }}
                        style={{ flexDirection: 'row', alignItems: 'center' }}
                      >
                        <Ionicons name="add" size={16} color={colors.primary} />
                        <Text style={{ color: colors.primary, fontWeight: '600', marginLeft: 4 }}>Add lesson</Text>
                      </TouchableOpacity>
                    </View>

                    {lessonsLoading && expandedSectionId === section.id ? (
                      <View style={{ paddingVertical: 10, alignItems: 'center' }}>
                        <ActivityIndicator size="small" color={colors.primary} />
                      </View>
                    ) : currentLessons.length === 0 ? (
                      <View style={{ borderRadius: 12, borderWidth: 1, borderColor: colors.backgroundSelected, padding: 12 }}>
                        <Text style={{ color: colors.textSecondary }}>No lessons yet for this section.</Text>
                      </View>
                    ) : (
                      currentLessons.map((lesson) => (
                        <View key={lesson.id} style={{ borderRadius: 12, backgroundColor: colors.background, padding: 12, marginBottom: 8 }}>
                          <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                            <View style={{ flex: 1 }}>
                              <Text style={{ color: colors.text, fontWeight: '700' }}>{lesson.title}</Text>
                              {lesson.description ? (
                                <Text style={{ color: colors.textSecondary, fontSize: 13, marginTop: 4 }} numberOfLines={2}>
                                  {lesson.description}
                                </Text>
                              ) : null}
                              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 8 }}>
                                {lesson.duration ? (
                                  <Text style={{ color: colors.textSecondary, fontSize: 12 }}>{lesson.duration}</Text>
                                ) : null}
                                {lesson.isPreview ? (
                                  <View style={{ paddingHorizontal: 8, paddingVertical: 3, backgroundColor: `${colors.primary}20`, borderRadius: 999 }}>
                                    <Text style={{ color: colors.primary, fontSize: 11, fontWeight: '700' }}>Preview</Text>
                                  </View>
                                ) : null}
                                {lesson.isFree ? (
                                  <View style={{ paddingHorizontal: 8, paddingVertical: 3, backgroundColor: '#10B98120', borderRadius: 999 }}>
                                    <Text style={{ color: '#10B981', fontSize: 11, fontWeight: '700' }}>Free</Text>
                                  </View>
                                ) : null}
                              </View>
                            </View>
                            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                              <TouchableOpacity onPress={() => handleEditLesson(lesson, section.id)} style={{ padding: 6 }}>
                                <Ionicons name="create-outline" size={18} color={colors.primary} />
                              </TouchableOpacity>
                              <TouchableOpacity onPress={() => handleDeleteLesson(lesson, section.id)} style={{ padding: 6 }}>
                                <Ionicons name="trash-outline" size={18} color="#EF4444" />
                              </TouchableOpacity>
                            </View>
                          </View>
                        </View>
                      ))
                    )}

                    <View style={{ flexDirection: 'row', justifyContent: 'flex-end', marginTop: 10, gap: 8 }}>
                      <TouchableOpacity onPress={() => handleEditSection(section)} style={{ flexDirection: 'row', alignItems: 'center', paddingHorizontal: 10, paddingVertical: 8, borderRadius: 999, backgroundColor: `${colors.primary}20` }}>
                        <Ionicons name="create-outline" size={15} color={colors.primary} />
                        <Text style={{ color: colors.primary, fontWeight: '600', marginLeft: 6 }}>Edit section</Text>
                      </TouchableOpacity>
                      <TouchableOpacity onPress={() => handleDeleteSection(section)} style={{ flexDirection: 'row', alignItems: 'center', paddingHorizontal: 10, paddingVertical: 8, borderRadius: 999, backgroundColor: '#FEE2E220' }}>
                        <Ionicons name="trash-outline" size={15} color="#EF4444" />
                        <Text style={{ color: '#EF4444', fontWeight: '600', marginLeft: 6 }}>Delete</Text>
                      </TouchableOpacity>
                    </View>
                  </View>
                ) : null}
              </View>
            );
          })}
        </View>
      </ScrollView>

      <Modal visible={showSectionModal} animationType="slide">
        <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
          <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={{ flex: 1 }}>
            <ScrollView contentContainerStyle={{ padding: 20 }}>
              <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
                <TouchableOpacity onPress={() => { setShowSectionModal(false); setEditingSection(null); }}>
                  <Ionicons name="close" size={24} color={colors.text} />
                </TouchableOpacity>
                <Text style={{ color: colors.text, fontSize: 20, fontWeight: '700' }}>
                  {editingSection ? 'Edit section' : 'Create section'}
                </Text>
                <View style={{ width: 24 }} />
              </View>

              <Text style={{ color: colors.text, fontWeight: '700', marginBottom: 8 }}>Section title</Text>
              <TextInput
                value={sectionTitle}
                onChangeText={setSectionTitle}
                placeholder="e.g. Introduction"
                placeholderTextColor={colors.textSecondary}
                style={{ backgroundColor: colors.backgroundElement, borderRadius: 12, paddingHorizontal: 14, paddingVertical: 12, color: colors.text, marginBottom: 14 }}
              />

              <Text style={{ color: colors.text, fontWeight: '700', marginBottom: 8 }}>Description</Text>
              <TextInput
                value={sectionDescription}
                onChangeText={setSectionDescription}
                placeholder="Describe what students will learn in this section"
                placeholderTextColor={colors.textSecondary}
                multiline
                style={{ backgroundColor: colors.backgroundElement, borderRadius: 12, paddingHorizontal: 14, paddingVertical: 12, color: colors.text, minHeight: 96, textAlignVertical: 'top', marginBottom: 20 }}
              />

              <TouchableOpacity
                onPress={editingSection ? handleUpdateSection : handleCreateSection}
                style={{ backgroundColor: colors.primary, borderRadius: 14, paddingVertical: 14, alignItems: 'center' }}
              >
                <Text style={{ color: '#FFFFFF', fontWeight: '700' }}>{editingSection ? 'Save section' : 'Create section'}</Text>
              </TouchableOpacity>
            </ScrollView>
          </KeyboardAvoidingView>
        </SafeAreaView>
      </Modal>

      <Modal visible={showLessonModal} animationType="slide">
        <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
          <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={{ flex: 1 }}>
            <ScrollView contentContainerStyle={{ padding: 20 }}>
              <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
                <TouchableOpacity onPress={() => { setShowLessonModal(false); resetLessonForm(); }}>
                  <Ionicons name="close" size={24} color={colors.text} />
                </TouchableOpacity>
                <Text style={{ color: colors.text, fontSize: 20, fontWeight: '700' }}>
                  {editingLesson ? 'Edit lesson' : 'Create lesson'}
                </Text>
                <View style={{ width: 24 }} />
              </View>

              <Text style={{ color: colors.text, fontWeight: '700', marginBottom: 8 }}>Lesson title</Text>
              <TextInput
                value={lessonTitle}
                onChangeText={setLessonTitle}
                placeholder="e.g. Why this matters"
                placeholderTextColor={colors.textSecondary}
                style={{ backgroundColor: colors.backgroundElement, borderRadius: 12, paddingHorizontal: 14, paddingVertical: 12, color: colors.text, marginBottom: 14 }}
              />

              <Text style={{ color: colors.text, fontWeight: '700', marginBottom: 8 }}>Description</Text>
              <TextInput
                value={lessonDescription}
                onChangeText={setLessonDescription}
                placeholder="Explain the lesson topic"
                placeholderTextColor={colors.textSecondary}
                multiline
                style={{ backgroundColor: colors.backgroundElement, borderRadius: 12, paddingHorizontal: 14, paddingVertical: 12, color: colors.text, minHeight: 96, textAlignVertical: 'top', marginBottom: 14 }}
              />

              <Text style={{ color: colors.text, fontWeight: '700', marginBottom: 8 }}>Duration</Text>
              <TextInput
                value={lessonDuration}
                onChangeText={setLessonDuration}
                placeholder="e.g. 12 min"
                placeholderTextColor={colors.textSecondary}
                style={{ backgroundColor: colors.backgroundElement, borderRadius: 12, paddingHorizontal: 14, paddingVertical: 12, color: colors.text, marginBottom: 14 }}
              />

              <View style={{ flexDirection: 'row', gap: 12, marginBottom: 20 }}>
                <TouchableOpacity onPress={() => setLessonIsPreview((prev) => !prev)} style={{ flex: 1, borderRadius: 12, paddingVertical: 12, alignItems: 'center', borderWidth: 1, borderColor: lessonIsPreview ? colors.primary : colors.backgroundSelected, backgroundColor: lessonIsPreview ? `${colors.primary}20` : colors.backgroundElement }}>
                  <Text style={{ color: lessonIsPreview ? colors.primary : colors.text, fontWeight: '700' }}>Preview lesson</Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={() => setLessonIsFree((prev) => !prev)} style={{ flex: 1, borderRadius: 12, paddingVertical: 12, alignItems: 'center', borderWidth: 1, borderColor: lessonIsFree ? '#10B981' : colors.backgroundSelected, backgroundColor: lessonIsFree ? '#10B98120' : colors.backgroundElement }}>
                  <Text style={{ color: lessonIsFree ? '#10B981' : colors.text, fontWeight: '700' }}>Free lesson</Text>
                </TouchableOpacity>
              </View>

              <Text style={{ color: colors.text, fontWeight: '700', marginBottom: 8 }}>Lesson video</Text>
              <TouchableOpacity
                onPress={handlePickLessonVideo}
                style={{ borderRadius: 12, borderWidth: 1, borderColor: colors.backgroundSelected, backgroundColor: colors.backgroundElement, padding: 14, marginBottom: 12 }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                  <Ionicons name="videocam-outline" size={18} color={colors.primary} />
                  <Text style={{ color: colors.text, fontWeight: '700', marginLeft: 8 }}>
                    {selectedLessonVideo ? 'Video selected' : editingLesson?.videoUrl ? 'Replace video' : 'Attach video'}
                  </Text>
                </View>
                <Text style={{ color: colors.textSecondary, fontSize: 13, marginTop: 6 }}>
                  {selectedLessonVideo
                    ? `${selectedLessonVideo.name} • ${selectedLessonVideo.mimeType}`
                    : editingLesson?.videoUrl
                    ? 'Choose a new video file to replace the current lesson video.'
                    : 'Choose a video file from your device to upload after saving the lesson.'}
                </Text>
              </TouchableOpacity>

              {uploadLoading ? (
                <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'center', marginBottom: 12 }}>
                  <ActivityIndicator size="small" color={colors.primary} />
                  <Text style={{ color: colors.textSecondary, marginLeft: 8 }}>Uploading video…</Text>
                </View>
              ) : null}

              {uploadError ? (
                <Text style={{ color: '#EF4444', marginBottom: 12 }}>{uploadError}</Text>
              ) : null}

              <TouchableOpacity
                onPress={editingLesson ? handleUpdateLesson : handleCreateLesson}
                disabled={uploadLoading}
                style={{ backgroundColor: uploadLoading ? colors.textSecondary : colors.primary, borderRadius: 14, paddingVertical: 14, alignItems: 'center' }}
              >
                <Text style={{ color: '#FFFFFF', fontWeight: '700' }}>{editingLesson ? 'Save lesson' : 'Create lesson'}</Text>
              </TouchableOpacity>
            </ScrollView>
          </KeyboardAvoidingView>
        </SafeAreaView>
      </Modal>

      {sectionsError ? (
        <View style={{ paddingHorizontal: 20, paddingBottom: 10 }}>
          <Text style={{ color: '#EF4444' }}>{sectionsError}</Text>
        </View>
      ) : null}
      {lessonsError ? (
        <View style={{ paddingHorizontal: 20, paddingBottom: 10 }}>
          <Text style={{ color: '#EF4444' }}>{lessonsError}</Text>
        </View>
      ) : null}
    </SafeAreaView>
  );
};

export default CurriculumWorkspace;
