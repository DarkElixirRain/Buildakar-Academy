// components/instructor/SectionManager.tsx
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, TextInput, ScrollView, Modal, Alert, KeyboardAvoidingView, Platform, SafeAreaView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Section, CreateSectionInput, UpdateSectionInput } from '@/types/instructor';
import { useInstructorStore } from '@/store/instructorStore';
import { StatusBadge, LevelBadge } from './StatusBadge';
import { LessonManager } from './LessonManager';

interface SectionManagerProps {
  courseId: string;
  courseTitle: string;
  onClose?: () => void;
}

export const SectionManager: React.FC<SectionManagerProps> = ({ 
  courseId, 
  courseTitle, 
  onClose 
}) => {
  const { 
    sections, 
    sectionsLoading, 
    sectionsError,
    fetchSections, 
    createSection, 
    updateSection, 
    deleteSection, 
    reorderSections,
    setCurrentSection,
    clearSectionsError,
  } = useInstructorStore();

  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [newSectionTitle, setNewSectionTitle] = useState('');
  const [newSectionDescription, setNewSectionDescription] = useState('');
  const [editingSection, setEditingSection] = useState<Section | null>(null);
  const [editTitle, setEditTitle] = useState('');
  const [editDescription, setEditDescription] = useState('');
  
  const [showLessonManager, setShowLessonManager] = useState(false);
  const [selectedSection, setSelectedSection] = useState<Section | null>(null);

  useEffect(() => {
    fetchSections(courseId);
    clearSectionsError();
  }, [courseId]);

  const handleCreateSection = async () => {
    if (!newSectionTitle.trim()) {
      Alert.alert('Error', 'Section title is required');
      return;
    }

    try {
      await createSection(courseId, { title: newSectionTitle, description: newSectionDescription });
      setNewSectionTitle('');
      setNewSectionDescription('');
      setShowCreateModal(false);
    } catch (error) {
      // Error handled in store
    }
  };

  const handleEditSection = async (section: Section) => {
    setEditingSection(section);
    setEditTitle(section.title);
    setEditDescription(section.description || '');
    setShowEditModal(true);
  };

  const handleUpdateSection = async () => {
    if (!editingSection || !editTitle.trim()) return;

    try {
      await updateSection(editingSection.id, { title: editTitle, description: editDescription });
      setEditingSection(null);
      setEditTitle('');
      setEditDescription('');
      setShowEditModal(false);
    } catch (error) {
      // Error handled in store
    }
  };

  const handleDeleteSection = (section: Section) => {
    Alert.alert(
      'Delete Section',
      `Are you sure you want to delete "${section.title}"? This will also delete all lessons in this section.`,
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Delete', 
          style: 'destructive',
          onPress: async () => {
            try {
              await deleteSection(section.id);
            } catch (error) {
              // Error handled in store
            }
          }
        },
      ]
    );
  };

  const handleReorder = async (fromIndex: number, toIndex: number) => {
    const reorderedSections = [...sections];
    const [removed] = reorderedSections.splice(fromIndex, 1);
    reorderedSections.splice(toIndex, 0, removed);
    
    const updatedSections = reorderedSections.map((section, index) => ({
      id: section.id,
      order: index + 1,
    }));

    try {
      await reorderSections(courseId, updatedSections);
    } catch (error) {
      // Error handled in store
    }
  };

  const renderSectionItem = (section: Section, index: number) => (
    <View
      key={section.id}
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

      {/* Section info */}
      <View style={{ flex: 1 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 4 }}>
          <Text style={{ fontSize: 16, fontWeight: '600', color: '#0F172A' }}>
            {section.title}
          </Text>
          <Text style={{ fontSize: 12, color: '#94A3B8', fontWeight: '500' }}>
            Section {index + 1}
          </Text>
        </View>
        
        {section.description && (
          <Text style={{ fontSize: 13, color: '#64748B', marginBottom: 4 }}>
            {section.description}
          </Text>
        )}

        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
          <Text style={{ fontSize: 12, color: '#94A3B8' }}>
            {section._count?.lessons || 0} lessons
          </Text>
        </View>
      </View>

      {/* Actions */}
      <View style={{ flexDirection: 'row', gap: 8 }}>
        <TouchableOpacity
          onPress={() => {
            setSelectedSection(section);
            setShowLessonManager(true);
          }}
          style={{ padding: 8, backgroundColor: '#F3E8FF', borderRadius: 8 }}
          activeOpacity={0.7}
        >
          <Ionicons name="list-outline" size={20} color="#9333EA" />
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => handleEditSection(section)}
          style={{ padding: 8, backgroundColor: '#EFF6FF', borderRadius: 8 }}
          activeOpacity={0.7}
        >
          <Ionicons name="create-outline" size={20} color="#2563EB" />
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => handleDeleteSection(section)}
          style={{ padding: 8, backgroundColor: '#FEF2F2', borderRadius: 8 }}
          activeOpacity={0.7}
        >
          <Ionicons name="trash-outline" size={20} color="#EF4444" />
        </TouchableOpacity>
      </View>
    </View>
  );

  if (sectionsLoading && sections.length === 0) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', padding: 32 }}>
        <Ionicons name="folder-outline" size={64} color="#94A3B8" />
        <Text style={{ fontSize: 18, fontWeight: '600', color: '#0F172A', marginTop: 16 }}>
          Loading sections...
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
                Sections
              </Text>
              <Text style={{ fontSize: 14, color: '#64748B' }}>
                {courseTitle}
              </Text>
            </View>
          </View>
          
          <TouchableOpacity
            onPress={() => setShowCreateModal(true)}
            style={{ flexDirection: 'row', alignItems: 'center', backgroundColor: '#2563EB', borderRadius: 12, paddingHorizontal: 16, paddingVertical: 10 }}
            activeOpacity={0.85}
          >
            <Ionicons name="add" size={20} color="#FFFFFF" style={{ marginRight: 8 }} />
            <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 14 }}>Add Section</Text>
          </TouchableOpacity>
        </View>

        {/* Sections list */}
        {sections.length === 0 ? (
          <View style={{ alignItems: 'center', paddingVertical: 48, backgroundColor: '#FFFFFF', borderRadius: 16 }}>
            <Ionicons name="folder-outline" size={64} color="#94A3B8" />
            <Text style={{ fontSize: 18, fontWeight: '600', color: '#0F172A', marginTop: 16 }}>
              No sections yet
            </Text>
            <Text style={{ fontSize: 14, color: '#64748B', marginTop: 4, textAlign: 'center', paddingHorizontal: 32 }}>
              Create sections to organize your course content into logical modules
            </Text>
            <TouchableOpacity
              onPress={() => setShowCreateModal(true)}
              style={{ marginTop: 20, backgroundColor: '#2563EB', borderRadius: 12, paddingHorizontal: 24, paddingVertical: 12 }}
              activeOpacity={0.85}
            >
              <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 14 }}>Create First Section</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <View style={{ marginBottom: 100 }}>
            {sections.map((section: Section, index: number) => renderSectionItem(section, index))}
          </View>
        )}

        {sectionsError && (
          <View style={{ backgroundColor: '#FEF2F2', borderWidth: 1, borderColor: '#FECACA', borderRadius: 12, padding: 16, marginTop: 16 }}>
            <Text style={{ color: '#DC2626', fontSize: 14 }}>{sectionsError}</Text>
          </View>
        )}
      </ScrollView>

      {/* Create Section Modal */}
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
                Create New Section
              </Text>
              <Text style={{ fontSize: 14, color: '#64748B', marginBottom: 24 }}>
                Add a section to organize your course content
              </Text>

              <View style={{ marginBottom: 16 }}>
                <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                  Section Title *
                </Text>
                <TextInput
                  value={newSectionTitle}
                  onChangeText={setNewSectionTitle}
                  placeholder="e.g., Introduction to React Native"
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

              <View style={{ marginBottom: 24 }}>
                <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                  Description (optional)
                </Text>
                <TextInput
                  value={newSectionDescription}
                  onChangeText={setNewSectionDescription}
                  placeholder="What will students learn in this section?"
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
                    minHeight: 100,
                  }}
                  multiline
                  autoCapitalize="sentences"
                />
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
                  onPress={handleCreateSection}
                  disabled={!newSectionTitle.trim()}
                  style={{ flex: 1, backgroundColor: '#2563EB', borderRadius: 12, paddingVertical: 14, alignItems: 'center' }}
                  activeOpacity={0.85}
                >
                  <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 16 }}>Create Section</Text>
                </TouchableOpacity>
              </View>
            </ScrollView>
          </KeyboardAvoidingView>
        </SafeAreaView>
      </Modal>

      {/* Edit Section Modal */}
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
                Edit Section
              </Text>

              <View style={{ marginBottom: 16 }}>
                <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                  Section Title *
                </Text>
                <TextInput
                  value={editTitle}
                  onChangeText={setEditTitle}
                  placeholder="e.g., Introduction to React Native"
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

              <View style={{ marginBottom: 24 }}>
                <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                  Description (optional)
                </Text>
                <TextInput
                  value={editDescription}
                  onChangeText={setEditDescription}
                  placeholder="What will students learn in this section?"
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
                    minHeight: 100,
                  }}
                  multiline
                  autoCapitalize="sentences"
                />
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
                  onPress={handleUpdateSection}
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

      {/* Lesson Manager Modal */}
      <Modal visible={showLessonManager} animationType="slide">
        {selectedSection && (
          <LessonManager
            sectionId={selectedSection.id}
            sectionTitle={selectedSection.title}
            courseId={courseId}
            onClose={() => {
              setShowLessonManager(false);
              setSelectedSection(null);
              fetchSections(courseId); // refresh section counts
            }}
          />
        )}
      </Modal>
    </SafeAreaView>
  );
};

export default SectionManager;