// components/home/PopularCourses.tsx
import React, { useState, useEffect, useCallback } from 'react';
import { 
  View, 
  Text, 
  TouchableOpacity, 
  ScrollView, 
  Image, 
  ActivityIndicator,
  RefreshControl,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';
import { useRouter } from 'expo-router';

// API Configuration
const API_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000/api';

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
  onCoursePress?: (courseId: string) => void;
  onSeeAll?: () => void;
  limit?: number;
}

export const PopularCourses: React.FC<PopularCoursesProps> = ({
  onCoursePress,
  onSeeAll,
  limit = 10,
}) => {
  const router = useRouter();
  const { isDarkMode, colors } = useTheme();

  // State for real data
  const [courses, setCourses] = useState<PopularCourse[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const [offset, setOffset] = useState(0);

  // Fetch popular courses from API - NO FILTERS
  const fetchPopularCourses = async (isLoadMore = false) => {
    try {
      console.log('🌐 Fetching popular courses...');
      
      const response = await fetch(
        `${API_URL}/api/courses/public`
      );

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const result = await response.json();
      console.log('📥 Popular courses response:', JSON.stringify(result, null, 2));

      if (!result.success) {
        throw new Error(result.message || 'Failed to fetch courses');
      }

      // Transform all courses - NO FILTERING
      const transformedCourses: PopularCourse[] = result.data.map((course: any) => ({
        id: course.id,
        title: course.title,
        instructor: course.instructor 
          ? `${course.instructor.firstName || ''} ${course.instructor.lastName || ''}`.trim() 
          : 'Unknown Instructor',
        thumbnail: course.thumbnail || 'https://picsum.photos/seed/default/400/300',
        rating: course.rating || 0,
        students: course.students || course.enrollments || 0,
        isTrending: course.isTrending || course.isBestseller || false,
      }));

      console.log(`✅ Fetched ${transformedCourses.length} popular courses`);

      // Update state - NO FILTERING, use all courses
      if (isLoadMore) {
        setCourses((prev) => [...prev, ...transformedCourses]);
        setOffset(offset + limit);
        setHasMore(transformedCourses.length === limit);
      } else {
        setCourses(transformedCourses);
        setOffset(limit);
        setHasMore(transformedCourses.length === limit);
      }
    } catch (error: any) {
      console.error('❌ Failed to fetch popular courses:', error);
      Alert.alert(
        'Error',
        error.message || 'Failed to load popular courses. Please try again.'
      );
      if (!isLoadMore) {
        setCourses([]);
      }
    } finally {
      setLoading(false);
      setRefreshing(false);
      setLoadingMore(false);
    }
  };

  // Initial fetch
  useEffect(() => {
    fetchPopularCourses();
  }, []);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    setOffset(0);
    setHasMore(true);
    fetchPopularCourses(false);
  }, []);

  const loadMore = useCallback(() => {
    if (!loadingMore && hasMore && !loading) {
      setLoadingMore(true);
      fetchPopularCourses(true);
    }
  }, [loadingMore, hasMore, loading]);

  const handleCoursePress = (courseId: string) => {
    if (onCoursePress) {
      onCoursePress(courseId);
    } else {
      router.push(`/course-details/${courseId}` as any);
    }
  };

  const handleSeeAll = () => {
    if (onSeeAll) {
      onSeeAll();
    } else {
      router.push("/explore" as any);
    }
  };

  // Loading Skeleton
  if (loading) {
    const skeletonBg = isDarkMode ? "#1E293B" : "#E2E8F0";
    return (
      <View style={{ width: '100%', marginBottom: 16 }}>
        <View className="flex-row justify-between items-center mb-3">
          <View 
            className="h-6 w-40 rounded" 
            style={{ backgroundColor: skeletonBg }}
          />
          <View 
            className="h-4 w-20 rounded" 
            style={{ backgroundColor: skeletonBg }}
          />
        </View>
        <View className="flex-row">
          {[1, 2, 3].map((i) => (
            <View
              key={i}
              style={{
                width: 224,
                height: 180,
                marginRight: 16,
                borderRadius: 16,
                backgroundColor: skeletonBg,
              }}
            />
          ))}
        </View>
      </View>
    );
  }

  // Empty state
  if (courses.length === 0) {
    return (
      <View style={{ width: '100%', marginBottom: 16 }}>
        <View className="flex-row justify-between items-center mb-3">
          <Text style={{
            fontSize: 20,
            fontWeight: 'bold',
            color: colors.text,
          }}>
            Popular Courses
          </Text>
        </View>
        <View 
          className="items-center justify-center py-8 rounded-2xl"
          style={{ backgroundColor: colors.backgroundElement }}
        >
          <Ionicons name="flame-outline" size={48} color={colors.textSecondary} />
          <Text 
            className="text-center mt-2 px-8"
            style={{ color: colors.textSecondary }}
          >
            No popular courses available
          </Text>
        </View>
      </View>
    );
  }

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
        <TouchableOpacity onPress={handleSeeAll}>
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
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.primary}
            colors={[colors.primary]}
          />
        }
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
            onPress={() => handleCoursePress(course.id)}
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
        
        {/* Loading More Indicator */}
        {loadingMore && (
          <View className="w-20 items-center justify-center">
            <ActivityIndicator color={colors.primary} size="large" />
          </View>
        )}
      </ScrollView>
    </View>
  );
};