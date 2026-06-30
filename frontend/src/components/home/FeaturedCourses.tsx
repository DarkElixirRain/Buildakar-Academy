// components/home/FeaturedCourses.tsx
import React, { useState, useEffect, useCallback, useRef } from 'react';
import { 
  View, 
  Text, 
  TouchableOpacity, 
  FlatList, 
  Image, 
  Dimensions,
  Animated,
  Platform,
  RefreshControl,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '@/context/themeContext';
import { useRouter } from 'expo-router';

const { width } = Dimensions.get('window');

// API Configuration
const API_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000/api';

interface FeaturedCourse {
  id: string;
  title: string;
  instructor: string;
  image: string;
  rating: number;
  isBestseller: boolean;
}

interface FeaturedCoursesProps {
  onCoursePress?: (courseId: string) => void;
}

export const FeaturedCourses: React.FC<FeaturedCoursesProps> = ({
  onCoursePress,
}) => {
  const router = useRouter();
  const flatListRef = useRef<FlatList>(null);
  const [currentIndex, setCurrentIndex] = useState(0);
  const scrollX = useRef(new Animated.Value(0)).current;
  const { isDarkMode, colors } = useTheme();
  
  // State for real data
  const [courses, setCourses] = useState<FeaturedCourse[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  // Fetch featured courses from API
  const fetchFeaturedCourses = async () => {
    try {
      console.log('🌐 Fetching featured courses...');
      
      const response = await fetch(
        `${API_URL}/api/courses/public`
      );

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const result = await response.json();
      console.log('📥 Featured courses response:', JSON.stringify(result, null, 2));

      if (!result.success) {
        throw new Error(result.message || 'Failed to fetch courses');
      }

      // Transform API data to match FeaturedCourse interface
      const transformedCourses: FeaturedCourse[] = result.data.map((course: any) => ({
        id: course.id,
        title: course.title,
        instructor: course.instructor 
          ? `${course.instructor.firstName || ''} ${course.instructor.lastName || ''}`.trim() 
          : 'Unknown Instructor',
        image: course.thumbnail || 'https://picsum.photos/seed/default/400/300',
        rating: course.rating || 0,
        isBestseller: course.isBestseller || false,
      }));

      console.log(`✅ Fetched ${transformedCourses.length} featured courses`);
      setCourses(transformedCourses);
    } catch (error: any) {
      console.error('❌ Failed to fetch featured courses:', error);
      Alert.alert(
        'Error',
        error.message || 'Failed to load featured courses. Please try again.'
      );
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  // Initial fetch
  useEffect(() => {
    fetchFeaturedCourses();
  }, []);

  // Auto-scroll effect
  useEffect(() => {
    if (courses.length === 0) return;
    
    const interval = setInterval(() => {
      const nextIndex = (currentIndex + 1) % courses.length;
      flatListRef.current?.scrollToIndex({
        index: nextIndex,
        animated: true,
      });
      setCurrentIndex(nextIndex);
    }, 5000);

    return () => clearInterval(interval);
  }, [currentIndex, courses.length]);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    fetchFeaturedCourses();
  }, []);

  const handleCoursePress = (courseId: string) => {
    if (onCoursePress) {
      onCoursePress(courseId);
    } else {
      router.push(`/course-details/${courseId}` as any);
    }
  };

  const renderItem = ({ item }: { item: FeaturedCourse }) => (
    <TouchableOpacity
      style={{
        width: 350,
        marginRight: 16,
        borderRadius: 24,
        overflow: 'hidden',
      }}
      onPress={() => handleCoursePress(item.id)}
      activeOpacity={0.9}
    >
      <View className="relative h-48">
        <Image 
          source={{ uri: item.image }}
          className="w-full h-full"
          resizeMode="cover"
        />
        <LinearGradient
          colors={['transparent', 'rgba(0,0,0,0.7)']}
          className="absolute inset-0"
        />
        
        {/* Bestseller Badge */}
        {item.isBestseller && (
          <View className="absolute top-3 left-3 bg-[#22C55E] px-3 py-1 rounded-full">
            <Text className="text-white text-xs font-bold">Bestseller</Text>
          </View>
        )}

        {/* Rating */}
        <View className="absolute top-3 right-3 bg-black/60 px-2.5 py-1 rounded-full flex-row items-center">
          <Ionicons name="star" size={14} color="#FBBF24" />
          <Text className="text-white text-xs font-medium ml-1">
            {item.rating.toFixed(1)}
          </Text>
        </View>

        {/* Content */}
        <View className="absolute bottom-0 left-0 right-0 p-4">
          <Text className="text-white font-bold text-lg mb-0.5" numberOfLines={1}>
            {item.title}
          </Text>
          <Text className="text-white/80 text-sm mb-2">
            {item.instructor}
          </Text>
          <View className="flex-row items-center">
            <TouchableOpacity 
              className="bg-white/20 backdrop-blur-sm px-5 py-2 rounded-full border border-white/20"
              onPress={() => handleCoursePress(item.id)}
            >
              <Text className="text-white font-bold text-sm">
                Explore Course →
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </TouchableOpacity>
  );

  // Loading Skeleton
  if (loading) {
    const skeletonBg = isDarkMode ? '#1E293B' : '#E2E8F0';
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
                width: 350,
                height: 192,
                marginRight: 16,
                borderRadius: 24,
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
        <Text style={{ 
          fontSize: 20, 
          fontWeight: 'bold', 
          marginBottom: 12, 
          color: colors.text 
        }}>
          Featured Courses
        </Text>
        <View 
          className="items-center justify-center py-8 rounded-2xl"
          style={{ backgroundColor: colors.backgroundElement }}
        >
          <Ionicons name="book-outline" size={48} color={colors.textSecondary} />
          <Text 
            className="text-center mt-2 px-8"
            style={{ color: colors.textSecondary }}
          >
            No featured courses available
          </Text>
        </View>
      </View>
    );
  }

  const useNativeDriver = Platform.OS !== 'web';

  return (
    <View style={{ width: '100%', marginBottom: 16 }}>
      <View className="flex-row justify-between items-center mb-3">
        <Text style={{ 
          fontSize: 20, 
          fontWeight: 'bold', 
          color: colors.text 
        }}>
          Featured Courses
        </Text>
        {courses.length > 0 && (
          <TouchableOpacity 
            onPress={() => router.push('/explore' as any)}
            className="flex-row items-center"
          >
            <Text style={{ color: colors.primary, fontSize: 14 }}>
              See All
            </Text>
            <Ionicons name="chevron-forward" size={16} color={colors.primary} />
          </TouchableOpacity>
        )}
      </View>

      <FlatList
        ref={flatListRef}
        data={courses}
        renderItem={renderItem}
        keyExtractor={(item) => item.id}
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
        decelerationRate="fast"
        snapToInterval={350 + 16}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.primary}
            colors={[colors.primary]}
          />
        }
        onScroll={Animated.event(
          [{ nativeEvent: { contentOffset: { x: scrollX } } }],
          { 
            useNativeDriver: useNativeDriver,
          }
        )}
        scrollEventThrottle={16}
      />

      {/* Dots Indicator */}
      {courses.length > 1 && (
        <View className="flex-row justify-center mt-3">
          {courses.map((_, index) => {
            const inputRange = [
              (index - 1) * (350 + 16),
              index * (350 + 16),
              (index + 1) * (350 + 16),
            ];
            const dotWidth = scrollX.interpolate({
              inputRange,
              outputRange: [6, 20, 6],
              extrapolate: 'clamp',
            });
            const opacity = scrollX.interpolate({
              inputRange,
              outputRange: [0.3, 1, 0.3],
              extrapolate: 'clamp',
            });

            return (
              <Animated.View
                key={index}
                style={{
                  height: 6,
                  borderRadius: 3,
                  marginHorizontal: 4,
                  backgroundColor: colors.primary,
                  width: dotWidth,
                  opacity,
                }}
              />
            );
          })}
        </View>
      )}
    </View>
  );
};