// components/home/RecentlyViewed.tsx
import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

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
  return (
    <View className="w-full">
      <View className="flex-row justify-between items-center mb-3">
        <Text className="text-[#0F172A] text-xl font-bold">
          Recently Viewed
        </Text>
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
      >
        {courses.map((course) => (
          <TouchableOpacity
            key={course.id}
            className="w-40 mr-3 bg-white rounded-2xl border border-[#E2E8F0] overflow-hidden"
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
            <Image 
              source={{ uri: course.thumbnail }}
              className="w-full h-24"
              resizeMode="cover"
            />
            <View className="p-2.5">
              <Text className="text-[#0F172A] font-semibold text-xs" numberOfLines={1}>
                {course.title}
              </Text>
              <Text className="text-[#94A3B8] text-xs mt-0.5">
                {course.lastOpened}
              </Text>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
};