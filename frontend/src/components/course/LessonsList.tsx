// components/course/LessonsList.tsx
import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';

interface Lesson {
  id: string;
  order: number;
  title: string;
  duration: string;
  videoUrl?: string;
  youtubeId?: string;
  completed?: boolean;
  locked?: boolean;
  isPreview?: boolean;
  description?: string;
  content?: string;
}

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

  // Sort lessons by order
  const sortedLessons = [...lessons].sort((a, b) => (a.order || 0) - (b.order || 0));

  return (
    <View className="px-4 py-2">
      {sortedLessons.map((lesson, index) => {
        const isActive = lesson.id === activeLessonId;
        const isCompleted = lesson.completed || false;
        const isLocked = lesson.locked || false;

        return (
          <TouchableOpacity
            key={lesson.id}
            onPress={() => !isLocked && onSelectLesson(lesson.id)}
            disabled={isLocked}
            className={`flex-row items-center py-3 px-3 rounded-xl mb-1 ${
              isActive ? 'bg-[#2563EB]/10' : ''
            }`}
            style={{
              backgroundColor: isActive 
                ? isDarkMode ? 'rgba(37,99,235,0.2)' : 'rgba(37,99,235,0.08)'
                : 'transparent',
            }}
          >
            {/* Lesson number / status icon */}
            <View className="w-8 h-8 rounded-full items-center justify-center mr-3">
              {isCompleted ? (
                <View className="w-6 h-6 rounded-full bg-[#16A34A] items-center justify-center">
                  <Ionicons name="checkmark" size={14} color="#FFFFFF" />
                </View>
              ) : isLocked ? (
                <View className="w-6 h-6 rounded-full items-center justify-center" style={{ backgroundColor: colors.backgroundSelected }}>
                  <Ionicons name="lock-closed" size={14} color={colors.textSecondary} />
                </View>
              ) : (
                <View 
                  className="w-6 h-6 rounded-full items-center justify-center"
                  style={{ 
                    backgroundColor: isActive 
                      ? colors.primary 
                      : colors.backgroundSelected 
                  }}
                >
                  <Text 
                    className="text-xs font-semibold"
                    style={{ 
                      color: isActive 
                        ? '#FFFFFF' 
                        : colors.textSecondary 
                    }}
                  >
                    {index + 1}
                  </Text>
                </View>
              )}
            </View>

            {/* Lesson info */}
            <View className="flex-1">
              <Text 
                className="text-sm font-medium"
                style={{ 
                  color: isLocked 
                    ? colors.textSecondary 
                    : isActive 
                      ? colors.primary 
                      : colors.text,
                  opacity: isLocked ? 0.6 : 1,
                }}
                numberOfLines={1}
              >
                {lesson.title}
              </Text>
              {lesson.isPreview && (
                <Text style={{ color: colors.primary, fontSize: 10, marginTop: 1 }}>
                  Preview
                </Text>
              )}
            </View>

            {/* Duration */}
            <Text 
              className="text-xs ml-2"
              style={{ color: colors.textSecondary }}
            >
              {lesson.duration || 'N/A'}
            </Text>

            {/* Active indicator */}
            {isActive && (
              <View className="w-1.5 h-6 rounded-full ml-2" style={{ backgroundColor: colors.primary }} />
            )}
          </TouchableOpacity>
        );
      })}
    </View>
  );
};