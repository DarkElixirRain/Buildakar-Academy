// components/home/ContinueLearning.tsx
import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useTheme } from '@/context/themeContext';

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
  const { isDarkMode, colors } = useTheme();

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
    <View style={{ width: '100%' }}>
      <View className="flex-row justify-between items-center mb-3">
        <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text }}>
          Continue Learning
        </Text>
        <TouchableOpacity onPress={handleSeeAll}>
          <Text style={{ fontSize: 14, fontWeight: '600', color: colors.primary }}>
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
            style={{
              width: 256,
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
            onPress={() => handleCoursePress(course.id)}
            activeOpacity={0.8}
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
              <Text style={{ 
                fontWeight: '600', 
                fontSize: 14, 
                marginBottom: 2, 
                color: colors.text 
              }} numberOfLines={1}>
                {course.title}
              </Text>
              <Text style={{ 
                fontSize: 12, 
                marginBottom: 8, 
                color: colors.textSecondary 
              }} numberOfLines={1}>
                {course.instructor}
              </Text>

              <View className="flex-row items-center justify-between">
                <View className="flex-1 mr-2">
                  <View style={{
                    width: '100%',
                    height: 6,
                    borderRadius: 3,
                    overflow: 'hidden',
                    backgroundColor: isDarkMode ? '#334155' : '#F1F5F9',
                  }}>
                    <View 
                      style={{
                        height: '100%',
                        borderRadius: 3,
                        backgroundColor: colors.primary,
                        width: `${course.progress}%`,
                      }}
                    />
                  </View>
                </View>
                <Text style={{ 
                  fontSize: 12, 
                  fontWeight: '500', 
                  color: colors.textSecondary 
                }}>
                  {course.progress}%
                </Text>
              </View>

              <TouchableOpacity 
                style={{
                  marginTop: 10,
                  paddingVertical: 6,
                  borderRadius: 20,
                  backgroundColor: colors.primary,
                }}
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