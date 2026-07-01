// components/home/ContinueLearning.tsx
import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  Image,
  Alert,
  RefreshControl,
  Dimensions,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useTheme } from '@/context/themeContext';
import { useAuthStore } from '@/store/authStore';
import api from '@/lib/api';
import { ContinueLearningCourse } from '@/types/home';

const { width: SCREEN_WIDTH } = Dimensions.get('window');
const CARD_WIDTH = SCREEN_WIDTH * 0.65;
const CARD_HEIGHT = 240;

interface ContinueLearningProps {
  onCoursePress?: (courseId: string) => void;
  limit?: number;
}

// ✅ Skeleton Loading Component - FIXED: No text nodes in View
const SkeletonCard: React.FC<{ colors: any; isDarkMode: boolean }> = ({ colors, isDarkMode }) => {
  return (
    <View
      style={{
        width: CARD_WIDTH,
        marginRight: 16,
        borderRadius: 16,
        borderWidth: 1,
        overflow: 'hidden',
        backgroundColor: colors.backgroundElement,
        borderColor: colors.backgroundSelected,
      }}
    >
      {/* Image Skeleton */}
      <View
        style={{
          height: CARD_HEIGHT * 0.5,
          backgroundColor: isDarkMode ? '#2E3135' : '#E5E7EB',
        }}
      />
      
      {/* Content Skeleton */}
      <View style={{ padding: 12 }}>
        {/* Title Skeleton */}
        <View
          style={{
            height: 16,
            width: '85%',
            borderRadius: 4,
            marginBottom: 8,
            backgroundColor: isDarkMode ? '#2E3135' : '#E5E7EB',
          }}
        />
        
        {/* Instructor Skeleton */}
        <View
          style={{
            height: 12,
            width: '60%',
            borderRadius: 4,
            marginBottom: 12,
            backgroundColor: isDarkMode ? '#2E3135' : '#E5E7EB',
          }}
        />
        
        {/* Progress Bar Skeleton */}
        <View
          style={{
            height: 6,
            width: '100%',
            borderRadius: 3,
            marginBottom: 12,
            backgroundColor: isDarkMode ? '#2E3135' : '#E5E7EB',
          }}
        />
        
        {/* Button Skeleton */}
        <View
          style={{
            height: 32,
            width: '100%',
            borderRadius: 20,
            backgroundColor: isDarkMode ? '#2E3135' : '#E5E7EB',
          }}
        />
      </View>
    </View>
  );
};

// ✅ Skeleton Loading State - FIXED: No text nodes in View
const SkeletonLoading: React.FC<{ colors: any; isDarkMode: boolean }> = ({ colors, isDarkMode }) => {
  return (
    <View style={{ width: '100%' }}>
      {/* Header Skeleton */}
      <View className="flex-row justify-between items-center mb-3">
        <View
          style={{
            height: 24,
            width: 160,
            borderRadius: 4,
            backgroundColor: isDarkMode ? '#2E3135' : '#E5E7EB',
          }}
        />
        <View
          style={{
            height: 18,
            width: 60,
            borderRadius: 4,
            backgroundColor: isDarkMode ? '#2E3135' : '#E5E7EB',
          }}
        />
      </View>

      {/* Horizontal Scroll Skeleton */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
      >
        {[1, 2, 3].map((index) => (
          <SkeletonCard key={index} colors={colors} isDarkMode={isDarkMode} />
        ))}
      </ScrollView>
    </View>
  );
};

export const ContinueLearning: React.FC<ContinueLearningProps> = ({
  onCoursePress,
  limit = 10,
}) => {
  const router = useRouter();
  const { isDarkMode, colors } = useTheme();
  
  // ✅ Get token directly from auth store
  const authStore = useAuthStore();
  const { 
    user, 
    token,
    isAuthenticated,
  } = authStore;

  // State
  const [courses, setCourses] = useState<ContinueLearningCourse[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Debug: Log auth status
  useEffect(() => {
    console.log('🔐 ContinueLearning Auth Status:', {
      isAuthenticated,
      hasToken: !!token,
      tokenPreview: token ? `${token.substring(0, 20)}...` : 'null',
      userEmail: user?.email || 'No user',
    });
  }, [isAuthenticated, token, user]);

  // Calculate remaining time based on progress
  const calculateRemainingTime = (progress: number): string => {
    if (progress >= 100) return 'Completed ✅';
    if (progress === 0) return 'Not started';
    
    const totalHours = 40;
    const remainingPercent = (100 - progress) / 100;
    const remainingHours = Math.round(totalHours * remainingPercent);
    
    if (remainingHours > 24) {
      return `${Math.round(remainingHours / 24)} days left`;
    } else if (remainingHours > 1) {
      return `${remainingHours}h left`;
    } else if (remainingHours === 1) {
      return '1h left';
    } else {
      return '< 1h left';
    }
  };

  // Fetch continue learning
  const fetchContinueLearning = useCallback(
    async (forceRefresh: boolean = false) => {
      if (!isAuthenticated || !token) {
        console.warn('⚠️ User not authenticated - skipping fetch');
        setLoading(false);
        setError('Please login to view your courses');
        return;
      }

      try {
        setError(null);
        console.log('📚 Fetching continue learning courses...');
        
        const response = await api.get(`/api/enroll/continue-learning?limit=${limit}`);
        
        console.log('📥 Response status:', response.status);
        
        if (response.data.success) {
          const transformedData = response.data.data.map((item: any) => {
            const course = item.course || item;
            const instructor = course.instructor || {};
            
            return {
              id: item.id || course.id,
              courseId: course.id || item.courseId || '',
              title: course.title || 'Untitled Course',
              instructor: `${instructor.firstName || ''} ${instructor.lastName || ''}`.trim() || 'Instructor',
              thumbnail: course.thumbnail || 'https://via.placeholder.com/400x300',
              progress: item.progress || 0,
              remainingTime: calculateRemainingTime(item.progress || 0),
              isCompleted: item.isCompleted || false,
              enrolledAt: item.enrolledAt || null,
              completedAt: item.completedAt || null,
              lastAccessed: item.updatedAt || null,
              level: course.level || 'BEGINNER',
              category: course.category?.name || '',
            };
          });
          
          setCourses(transformedData);
          console.log(`✅ Loaded ${transformedData.length} continue learning courses`);
        } else {
          throw new Error(response.data.message || 'Failed to load courses');
        }
      } catch (error: any) {
        console.error('❌ Error fetching continue learning:', error);
        
        if (error.response?.status === 401) {
          setError('Session expired. Please login again.');
          Alert.alert(
            'Session Expired',
            'Your session has expired. Please login again.',
            [{ text: 'Login', onPress: () => router.push('/(auth)/login') }]
          );
        } else if (error.response?.status === 404) {
          setError('No continue learning courses found');
          setCourses([]);
        } else {
          setError(error.message || 'Failed to load your courses');
          Alert.alert(
            'Error',
            error.message || 'Failed to load your courses. Please try again.',
            [{ text: 'Retry', onPress: () => fetchContinueLearning(true) }]
          );
        }
      } finally {
        setLoading(false);
        setRefreshing(false);
      }
    },
    [limit, isAuthenticated, token, router]
  );

  // Handle course press
  const handleCoursePress = useCallback(
    (course: ContinueLearningCourse) => {
      try {
        const navigationId = course.courseId || course.id;
        console.log('Navigating to course:', navigationId);

        if (onCoursePress) {
          onCoursePress(navigationId);
        } else {
          router.push(`/course/${navigationId}`);
        }
      } catch (error) {
        console.error('Navigation error:', error);
        Alert.alert('Error', 'Unable to open course. Please try again.');
      }
    },
    [onCoursePress, router]
  );

  // Handle see all
  const handleSeeAll = useCallback(() => {
    try {
      router.push('/my-learning');
    } catch (error) {
      console.error('Navigation error:', error);
      Alert.alert('Error', 'Unable to open My Learning.');
    }
  }, [router]);

  // Handle refresh
  const handleRefresh = useCallback(() => {
    setRefreshing(true);
    fetchContinueLearning(true);
  }, [fetchContinueLearning]);

  // Initial fetch
  useEffect(() => {
    if (isAuthenticated && token) {
      fetchContinueLearning();
    } else {
      setLoading(false);
    }
  }, [isAuthenticated, token, fetchContinueLearning]);

  // ======================== RENDER STATES ========================

  // 1. Not authenticated state
  if (!isAuthenticated || !token) {
    return (
      <View style={{ width: '100%' }}>
        <View className="flex-row justify-between items-center mb-3">
          <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text }}>
            Continue Learning
          </Text>
        </View>
        <View
          style={{
            padding: 32,
            borderRadius: 16,
            alignItems: 'center',
            backgroundColor: colors.backgroundElement,
            borderWidth: 1,
            borderColor: colors.backgroundSelected,
          }}
        >
          <Ionicons name="log-in-outline" size={56} color={colors.textSecondary} />
          <Text
            style={{
              fontSize: 18,
              fontWeight: '600',
              color: colors.text,
              marginTop: 16,
            }}
          >
            Login to Continue Learning
          </Text>
          <Text
            style={{
              fontSize: 14,
              color: colors.textSecondary,
              textAlign: 'center',
              marginTop: 4,
              paddingHorizontal: 20,
            }}
          >
            Sign in to track your progress and continue where you left off.
          </Text>
          <TouchableOpacity
            style={{
              marginTop: 20,
              paddingHorizontal: 32,
              paddingVertical: 12,
              borderRadius: 24,
              backgroundColor: colors.primary,
            }}
            onPress={() => router.push('/(auth)/login')}
          >
            <Text style={{ color: 'white', fontWeight: '600', fontSize: 16 }}>
              Login
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  // 2. Loading state with Skeleton
  if (loading) {
    return <SkeletonLoading colors={colors} isDarkMode={isDarkMode} />;
  }

  // 3. Error state
  if (error && courses.length === 0) {
    return (
      <View style={{ width: '100%' }}>
        <View className="flex-row justify-between items-center mb-3">
          <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text }}>
            Continue Learning
          </Text>
        </View>
        <View
          style={{
            padding: 32,
            borderRadius: 16,
            alignItems: 'center',
            backgroundColor: colors.backgroundElement,
            borderWidth: 1,
            borderColor: colors.backgroundSelected,
          }}
        >
          <Ionicons name="alert-circle-outline" size={56} color={colors.error || '#EF4444'} />
          <Text
            style={{
              fontSize: 16,
              fontWeight: '600',
              color: colors.text,
              marginTop: 16,
            }}
          >
            Unable to Load Courses
          </Text>
          <Text
            style={{
              fontSize: 14,
              color: colors.textSecondary,
              textAlign: 'center',
              marginTop: 4,
              paddingHorizontal: 20,
            }}
          >
            {error}
          </Text>
          <TouchableOpacity
            style={{
              marginTop: 20,
              paddingHorizontal: 32,
              paddingVertical: 12,
              borderRadius: 24,
              backgroundColor: colors.primary,
            }}
            onPress={() => fetchContinueLearning(true)}
          >
            <Text style={{ color: 'white', fontWeight: '600', fontSize: 16 }}>
              Try Again
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  // 4. No courses state
  if (courses.length === 0) {
    return (
      <View style={{ width: '100%' }}>
        <View className="flex-row justify-between items-center mb-3">
          <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text }}>
            Continue Learning
          </Text>
        </View>
        <View
          style={{
            padding: 32,
            borderRadius: 16,
            alignItems: 'center',
            backgroundColor: colors.backgroundElement,
            borderWidth: 1,
            borderColor: colors.backgroundSelected,
          }}
        >
          <Ionicons name="school-outline" size={56} color={colors.textSecondary} />
          <Text
            style={{
              fontSize: 18,
              fontWeight: '600',
              color: colors.text,
              marginTop: 16,
            }}
          >
            No courses in progress
          </Text>
          <Text
            style={{
              fontSize: 14,
              color: colors.textSecondary,
              textAlign: 'center',
              marginTop: 4,
              paddingHorizontal: 20,
            }}
          >
            Browse our catalog and start learning today!
          </Text>
          <TouchableOpacity
            style={{
              marginTop: 20,
              paddingHorizontal: 32,
              paddingVertical: 12,
              borderRadius: 24,
              backgroundColor: colors.primary,
            }}
            onPress={() => router.push('/courses' as any)}
          >
            <Text style={{ color: 'white', fontWeight: '600', fontSize: 16 }}>
              Browse Courses
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  // 5. Main render with courses
  return (
    <View style={{ width: '100%' }}>
      {/* Header */}
      <View className="flex-row justify-between items-center mb-3">
        <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text }}>
          Continue Learning
        </Text>
        <TouchableOpacity onPress={handleSeeAll}>
          <Text style={{ fontSize: 14, fontWeight: '600', color: colors.primary }}>
            See All ({courses.length})
          </Text>
        </TouchableOpacity>
      </View>

      {/* Horizontal Scroll */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20, paddingVertical: 4 }}
        decelerationRate="fast"
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={handleRefresh}
            tintColor={colors.primary}
            colors={[colors.primary]}
          />
        }
      >
        {courses.map((course, index) => {
          const isCompleted = course.isCompleted || false;
          const progress = Math.min(course.progress || 0, 100);
          const progressColor = isCompleted ? (colors.success || '#22C55E') : colors.primary;

          return (
            <TouchableOpacity
              key={course.id}
              style={{
                width: CARD_WIDTH,
                marginRight: index === courses.length - 1 ? 0 : 16,
                borderRadius: 16,
                borderWidth: 1,
                overflow: 'hidden',
                backgroundColor: colors.backgroundElement,
                borderColor: colors.backgroundSelected,
                shadowColor: isDarkMode ? '#000000' : '#0F172A',
                shadowOffset: { width: 0, height: 4 },
                shadowOpacity: isDarkMode ? 0.3 : 0.08,
                shadowRadius: 8,
                elevation: 3,
              }}
              onPress={() => handleCoursePress(course)}
              activeOpacity={0.8}
            >
              {/* Image Section */}
              <View style={{ position: 'relative', height: CARD_HEIGHT * 0.5 }}>
                <Image
                  source={{ uri: course.thumbnail || 'https://via.placeholder.com/400x200' }}
                  style={{ width: '100%', height: '100%' }}
                  resizeMode="cover"
                />

                {/* Progress Badge - Top Right */}
                <View className="absolute top-2 right-2 bg-black/70 px-2.5 py-1 rounded-full">
                  <Text className="text-white text-xs font-medium">
                    {progress}%
                  </Text>
                </View>

                {/* Completed Badge - Top Left */}
                {isCompleted && (
                  <View className="absolute top-2 left-2 bg-green-500 px-2.5 py-1 rounded-full">
                    <Text className="text-white text-xs font-medium">
                      ✅ Completed
                    </Text>
                  </View>
                )}

                {/* Level Badge - Bottom Left */}
                {course.level && (
                  <View className="absolute bottom-2 left-2 bg-black/60 px-2.5 py-1 rounded-full">
                    <Text className="text-white text-xs font-medium">
                      {course.level}
                    </Text>
                  </View>
                )}

                {/* Time Remaining Badge - Bottom Right */}
                <View className="absolute bottom-2 right-2 bg-black/60 px-2.5 py-1 rounded-full">
                  <Text className="text-white text-xs font-medium">
                    {course.remainingTime}
                  </Text>
                </View>
              </View>

              {/* Content Section */}
              <View style={{ padding: 12, flex: 1 }}>
                {/* Title */}
                <Text
                  style={{
                    fontWeight: '600',
                    fontSize: 14,
                    marginBottom: 2,
                    color: colors.text,
                  }}
                  numberOfLines={1}
                >
                  {course.title}
                </Text>

                {/* Instructor */}
                <Text
                  style={{
                    fontSize: 12,
                    color: colors.textSecondary,
                  }}
                  numberOfLines={1}
                >
                  {course.instructor}
                </Text>

                {/* Category */}
                {course.category && (
                  <Text
                    style={{
                      fontSize: 10,
                      color: colors.textSecondary,
                      marginTop: 2,
                    }}
                    numberOfLines={1}
                  >
                    {course.category}
                  </Text>
                )}

                {/* Progress Bar */}
                <View style={{ marginTop: 8 }}>
                  <View className="flex-row items-center justify-between">
                    <View style={{ flex: 1, marginRight: 8 }}>
                      <View
                        style={{
                          width: '100%',
                          height: 6,
                          borderRadius: 3,
                          overflow: 'hidden',
                          backgroundColor: isDarkMode ? '#334155' : '#F1F5F9',
                        }}
                      >
                        <View
                          style={{
                            height: '100%',
                            borderRadius: 3,
                            backgroundColor: progressColor,
                            width: `${progress}%`,
                          }}
                        />
                      </View>
                    </View>
                    <Text
                      style={{
                        fontSize: 11,
                        fontWeight: '500',
                        color: colors.textSecondary,
                        minWidth: 32,
                        textAlign: 'right',
                      }}
                    >
                      {progress}%
                    </Text>
                  </View>
                </View>

                {/* Resume Button */}
                <TouchableOpacity
                  style={{
                    marginTop: 10,
                    paddingVertical: 8,
                    borderRadius: 20,
                    backgroundColor: isCompleted ? (colors.success || '#22C55E') : colors.primary,
                    alignItems: 'center',
                  }}
                  onPress={(e) => {
                    e.stopPropagation();
                    handleCoursePress(course);
                  }}
                  activeOpacity={0.7}
                >
                  <Text style={{ color: 'white', fontWeight: '600', fontSize: 12 }}>
                    {isCompleted ? 'Review Course' : 'Resume'}
                  </Text>
                </TouchableOpacity>
              </View>
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </View>
  );
};

export default ContinueLearning;