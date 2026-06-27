// components/course/LessonsList.tsx
import React from 'react';
import { View, Text, TouchableOpacity, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import type { Lesson } from '../../data/courseData';

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
  const handlePress = (lesson: Lesson) => {
    if (lesson.locked) {
      Alert.alert('Lesson locked', 'Complete the previous lesson to unlock this one.');
      return;
    }
    onSelectLesson(lesson.id);
  };

  return (
    <View>
      {lessons.map((lesson, index) => {
        const isActive = lesson.id === activeLessonId;
        return (
          <TouchableOpacity
            key={lesson.id}
            onPress={() => handlePress(lesson)}
            activeOpacity={0.7}
            className={`flex-row items-center px-4 py-3 border-b border-[#E2E8F0] ${
              isActive ? 'bg-[#EFF6FF]' : 'bg-white'
            }`}
          >
            <View
              className={`w-9 h-9 rounded-full items-center justify-center mr-3 ${
                lesson.completed
                  ? 'bg-[#16A34A]'
                  : isActive
                  ? 'bg-[#2563EB]'
                  : lesson.locked
                  ? 'bg-[#F1F5F9]'
                  : 'bg-[#F1F5F9]'
              }`}
            >
              {lesson.completed ? (
                <Ionicons name="checkmark" size={18} color="#FFFFFF" />
              ) : lesson.locked ? (
                <Ionicons name="lock-closed" size={14} color="#94A3B8" />
              ) : isActive ? (
                <Ionicons name="play" size={14} color="#FFFFFF" />
              ) : (
                <Text className="text-[#64748B] text-xs font-semibold">{index + 1}</Text>
              )}
            </View>

            <View className="flex-1">
              <Text
                className={`text-sm font-semibold ${
                  lesson.locked ? 'text-[#94A3B8]' : 'text-[#0F172A]'
                }`}
                numberOfLines={2}
              >
                {lesson.title}
              </Text>
              <Text className="text-[#64748B] text-xs mt-0.5">{lesson.duration}</Text>
            </View>

            {isActive && !lesson.completed && (
              <View className="bg-[#2563EB] px-2 py-0.5 rounded-full ml-2">
                <Text className="text-white text-[10px] font-semibold">Now Playing</Text>
              </View>
            )}
          </TouchableOpacity>
        );
      })}
    </View>
  );
};