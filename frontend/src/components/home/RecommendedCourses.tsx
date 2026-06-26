// components/home/RecommendedCourses.tsx
import React, { useState } from 'react';
import { 
  View, 
  Text, 
  TouchableOpacity, 
  ScrollView, 
  Image, 
  FlatList,
  ActivityIndicator,
} from 'react-native';
import { Ionicons, Feather } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';

interface Course {
  id: string;
  title: string;
  instructor: string;
  thumbnail: string;
  rating: number;
  students: number;
  duration: string;
  isSaved?: boolean;
}

interface RecommendedCoursesProps {
  courses: Course[];
  onCoursePress: (courseId: string) => void;
  onSeeAll: () => void;
  onLoadMore?: () => void;
}

export const RecommendedCourses: React.FC<RecommendedCoursesProps> = ({
  courses,
  onCoursePress,
  onSeeAll,
  onLoadMore,
}) => {
  const [savedCourses, setSavedCourses] = useState<Set<string>>(new Set());

  const toggleSave = (courseId: string) => {
    setSavedCourses(prev => {
      const newSet = new Set(prev);
      if (newSet.has(courseId)) {
        newSet.delete(courseId);
      } else {
        newSet.add(courseId);
      }
      return newSet;
    });
  };

  const renderItem = ({ item }: { item: Course }) => {
    const isSaved = savedCourses.has(item.id);

    return (
      <TouchableOpacity
        className="w-64 mr-4 bg-white rounded-2xl border border-[#E2E8F0] overflow-hidden"
        onPress={() => onCoursePress(item.id)}
        activeOpacity={0.8}
        style={{
          shadowColor: '#0F172A',
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: 0.05,
          shadowRadius: 4,
          elevation: 2,
        }}
      >
        {/* Thumbnail */}
        <View className="relative">
          <Image 
            source={{ uri: item.thumbnail }}
            className="w-full h-36"
            resizeMode="cover"
          />
          
          {/* Save Button */}
          <TouchableOpacity
            className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white/90 items-center justify-center"
            onPress={() => toggleSave(item.id)}
          >
            <Ionicons 
              name={isSaved ? 'bookmark' : 'bookmark-outline'} 
              size={18} 
              color={isSaved ? '#2563EB' : '#475569'} 
            />
          </TouchableOpacity>
        </View>

        {/* Content */}
        <View className="p-3">
          <Text className="text-[#0F172A] font-semibold text-sm mb-0.5" numberOfLines={1}>
            {item.title}
          </Text>
          <Text className="text-[#64748B] text-xs mb-1.5">
            {item.instructor}
          </Text>

          <View className="flex-row items-center justify-between">
            <View className="flex-row items-center">
              <Ionicons name="star" size={14} color="#FBBF24" />
              <Text className="text-[#0F172A] text-xs font-medium ml-0.5">
                {item.rating.toFixed(1)}
              </Text>
              <Text className="text-[#94A3B8] text-xs ml-1">
                ({item.students.toLocaleString()})
              </Text>
            </View>
            <Text className="text-[#94A3B8] text-xs">
              {item.duration}
            </Text>
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  return (
    <View className="w-full">
      <View className="flex-row justify-between items-center mb-3">
        <Text className="text-[#0F172A] text-xl font-bold">
          Recommended For You
        </Text>
        <TouchableOpacity onPress={onSeeAll}>
          <Text className="text-[#2563EB] text-sm font-semibold">
            See All
          </Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={courses}
        renderItem={renderItem}
        keyExtractor={(item) => item.id}
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
        onEndReached={onLoadMore}
        onEndReachedThreshold={0.5}
        ListFooterComponent={
          onLoadMore ? (
            <View className="w-16 items-center justify-center">
              <ActivityIndicator color="#2563EB" />
            </View>
          ) : null
        }
      />
    </View>
  );
};