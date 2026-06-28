// components/course/LessonsList.tsx
import React from 'react';
import { View, Text, TouchableOpacity, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import type { Lesson } from '../../data/courseData';
import { useTheme } from '@/context/themeContext';

interface LessonsListProps {
  lessons: Lesson[];
  activeLessonId: string;
  onSelectLesson: (lessonId: string) => void;
}

export const LessonsList: React.FC<LessonsListProps> = ({
  lessons,
  activeLessonId,
  onSelectLesson,
}) => {
  const { isDarkMode, colors } = useTheme();

  const handlePress = (lesson: Lesson) => {
    if (lesson.locked) {
      Alert.alert('Lesson locked', 'Complete the previous lesson to unlock this one.');
      return;
    }
    onSelectLesson(lesson.id);
  };

  return (
    <View style={{ backgroundColor: colors.background }}>
      {lessons.map((lesson, index) => {
        const isActive = lesson.id === activeLessonId;
        return (
          <TouchableOpacity
            key={lesson.id}
            onPress={() => handlePress(lesson)}
            activeOpacity={0.7}
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              paddingHorizontal: 16,
              paddingVertical: 12,
              borderBottomWidth: 1,
              borderBottomColor: colors.backgroundSelected,
              backgroundColor: isActive 
                ? (isDarkMode ? '#1E3A5F' : '#EFF6FF')
                : colors.background,
            }}
          >
            <View
              style={{
                width: 36,
                height: 36,
                borderRadius: 18,
                alignItems: 'center',
                justifyContent: 'center',
                marginRight: 12,
                backgroundColor: lesson.completed
                  ? '#16A34A'
                  : isActive
                  ? colors.primary
                  : lesson.locked
                  ? colors.backgroundSelected
                  : colors.backgroundSelected,
              }}
            >
              {lesson.completed ? (
                <Ionicons name="checkmark" size={18} color="#FFFFFF" />
              ) : lesson.locked ? (
                <Ionicons name="lock-closed" size={14} color={colors.textSecondary} />
              ) : isActive ? (
                <Ionicons name="play" size={14} color="#FFFFFF" />
              ) : (
                <Text style={{
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: '600',
                }}>{index + 1}</Text>
              )}
            </View>

            <View className="flex-1">
              <Text
                style={{
                  fontSize: 14,
                  fontWeight: '600',
                  color: lesson.locked ? colors.textSecondary : colors.text,
                }}
                numberOfLines={2}
              >
                {lesson.title}
              </Text>
              <Text style={{
                color: colors.textSecondary,
                fontSize: 12,
                marginTop: 2,
              }}>{lesson.duration}</Text>
            </View>

            {isActive && !lesson.completed && (
              <View style={{
                backgroundColor: colors.primary,
                paddingHorizontal: 8,
                paddingVertical: 2,
                borderRadius: 12,
                marginLeft: 8,
              }}>
                <Text className="text-white text-[10px] font-semibold">Now Playing</Text>
              </View>
            )}
          </TouchableOpacity>
        );
      })}
    </View>
  );
};