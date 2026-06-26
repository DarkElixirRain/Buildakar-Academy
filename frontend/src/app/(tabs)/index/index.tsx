// app/(tabs)/index.tsx
import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  ScrollView,
  RefreshControl,
  SafeAreaView,
  Dimensions,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { router } from 'expo-router';
import { useAuthStore } from '@/store/authStore';
import { useHomeStore } from '@/store/homeStore';
import { HomeHeader } from '@/components/home/HomeHeader';
import { SearchBar } from '@/components/home/SearchBar';
import { LearningProgress } from '@/components/home/LearningProgress';
import { ContinueLearning } from '@/components/home/ContinueLearning';
import { FeaturedCourses } from '@/components/home/FeaturedCourses';
import { Categories } from '@/components/home/Categories';
import { RecommendedCourses } from '@/components/home/RecommendedCourses';
import { PopularCourses } from '@/components/home/PopularCourses';
import { LearningPaths } from '@/components/home/LearningPaths';
import { LiveClasses } from '@/components/home/LiveClasses';
import { Achievements } from '@/components/home/Achievements';
import { TopInstructors } from '@/components/home/TopInstructors';
import { RecentlyViewed } from '@/components/home/RecentlyViewed';
import { LoadingSkeleton } from '@/components/home/LoadingSkeleton';
import { ErrorState } from '@/components/common/ErrorState';
import { EmptyState } from '@/components/common/EmptyState';

const { width } = Dimensions.get('window');

export default function HomeScreen() {
  const insets = useSafeAreaInsets();
  const { user } = useAuthStore();
  const { 
    loading, 
    refreshing,
    error, 
    data,
    featuredCourses,
    recommendedCourses,
    popularCourses,
    categories,
    continueLearning,
    learningPaths,
    liveClasses,
    achievements,
    topInstructors,
    userProgress,
    notifications,
    recentlyViewed,
    fetchHomeData,
    refreshHomeData,
    loadMoreRecommendations,
    clearError,
  } = useHomeStore();

  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    fetchHomeData();
  }, []);

  const onRefresh = useCallback(async () => {
    await refreshHomeData();
  }, [refreshHomeData]);

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    if (query.trim()) {
      router.push({
        pathname: '/(search)',
        params: { q: query }
      } as any);
    }
  };

  const handleNotificationPress = () => {
    router.push('/(notifications)' as any);
  };

  const handleContinueLearning = () => {
    router.push('/(my-learning)' as any);
  };

  const handleCoursePress = (courseId: string) => {
    router.push({
      pathname: '/(course)/[id]',
      params: { id: courseId }
    } as any);
  };

  const handleCategoryPress = (categoryId: string) => {
    router.push({
      pathname: '/(categories)/[id]',
      params: { id: categoryId }
    } as any);
  };

  const handleSeeAll = (section: string) => {
    // Navigate to categories page when categories section is clicked
    if (section === 'categories') {
      router.push('/categories' as any);
    } else {
      router.push({
        pathname: '/(explore)',
        params: { section }
      } as any);
    }
  };

  const handleLiveClassJoin = (classId: string) => {
    router.push({
      pathname: '/(live)/[id]',
      params: { id: classId }
    } as any);
  };

  const handleInstructorFollow = (instructorId: string) => {
    console.log('Following instructor:', instructorId);
  };

  const handleAchievementPress = () => {
    router.push('/(achievements)' as any);
  };

  const handleInstructorPress = (instructorId: string) => {
    router.push({
      pathname: '/(instructor)/[id]',
      params: { id: instructorId }
    } as any);
  };

  const handlePathPress = (pathId: string) => {
    router.push({
      pathname: '/(path)/[id]',
      params: { id: pathId }
    } as any);
  };

  if (loading && !data) {
    return <LoadingSkeleton />;
  }

  if (error) {
    return (
      <SafeAreaView className="flex-1 bg-[#F8FAFC]">
        <ErrorState 
          message={error}
          onRetry={() => {
            clearError();
            fetchHomeData();
          }}
        />
      </SafeAreaView>
    );
  }

  if (!data || !recommendedCourses || recommendedCourses.length === 0) {
    return (
      <SafeAreaView className="flex-1 bg-[#F8FAFC]">
        <HomeHeader 
          notificationCount={notifications?.unread || 0}
          onNotificationPress={handleNotificationPress}
        />
        <EmptyState 
          title="Start Your Learning Journey"
          description="Explore thousands of courses and start learning today"
          buttonText="Explore Courses"
          onPress={() => router.push('/(explore)' as any)}
        />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView className="flex-1 bg-[#F8FAFC]">
      <StatusBar style="dark" />
      
      <HomeHeader 
        notificationCount={notifications?.unread || 0}
        onNotificationPress={handleNotificationPress}
      />

      <ScrollView
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor="#2563EB"
            colors={['#2563EB']}
          />
        }
        contentContainerStyle={{
          paddingBottom: insets.bottom + 80,
        }}
      >
        <View className="px-4 space-y-6">
          {/* Search Bar */}
          <SearchBar 
            value={searchQuery}
            onChangeText={setSearchQuery}
            onSearch={handleSearch}
          />

          

          {/* Continue Learning Section */}
          {continueLearning && continueLearning.length > 0 && (
            <ContinueLearning 
              courses={continueLearning}
              onCoursePress={handleCoursePress}
            />
          )}

          {/* Featured Courses Carousel */}
          {featuredCourses && featuredCourses.length > 0 && (
            <FeaturedCourses 
              courses={featuredCourses}
              onCoursePress={handleCoursePress}
            />
          )}

          {/* Categories Section */}
          {categories && categories.length > 0 && (
            <Categories 
              categories={categories}
              onCategoryPress={handleCategoryPress}
              onSeeAll={() => handleSeeAll('categories')}
            />
          )}

          {/* Recommended For You */}
          {recommendedCourses && recommendedCourses.length > 0 && (
            <RecommendedCourses 
              courses={recommendedCourses}
              onCoursePress={handleCoursePress}
              onSeeAll={() => handleSeeAll('recommended')}
              onLoadMore={loadMoreRecommendations}
            />
          )}

          {/* Popular Courses */}
          {popularCourses && popularCourses.length > 0 && (
            <PopularCourses 
              courses={popularCourses}
              onCoursePress={handleCoursePress}
              onSeeAll={() => handleSeeAll('popular')}
            />
          )}

          

          {/* Upcoming Live Classes */}
          {liveClasses && liveClasses.length > 0 && (
            <LiveClasses 
              classes={liveClasses}
              onJoinPress={handleLiveClassJoin}
              onSeeAll={() => handleSeeAll('live')}
            />
          )}

        

          {/* Top Instructors */}
          {topInstructors && topInstructors.length > 0 && (
            <TopInstructors 
              instructors={topInstructors}
              onFollowPress={handleInstructorFollow}
              onInstructorPress={handleInstructorPress}
              onSeeAll={() => handleSeeAll('instructors')}
            />
          )}

          {/* Recently Viewed */}
          {recentlyViewed && recentlyViewed.length > 0 && (
            <RecentlyViewed 
              courses={recentlyViewed}
              onCoursePress={handleCoursePress}
            />
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}