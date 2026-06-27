// components/course-details/CourseCurriculum.tsx
import React from 'react';
import { View, Text, TouchableOpacity, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import type { Lesson } from '../../data/courseData';

interface CourseCurriculumProps {
  lessons: Lesson[];
  totalDurationLabel: string;
  /** Called when a free-preview lesson is tapped. */
  onPreviewPress: (lessonId: string) => void;
}

export const CourseCurriculum: React.FC<CourseCurriculumProps> = ({
  lessons,
  totalDurationLabel,
  onPreviewPress,
}) => {
  const handlePress = (lesson: Lesson) => {
    if (lesson.isPreview) {
      onPreviewPress(lesson.id);
    } else {
      Alert.alert('Enroll to unlock', 'Enroll in this course to watch the full lesson.');
    }
  };

  return (
    <View>
      <View className="flex-row justify-between items-center px-4 py-3 bg-[#F8FAFC] border-b border-[#E2E8F0]">
        <Text className="text-[#0F172A] text-sm font-bold">Course Content</Text>
        <Text className="text-[#64748B] text-xs">
          {lessons.length} lectures • {totalDurationLabel}
        </Text>
      </View>

      {lessons.map((lesson, index) => (
        <TouchableOpacity
          key={lesson.id}
          onPress={() => handlePress(lesson)}
          activeOpacity={0.7}
          className="flex-row items-center px-4 py-3 border-b border-[#E2E8F0]"
        >
          <Ionicons
            name={lesson.isPreview ? 'play-circle-outline' : 'lock-closed-outline'}
            size={20}
            color={lesson.isPreview ? '#2563EB' : '#94A3B8'}
            style={{ marginRight: 12 }}
          />
          <Text className="flex-1 text-sm text-[#0F172A] mr-2" numberOfLines={1}>
            {index + 1}. {lesson.title}
          </Text>
          {lesson.isPreview && (
            <View className="bg-[#EFF6FF] px-2 py-0.5 rounded-full mr-2">
              <Text className="text-[#2563EB] text-[10px] font-semibold">Preview</Text>
            </View>
          )}
          <Text className="text-[#64748B] text-xs">{lesson.duration}</Text>
        </TouchableOpacity>
      ))}
    </View>
  );
};