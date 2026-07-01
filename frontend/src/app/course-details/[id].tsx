// app/course-details/[id].tsx
import React, { useMemo, useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  Image,
  Modal,
  StyleSheet,
  useWindowDimensions,
  StatusBar,
  RefreshControl,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { useLocalSearchParams, useRouter, Stack } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '@/context/themeContext';
import { useAuthStore } from '@/store/authStore';
import api from '@/lib/api';

import { CustomVideoPlayer } from '../../components/course/CustomVideoPlayer';
import { CourseCurriculum } from '../../components/course-details/CourseCurriculum';
import { CourseReviews } from '../../components/course-details/CourseReviews';
import { Lesson } from '@/types/course';

type Tab = 'overview' | 'curriculum' | 'reviews';

// API Configuration
const API_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000/api';

// API Response Types
interface ApiInstructor {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  photo?: string;
  bio?: string;
}

interface ApiCategory {
  id: string;
  name: string;
  slug: string;
}

interface ApiLesson {
  id: string;
  title: string;
  description?: string;
  duration?: string;
  videoUrl?: string;
  order: number;
  isPreview: boolean;
  isFree: boolean;
  content?: string;
  completed?: boolean;
}

interface ApiSection {
  id: string;
  title: string;
  description?: string;
  order: number;
  lessons: ApiLesson[];
  _count: {
    lessons: number;
  };
}

interface ApiCourse {
  id: string;
  title: string;
  description: string;
  thumbnail: string;
  price: number;
  originalPrice?: number;
  level: string;
  language: string;
  duration?: string;
  totalHours?: number;
  rating: number;
  studentsCount: number;
  isPublished: boolean;
  isBestseller: boolean;
  isTrending: boolean;
  status: string;
  createdAt: string;
  updatedAt: string;
  instructorId: string;
  categoryId: string;
  instructor: ApiInstructor;
  category: ApiCategory;
  sections: ApiSection[];
  _count: {
    enrollments: number;
    reviews: number;
    lessons: number;
  };
  learningObjectives?: string[];
  requirements?: string[];
  whatYouWillLearn?: string[];
}

// Enrollment Status Response
interface EnrollmentStatus {
  isEnrolled: boolean;
  progress: number;
  isCompleted: boolean;
  enrollmentId?: string;
}

// Skeleton Components
const Skeleton = ({ className = '', bgColor = '#E2E8F0' }: { className?: string; bgColor?: string }) => (
  <View className={`rounded-lg animate-pulse ${className}`} style={{ backgroundColor: bgColor }} />
);

const SkeletonText = ({ className = '', bgColor = '#E2E8F0' }: { className?: string; bgColor?: string }) => (
  <View className={`rounded h-4 ${className}`} style={{ backgroundColor: bgColor }} />
);

const SkeletonCircle = ({ size = 28, bgColor = '#E2E8F0' }: { size?: number; bgColor?: string }) => (
  <View className="rounded-full" style={{ width: size, height: size, backgroundColor: bgColor }} />
);

export default function CourseDetailsScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { width } = useWindowDimensions();
  const { isDarkMode, colors } = useTheme();
  
  // ✅ Get auth state
  const authStore = useAuthStore();
  const { 
    user, 
    token, 
    isAuthenticated,
  } = authStore;

  // State
  const [isLoading, setIsLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [courseData, setCourseData] = useState<ApiCourse | null>(null);
  const [activeTab, setActiveTab] = useState<Tab>('overview');
  const [previewVisible, setPreviewVisible] = useState(false);
  const [bookmarked, setBookmarked] = useState(false);
  
  // ✅ Enrollment state
  const [enrolled, setEnrolled] = useState(false);
  const [enrollmentLoading, setEnrollmentLoading] = useState(false);
  const [enrollmentStatus, setEnrollmentStatus] = useState<EnrollmentStatus | null>(null);
  const [isCheckingEnrollment, setIsCheckingEnrollment] = useState(true);

  // ✅ Check enrollment status on load
  const checkEnrollmentStatus = async () => {
    if (!isAuthenticated || !token || !id) {
      setIsCheckingEnrollment(false);
      return;
    }

    try {
      const response = await api.get(`/api/enroll/${id}/status`);
      
      if (response.data.success) {
        const status = response.data.data;
        setEnrollmentStatus(status);
        setEnrolled(status.isEnrolled);
      }
    } catch (error: any) {
      if (error.response?.status === 404) {
        // Course not found or not enrolled - that's fine
        setEnrolled(false);
      } else {
        console.error('❌ Failed to check enrollment status:', error);
      }
    } finally {
      setIsCheckingEnrollment(false);
    }
  };

  // Fetch course details from API
  const fetchCourseDetails = async () => {
    try {
      setIsLoading(true);
      console.log(`🌐 Fetching course details for ID: ${id}`);

      const response = await fetch(`${API_URL}/api/courses/${id}`);

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const result = await response.json();

      if (!result.success) {
        throw new Error(result.message || 'Failed to fetch course');
      }

      console.log('✅ Course loaded:', result.data.title);
      setCourseData(result.data);
    } catch (error: any) {
      console.error('❌ Failed to fetch course:', error);
      Alert.alert(
        'Error',
        error.message || 'Failed to load course details. Please try again.'
      );
    } finally {
      setIsLoading(false);
      setRefreshing(false);
    }
  };

  // ✅ Handle Enrollment
  const handleEnroll = async () => {
    if (!isAuthenticated) {
      Alert.alert(
        'Login Required',
        'Please login to enroll in this course.',
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Login', onPress: () => router.push('/(auth)/login') }
        ]
      );
      return;
    }

    if (enrolled) {
      // If already enrolled, navigate to course
      router.push(`/course/${courseData?.id}`);
      return;
    }

    try {
      setEnrollmentLoading(true);
      
      console.log(`📚 Enrolling in course: ${id}`);
      const response = await api.post(`/api/enroll/${id}`);
      
      if (response.data.success) {
        setEnrolled(true);
        setEnrollmentStatus({
          isEnrolled: true,
          progress: 0,
          isCompleted: false,
          enrollmentId: response.data.data.id,
        });
        
        Alert.alert(
          '🎉 Success!',
          'You have been successfully enrolled in this course!',
          [
            {
              text: 'Start Learning',
              onPress: () => router.push(`/course/${courseData?.id}`)
            },
            { text: 'Continue Browsing', style: 'cancel' }
          ]
        );
      }
    } catch (error: any) {
      console.error('❌ Enrollment failed:', error);
      
      let errorMessage = 'Failed to enroll. Please try again.';
      if (error.response?.status === 409) {
        errorMessage = 'You are already enrolled in this course.';
        setEnrolled(true);
      } else if (error.response?.status === 403) {
        errorMessage = 'Instructors cannot enroll in their own courses.';
      } else if (error.response?.data?.message) {
        errorMessage = error.response.data.message;
      }
      
      Alert.alert('Enrollment Failed', errorMessage);
    } finally {
      setEnrollmentLoading(false);
    }
  };

  // Initial fetch
  useEffect(() => {
    if (id) {
      fetchCourseDetails();
    }
  }, [id]);

  // Check enrollment status after course loads
  useEffect(() => {
    if (courseData && isAuthenticated) {
      checkEnrollmentStatus();
    } else {
      setIsCheckingEnrollment(false);
    }
  }, [courseData, isAuthenticated, id]);

  // Handle refresh
  const onRefresh = async () => {
    setRefreshing(true);
    await fetchCourseDetails();
    if (isAuthenticated) {
      await checkEnrollmentStatus();
    }
  };

  // Handle back navigation
  const handleBack = () => {
    try {
      if (router.canGoBack()) {
        router.back();
      } else {
        router.replace('/(tabs)' as any);
      }
    } catch (error) {
      router.replace('/' as any);
    }
  };

  // Toggle bookmark
  const toggleBookmark = () => {
    setBookmarked((prev) => !prev);
    // TODO: Implement API call to save/unsave course
  };

  // Handle primary action
  const handlePrimaryAction = () => {
    if (enrolled) {
      // Continue learning
      router.push(`/course/${courseData?.id}`);
    } else {
      // Enroll
      handleEnroll();
    }
  };

  // Helper: Get instructor full name
  const getInstructorName = (instructor: ApiInstructor) => {
    if (!instructor) return 'Unknown Instructor';
    const firstName = instructor.firstName || '';
    const lastName = instructor.lastName || '';
    return `${firstName} ${lastName}`.trim() || 'Instructor';
  };

  // Helper: Get instructor avatar
  const getInstructorAvatar = (instructor: ApiInstructor) => {
    if (!instructor) return 'https://ui-avatars.com/api/?name=Instructor&size=150&background=4F46E5&color=fff';
    const name = getInstructorName(instructor);
    return instructor.photo || 
      `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&size=150&background=4F46E5&color=fff`;
  };

  // Helper: Get total duration
  const getTotalDuration = (sections: ApiSection[]) => {
    if (!sections || sections.length === 0) return 'N/A';
    
    let totalMinutes = 0;
    sections.forEach(section => {
      section.lessons?.forEach(lesson => {
        if (lesson.duration) {
          const parts = lesson.duration.split(':');
          if (parts.length === 2) {
            totalMinutes += parseInt(parts[0]) + parseInt(parts[1]) / 60;
          } else if (parts.length === 3) {
            totalMinutes += parseInt(parts[0]) * 60 + parseInt(parts[1]) + parseInt(parts[2]) / 60;
          }
        }
      });
    });
    
    const hours = Math.floor(totalMinutes / 60);
    const minutes = Math.round(totalMinutes % 60);
    return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
  };

  // Helper: Format date
  const formatDate = (dateString: string) => {
    if (!dateString) return 'Recently';
    const d = new Date(dateString);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return `${months[d.getMonth()]} ${d.getFullYear()}`;
  };

  // Helper: Map API lessons to component lessons
  const mapLessons = (sections: ApiSection[]): Lesson[] => {
    if (!sections) return [];
    const allLessons: Lesson[] = [];
    sections.forEach(section => {
      section.lessons?.forEach(lesson => {
        allLessons.push({
          id: lesson.id,
          title: lesson.title,
          duration: lesson.duration || 'N/A',
          videoUrl: lesson.videoUrl,
          youtubeId: lesson.videoUrl,
          completed: lesson.completed || false,
          locked: false,
          isPreview: lesson.isPreview || false,
          description: lesson.description,
          content: lesson.content,
          order: lesson.order,
          isFree: lesson.isFree || false,
        });
      });
    });
    return allLessons;
  };

  // Loading Skeleton
  if (isLoading) {
    const skeletonBg = isDarkMode ? '#1E293B' : '#E2E8F0';
    return (
      <View className="flex-1" style={{ backgroundColor: colors.background }}>
        <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} translucent backgroundColor="transparent" />
        <Stack.Screen options={{ headerShown: false }} />

        <View style={{ width, height: width * 0.55, backgroundColor: '#1a1a2e' }}>
          <LinearGradient
            colors={['rgba(15,23,42,0.45)', 'transparent', 'rgba(15,23,42,0.6)']}
            style={StyleSheet.absoluteFill}
          />
          
          <View
            className="absolute left-0 right-0 flex-row items-center justify-between px-4"
            style={{ top: insets.top + 8, zIndex: 10 }}
          >
            <View className="flex-row items-center bg-black/40 px-3 py-2 rounded-full">
              <Skeleton className="w-5 h-5 rounded-full" bgColor={skeletonBg} />
              <SkeletonText className="w-12 ml-1" bgColor={skeletonBg} />
            </View>
            <SkeletonCircle size={40} bgColor={skeletonBg} />
          </View>

          <View className="absolute inset-0 items-center justify-center">
            <SkeletonCircle size={56} bgColor={skeletonBg} />
            <SkeletonText className="w-24 mt-2" bgColor={skeletonBg} />
          </View>
        </View>

        <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
          <View className="px-4 pt-4">
            <View className="flex-row items-center mb-2">
              <Skeleton className="w-16 h-5 rounded-full mr-2" bgColor={skeletonBg} />
              <Skeleton className="w-4 h-4 rounded-full" bgColor={skeletonBg} />
              <SkeletonText className="w-12 ml-1" bgColor={skeletonBg} />
              <SkeletonText className="w-16 ml-1" bgColor={skeletonBg} />
              <SkeletonText className="w-20 ml-3" bgColor={skeletonBg} />
            </View>

            <SkeletonText className="h-7 w-3/4 mb-2" bgColor={skeletonBg} />

            <View className="flex-row items-center mb-3">
              <SkeletonCircle size={28} bgColor={skeletonBg} />
              <SkeletonText className="w-32 ml-2" bgColor={skeletonBg} />
            </View>

            <View className="flex-row items-center flex-wrap mb-1">
              {[1, 2, 3].map((i) => (
                <View key={i} className="flex-row items-center mr-4 mb-2">
                  <Skeleton className="w-4 h-4 rounded-full" bgColor={skeletonBg} />
                  <SkeletonText className="w-16 ml-1.5" bgColor={skeletonBg} />
                </View>
              ))}
            </View>
          </View>

          <View className="flex-row px-4 mt-2" style={{ borderBottomWidth: 1, borderBottomColor: colors.backgroundSelected }}>
            {['overview', 'curriculum', 'reviews'].map((tab) => (
              <View key={tab} className="mr-6 py-3">
                <SkeletonText className="w-16 h-5" bgColor={skeletonBg} />
              </View>
            ))}
          </View>

          <View className="px-4 py-4">
            <SkeletonText className="h-5 w-40 mb-2" bgColor={skeletonBg} />
            {[1, 2, 3, 4].map((i) => (
              <SkeletonText key={i} className="w-full h-4 mb-1" bgColor={skeletonBg} />
            ))}
          </View>
        </ScrollView>

        <View
          className="flex-row items-center px-4 py-3 border-t"
          style={{ 
            paddingBottom: Math.max(insets.bottom, 12),
            borderTopColor: colors.backgroundSelected,
            backgroundColor: colors.backgroundElement,
          }}
        >
          <View className="mr-4">
            <SkeletonText className="h-7 w-20" bgColor={skeletonBg} />
            <SkeletonText className="h-3 w-12 mt-1" bgColor={skeletonBg} />
          </View>
          <Skeleton className="flex-1 h-14 rounded-full" bgColor={skeletonBg} />
        </View>
      </View>
    );
  }

  // Error state
  if (!courseData) {
    return (
      <View className="flex-1 items-center justify-center" style={{ backgroundColor: colors.background }}>
        <Ionicons name="book-outline" size={64} color={colors.textSecondary} />
        <Text style={{ color: colors.textSecondary, fontSize: 18, marginTop: 16 }}>Course not found</Text>
        <TouchableOpacity 
          onPress={handleBack}
          className="mt-4 px-6 py-3 rounded-lg"
          style={{ backgroundColor: colors.primary }}
        >
          <Text className="text-white font-semibold">Go Back</Text>
        </TouchableOpacity>
      </View>
    );
  }

  const instructorName = getInstructorName(courseData.instructor);
  const instructorAvatar = getInstructorAvatar(courseData.instructor);
  const totalDuration = getTotalDuration(courseData.sections);
  const lastUpdated = formatDate(courseData.updatedAt || courseData.createdAt);
  const discountPercent = courseData.originalPrice
    ? Math.round((1 - courseData.price / courseData.originalPrice) * 100)
    : 0;
  const lessons = mapLessons(courseData.sections);

  // Determine button text and state
  const getButtonText = () => {
    if (enrollmentLoading) return 'Enrolling...';
    if (enrolled) return 'Continue Learning';
    if (isCheckingEnrollment) return 'Checking...';
    return 'Enroll Now';
  };

  const isButtonDisabled = enrollmentLoading || isCheckingEnrollment;

  return (
    <View className="flex-1" style={{ backgroundColor: colors.background }}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} translucent backgroundColor="transparent" />
      <Stack.Screen options={{ headerShown: false }} />

      <ScrollView 
        className="flex-1" 
        contentContainerStyle={{ paddingBottom: 24 }}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.primary} />
        }
      >
        {/* Hero */}
        <View style={{ width, height: width * 0.55, backgroundColor: '#000' }}>
          <Image
            source={{ uri: courseData.thumbnail || 'https://picsum.photos/seed/default/800/600' }}
            style={StyleSheet.absoluteFill}
            resizeMode="cover"
          />
          <LinearGradient
            colors={['rgba(15,23,42,0.45)', 'transparent', 'rgba(15,23,42,0.6)']}
            style={StyleSheet.absoluteFill}
          />

          <View
            className="absolute left-0 right-0 flex-row items-center justify-between px-4"
            style={{ top: insets.top + 8, zIndex: 10 }}
          >
            <TouchableOpacity
              onPress={handleBack}
              className="flex-row items-center bg-black/40 backdrop-blur-sm px-3 py-2 rounded-full"
              activeOpacity={0.7}
            >
              <Ionicons name="chevron-back" size={20} color="#FFFFFF" />
              <Text className="text-white text-sm font-medium ml-1">Back</Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={toggleBookmark}
              className="bg-black/40 backdrop-blur-sm w-10 h-10 rounded-full items-center justify-center"
              activeOpacity={0.7}
            >
              <Ionicons
                name={bookmarked ? 'bookmark' : 'bookmark-outline'}
                size={20}
                color="#FFFFFF"
              />
            </TouchableOpacity>
          </View>

          <View className="absolute inset-0 items-center justify-center">
            <TouchableOpacity
              onPress={() => setPreviewVisible(true)}
              className="w-14 h-14 rounded-full items-center justify-center mb-2"
              style={{ backgroundColor: isDarkMode ? 'rgba(96,165,250,0.9)' : 'rgba(255,255,255,0.9)' }}
              activeOpacity={0.85}
            >
              <Ionicons 
                name="play" 
                size={26} 
                color={isDarkMode ? '#FFFFFF' : '#0F172A'} 
              />
            </TouchableOpacity>
            <Text className="text-white text-xs font-semibold">Watch Preview</Text>
          </View>
        </View>

        {/* Title + meta */}
        <View className="px-4 pt-4">
          <View className="flex-row items-center flex-wrap mb-2">
            <View className="px-2.5 py-1 rounded-full mr-2" style={{ backgroundColor: isDarkMode ? '#1E3A5F' : '#EFF6FF' }}>
              <Text className="text-[11px] font-semibold" style={{ color: colors.primary }}>
                {courseData.level || 'Beginner'}
              </Text>
            </View>
            <Ionicons name="star" size={14} color="#F59E0B" />
            <Text style={{ color: colors.text, fontSize: 12, fontWeight: '600', marginLeft: 4 }}>
              {courseData.rating?.toFixed(1) || '0.0'}
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 4 }}>
              ({courseData._count?.reviews || 0})
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 12 }}>
              {courseData.studentsCount || 0} students
            </Text>
          </View>

          <Text style={{ color: colors.text, fontSize: 20, fontWeight: 'bold', marginBottom: 8 }}>
            {courseData.title}
          </Text>

          <TouchableOpacity className="flex-row items-center mb-3">
            <Image
              source={{ uri: instructorAvatar }}
              className="w-7 h-7 rounded-full mr-2"
            />
            <Text style={{ color: colors.textSecondary, fontSize: 14 }}>
              Created by <Text style={{ fontWeight: '600', color: colors.text }}>{instructorName}</Text>
            </Text>
          </TouchableOpacity>

          <View className="flex-row items-center flex-wrap mb-1">
            <View className="flex-row items-center mr-4 mb-2">
              <Ionicons name="time-outline" size={14} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 6 }}>
                {totalDuration}
              </Text>
            </View>
            <View className="flex-row items-center mr-4 mb-2">
              <Ionicons name="globe-outline" size={14} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 6 }}>
                {courseData.language || 'English'}
              </Text>
            </View>
            <View className="flex-row items-center mb-2">
              <Ionicons name="calendar-outline" size={14} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 6 }}>
                Updated {lastUpdated}
              </Text>
            </View>
          </View>
        </View>

        {/* Tabs */}
        <View className="flex-row px-4 mt-2" style={{ borderBottomWidth: 1, borderBottomColor: colors.backgroundSelected }}>
          {(['overview', 'curriculum', 'reviews'] as Tab[]).map((tab) => (
            <TouchableOpacity
              key={tab}
              onPress={() => setActiveTab(tab)}
              className={`mr-6 py-3 border-b-2 ${
                activeTab === tab ? 'border-[#2563EB]' : 'border-transparent'
              }`}
            >
              <Text
                className={`text-sm font-semibold capitalize ${
                  activeTab === tab ? 'text-[#2563EB]' : 'text-[#64748B]'
                }`}
              >
                {tab}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {activeTab === 'overview' && (
          <View className="px-4 py-4">
            <Text style={{ color: colors.text, fontSize: 14, fontWeight: 'bold', marginBottom: 8 }}>
              About this course
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 14, lineHeight: 20, marginBottom: 20 }}>
              {courseData.description || 'No description available.'}
            </Text>

            <Text style={{ color: colors.text, fontSize: 14, fontWeight: 'bold', marginBottom: 8 }}>
              What you'll learn
            </Text>
            {courseData.whatYouWillLearn && courseData.whatYouWillLearn.length > 0 ? (
              courseData.whatYouWillLearn.map((point, i) => (
                <View key={i} className="flex-row items-start mb-2">
                  <Ionicons name="checkmark-circle" size={16} color="#16A34A" style={{ marginTop: 2, marginRight: 8 }} />
                  <Text style={{ color: colors.textSecondary, fontSize: 14, flex: 1, lineHeight: 20 }}>
                    {point}
                  </Text>
                </View>
              ))
            ) : (
              <Text style={{ color: colors.textSecondary, fontSize: 14 }}>
                No learning objectives listed.
              </Text>
            )}

            <Text style={{ color: colors.text, fontSize: 14, fontWeight: 'bold', marginTop: 16, marginBottom: 8 }}>
              Requirements
            </Text>
            {courseData.requirements && courseData.requirements.length > 0 ? (
              courseData.requirements.map((req, i) => (
                <View key={i} className="flex-row items-start mb-2">
                  <View className="w-1.5 h-1.5 rounded-full mt-2 mr-3" style={{ backgroundColor: colors.textSecondary }} />
                  <Text style={{ color: colors.textSecondary, fontSize: 14, flex: 1, lineHeight: 20 }}>
                    {req}
                  </Text>
                </View>
              ))
            ) : (
              <Text style={{ color: colors.textSecondary, fontSize: 14 }}>
                No requirements listed.
              </Text>
            )}

            <View className="mt-5 p-3.5 rounded-2xl flex-row" style={{ backgroundColor: colors.backgroundElement }}>
              <Image source={{ uri: instructorAvatar }} className="w-12 h-12 rounded-full mr-3" />
              <View className="flex-1">
                <Text style={{ color: colors.text, fontSize: 14, fontWeight: 'bold', marginBottom: 4 }}>
                  {instructorName}
                </Text>
                <Text style={{ color: colors.textSecondary, fontSize: 12, lineHeight: 18 }}>
                  {courseData.instructor?.bio || 'Experienced instructor passionate about teaching.'}
                </Text>
              </View>
            </View>
          </View>
        )}

        {activeTab === 'curriculum' && (
          <CourseCurriculum
            sections={(courseData.sections || []).map((section) => ({
              ...section,
              lessons: (section.lessons || []).map((lesson) => ({
                ...lesson,
                duration: lesson.duration ?? '',
              })),
            }))}
            totalDurationLabel={totalDuration}
            onPreviewPress={() => setPreviewVisible(true)}
          />
        )}

        {activeTab === 'reviews' && (
          <CourseReviews
            rating={courseData.rating || 0}
            reviewsCount={courseData._count?.reviews || 0}
            reviews={[]}
          />
        )}
      </ScrollView>

      {/* ✅ Sticky enroll bar with enrollment logic */}
      <View
        className="flex-row items-center px-4 py-3 border-t"
        style={{
          paddingBottom: Math.max(insets.bottom, 12),
          borderTopColor: colors.backgroundSelected,
          backgroundColor: colors.backgroundElement,
        }}
      >
        <View className="mr-4">
          {!enrolled ? (
            <>
              <View className="flex-row items-center">
                <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold' }}>
                  ${(courseData.price || 0).toFixed(2)}
                </Text>
                {courseData.originalPrice && (
                  <Text style={{ color: colors.textSecondary, fontSize: 12, textDecorationLine: 'line-through', marginLeft: 8 }}>
                    ${courseData.originalPrice.toFixed(2)}
                  </Text>
                )}
              </View>
              {discountPercent > 0 && (
                <Text style={{ color: '#16A34A', fontSize: 12, fontWeight: '600' }}>
                  {discountPercent}% off
                </Text>
              )}
            </>
          ) : (
            <>
              <Text style={{ color: '#16A34A', fontSize: 16, fontWeight: 'bold' }}>
                ✅ Enrolled
              </Text>
              <Text style={{ color: colors.textSecondary, fontSize: 11 }}>
                {enrollmentStatus?.progress || 0}% complete
              </Text>
            </>
          )}
        </View>

        <TouchableOpacity
          onPress={handlePrimaryAction}
          disabled={isButtonDisabled}
          className="flex-1 py-3.5 rounded-full items-center"
          style={{ 
            backgroundColor: enrolled ? '#16A34A' : colors.primary,
            opacity: isButtonDisabled ? 0.7 : 1,
          }}
          activeOpacity={0.85}
        >
          {enrollmentLoading ? (
            <ActivityIndicator color="#FFFFFF" size="small" />
          ) : (
            <Text className="text-white font-bold text-sm">
              {getButtonText()}
            </Text>
          )}
        </TouchableOpacity>
      </View>

      {/* Preview modal */}
      <Modal
        visible={previewVisible}
        animationType="slide"
        onRequestClose={() => setPreviewVisible(false)}
        statusBarTranslucent
      >
        <View style={{ flex: 1, backgroundColor: '#000' }}>
          <CustomVideoPlayer
            source={{ uri: 'https://www.pexels.com/download/video/34279733/' }}
            title={`${courseData.title} — Preview`}
            topInset={insets.top}
            onBack={() => setPreviewVisible(false)}
          />
        </View>
      </Modal>
    </View>
  );
}