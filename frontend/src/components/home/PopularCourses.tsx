// components/home/PopularCourses.tsx
import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

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
  return (
    <View className="w-full">
      <View className="flex-row justify-between items-center mb-3">
        <Text className="text-[#0F172A] text-xl font-bold">
          Popular Courses
        </Text>
        <TouchableOpacity onPress={onSeeAll}>
          <Text className="text-[#2563EB] text-sm font-semibold">
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
            className="w-56 mr-4 bg-white rounded-2xl border border-[#E2E8F0] overflow-hidden"
            onPress={() => onCoursePress(course.id)}
            activeOpacity={0.8}
            style={{
              shadowColor: '#0F172A',
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: 0.05,
              shadowRadius: 4,
              elevation: 2,
            }}
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
              <Text className="text-[#0F172A] font-semibold text-sm mb-0.5" numberOfLines={1}>
                {course.title}
              </Text>
              <Text className="text-[#64748B] text-xs mb-1.5">
                {course.instructor}
              </Text>

              <View className="flex-row items-center justify-between">
                <View className="flex-row items-center">
                  <Ionicons name="star" size={14} color="#FBBF24" />
                  <Text className="text-[#0F172A] text-xs font-medium ml-0.5">
                    {course.rating.toFixed(1)}
                  </Text>
                  <Text className="text-[#94A3B8] text-xs ml-1">
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