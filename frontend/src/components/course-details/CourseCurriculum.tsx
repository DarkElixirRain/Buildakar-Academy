// components/course-details/CourseCurriculum.tsx
import React, { useState } from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';

interface Lesson {
  id: string;
  title: string;
  duration: string;
  videoUrl?: string;
  youtubeId?: string;
  completed?: boolean; // ✅ Made optional
  locked?: boolean;
  isPreview?: boolean;
  description?: string;
  content?: string;
  order?: number;
  isFree?: boolean;
}

interface Section {
  id: string;
  title: string;
  description?: string;
  order: number;
  lessons: Lesson[];
  _count?: {
    lessons: number;
  };
}

interface CourseCurriculumProps {
  sections: Section[];
  totalDurationLabel: string;
  onPreviewPress?: () => void;
  onLessonPress?: (lessonId: string) => void;
}

export const CourseCurriculum: React.FC<CourseCurriculumProps> = ({
  sections,
  totalDurationLabel,
  onPreviewPress,
  onLessonPress,
}) => {
  const { isDarkMode, colors } = useTheme();
  const [expandedSections, setExpandedSections] = useState<Set<string>>(new Set());

  const toggleSection = (sectionId: string) => {
    const newExpanded = new Set(expandedSections);
    if (newExpanded.has(sectionId)) {
      newExpanded.delete(sectionId);
    } else {
      newExpanded.add(sectionId);
    }
    setExpandedSections(newExpanded);
  };

  const totalLessons = sections.reduce((acc, section) => acc + (section.lessons?.length || 0), 0);

  if (sections.length === 0) {
    return (
      <View className="px-4 py-8 items-center justify-center">
        <Ionicons name="book-outline" size={48} color={colors.textSecondary} />
        <Text style={{ color: colors.textSecondary, fontSize: 16, marginTop: 12 }}>
          No content yet
        </Text>
        <Text style={{ color: colors.textSecondary, fontSize: 14, marginTop: 4, textAlign: 'center' }}>
          This course is being prepared
        </Text>
      </View>
    );
  }

  return (
    <View className="px-4 py-4">
      {/* Header */}
      <View className="flex-row justify-between items-center mb-4">
        <Text style={{ color: colors.text, fontSize: 16, fontWeight: 'bold' }}>
          Course Content
        </Text>
        <View className="flex-row items-center">
          <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
            {totalLessons} lectures • {totalDurationLabel}
          </Text>
        </View>
      </View>

      {/* Sections */}
      {sections.map((section) => {
        const isExpanded = expandedSections.has(section.id);
        const completedCount = section.lessons?.filter(l => l.completed).length || 0;
        const totalCount = section.lessons?.length || 0;

        return (
          <View
            key={section.id}
            className="mb-3 rounded-xl overflow-hidden"
            style={{ backgroundColor: colors.backgroundElement }}
          >
            {/* Section Header */}
            <TouchableOpacity
              onPress={() => toggleSection(section.id)}
              className="p-4 flex-row items-center justify-between"
            >
              <View className="flex-1 mr-4">
                <Text style={{ color: colors.text, fontSize: 15, fontWeight: '600' }}>
                  {section.title}
                </Text>
                {section.description && (
                  <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 2 }}>
                    {section.description}
                  </Text>
                )}
                <Text style={{ color: colors.textSecondary, fontSize: 11, marginTop: 4 }}>
                  {totalCount} lectures • {completedCount}/{totalCount} completed
                </Text>
              </View>
              <Ionicons
                name={isExpanded ? 'chevron-up' : 'chevron-down'}
                size={20}
                color={colors.textSecondary}
              />
            </TouchableOpacity>

            {/* Lessons */}
            {isExpanded && (
              <View className="border-t" style={{ borderColor: colors.backgroundSelected }}>
                {section.lessons?.map((lesson, index) => (
                  <TouchableOpacity
                    key={lesson.id}
                    onPress={() => onLessonPress?.(lesson.id)}
                    className={`p-4 flex-row items-center ${
                      index < (section.lessons?.length || 0) - 1 ? 'border-b' : ''
                    }`}
                    style={{ borderColor: colors.backgroundSelected }}
                    disabled={lesson.locked}
                  >
                    <View className="mr-3">
                      {lesson.completed ? (
                        <Ionicons name="checkmark-circle" size={20} color="#16A34A" />
                      ) : lesson.locked ? (
                        <Ionicons name="lock-closed" size={18} color={colors.textSecondary} />
                      ) : (
                        <Ionicons name="play-circle-outline" size={20} color={colors.primary} />
                      )}
                    </View>
                    <View className="flex-1">
                      <Text
                        style={{
                          color: lesson.locked ? colors.textSecondary : colors.text,
                          fontSize: 14,
                          opacity: lesson.locked ? 0.6 : 1,
                        }}
                      >
                        {lesson.title}
                      </Text>
                      {lesson.isPreview && (
                        <View className="flex-row items-center mt-1">
                          <Text style={{ color: colors.primary, fontSize: 10, fontWeight: '600' }}>
                            Preview
                          </Text>
                        </View>
                      )}
                    </View>
                    <View className="flex-row items-center">
                      {lesson.isPreview && (
                        <TouchableOpacity
                          onPress={onPreviewPress}
                          className="mr-3"
                        >
                          <Text style={{ color: colors.primary, fontSize: 11 }}>
                            Preview
                          </Text>
                        </TouchableOpacity>
                      )}
                      <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
                        {lesson.duration || 'N/A'}
                      </Text>
                    </View>
                  </TouchableOpacity>
                ))}
              </View>
            )}
          </View>
        );
      })}
    </View>
  );
};