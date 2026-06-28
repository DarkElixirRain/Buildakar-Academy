// components/home/PopularCourses.tsx
import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';

interface PopularCourse {
  id: string;
  title: string;
  instructor: string;
  thumbnail: string;
  rating: number;
  students: number;
  isTrending: boolean;
}

interface PopularCoursesProps {
  courses: PopularCourse[];
  onCoursePress: (courseId: string) => void;
  onSeeAll: () => void;
}

export const PopularCourses: React.FC<PopularCoursesProps> = ({
  courses,
  onCoursePress,
  onSeeAll,
}) => {
  const { isDarkMode, colors } = useTheme();

  return (
    <View style={{ width: '100%' }}>
      <View className="flex-row justify-between items-center mb-3">
        <Text style={{
          fontSize: 20,
          fontWeight: 'bold',
          color: colors.text,
        }}>
          Popular Courses
        </Text>
        <TouchableOpacity onPress={onSeeAll}>
          <Text style={{
            fontSize: 14,
            fontWeight: '600',
            color: colors.primary,
          }}>
            See All
          </Text>
        </TouchableOpacity>
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
      >
        {courses.map((course) => (
          <TouchableOpacity
            key={course.id}
            style={{
              width: 224,
              marginRight: 16,
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
                className="w-full h-32"
                resizeMode="cover"
              />
              
              {course.isTrending && (
                <View className="absolute top-2 left-2 bg-[#EF4444] px-2 py-0.5 rounded-full flex-row items-center">
                  <Ionicons name="flame" size={12} color="white" />
                  <Text className="text-white text-xs font-bold ml-0.5">
                    Trending
                  </Text>
                </View>
              )}
            </View>

            <View className="p-3">
              <Text style={{
                fontWeight: '600',
                fontSize: 14,
                marginBottom: 2,
                color: colors.text,
              }} numberOfLines={1}>
                {course.title}
              </Text>
              <Text style={{
                fontSize: 12,
                marginBottom: 6,
                color: colors.textSecondary,
              }}>
                {course.instructor}
              </Text>

              <View className="flex-row items-center justify-between">
                <View className="flex-row items-center">
                  <Ionicons name="star" size={14} color="#FBBF24" />
                  <Text style={{
                    fontSize: 12,
                    fontWeight: '500',
                    marginLeft: 2,
                    color: colors.text,
                  }}>
                    {course.rating.toFixed(1)}
                  </Text>
                  <Text style={{
                    fontSize: 12,
                    marginLeft: 4,
                    color: colors.textSecondary,
                  }}>
                    ({course.students.toLocaleString()})
                  </Text>
                </View>
              </View>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
};