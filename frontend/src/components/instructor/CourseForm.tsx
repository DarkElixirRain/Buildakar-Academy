// components/instructor/CourseForm.tsx
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, TextInput, ScrollView, Modal, Alert, KeyboardAvoidingView, Platform, SafeAreaView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { CreateCourseInput, UpdateCourseInput, Course } from '@/types/instructor';
import { useInstructorStore } from '@/store/instructorStore';
import { StatusBadge, LevelBadge } from './StatusBadge';

interface CourseFormProps {
  course?: Course | null;
  onClose?: () => void;
  onSuccess?: (course: Course) => void;
}

export const CourseForm: React.FC<CourseFormProps> = ({ 
  course, 
  onClose, 
  onSuccess 
}) => {
  const { 
    createCourse, 
    updateCourse, 
    coursesLoading, 
    coursesError,
    clearCourseError,
  } = useInstructorStore();

  const isEditing = !!course;
  
  const [title, setTitle] = useState(course?.title || '');
  const [description, setDescription] = useState(course?.description || '');
  const [thumbnail, setThumbnail] = useState(course?.thumbnail || '');
  const [price, setPrice] = useState(course?.price?.toString() || '0');
  const [originalPrice, setOriginalPrice] = useState(course?.originalPrice?.toString() || '');
  const [level, setLevel] = useState<'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED'>(course?.level as any || 'BEGINNER');
  const [language, setLanguage] = useState(course?.language || 'English');
  const [duration, setDuration] = useState(course?.duration || '');
  const [totalHours, setTotalHours] = useState(course?.totalHours?.toString() || '');
  const [categoryId, setCategoryId] = useState(course?.categoryId || '');
  const [isBestseller, setIsBestseller] = useState(course?.isBestseller || false);
  const [isTrending, setIsTrending] = useState(course?.isTrending || false);
  const [showCategoryPicker, setShowCategoryPicker] = useState(false);
  const [showThumbnailModal, setShowThumbnailModal] = useState(false);
  const [thumbnailUrl, setThumbnailUrl] = useState('');

  // Mock categories - in real app, fetch from API
  const categories = [
    { id: 'cat1', name: 'Development', slug: 'development' },
    { id: 'cat2', name: 'AI & Machine Learning', slug: 'ai-machine-learning' },
    { id: 'cat3', name: 'Data Science', slug: 'data-science' },
    { id: 'cat4', name: 'Design', slug: 'design' },
    { id: 'cat5', name: 'Marketing', slug: 'marketing' },
    { id: 'cat6', name: 'Business', slug: 'business' },
    { id: 'cat7', name: 'Finance', slug: 'finance' },
    { id: 'cat8', name: 'Languages', slug: 'languages' },
  ];

  const selectedCategory = categories.find(c => c.id === categoryId);

  const handleSubmit = async () => {
    if (!title.trim()) {
      Alert.alert('Error', 'Course title is required');
      return;
    }
    if (!categoryId) {
      Alert.alert('Error', 'Please select a category');
      return;
    }

    const courseData: CreateCourseInput = {
      title: title.trim(),
      description: description.trim() || undefined,
      thumbnail: thumbnail || undefined,
      price: parseFloat(price) || 0,
      originalPrice: originalPrice ? parseFloat(originalPrice) : undefined,
      level,
      language: language || 'English',
      duration: duration || undefined,
      totalHours: totalHours ? parseFloat(totalHours) : undefined,
      categoryId,
    };

    try {
      let result: Course;
      if (isEditing && course) {
        result = await updateCourse(course.id, courseData as UpdateCourseInput);
      } else {
        result = await createCourse(courseData);
      }
      if (onSuccess) onSuccess(result);
      if (onClose) onClose();
    } catch (error) {
      // Error handled in store
    }
  };

  const handleThumbnailSelect = (url: string) => {
    setThumbnail(url);
    setThumbnailUrl('');
    setShowThumbnailModal(false);
  };

  if (coursesError) {
    clearCourseError();
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={{ flex: 1 }}
        keyboardVerticalOffset={100}
      >
        <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false} contentContainerStyle={{ padding: 16 }}>
          {/* Header */}
          <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
            <TouchableOpacity onPress={onClose} activeOpacity={0.7} style={{ padding: 4 }}>
              <Ionicons name="chevron-back" size={28} color="#0F172A" />
            </TouchableOpacity>
            <Text style={{ fontSize: 24, fontWeight: '700', color: '#0F172A' }}>
              {isEditing ? 'Edit Course' : 'Create Course'}
            </Text>
            <View style={{ width: 44 }} />
          </View>

          {/* Thumbnail */}
          <View style={{ marginBottom: 24 }}>
            <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 12 }}>
              Course Thumbnail
            </Text>
            <TouchableOpacity 
              onPress={() => setShowThumbnailModal(true)}
              style={{
                width: '100%',
                height: 200,
                borderRadius: 16,
                borderWidth: 2,
                borderColor: thumbnail ? '#2563EB' : '#E2E8F0',
                borderStyle: 'dashed',
                backgroundColor: '#FFFFFF',
                justifyContent: 'center',
                alignItems: 'center',
                overflow: 'hidden',
              }}
              activeOpacity={0.85}
            >
              {thumbnail ? (
                <Image
                  source={{ uri: thumbnail }}
                  style={{ width: '100%', height: '100%', borderRadius: 14 }}
                  resizeMode="cover"
                />
              ) : (
                <View style={{ alignItems: 'center', gap: 12 }}>
                  <Ionicons name="image-outline" size={48} color="#94A3B8" />
                  <Text style={{ fontSize: 16, fontWeight: '600', color: '#64748B' }}>
                    Tap to add thumbnail
                  </Text>
                  <Text style={{ fontSize: 13, color: '#94A3B8' }}>
                    Recommended: 1280x720px (16:9)
                  </Text>
                </View>
              )}
            </TouchableOpacity>
            {thumbnail && (
              <TouchableOpacity
                onPress={() => setThumbnail('')}
                style={{ marginTop: 8, flexDirection: 'row', alignItems: 'center', gap: 4 }}
              >
                <Ionicons name="trash-outline" size={16} color="#EF4444" />
                <Text style={{ fontSize: 13, color: '#EF4444' }}>Remove thumbnail</Text>
              </TouchableOpacity>
            )}
          </View>

          {/* Title */}
          <View style={{ marginBottom: 16 }}>
            <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
              Course Title *
            </Text>
            <TextInput
              value={title}
              onChangeText={setTitle}
              placeholder="Enter a compelling course title"
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
              maxLength={200}
            />
          </View>

          {/* Description */}
          <View style={{ marginBottom: 16 }}>
            <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
              Description
            </Text>
            <TextInput
              value={description}
              onChangeText={setDescription}
              placeholder="What will students learn? What are the prerequisites? What makes this course unique?"
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
                minHeight: 120,
              }}
              multiline
              autoCapitalize="sentences"
              maxLength={5000}
            />
          </View>

          {/* Category */}
          <View style={{ marginBottom: 16 }}>
            <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
              Category *
            </Text>
            <TouchableOpacity
              onPress={() => setShowCategoryPicker(true)}
              style={{
                flexDirection: 'row',
                justifyContent: 'space-between',
                alignItems: 'center',
                backgroundColor: '#FFFFFF',
                borderWidth: 1,
                borderColor: categoryId ? '#2563EB' : '#E2E8F0',
                borderRadius: 12,
                paddingHorizontal: 16,
                paddingVertical: 14,
              }}
              activeOpacity={0.7}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
                <Ionicons name="folder-outline" size={22} color={categoryId ? '#2563EB' : '#94A3B8'} />
                <Text style={{ fontSize: 16, color: categoryId ? '#0F172A' : '#94A3B8' }}>
                  {selectedCategory?.name || 'Select a category'}
                </Text>
              </View>
              <Ionicons name="chevron-down" size={22} color="#94A3B8" />
            </TouchableOpacity>
          </View>

          {/* Level, Language, Duration */}
          <View style={{ flexDirection: 'row', gap: 12, marginBottom: 16 }}>
            <View style={{ flex: 1 }}>
              <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                Level
              </Text>
              <View style={{ flexDirection: 'row', gap: 8 }}>
                {(['BEGINNER', 'INTERMEDIATE', 'ADVANCED'] as const).map((lvl) => (
                  <TouchableOpacity
                    key={lvl}
                    onPress={() => setLevel(lvl)}
                    style={{
                      flex: 1,
                      flexDirection: 'row',
                      alignItems: 'center',
                      justifyContent: 'center',
                      backgroundColor: level === lvl ? '#2563EB' : '#F1F5F9',
                      borderWidth: 1,
                      borderColor: level === lvl ? '#2563EB' : '#E2E8F0',
                      borderRadius: 10,
                      paddingVertical: 12,
                    }}
                    activeOpacity={0.7}
                  >
                    <Text style={{ 
                      color: level === lvl ? '#FFFFFF' : '#475569', 
                      fontWeight: '600', 
                      fontSize: 13 
                    }}>
                      {lvl}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>
            </View>
          </View>

          <View style={{ flexDirection: 'row', gap: 12, marginBottom: 16 }}>
            <View style={{ flex: 1 }}>
              <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                Language
              </Text>
              <TextInput
                value={language}
                onChangeText={setLanguage}
                placeholder="English"
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
            <View style={{ flex: 1 }}>
              <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                Duration (optional)
              </Text>
              <TextInput
                value={duration}
                onChangeText={setDuration}
                placeholder="e.g., 12h 30m"
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

          {/* Pricing */}
          <View style={{ marginBottom: 16 }}>
            <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
              Pricing
            </Text>
            <View style={{ flexDirection: 'row', gap: 12 }}>
              <View style={{ flex: 1 }}>
                <Text style={{ fontSize: 13, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                  Price ($) *
                </Text>
                <TextInput
                  value={price}
                  onChangeText={setPrice}
                  placeholder="0"
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
                  keyboardType="decimal-pad"
                />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={{ fontSize: 13, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                  Original Price ($) (optional)
                </Text>
                <TextInput
                  value={originalPrice}
                  onChangeText={setOriginalPrice}
                  placeholder="e.g., 99.99"
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
                  keyboardType="decimal-pad"
                />
              </View>
            </View>
          </View>

          {/* Total Hours */}
          <View style={{ marginBottom: 16 }}>
            <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
              Total Hours (optional)
            </Text>
            <TextInput
              value={totalHours}
              onChangeText={setTotalHours}
              placeholder="e.g., 12.5"
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
              keyboardType="decimal-pad"
            />
          </View>

          {/* Toggle options */}
          <View style={{ marginBottom: 24 }}>
            <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 12 }}>
              Options
            </Text>
            <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap' }}>
              <TouchableOpacity
                onPress={() => setIsBestseller(!isBestseller)}
                style={{ 
                  flex: 1, 
                  minWidth: 160,
                  flexDirection: 'row', 
                  alignItems: 'center', 
                  justifyContent: 'center',
                  backgroundColor: isBestseller ? '#FEF3C7' : '#F1F5F9', 
                  borderWidth: 1,
                  borderColor: isBestseller ? '#F59E0B' : '#E2E8F0',
                  borderRadius: 12, 
                  paddingVertical: 14 
                }}
                activeOpacity={0.7}
              >
                <Ionicons 
                  name={isBestseller ? 'checkmark-circle' : 'checkmark-circle-outline'} 
                  size={20} 
                  color={isBestseller ? '#F59E0B' : '#94A3B8'} 
                  style={{ marginRight: 8 }} 
                />
                <Text style={{ color: isBestseller ? '#92400E' : '#475569', fontWeight: '600', fontSize: 14 }}>
                  Bestseller
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={() => setIsTrending(!isTrending)}
                style={{ 
                  flex: 1, 
                  minWidth: 160,
                  flexDirection: 'row', 
                  alignItems: 'center', 
                  justifyContent: 'center',
                  backgroundColor: isTrending ? '#DBEAFE' : '#F1F5F9', 
                  borderWidth: 1,
                  borderColor: isTrending ? '#3B82F6' : '#E2E8F0',
                  borderRadius: 12, 
                  paddingVertical: 14 
                }}
                activeOpacity={0.7}
              >
                <Ionicons 
                  name={isTrending ? 'checkmark-circle' : 'checkmark-circle-outline'} 
                  size={20} 
                  color={isTrending ? '#3B82F6' : '#94A3B8'} 
                  style={{ marginRight: 8 }} 
                />
                <Text style={{ color: isTrending ? '#1E40AF' : '#475569', fontWeight: '600', fontSize: 14 }}>
                  Trending
                </Text>
              </TouchableOpacity>
            </View>
          </View>

          {/* Submit buttons */}
          <View style={{ flexDirection: 'row', gap: 12, marginTop: 8, paddingBottom: 32 }}>
            <TouchableOpacity
              onPress={onClose}
              style={{ flex: 1, backgroundColor: '#F1F5F9', borderRadius: 12, paddingVertical: 16, alignItems: 'center' }}
              activeOpacity={0.7}
            >
              <Text style={{ color: '#475569', fontWeight: '600', fontSize: 16 }}>Cancel</Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={handleSubmit}
              disabled={coursesLoading || !title.trim() || !categoryId}
              style={{ flex: 1, backgroundColor: '#2563EB', borderRadius: 12, paddingVertical: 16, alignItems: 'center' }}
              activeOpacity={0.85}
            >
              {coursesLoading ? (
                <Ionicons name="refresh" size={24} color="#FFFFFF" />
              ) : (
                <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 16 }}>
                  {isEditing ? 'Save Changes' : 'Create Course'}
                </Text>
              )}
            </TouchableOpacity>
          </View>

          {coursesError && (
            <View style={{ backgroundColor: '#FEF2F2', borderWidth: 1, borderColor: '#FECACA', borderRadius: 12, padding: 16, marginTop: 16 }}>
              <Text style={{ color: '#DC2626', fontSize: 14 }}>{coursesError}</Text>
            </View>
          )}
        </ScrollView>
      </KeyboardAvoidingView>

      {/* Category Picker Modal */}
      <Modal visible={showCategoryPicker} animationType="slide" transparent={false}>
        <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
          <View style={{ flex: 1, padding: 24 }}>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
              <Text style={{ fontSize: 20, fontWeight: '700', color: '#0F172A' }}>Select Category</Text>
              <TouchableOpacity onPress={() => setShowCategoryPicker(false)} activeOpacity={0.7} style={{ padding: 4 }}>
                <Ionicons name="close" size={28} color="#0F172A" />
              </TouchableOpacity>
            </View>
            <ScrollView>
              {categories.map(cat => (
                <TouchableOpacity
                  key={cat.id}
                  onPress={() => { setCategoryId(cat.id); setShowCategoryPicker(false); }}
                  style={{ 
                    backgroundColor: categoryId === cat.id ? '#EFF6FF' : '#FFFFFF', 
                    borderWidth: 1, 
                    borderColor: categoryId === cat.id ? '#2563EB' : '#E2E8F0',
                    borderRadius: 12, 
                    padding: 16, 
                    marginBottom: 12 
                  }}
                  activeOpacity={0.7}
                >
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
                    <Ionicons name="folder-outline" size={24} color={categoryId === cat.id ? '#2563EB' : '#94A3B8'} />
                    <Text style={{ fontSize: 16, fontWeight: '500', color: categoryId === cat.id ? '#2563EB' : '#0F172A' }}>
                      {cat.name}
                    </Text>
                    {categoryId === cat.id && <Ionicons name="checkmark" size={24} color="#2563EB" style={{ marginLeft: 'auto' }} />}
                  </View>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>
        </SafeAreaView>
      </Modal>

      {/* Thumbnail URL Modal */}
      <Modal visible={showThumbnailModal} animationType="slide" transparent={false}>
        <SafeAreaView style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
          <KeyboardAvoidingView
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
            style={{ flex: 1 }}
            keyboardVerticalOffset={100}
          >
            <View style={{ flex: 1, padding: 24 }}>
              <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
                <Text style={{ fontSize: 20, fontWeight: '700', color: '#0F172A' }}>Add Thumbnail URL</Text>
                <TouchableOpacity onPress={() => setShowThumbnailModal(false)} activeOpacity={0.7} style={{ padding: 4 }}>
                  <Ionicons name="close" size={28} color="#0F172A" />
                </TouchableOpacity>
              </View>
              <View style={{ marginBottom: 24 }}>
                <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                  Image URL
                </Text>
                <TextInput
                  value={thumbnailUrl}
                  onChangeText={setThumbnailUrl}
                  placeholder="https://example.com/image.jpg"
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
                  autoCapitalize="none"
                />
              </View>
              {thumbnailUrl && (
                <View style={{ marginBottom: 24 }}>
                  <Text style={{ fontSize: 14, fontWeight: '600', color: '#0F172A', marginBottom: 8 }}>
                    Preview
                  </Text>
                  <Image
                    source={{ uri: thumbnailUrl }}
                    style={{ width: '100%', height: 200, borderRadius: 12 }}
                    resizeMode="cover"
                  />
                </View>
              )}
              <View style={{ flexDirection: 'row', gap: 12 }}>
                <TouchableOpacity
                  onPress={() => setShowThumbnailModal(false)}
                  style={{ flex: 1, backgroundColor: '#F1F5F9', borderRadius: 12, paddingVertical: 16, alignItems: 'center' }}
                  activeOpacity={0.7}
                >
                  <Text style={{ color: '#475569', fontWeight: '600', fontSize: 16 }}>Cancel</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  onPress={() => handleThumbnailSelect(thumbnailUrl)}
                  disabled={!thumbnailUrl.trim()}
                  style={{ flex: 1, backgroundColor: '#2563EB', borderRadius: 12, paddingVertical: 16, alignItems: 'center' }}
                  activeOpacity={0.85}
                >
                  <Text style={{ color: '#FFFFFF', fontWeight: '600', fontSize: 16 }}>Use This Image</Text>
                </TouchableOpacity>
              </View>
            </View>
          </KeyboardAvoidingView>
        </SafeAreaView>
      </Modal>
    </SafeAreaView>
  );
};

export default CourseForm;