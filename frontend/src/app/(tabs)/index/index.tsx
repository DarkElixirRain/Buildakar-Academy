// app/(tabs)/index.tsx
import React, { useState, useEffect, useCallback } from "react";
import {
  View,
  ScrollView,
  RefreshControl,
  SafeAreaView,
  Dimensions,
  Text,
  TouchableOpacity,
} from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";
import { router } from "expo-router";
import { useAuthStore } from "@/store/authStore";
import { useHomeStore } from "@/store/homeStore";
import { useTheme } from "@/context/themeContext";
import { HomeHeader } from "@/components/home/HomeHeader";
import { SearchBar } from "@/components/home/SearchBar";
import { ContinueLearning } from "@/components/home/ContinueLearning";
import { FeaturedCourses } from "@/components/home/FeaturedCourses";
import { Categories } from "@/components/home/Categories";
import { RecommendedCourses } from "@/components/home/RecommendedCourses";
import { PopularCourses } from "@/components/home/PopularCourses";
import { LiveClasses } from "@/components/home/LiveClasses";
import { TopInstructors } from "@/components/home/TopInstructors";
import { RecentlyViewed } from "@/components/home/RecentlyViewed";
import { LoadingSkeleton } from "@/components/home/LoadingSkeleton";
import { ErrorState } from "@/components/common/ErrorState";
import { EmptyState } from "@/components/common/EmptyState";
import { homeService } from "@/services/homeService";

const { width } = Dimensions.get("window");

export default function HomeScreen() {
  const insets = useSafeAreaInsets();
  const { user } = useAuthStore();
  const { isDarkMode, colors } = useTheme();
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

  const [searchQuery, setSearchQuery] = useState("");
  const [localTopInstructors, setLocalTopInstructors] = useState<any[]>([]);
  const [localFeaturedCourses, setLocalFeaturedCourses] = useState<any[]>([]);

  useEffect(() => {
    fetchHomeData();
    loadTopInstructors();
  }, []);

  // Load top instructors separately to ensure real data
  const loadTopInstructors = async () => {
    try {
      const instructors = await homeService.getTopInstructors(10);
      setLocalTopInstructors(instructors);
    } catch (error) {
      console.error('Failed to load top instructors:', error);
    }
  };

  const onRefresh = useCallback(async () => {
    await refreshHomeData();
    await loadTopInstructors(); // Refresh instructors too
  }, [refreshHomeData]);

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    if (query.trim()) {
      router.push({
        pathname: "/(search)",
        params: { q: query },
      } as any);
    }
  };

  const handleNotificationPress = () => {
    router.push("/(notifications)" as any);
  };

  const handleContinueLearning = () => {
    router.push("/(my-learning)" as any);
  };

  const handleCoursePress = (courseId: string) => {
    router.push({
      pathname: "/course/[id]",
      params: { id: courseId },
    } as any);
  };

  const handleCourseDetailsPress = (courseId: string) => {
    router.push({
      pathname: "/course-details/[id]",
      params: { id: courseId },
    } as any);
  };

  const handleCategoryPress = (categoryId: string) => {
    const category = categories?.find((cat) => cat.id === categoryId);
    if (category) {
      const slug = category.slug || category.name.toLowerCase().replace(/\s+/g, "-");
      router.push(`/categories/${slug}` as any);
    } else {
      router.push("/categories" as any);
    }
  };

  const handleSeeAll = (section: string) => {
    if (section === "categories") {
      router.push("/categories" as any);
    } else if (section === "instructors") {
      router.push("/instructor" as any);
    } else if (section === "recommended") {
      router.push("/explore" as any);
    } else if (section === "popular") {
      router.push("/explore" as any);
    } else if (section === "live") {
      router.push("/live" as any);
    } else {
      router.push("/explore" as any);
    }
  };

  const handleLiveClassJoin = (classId: string) => {
    router.push({
      pathname: "/(live)/[id]",
      params: { id: classId },
    } as any);
  };

  const handleInstructorFollow = (instructorId: string) => {
    console.log("Following instructor:", instructorId);
    // Refresh instructors after follow/unfollow
    loadTopInstructors();
  };

  const handleAchievementPress = () => {
    router.push("/(achievements)" as any);
  };

  const handleInstructorPress = (instructorId: string) => {
    router.push(`/instructor/${instructorId}` as any);
  };

  const handlePathPress = (pathId: string) => {
    router.push({
      pathname: "/(path)/[id]",
      params: { id: pathId },
    } as any);
  };

  const statusBarStyle = isDarkMode ? 'light' : 'dark';

  // Use real instructors from local state or store
  const displayInstructors = localTopInstructors.length > 0 
    ? localTopInstructors 
    : topInstructors || [];

  if (loading && !data) {
    return <LoadingSkeleton />;
  }

  if (error) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
        <ErrorState
          message={error}
          onRetry={() => {
            clearError();
            fetchHomeData();
            loadTopInstructors();
          }}
        />
      </SafeAreaView>
    );
  }

  if (!data) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
        <HomeHeader
          notificationCount={notifications?.unread || 0}
          onNotificationPress={handleNotificationPress}
        />
        <EmptyState
          title="Start Your Learning Journey"
          description="Explore thousands of courses and start learning today"
          buttonText="Explore Courses"
          onPress={() => router.push("/explore" as any)}
        />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <StatusBar style={statusBarStyle} />

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
            tintColor={colors.text}
            colors={[colors.text]}
          />
        }
        contentContainerStyle={{
          paddingBottom: insets.bottom + 80,
        }}
      >
        <View style={{ paddingHorizontal: 16, backgroundColor: colors.background }}>
          {/* Search Bar */}
          <View style={{ marginBottom: 16 }}>
            <SearchBar
              value={searchQuery}
              onChangeText={setSearchQuery}
              onSearch={handleSearch}
            />
          </View>

          {/* Continue Learning Section */}
          {continueLearning && continueLearning.length > 0 && (
            <View style={{ marginBottom: 24 }}>
              <ContinueLearning
                courses={continueLearning}
                onCoursePress={handleCoursePress}
              />
            </View>
          )}

          {/* Featured Courses Carousel - NOW FETCHES DATA INTERNALLY */}
          <View style={{ marginBottom: 24 }}>
            <FeaturedCourses onCoursePress={handleCourseDetailsPress} />
          </View>

          {/* Categories Section */}
          {categories && categories.length > 0 && (
            <View style={{ marginBottom: 24 }}>
              <Categories
                categories={categories}
                onCategoryPress={handleCategoryPress}
                onSeeAll={() => handleSeeAll("categories")}
              />
            </View>
          )}

          {/* Recommended For You */}
          {recommendedCourses && recommendedCourses.length > 0 && (
            <View style={{ marginBottom: 24 }}>
              <RecommendedCourses
                courses={recommendedCourses}
                onCoursePress={handleCourseDetailsPress}
                onSeeAll={() => handleSeeAll("recommended")}
                onLoadMore={loadMoreRecommendations}
              />
            </View>
          )}

          {/* Popular Courses */}
          {popularCourses && popularCourses.length > 0 && (
            <View style={{ marginBottom: 24 }}>
              <PopularCourses
                courses={popularCourses}
                onCoursePress={handleCourseDetailsPress}
                onSeeAll={() => handleSeeAll("popular")}
              />
            </View>
          )}

          {/* Upcoming Live Classes */}
          {liveClasses && liveClasses.length > 0 && (
            <View style={{ marginBottom: 24 }}>
              <LiveClasses
                classes={liveClasses}
                onJoinPress={handleLiveClassJoin}
                onSeeAll={() => handleSeeAll("live")}
              />
            </View>
          )}

          {/* Top Instructors - Using real data */}
          {displayInstructors.length > 0 && (
            <View style={{ marginBottom: 24 }}>
              <TopInstructors
                onFollowPress={handleInstructorFollow}
                onInstructorPress={handleInstructorPress}
                onSeeAll={() => handleSeeAll("instructors")}
              />
            </View>
          )}

          {/* Recently Viewed */}
          {recentlyViewed && recentlyViewed.length > 0 && (
            <View style={{ marginBottom: 24 }}>
              <RecentlyViewed
                courses={recentlyViewed}
                onCoursePress={handleCoursePress}
              />
            </View>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}