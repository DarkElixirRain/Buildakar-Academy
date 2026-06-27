// app/categories/[id].tsx
import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  Image,
  SafeAreaView,
  FlatList,
  RefreshControl,
  Dimensions,
  Alert,
} from 'react-native';
import { router, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { LinearGradient } from 'expo-linear-gradient';

const { width } = Dimensions.get('window');

// API Configuration
const API_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000/api';

interface Course {
  id: string;
  title: string;
  instructor: string;
  thumbnail: string;
  rating: number;
  students: number;
  price?: number;
  level?: string;
  duration?: string;
}

interface CategoryDetail {
  id: string;
  name: string;
  description: string;
  image: string;
  color: string;
  courseCount: number;
  courses: Course[];
}

// Skeleton Components matching home page style
const Skeleton = ({ className = '' }: { className?: string }) => (
  <View className={`bg-[#E2E8F0] rounded-lg animate-pulse ${className}`} />
);

const SkeletonText = ({ className = '' }: { className?: string }) => (
  <View className={`bg-[#E2E8F0] rounded h-4 ${className}`} />
);

const SkeletonCircle = ({ size = 28 }: { size?: number }) => (
  <View className="bg-[#E2E8F0] rounded-full" style={{ width: size, height: size }} />
);

export default function CategoryDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const insets = useSafeAreaInsets();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [category, setCategory] = useState<CategoryDetail | null>(null);
  const [sortBy, setSortBy] = useState<'popular' | 'newest' | 'rating'>('popular');

  useEffect(() => {
    if (id) {
      fetchCategoryDetail();
    }
  }, [id, sortBy]);

  const fetchCategoryDetail = async () => {
    try {
      setLoading(true);
      
      console.log('🌐 Fetching category details for slug:', id);
      
      // ✅ Fetch category from backend API by slug
      const response = await fetch(`${API_URL}/categories/slug/${id}?includeCourses=true&sortBy=${sortBy}`);
      const result = await response.json();
      
      console.log('📥 API Response:', JSON.stringify(result, null, 2));
      
      if (!result.success) {
        throw new Error(result.message || 'Failed to fetch category');
      }

      const categoryData = result.data;
      
      // Transform API response to match frontend interface
      const transformedCategory: CategoryDetail = {
        id: categoryData.id,
        name: categoryData.name,
        description: categoryData.description || `Learn ${categoryData.name} with top-rated courses from industry experts.`,
        image: categoryData.image || 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&h=400&fit=crop',
        color: categoryData.color || '#2563EB',
        courseCount: categoryData.stats?.totalCourses || categoryData._count?.courses || categoryData.courses?.length || 0,
        courses: categoryData.courses?.map((course: any) => ({
          id: course.id,
          title: course.title,
          instructor: `${course.instructor?.firstName || ''} ${course.instructor?.lastName || ''}`.trim() || 'Unknown Instructor',
          thumbnail: course.thumbnail || 'https://picsum.photos/seed/default/400/300',
          rating: course.rating || 0,
          students: course.studentsCount || 0,
          price: course.price || 0,
          level: course.level || 'Beginner',
          duration: course.duration || 'N/A',
        })) || [],
      };
      
      console.log(`✅ Category loaded: ${transformedCategory.name}, ${transformedCategory.courses.length} courses`);
      
      setCategory(transformedCategory);
    } catch (error: any) {
      console.error('❌ Failed to fetch category:', error);
      Alert.alert(
        'Error',
        error.message || 'Failed to load category details. Please try again.'
      );
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchCategoryDetail();
    setRefreshing(false);
  };

  const handleCoursePress = (courseId: string) => {
    router.push(`/course-details/${courseId}` as any);
  };

  const handleBack = () => {
    router.back();
  };

  const handleSortChange = (newSort: 'popular' | 'newest' | 'rating') => {
    setSortBy(newSort);
  };

  const getSortedCourses = () => {
    if (!category) return [];
    // If courses are already sorted from API, just return them
    return category.courses;
  };

  const renderCourseItem = ({ item, index }: { item: Course; index: number }) => {
    return (
      <TouchableOpacity
        className="mb-4 bg-white rounded-2xl border border-[#E2E8F0] overflow-hidden"
        onPress={() => handleCoursePress(item.id)}
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
            source={{ uri: item.thumbnail }}
            className="w-full h-48"
            resizeMode="cover"
          />
          <LinearGradient
            colors={['transparent', 'rgba(0,0,0,0.4)']}
            className="absolute inset-0"
          />
          {item.level && (
            <View className="absolute top-3 right-3 bg-black/60 px-3 py-1 rounded-full">
              <Text className="text-white text-[10px] font-semibold">{item.level}</Text>
            </View>
          )}
          {item.price && item.price > 0 && (
            <View className="absolute bottom-3 left-3 bg-white/90 px-3 py-1 rounded-full">
              <Text className="text-[#0F172A] font-bold text-sm">
                ${item.price.toFixed(2)}
              </Text>
            </View>
          )}
          {item.duration && (
            <View className="absolute bottom-3 right-3 bg-black/60 px-3 py-1 rounded-full flex-row items-center">
              <Ionicons name="time-outline" size={12} color="#FFFFFF" />
              <Text className="text-white text-[10px] font-medium ml-1">{item.duration}</Text>
            </View>
          )}
        </View>
        
        <View className="p-4">
          <Text className="text-[#0F172A] font-semibold text-base" numberOfLines={1}>
            {item.title}
          </Text>
          <Text className="text-[#64748B] text-sm mt-0.5">
            {item.instructor}
          </Text>
          <View className="flex-row items-center mt-2">
            <View className="flex-row items-center">
              <Ionicons name="star" size={16} color="#FBBF24" />
              <Text className="text-[#0F172A] font-medium text-sm ml-1">
                {item.rating.toFixed(1)}
              </Text>
            </View>
            <View className="w-px h-4 bg-[#E2E8F0] mx-2" />
            <Text className="text-[#94A3B8] text-sm">
              {item.students.toLocaleString()} students
            </Text>
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  // Loading Skeleton
  if (loading) {
    return (
      <SafeAreaView className="flex-1 bg-[#F8FAFC]">
        <StatusBar style="dark" />
        
        {/* Header Skeleton */}
        <View className="flex-row items-center px-4 py-3 bg-white border-b border-[#E2E8F0]">
          <SkeletonCircle size={40} />
          <SkeletonText className="w-32 h-6 ml-2" />
          <SkeletonText className="w-20 h-5 ml-auto" />
        </View>

        <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
          {/* Banner Skeleton */}
          <View className="px-4 pt-4">
            <Skeleton className="w-full h-48 rounded-2xl" />
            <SkeletonText className="w-full h-4 mt-3" />
            <SkeletonText className="w-11/12 h-4 mt-1" />
          </View>

          {/* Sort Options Skeleton */}
          <View className="flex-row px-4 mt-4">
            {[1, 2, 3].map((i) => (
              <Skeleton key={i} className="w-20 h-9 rounded-full mr-3" />
            ))}
          </View>

          {/* Course Cards Skeleton */}
          <View className="px-4 pt-4">
            {[1, 2, 3].map((i) => (
              <View key={i} className="bg-white rounded-2xl mb-4 border border-[#E2E8F0] overflow-hidden">
                <Skeleton className="w-full h-48" />
                <View className="p-4">
                  <SkeletonText className="w-3/4 h-5" />
                  <SkeletonText className="w-1/2 h-4 mt-1" />
                  <View className="flex-row items-center mt-2">
                    <Skeleton className="w-16 h-4" />
                    <Skeleton className="w-px h-4 mx-2" />
                    <Skeleton className="w-24 h-4" />
                  </View>
                </View>
              </View>
            ))}
          </View>
        </ScrollView>
      </SafeAreaView>
    );
  }

  if (!category) {
    return (
      <SafeAreaView className="flex-1 bg-[#F8FAFC] items-center justify-center p-4">
        <StatusBar style="dark" />
        <View className="w-24 h-24 rounded-full bg-[#F1F5F9] items-center justify-center mb-4">
          <Ionicons name="alert-circle-outline" size={48} color="#EF4444" />
        </View>
        <Text className="text-[#0F172A] text-xl font-bold">
          Category Not Found
        </Text>
        <Text className="text-[#64748B] text-center mt-1 px-8">
          The category you're looking for doesn't exist or has been removed
        </Text>
        <TouchableOpacity
          className="mt-6 bg-[#2563EB] px-8 py-3 rounded-xl"
          onPress={handleBack}
          activeOpacity={0.8}
        >
          <Text className="text-white font-bold">Go Back</Text>
        </TouchableOpacity>
      </SafeAreaView>
    );
  }

  const sortedCourses = getSortedCourses();

  return (
    <SafeAreaView className="flex-1 bg-[#F8FAFC]">
      <StatusBar style="dark" />

      {/* Header matching home page style */}
      <View className="flex-row items-center px-4 py-3 bg-white border-b border-[#E2E8F0]">
        <TouchableOpacity
          onPress={handleBack}
          className="w-10 h-10 rounded-full bg-[#F1F5F9] items-center justify-center"
          activeOpacity={0.7}
        >
          <Ionicons name="chevron-back" size={24} color="#0F172A" />
        </TouchableOpacity>
        <Text className="text-[#0F172A] text-lg font-bold ml-2 flex-1" numberOfLines={1}>
          {category.name}
        </Text>
        <View className="flex-row items-center">
          <Text className="text-[#64748B] text-sm mr-2">
            {category.courseCount}
          </Text>
          <Ionicons name="bookmark-outline" size={20} color="#64748B" />
        </View>
      </View>

      <FlatList
        data={sortedCourses}
        renderItem={renderCourseItem}
        keyExtractor={(item) => item.id}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor="#2563EB"
            colors={["#2563EB"]}
          />
        }
        contentContainerStyle={{ 
          paddingTop: 0,
          paddingBottom: insets.bottom + 80,
        }}
        showsVerticalScrollIndicator={false}
        ListHeaderComponent={
          <View>
            {/* Banner */}
            <View className="px-4 pt-4">
              <View className="relative rounded-2xl overflow-hidden">
                <Image
                  source={{ uri: category.image }}
                  className="w-full h-52"
                  resizeMode="cover"
                />
                <LinearGradient
                  colors={['transparent', 'rgba(0,0,0,0.6)']}
                  className="absolute inset-0"
                />
                <View className="absolute bottom-4 left-4 right-4">
                  <Text className="text-white text-2xl font-bold">
                    {category.name}
                  </Text>
                  <Text className="text-white/90 text-sm mt-1">
                    {category.description}
                  </Text>
                  <View className="flex-row items-center mt-2">
                    <View className="bg-white/20 px-3 py-1 rounded-full flex-row items-center">
                      <Ionicons name="book-outline" size={14} color="#FFFFFF" />
                      <Text className="text-white text-xs font-medium ml-1">
                        {category.courseCount} Courses
                      </Text>
                    </View>
                  </View>
                </View>
              </View>
            </View>

            {/* Sort Options */}
            <View className="flex-row px-4 mt-4">
              {[
                { key: 'popular', label: '⭐ Popular' },
                { key: 'rating', label: '📈 Top Rated' },
                { key: 'newest', label: '🆕 Newest' },
              ].map((option) => (
                <TouchableOpacity
                  key={option.key}
                  onPress={() => handleSortChange(option.key as any)}
                  className={`px-4 py-2 rounded-full mr-3 ${
                    sortBy === option.key
                      ? 'bg-[#2563EB]'
                      : 'bg-white border border-[#E2E8F0]'
                  }`}
                  activeOpacity={0.7}
                >
                  <Text
                    className={`text-sm font-medium ${
                      sortBy === option.key ? 'text-white' : 'text-[#64748B]'
                    }`}
                  >
                    {option.label}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            {/* Results count */}
            <View className="flex-row items-center justify-between px-4 pt-4 pb-2">
              <Text className="text-[#64748B] text-sm">
                {sortedCourses.length} courses found
              </Text>
              <Text className="text-[#94A3B8] text-xs">
                Showing {Math.min(sortedCourses.length, 10)} of {category.courseCount}
              </Text>
            </View>
          </View>
        }
        ListEmptyComponent={
          <View className="items-center py-12">
            <View className="w-24 h-24 rounded-full bg-[#F1F5F9] items-center justify-center mb-4">
              <Ionicons name="book-outline" size={48} color="#94A3B8" />
            </View>
            <Text className="text-[#0F172A] text-lg font-bold">
              No Courses Available
            </Text>
            <Text className="text-[#64748B] text-center mt-1 px-8">
              No courses available in this category yet. Check back later!
            </Text>
          </View>
        }
      />
    </SafeAreaView>
  );
}