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
import { useTheme } from '@/context/themeContext';

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
  const { isDarkMode, colors } = useTheme();

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
        onPress={() => onCoursePress(item.id)}
        activeOpacity={0.8}
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
              color={isSaved ? colors.primary : colors.textSecondary} 
            />
          </TouchableOpacity>
        </View>

        {/* Content */}
        <View className="p-3">
          <Text style={{
            fontWeight: '600',
            fontSize: 14,
            marginBottom: 2,
            color: colors.text,
          }} numberOfLines={1}>
            {item.title}
          </Text>
          <Text style={{
            fontSize: 12,
            marginBottom: 6,
            color: colors.textSecondary,
          }}>
            {item.instructor}
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
                {item.rating.toFixed(1)}
              </Text>
              <Text style={{
                fontSize: 12,
                marginLeft: 4,
                color: colors.textSecondary,
              }}>
                ({item.students.toLocaleString()})
              </Text>
            </View>
            <Text style={{
              fontSize: 12,
              color: colors.textSecondary,
            }}>
              {item.duration}
            </Text>
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  return (
    <View style={{ width: '100%' }}>
      <View className="flex-row justify-between items-center mb-3">
        <Text style={{
          fontSize: 20,
          fontWeight: 'bold',
          color: colors.text,
        }}>
          Recommended For You
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
              <ActivityIndicator color={colors.primary} />
            </View>
          ) : null
        }
      />
    </View>
  );
};