// components/home/ContinueLearning.tsx
import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';

interface Course {
  id: string;
  title: string;
  instructor: string;
  thumbnail: string;
  progress: number;
  remainingTime: string;
}

interface ContinueLearningProps {
  courses: Course[];
  onCoursePress?: (courseId: string) => void;
}

export const ContinueLearning: React.FC<ContinueLearningProps> = ({
  courses,
  onCoursePress,
}) => {
  const router = useRouter();

  const handleCoursePress = (courseId: string) => {
    try {
      console.log('Navigating to course:', courseId);
      
      if (onCoursePress) {
        onCoursePress(courseId);
      } else {
        // Use the correct path without parentheses
        router.push(`/course/${courseId}`);
      }
    } catch (error) {
      console.error('Navigation error:', error);
      Alert.alert('Error', 'Unable to open course. Please try again.');
    }
  };

  const handleSeeAll = () => {
    try {
      router.push('/my-learning');
    } catch (error) {
      console.error('Navigation error:', error);
      Alert.alert('Error', 'Unable to open My Learning.');
    }
  };

  return (
    <View className="w-full">
      <View className="flex-row justify-between items-center mb-3">
        <Text className="text-[#0F172A] text-xl font-bold">
          Continue Learning
        </Text>
        <TouchableOpacity onPress={handleSeeAll}>
          <Text className="text-[#2563EB] text-sm font-semibold">
            See All
          </Text>
        </TouchableOpacity>
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
        decelerationRate="fast"
      >
        {courses.map((course) => (
          <TouchableOpacity
            key={course.id}
            className="w-64 mr-4 bg-white rounded-2xl border border-[#E2E8F0] overflow-hidden"
            onPress={() => handleCoursePress(course.id)}
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
              <View className="absolute bottom-2 right-2 bg-black/60 px-2 py-0.5 rounded-full">
                <Text className="text-white text-xs font-medium">
                  {course.remainingTime}
                </Text>
              </View>
            </View>

            <View className="p-3">
              <Text className="text-[#0F172A] font-semibold text-sm mb-0.5" numberOfLines={1}>
                {course.title}
              </Text>
              <Text className="text-[#64748B] text-xs mb-2" numberOfLines={1}>
                {course.instructor}
              </Text>

              <View className="flex-row items-center justify-between">
                <View className="flex-1 mr-2">
                  <View className="w-full h-1.5 bg-[#F1F5F9] rounded-full overflow-hidden">
                    <View 
                      className="h-full bg-[#2563EB] rounded-full"
                      style={{ width: `${course.progress}%` }}
                    />
                  </View>
                </View>
                <Text className="text-[#64748B] text-xs font-medium">
                  {course.progress}%
                </Text>
              </View>

              <TouchableOpacity 
                className="mt-2.5 bg-[#2563EB] py-1.5 rounded-full"
                onPress={(e) => {
                  e.stopPropagation();
                  handleCoursePress(course.id);
                }}
                activeOpacity={0.7}
              >
                <Text className="text-white text-center text-xs font-semibold">
                  Resume
                </Text>
              </TouchableOpacity>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
};