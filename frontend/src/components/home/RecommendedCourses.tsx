// components/home/RecommendedCourses.tsx
import React, { useState, useEffect, useCallback } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  Image,
  FlatList,
  ActivityIndicator,
  RefreshControl,
  Alert,
} from "react-native";
import { Ionicons, Feather } from "@expo/vector-icons";
import { LinearGradient } from "expo-linear-gradient";
import { useTheme } from "@/context/themeContext";
import { useRouter } from "expo-router";

// API Configuration
const API_URL = process.env.EXPO_PUBLIC_API_URL || "http://localhost:3000/api";

interface Course {
  id: string;
  title: string;
  instructor: string;
  thumbnail: string;
  rating: number;
  students: number;
  duration: string;
  isSaved?: boolean;
  price?: number;
  discountPrice?: number;
  isBestseller?: boolean;
  category?: string;
}

interface RecommendedCoursesProps {
  onCoursePress?: (courseId: string) => void;
  onSeeAll?: () => void;
  limit?: number;
}

export const RecommendedCourses: React.FC<RecommendedCoursesProps> = ({
  onCoursePress,
  onSeeAll,
  limit = 10,
}) => {
  const router = useRouter();
  const { isDarkMode, colors } = useTheme();

  // State for real data
  const [courses, setCourses] = useState<Course[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const [offset, setOffset] = useState(0);
  const [savedCourses, setSavedCourses] = useState<Set<string>>(new Set());

  // EXACT SAME fetch pattern as FeaturedCourses
  const fetchRecommendedCourses = async (isLoadMore = false) => {
    try {
      console.log('🌐 Fetching recommended courses...');
      
      const response = await fetch(
        `${API_URL}/api/courses/public`
      );

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const result = await response.json();
      console.log('📥 Recommended courses response:', JSON.stringify(result, null, 2));

      if (!result.success) {
        throw new Error(result.message || 'Failed to fetch courses');
      }

      // EXACT SAME transformation pattern as FeaturedCourses
      const transformedCourses: Course[] = result.data.map((course: any) => ({
        id: course.id,
        title: course.title,
        instructor: course.instructor 
          ? `${course.instructor.firstName || ''} ${course.instructor.lastName || ''}`.trim() 
          : 'Unknown Instructor',
        thumbnail: course.thumbnail || 'https://picsum.photos/seed/default/400/300',
        rating: course.rating || 0,
        students: course.students || course.enrollments || 0,
        duration: course.duration || "2h 30m",
        price: course.price || 0,
        discountPrice: course.discountPrice,
        isBestseller: course.isBestseller || false,
        category: course.category?.name || "General",
      }));

      console.log(`✅ Fetched ${transformedCourses.length} recommended courses`);

      // Update state - same pattern as FeaturedCourses
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
      console.error('❌ Failed to fetch recommended courses:', error);
      Alert.alert(
        'Error',
        error.message || 'Failed to load recommended courses. Please try again.'
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

  // Initial fetch - EXACT SAME as FeaturedCourses
  useEffect(() => {
    fetchRecommendedCourses();
  }, []);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    setOffset(0);
    setHasMore(true);
    fetchRecommendedCourses(false);
  }, []);

  const loadMore = useCallback(() => {
    if (!loadingMore && hasMore && !loading) {
      setLoadingMore(true);
      fetchRecommendedCourses(true);
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

  const toggleSave = (courseId: string) => {
    setSavedCourses((prev) => {
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
          overflow: "hidden",
          backgroundColor: colors.backgroundElement,
          borderColor: colors.backgroundSelected,
          shadowColor: isDarkMode ? "#000000" : "#0F172A",
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: isDarkMode ? 0.3 : 0.05,
          shadowRadius: 4,
          elevation: 2,
        }}
        onPress={() => handleCoursePress(item.id)}
        activeOpacity={0.8}
      >
        {/* Thumbnail */}
        <View className="relative">
          <Image
            source={{ uri: item.thumbnail }}
            className="w-full h-36"
            resizeMode="cover"
          />

          {/* Bestseller Badge */}
          {item.isBestseller && (
            <View className="absolute top-2 left-2 bg-[#22C55E] px-2 py-1 rounded-full">
              <Text className="text-white text-[10px] font-bold">
                Bestseller
              </Text>
            </View>
          )}

          {/* Save Button */}
          <TouchableOpacity
            className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white/90 items-center justify-center"
            onPress={() => toggleSave(item.id)}
          >
            <Ionicons
              name={isSaved ? "bookmark" : "bookmark-outline"}
              size={18}
              color={isSaved ? colors.primary : colors.textSecondary}
            />
          </TouchableOpacity>

          {/* Price Tag */}
          {item.price && (
            <View className="absolute bottom-2 right-2 bg-black/70 px-2.5 py-1 rounded-full">
              <Text className="text-white text-xs font-bold">
                {item.discountPrice ? (
                  <>
                    <Text className="line-through opacity-60">
                      ${item.price}
                    </Text>{" "}
                    ${item.discountPrice}
                  </>
                ) : (
                  `$${item.price}`
                )}
              </Text>
            </View>
          )}
        </View>

        {/* Content */}
        <View className="p-3">
          <Text
            style={{
              fontWeight: "600",
              fontSize: 14,
              marginBottom: 2,
              color: colors.text,
            }}
            numberOfLines={1}
          >
            {item.title}
          </Text>
          <Text
            style={{
              fontSize: 12,
              marginBottom: 6,
              color: colors.textSecondary,
            }}
            numberOfLines={1}
          >
            {item.instructor}
          </Text>

          <View className="flex-row items-center justify-between">
            <View className="flex-row items-center">
              <Ionicons name="star" size={14} color="#FBBF24" />
              <Text
                style={{
                  fontSize: 12,
                  fontWeight: "500",
                  marginLeft: 2,
                  color: colors.text,
                }}
              >
                {item.rating.toFixed(1)}
              </Text>
              <Text
                style={{
                  fontSize: 12,
                  marginLeft: 4,
                  color: colors.textSecondary,
                }}
              >
                ({item.students.toLocaleString()})
              </Text>
            </View>
            <Text
              style={{
                fontSize: 12,
                color: colors.textSecondary,
              }}
            >
              {item.duration}
            </Text>
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  // Loading Skeleton - EXACT SAME as FeaturedCourses
  if (loading) {
    const skeletonBg = isDarkMode ? "#1E293B" : "#E2E8F0";
    return (
      <View style={{ width: "100%", marginBottom: 16 }}>
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
                width: 256,
                height: 220,
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

  // Empty state - EXACT SAME pattern as FeaturedCourses
  if (courses.length === 0) {
    return (
      <View style={{ width: "100%", marginBottom: 16 }}>
        <View className="flex-row justify-between items-center mb-3">
          <Text
            style={{
              fontSize: 20,
              fontWeight: "bold",
              color: colors.text,
            }}
          >
            Recommended For You
          </Text>
        </View>
        <View
          className="items-center justify-center py-8 rounded-2xl"
          style={{ backgroundColor: colors.backgroundElement }}
        >
          <Ionicons
            name="compass-outline"
            size={48}
            color={colors.textSecondary}
          />
          <Text
            className="text-center mt-2 px-8"
            style={{ color: colors.textSecondary }}
          >
            No recommended courses available
          </Text>
        </View>
      </View>
    );
  }

  return (
    <View style={{ width: "100%", marginBottom: 16 }}>
      <View className="flex-row justify-between items-center mb-3">
        <Text
          style={{
            fontSize: 20,
            fontWeight: "bold",
            color: colors.text,
          }}
        >
          Recommended For You
        </Text>
        <TouchableOpacity onPress={handleSeeAll}>
          <Text
            style={{
              fontSize: 14,
              fontWeight: "600",
              color: colors.primary,
            }}
          >
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
        onEndReached={loadMore}
        onEndReachedThreshold={0.5}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.primary}
            colors={[colors.primary]}
          />
        }
        ListFooterComponent={
          loadingMore ? (
            <View className="w-20 items-center justify-center">
              <ActivityIndicator color={colors.primary} size="large" />
            </View>
          ) : hasMore ? (
            <View className="w-20 items-center justify-center">
              <ActivityIndicator color={colors.primary} />
            </View>
          ) : courses.length > 0 ? (
            <View className="w-20 items-center justify-center">
              <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
                No more
              </Text>
            </View>
          ) : null
        }
      />
    </View>
  );
};