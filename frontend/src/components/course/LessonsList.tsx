// components/course/LessonsList.tsx
import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Lesson } from '../../types/course';

interface LessonsListProps {
  lessons: Lesson[];
  currentLessonId: string;
  onLessonPress: (lesson: Lesson) => void;
}

export const LessonsList: React.FC<LessonsListProps> = ({
  lessons,
  currentLessonId,
  onLessonPress,
}) => {
  return (
    <View className="px-4">
      {lessons.map((lesson) => {
        const isActive = lesson.id === currentLessonId;

        return (
          <TouchableOpacity
            key={lesson.id}
            disabled={lesson.locked}
            onPress={() => onLessonPress(lesson)}
            activeOpacity={0.7}
            className={`flex-row items-center py-3 px-3 mb-2 rounded-xl border ${
              isActive
                ? 'bg-[#EFF6FF] border-[#2563EB]'
                : 'bg-white border-[#E2E8F0]'
            } ${lesson.locked ? 'opacity-50' : ''}`}
          >
            <View
              className={`w-9 h-9 rounded-full items-center justify-center mr-3 ${
                isActive
                  ? 'bg-[#2563EB]'
                  : lesson.completed
                  ? 'bg-[#DCFCE7]'
                  : 'bg-[#F1F5F9]'
              }`}
            >
              {lesson.locked ? (
                <Ionicons name="lock-closed" size={16} color="#64748B" />
              ) : lesson.completed ? (
                <Ionicons name="checkmark" size={18} color="#16A34A" />
              ) : isActive ? (
                <Ionicons name="pause" size={16} color="#FFFFFF" />
              ) : (
                <Ionicons name="play" size={16} color="#2563EB" />
              )}
            </View>

            <View className="flex-1">
              <Text
                numberOfLines={1}
                className={`text-sm font-semibold ${
                  isActive ? 'text-[#2563EB]' : 'text-[#0F172A]'
                }`}
              >
                {lesson.order}. {lesson.title}
              </Text>
              <Text className="text-[#64748B] text-xs mt-0.5">
                {lesson.duration}
              </Text>
            </View>

            {isActive && (
              <View className="bg-[#2563EB] px-2 py-0.5 rounded-full">
                <Text className="text-white text-[10px] font-semibold">
                  NOW PLAYING
                </Text>
              </View>
            )}
          </TouchableOpacity>
        );
      })}
    </View>
  );
};