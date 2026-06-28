// components/home/RecentlyViewed.tsx
import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';

interface RecentlyViewedCourse {
  id: string;
  title: string;
  thumbnail: string;
  lastOpened: string;
}

interface RecentlyViewedProps {
  courses: RecentlyViewedCourse[];
  onCoursePress: (courseId: string) => void;
}

export const RecentlyViewed: React.FC<RecentlyViewedProps> = ({
  courses,
  onCoursePress,
}) => {
  const { isDarkMode, colors } = useTheme();

  // If no courses, show empty state
  if (!courses || courses.length === 0) {
    return null;
  }

  return (
    <View style={{ width: '100%' }}>
      <View className="flex-row justify-between items-center mb-3">
        <View className="flex-row items-center">
          <Ionicons name="time-outline" size={20} color={colors.primary} />
          <Text style={{
            fontSize: 20,
            fontWeight: 'bold',
            marginLeft: 8,
            color: colors.text,
          }}>
            Recently Viewed
          </Text>
        </View>
        <TouchableOpacity 
          onPress={() => {}} 
          activeOpacity={0.7}
        >
          <Text style={{
            fontSize: 14,
            fontWeight: '600',
            color: colors.primary,
          }}>
            View All
          </Text>
        </TouchableOpacity>
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
        decelerationRate="fast"
        snapToInterval={160}
        snapToAlignment="start"
      >
        {courses.map((course) => (
          <TouchableOpacity
            key={course.id}
            style={{
              width: 160,
              marginRight: 12,
              borderRadius: 16,
              borderWidth: 1,
              overflow: 'hidden',
              backgroundColor: colors.backgroundElement,
              borderColor: colors.backgroundSelected,
              shadowColor: isDarkMode ? '#000000' : '#0F172A',
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: isDarkMode ? 0.3 : 0.05,
              shadowRadius: 4,
              elevation: 2,
            }}
            onPress={() => onCoursePress(course.id)}
            activeOpacity={0.8}
          >
            <View className="relative">
              <Image 
                source={{ uri: course.thumbnail }}
                className="w-full h-24"
                resizeMode="cover"
              />
              {/* Play button overlay */}
              <View className="absolute inset-0 items-center justify-center">
                <View style={{
                  width: 32,
                  height: 32,
                  borderRadius: 16,
                  alignItems: 'center',
                  justifyContent: 'center',
                  backgroundColor: isDarkMode ? 'rgba(96, 165, 250, 0.8)' : 'rgba(37, 99, 235, 0.8)',
                }}>
                  <Ionicons name="play" size={14} color="white" />
                </View>
              </View>
            </View>
            <View className="p-2.5">
              <Text style={{
                fontWeight: '600',
                fontSize: 12,
                marginBottom: 2,
                color: colors.text,
              }} numberOfLines={1}>
                {course.title}
              </Text>
              <View className="flex-row items-center">
                <Ionicons name="time-outline" size={10} color={colors.textSecondary} />
                <Text style={{
                  fontSize: 12,
                  marginLeft: 2,
                  color: colors.textSecondary,
                }}>
                  {course.lastOpened}
                </Text>
              </View>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
};