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
} from 'react-native';
import { useLocalSearchParams, useRouter, Stack } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '@/context/themeContext';

import { CustomVideoPlayer } from '../../components/course/CustomVideoPlayer';
import { CourseCurriculum } from '../../components/course-details/CourseCurriculum';
import { CourseReviews } from '../../components/course-details/CourseReviews';
import { getCourseById, getCoursePreviewSource } from '../../data/courseData';

type Tab = 'overview' | 'curriculum' | 'reviews';

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

  // Loading state
  const [isLoading, setIsLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  // Replace with a real fetch (React Query, SWR, your API client, etc).
  const course = useMemo(() => getCourseById(id ?? 'unknown'), [id]);

  const [activeTab, setActiveTab] = useState<Tab>('overview');
  const [previewVisible, setPreviewVisible] = useState(false);
  const [bookmarked, setBookmarked] = useState(false);
  // In a real app this comes from the user's enrollment record, not local state.
  const [enrolled, setEnrolled] = useState(false);

  // Simulate loading
  useEffect(() => {
    setIsLoading(true);
    // Simulate network delay
    const timer = setTimeout(() => {
      setIsLoading(false);
    }, 1500);
    return () => clearTimeout(timer);
  }, [id]);

  const discountPercent = course?.originalPrice
    ? Math.round((1 - course.price / course.originalPrice) * 100)
    : 0;

  // ✅ Fixed back button handler with multiple fallbacks
  const handleBack = () => {
    try {
      if (router.canGoBack()) {
        router.back();
      } else {
        // Fallback: navigate to home or previous screen
        router.replace('/(tabs)' as any);
      }
    } catch (error) {
      // Ultimate fallback
      router.replace('/' as any);
    }
  };

  // ✅ Toggle bookmark with haptic feedback (optional)
  const toggleBookmark = () => {
    setBookmarked((prev) => !prev);
  };

  const handlePrimaryAction = () => {
    if (!enrolled) {
      // Simulate enrolling — swap this for your real purchase/enroll API call.
      setEnrolled(true);
    }
    router.push(`/course/${course.id}`);
  };

  const onRefresh = async () => {
    setRefreshing(true);
    // Simulate refresh
    await new Promise(resolve => setTimeout(resolve, 1500));
    setRefreshing(false);
  };

  // Loading Skeleton
  if (isLoading) {
    const skeletonBg = isDarkMode ? '#1E293B' : '#E2E8F0';
    return (
      <View className="flex-1" style={{ backgroundColor: colors.background }}>
        <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} translucent backgroundColor="transparent" />
        <Stack.Screen options={{ headerShown: false }} />

        {/* Hero Skeleton */}
        <View style={{ width, height: width * 0.55, backgroundColor: '#1a1a2e' }}>
          <LinearGradient
            colors={['rgba(15,23,42,0.45)', 'transparent', 'rgba(15,23,42,0.6)']}
            style={StyleSheet.absoluteFill}
          />
          
          {/* Header Skeleton */}
          <View
            className="absolute left-0 right-0 flex-row items-center justify-between px-4"
            style={{ 
              top: insets.top + 8,
              zIndex: 10,
            }}
          >
            <View className="flex-row items-center bg-black/40 px-3 py-2 rounded-full">
              <Skeleton className="w-5 h-5 rounded-full" bgColor={skeletonBg} />
              <SkeletonText className="w-12 ml-1" bgColor={skeletonBg} />
            </View>
            <SkeletonCircle size={40} bgColor={skeletonBg} />
          </View>

          {/* Play Button Skeleton */}
          <View className="absolute inset-0 items-center justify-center">
            <SkeletonCircle size={56} bgColor={skeletonBg} />
            <SkeletonText className="w-24 mt-2" bgColor={skeletonBg} />
          </View>
        </View>

        {/* Content Skeleton */}
        <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
          {/* Title + meta Skeleton */}
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
              <View className="flex-row items-center mr-4 mb-2">
                <Skeleton className="w-4 h-4 rounded-full" bgColor={skeletonBg} />
                <SkeletonText className="w-20 ml-1.5" bgColor={skeletonBg} />
              </View>
              <View className="flex-row items-center mr-4 mb-2">
                <Skeleton className="w-4 h-4 rounded-full" bgColor={skeletonBg} />
                <SkeletonText className="w-16 ml-1.5" bgColor={skeletonBg} />
              </View>
              <View className="flex-row items-center mb-2">
                <Skeleton className="w-4 h-4 rounded-full" bgColor={skeletonBg} />
                <SkeletonText className="w-24 ml-1.5" bgColor={skeletonBg} />
              </View>
            </View>
          </View>

          {/* Tabs Skeleton */}
          <View className="flex-row px-4 mt-2" style={{ borderBottomWidth: 1, borderBottomColor: colors.backgroundSelected }}>
            {['overview', 'curriculum', 'reviews'].map((tab) => (
              <View key={tab} className="mr-6 py-3">
                <SkeletonText className={`w-${tab === 'overview' ? '20' : tab === 'curriculum' ? '24' : '18'} h-5`} bgColor={skeletonBg} />
              </View>
            ))}
          </View>

          {/* Overview Content Skeleton */}
          <View className="px-4 py-4">
            <SkeletonText className="h-5 w-40 mb-2" bgColor={skeletonBg} />
            <SkeletonText className="w-full h-4 mb-1" bgColor={skeletonBg} />
            <SkeletonText className="w-11/12 h-4 mb-1" bgColor={skeletonBg} />
            <SkeletonText className="w-10/12 h-4 mb-1" bgColor={skeletonBg} />
            <SkeletonText className="w-9/12 h-4 mb-4" bgColor={skeletonBg} />

            <SkeletonText className="h-5 w-36 mb-2" bgColor={skeletonBg} />
            {[1, 2, 3].map((i) => (
              <View key={i} className="flex-row items-start mb-2">
                <Skeleton className="w-4 h-4 rounded-full mt-1 mr-2" bgColor={skeletonBg} />
                <SkeletonText className="flex-1 h-4" bgColor={skeletonBg} />
              </View>
            ))}

            <SkeletonText className="h-5 w-32 mt-4 mb-2" bgColor={skeletonBg} />
            {[1, 2].map((i) => (
              <View key={i} className="flex-row items-start mb-2">
                <Skeleton className="w-1.5 h-1.5 rounded-full mt-2 mr-3" bgColor={skeletonBg} />
                <SkeletonText className="flex-1 h-4" bgColor={skeletonBg} />
              </View>
            ))}

            <View className="mt-5 p-3.5 rounded-2xl flex-row" style={{ backgroundColor: colors.backgroundElement }}>
              <SkeletonCircle size={48} bgColor={skeletonBg} />
              <View className="flex-1 ml-3">
                <SkeletonText className="h-5 w-32 mb-1" bgColor={skeletonBg} />
                <SkeletonText className="w-full h-3 mb-0.5" bgColor={skeletonBg} />
                <SkeletonText className="w-10/12 h-3" bgColor={skeletonBg} />
              </View>
            </View>
          </View>
        </ScrollView>

        {/* Sticky enroll bar Skeleton */}
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

  // ✅ Handle case where course doesn't exist
  if (!course || !course.id) {
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
            source={{ uri: course.thumbnail }}
            style={StyleSheet.absoluteFill}
            resizeMode="cover"
          />
          <LinearGradient
            colors={['rgba(15,23,42,0.45)', 'transparent', 'rgba(15,23,42,0.6)']}
            style={StyleSheet.absoluteFill}
          />

          {/* ✅ Custom Header */}
          <View
            className="absolute left-0 right-0 flex-row items-center justify-between px-4"
            style={{ 
              top: insets.top + 8,
              zIndex: 10,
            }}
          >
            {/* Back Button with label */}
            <TouchableOpacity
              onPress={handleBack}
              className="flex-row items-center bg-black/40 backdrop-blur-sm px-3 py-2 rounded-full"
              activeOpacity={0.7}
              hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
            >
              <Ionicons name="chevron-back" size={20} color="#FFFFFF" />
              <Text className="text-white text-sm font-medium ml-1">Back</Text>
            </TouchableOpacity>

            {/* Bookmark Button */}
            <TouchableOpacity
              onPress={toggleBookmark}
              className="bg-black/40 backdrop-blur-sm w-10 h-10 rounded-full items-center justify-center"
              activeOpacity={0.7}
              hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
            >
              <Ionicons
                name={bookmarked ? 'bookmark' : 'bookmark-outline'}
                size={20}
                color="#FFFFFF"
              />
            </TouchableOpacity>
          </View>

          {/* Play Button */}
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
          <View className="flex-row items-center mb-2">
            <View className="px-2.5 py-1 rounded-full mr-2" style={{ backgroundColor: isDarkMode ? '#1E3A5F' : '#EFF6FF' }}>
              <Text className="text-[11px] font-semibold" style={{ color: colors.primary }}>
                {course.level}
              </Text>
            </View>
            <Ionicons name="star" size={14} color="#F59E0B" />
            <Text style={{ color: colors.text, fontSize: 12, fontWeight: '600', marginLeft: 4 }}>
              {course.rating.toFixed(1)}
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 4 }}>
              ({course.reviewsCount.toLocaleString()})
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 12 }}>
              {course.studentsCount.toLocaleString()} students
            </Text>
          </View>

          <Text style={{ color: colors.text, fontSize: 20, fontWeight: 'bold', marginBottom: 8 }}>
            {course.title}
          </Text>

          <TouchableOpacity className="flex-row items-center mb-3">
            <Image
              source={{ uri: course.instructorAvatar }}
              className="w-7 h-7 rounded-full mr-2"
            />
            <Text style={{ color: colors.textSecondary, fontSize: 14 }}>
              Created by <Text style={{ fontWeight: '600', color: colors.text }}>{course.instructor}</Text>
            </Text>
          </TouchableOpacity>

          <View className="flex-row items-center flex-wrap mb-1">
            <View className="flex-row items-center mr-4 mb-2">
              <Ionicons name="time-outline" size={14} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 6 }}>
                {course.totalDurationLabel}
              </Text>
            </View>
            <View className="flex-row items-center mr-4 mb-2">
              <Ionicons name="globe-outline" size={14} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 6 }}>
                {course.language}
              </Text>
            </View>
            <View className="flex-row items-center mb-2">
              <Ionicons name="calendar-outline" size={14} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 6 }}>
                Updated {course.lastUpdated}
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
              {course.description}
            </Text>

            <Text style={{ color: colors.text, fontSize: 14, fontWeight: 'bold', marginBottom: 8 }}>
              What you'll learn
            </Text>
            {course.whatYouWillLearn.map((point, i) => (
              <View key={i} className="flex-row items-start mb-2">
                <Ionicons
                  name="checkmark-circle"
                  size={16}
                  color="#16A34A"
                  style={{ marginTop: 2, marginRight: 8 }}
                />
                <Text style={{ color: colors.textSecondary, fontSize: 14, flex: 1, lineHeight: 20 }}>
                  {point}
                </Text>
              </View>
            ))}

            <Text style={{ color: colors.text, fontSize: 14, fontWeight: 'bold', marginTop: 16, marginBottom: 8 }}>
              Requirements
            </Text>
            {course.requirements.map((req, i) => (
              <View key={i} className="flex-row items-start mb-2">
                <View className="w-1.5 h-1.5 rounded-full mt-2 mr-3" style={{ backgroundColor: colors.textSecondary }} />
                <Text style={{ color: colors.textSecondary, fontSize: 14, flex: 1, lineHeight: 20 }}>
                  {req}
                </Text>
              </View>
            ))}

            <View className="mt-5 p-3.5 rounded-2xl flex-row" style={{ backgroundColor: colors.backgroundElement }}>
              <Image
                source={{ uri: course.instructorAvatar }}
                className="w-12 h-12 rounded-full mr-3"
              />
              <View className="flex-1">
                <Text style={{ color: colors.text, fontSize: 14, fontWeight: 'bold', marginBottom: 4 }}>
                  {course.instructor}
                </Text>
                <Text style={{ color: colors.textSecondary, fontSize: 12, lineHeight: 18 }}>
                  {course.instructorBio}
                </Text>
              </View>
            </View>
          </View>
        )}

        {activeTab === 'curriculum' && (
          <CourseCurriculum
            lessons={course.lessons}
            totalDurationLabel={course.totalDurationLabel}
            onPreviewPress={() => setPreviewVisible(true)}
          />
        )}

        {activeTab === 'reviews' && (
          <CourseReviews
            rating={course.rating}
            reviewsCount={course.reviewsCount}
            breakdown={course.ratingBreakdown}
            reviews={course.reviews}
          />
        )}
      </ScrollView>

      {/* Sticky enroll bar */}
      <View
        className="flex-row items-center px-4 py-3 border-t"
        style={{
          paddingBottom: Math.max(insets.bottom, 12),
          borderTopColor: colors.backgroundSelected,
          backgroundColor: colors.backgroundElement,
        }}
      >
        <View className="mr-4">
          <View className="flex-row items-center">
            <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold' }}>
              ${course.price.toFixed(2)}
            </Text>
            {course.originalPrice && (
              <Text style={{ color: colors.textSecondary, fontSize: 12, textDecorationLine: 'line-through', marginLeft: 8 }}>
                ${course.originalPrice.toFixed(2)}
              </Text>
            )}
          </View>
          {discountPercent > 0 && (
            <Text style={{ color: '#16A34A', fontSize: 12, fontWeight: '600' }}>
              {discountPercent}% off
            </Text>
          )}
        </View>

        <TouchableOpacity
          onPress={handlePrimaryAction}
          className="flex-1 py-3.5 rounded-full items-center"
          style={{ backgroundColor: colors.primary }}
          activeOpacity={0.85}
        >
          <Text className="text-white font-bold text-sm">
            {enrolled ? 'Continue Learning' : 'Enroll Now'}
          </Text>
        </TouchableOpacity>
      </View>

      {/* Preview trailer modal */}
      <Modal
        visible={previewVisible}
        animationType="slide"
        onRequestClose={() => setPreviewVisible(false)}
        statusBarTranslucent
      >
        <View style={{ flex: 1, backgroundColor: '#000' }}>
          <CustomVideoPlayer
            source={getCoursePreviewSource(course.id)}
            title={`${course.title} — Preview`}
            topInset={insets.top}
            onBack={() => setPreviewVisible(false)}
          />
        </View>
      </Modal>
    </View>
  );
}