// app/categories/[id].tsx
import React, { useState, useEffect, useCallback } from "react";
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
} from "react-native";
import { router, useLocalSearchParams } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";
import { LinearGradient } from "expo-linear-gradient";
import { useTheme } from "@/context/themeContext";

const { width } = Dimensions.get("window");

// API Configuration
const API_URL = process.env.EXPO_PUBLIC_API_URL || "http://localhost:3000/api";

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

// Skeleton Components
const Skeleton = ({
  className = "",
  bgColor = "#E2E8F0",
}: {
  className?: string;
  bgColor?: string;
}) => (
  <View
    className={`rounded-lg animate-pulse ${className}`}
    style={{ backgroundColor: bgColor }}
  />
);

const SkeletonText = ({
  className = "",
  bgColor = "#E2E8F0",
}: {
  className?: string;
  bgColor?: string;
}) => (
  <View
    className={`rounded h-4 ${className}`}
    style={{ backgroundColor: bgColor }}
  />
);

const SkeletonCircle = ({
  size = 28,
  bgColor = "#E2E8F0",
}: {
  size?: number;
  bgColor?: string;
}) => (
  <View
    className="rounded-full"
    style={{ width: size, height: size, backgroundColor: bgColor }}
  />
);

export default function CategoryDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const insets = useSafeAreaInsets();
  const { isDarkMode, colors } = useTheme();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [category, setCategory] = useState<CategoryDetail | null>(null);
  const [sortBy, setSortBy] = useState<"popular" | "newest" | "rating">(
    "popular",
  );

  useEffect(() => {
    if (id) {
      fetchCategoryDetail();
    }
  }, [id, sortBy]);

  const fetchCategoryDetail = async () => {
    try {
      setLoading(true);

      console.log("🌐 Fetching category details for slug:", id);

      // ✅ Use the correct API endpoint with /api prefix
      const response = await fetch(
        `http://localhost:3000/api/categories/slug/${id}?includeCourses=true&sortBy=${sortBy}`,
      );

      // Or use the API_URL constant
      // const API_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000/api';
      // const response = await fetch(`${API_URL}/categories/slug/${id}?includeCourses=true&sortBy=${sortBy}`);

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const result = await response.json();
      console.log("📥 API Response:", JSON.stringify(result, null, 2));

      if (!result.success) {
        throw new Error(result.message || "Failed to fetch category");
      }

      const categoryData = result.data;

      const transformedCategory: CategoryDetail = {
        id: categoryData.id,
        name: categoryData.name,
        description:
          categoryData.description ||
          `Learn ${categoryData.name} with top-rated courses from industry experts.`,
        image:
          categoryData.image ||
          "https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&h=400&fit=crop",
        color: categoryData.color || "#2563EB",
        courseCount:
          categoryData.stats?.totalCourses ||
          categoryData._count?.courses ||
          categoryData.courses?.length ||
          0,
        courses:
          categoryData.courses?.map((course: any) => ({
            id: course.id,
            title: course.title,
            instructor:
              `${course.instructor?.firstName || ""} ${
                course.instructor?.lastName || ""
              }`.trim() || "Unknown Instructor",
            thumbnail:
              course.thumbnail || "https://picsum.photos/seed/default/400/300",
            rating: course.rating || 0,
            students: course.studentsCount || 0,
            price: course.price || 0,
            level: course.level || "Beginner",
            duration: course.duration || "N/A",
          })) || [],
      };

      console.log(
        `✅ Category loaded: ${transformedCategory.name}, ${transformedCategory.courses.length} courses`,
      );

      setCategory(transformedCategory);
    } catch (error: any) {
      console.error("❌ Failed to fetch category:", error);
      Alert.alert(
        "Error",
        error.message || "Failed to load category details. Please try again.",
      );
      router.back();
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

  const handleSortChange = (newSort: "popular" | "newest" | "rating") => {
    setSortBy(newSort);
  };

  const getSortedCourses = () => {
    if (!category) return [];
    return category.courses;
  };

  const renderCourseItem = ({
    item,
    index,
  }: {
    item: Course;
    index: number;
  }) => {
    return (
      <TouchableOpacity
        className="mb-4 rounded-2xl border overflow-hidden"
        style={{
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
        <View className="relative">
          <Image
            source={{ uri: item.thumbnail }}
            className="w-full h-48"
            resizeMode="cover"
          />
          <LinearGradient
            colors={["transparent", "rgba(0,0,0,0.4)"]}
            className="absolute inset-0"
          />
          {item.level && (
            <View className="absolute top-3 right-3 bg-black/60 px-3 py-1 rounded-full">
              <Text className="text-white text-[10px] font-semibold">
                {item.level}
              </Text>
            </View>
          )}
          {item.price && item.price > 0 && (
            <View className="absolute bottom-3 left-3 bg-white/90 px-3 py-1 rounded-full">
              <Text
                className="font-bold text-sm"
                style={{ color: colors.text }}
              >
                ${item.price.toFixed(2)}
              </Text>
            </View>
          )}
          {item.duration && (
            <View className="absolute bottom-3 right-3 bg-black/60 px-3 py-1 rounded-full flex-row items-center">
              <Ionicons name="time-outline" size={12} color="#FFFFFF" />
              <Text className="text-white text-[10px] font-medium ml-1">
                {item.duration}
              </Text>
            </View>
          )}
        </View>

        <View className="p-4">
          <Text
            className="font-semibold text-base"
            style={{ color: colors.text }}
            numberOfLines={1}
          >
            {item.title}
          </Text>
          <Text
            className="text-sm mt-0.5"
            style={{ color: colors.textSecondary }}
          >
            {item.instructor}
          </Text>
          <View className="flex-row items-center mt-2">
            <View className="flex-row items-center">
              <Ionicons name="star" size={16} color="#FBBF24" />
              <Text
                className="font-medium text-sm ml-1"
                style={{ color: colors.text }}
              >
                {item.rating.toFixed(1)}
              </Text>
            </View>
            <View
              className="w-px h-4 mx-2"
              style={{ backgroundColor: colors.backgroundSelected }}
            />
            <Text className="text-sm" style={{ color: colors.textSecondary }}>
              {item.students.toLocaleString()} students
            </Text>
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  // Loading Skeleton
  if (loading) {
    const skeletonBg = isDarkMode ? "#1E293B" : "#E2E8F0";
    return (
      <SafeAreaView
        className="flex-1"
        style={{ backgroundColor: colors.background }}
      >
        <StatusBar style={isDarkMode ? "light" : "dark"} />

        <View
          className="flex-row items-center px-4 py-3 border-b"
          style={{
            backgroundColor: colors.backgroundElement,
            borderBottomColor: colors.backgroundSelected,
          }}
        >
          <SkeletonCircle size={40} bgColor={skeletonBg} />
          <SkeletonText className="w-32 h-6 ml-2" bgColor={skeletonBg} />
          <SkeletonText className="w-20 h-5 ml-auto" bgColor={skeletonBg} />
        </View>

        <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
          <View className="px-4 pt-4">
            <Skeleton
              className="w-full h-48 rounded-2xl"
              bgColor={skeletonBg}
            />
            <SkeletonText className="w-full h-4 mt-3" bgColor={skeletonBg} />
            <SkeletonText className="w-11/12 h-4 mt-1" bgColor={skeletonBg} />
          </View>

          <View className="flex-row px-4 mt-4">
            {[1, 2, 3].map((i) => (
              <Skeleton
                key={i}
                className="w-20 h-9 rounded-full mr-3"
                bgColor={skeletonBg}
              />
            ))}
          </View>

          <View className="px-4 pt-4">
            {[1, 2, 3].map((i) => (
              <View
                key={i}
                className="rounded-2xl mb-4 border overflow-hidden"
                style={{
                  backgroundColor: colors.backgroundElement,
                  borderColor: colors.backgroundSelected,
                }}
              >
                <Skeleton className="w-full h-48" bgColor={skeletonBg} />
                <View className="p-4">
                  <SkeletonText className="w-3/4 h-5" bgColor={skeletonBg} />
                  <SkeletonText
                    className="w-1/2 h-4 mt-1"
                    bgColor={skeletonBg}
                  />
                  <View className="flex-row items-center mt-2">
                    <Skeleton className="w-16 h-4" bgColor={skeletonBg} />
                    <Skeleton className="w-px h-4 mx-2" bgColor={skeletonBg} />
                    <Skeleton className="w-24 h-4" bgColor={skeletonBg} />
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
      <SafeAreaView
        className="flex-1 items-center justify-center p-4"
        style={{ backgroundColor: colors.background }}
      >
        <StatusBar style={isDarkMode ? "light" : "dark"} />
        <View
          className="w-24 h-24 rounded-full items-center justify-center mb-4"
          style={{ backgroundColor: colors.backgroundSelected }}
        >
          <Ionicons name="alert-circle-outline" size={48} color="#EF4444" />
        </View>
        <Text className="text-xl font-bold" style={{ color: colors.text }}>
          Category Not Found
        </Text>
        <Text
          className="text-center mt-1 px-8"
          style={{ color: colors.textSecondary }}
        >
          The category you're looking for doesn't exist or has been removed
        </Text>
        <TouchableOpacity
          className="mt-6 px-8 py-3 rounded-xl"
          style={{ backgroundColor: colors.primary }}
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
    <SafeAreaView
      className="flex-1"
      style={{ backgroundColor: colors.background }}
    >
      <StatusBar style={isDarkMode ? "light" : "dark"} />

      <View
        className="flex-row items-center px-4 py-3 border-b"
        style={{
          backgroundColor: colors.backgroundElement,
          borderBottomColor: colors.backgroundSelected,
        }}
      >
        <TouchableOpacity
          onPress={handleBack}
          className="w-10 h-10 rounded-full items-center justify-center"
          style={{ backgroundColor: colors.backgroundSelected }}
          activeOpacity={0.7}
        >
          <Ionicons name="chevron-back" size={24} color={colors.text} />
        </TouchableOpacity>
        <Text
          className="text-lg font-bold ml-2 flex-1"
          style={{ color: colors.text }}
          numberOfLines={1}
        >
          {category.name}
        </Text>
        <View className="flex-row items-center">
          <Text
            className="text-sm mr-2"
            style={{ color: colors.textSecondary }}
          >
            {category.courseCount}
          </Text>
          <Ionicons
            name="bookmark-outline"
            size={20}
            color={colors.textSecondary}
          />
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
            tintColor={colors.primary}
            colors={[colors.primary]}
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
                  colors={["transparent", "rgba(0,0,0,0.6)"]}
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
                { key: "popular", label: "⭐ Popular" },
                { key: "rating", label: "📈 Top Rated" },
                { key: "newest", label: "🆕 Newest" },
              ].map((option) => (
                <TouchableOpacity
                  key={option.key}
                  onPress={() => handleSortChange(option.key as any)}
                  className={`px-4 py-2 rounded-full mr-3 ${
                    sortBy === option.key ? "" : "border"
                  }`}
                  style={{
                    backgroundColor:
                      sortBy === option.key
                        ? colors.primary
                        : colors.backgroundElement,
                    borderColor: colors.backgroundSelected,
                  }}
                  activeOpacity={0.7}
                >
                  <Text
                    className={`text-sm font-medium ${
                      sortBy === option.key ? "text-white" : "text-[#64748B]"
                    }`}
                  >
                    {option.label}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            {/* Results count */}
            <View className="flex-row items-center justify-between px-4 pt-4 pb-2">
              <Text className="text-sm" style={{ color: colors.textSecondary }}>
                {sortedCourses.length} courses found
              </Text>
              <Text className="text-xs" style={{ color: colors.textSecondary }}>
                Showing {Math.min(sortedCourses.length, 10)} of{" "}
                {category.courseCount}
              </Text>
            </View>
          </View>
        }
        ListEmptyComponent={
          <View className="items-center py-12">
            <View
              className="w-24 h-24 rounded-full items-center justify-center mb-4"
              style={{ backgroundColor: colors.backgroundSelected }}
            >
              <Ionicons
                name="book-outline"
                size={48}
                color={colors.textSecondary}
              />
            </View>
            <Text className="text-lg font-bold" style={{ color: colors.text }}>
              No Courses Available
            </Text>
            <Text
              className="text-center mt-1 px-8"
              style={{ color: colors.textSecondary }}
            >
              No courses available in this category yet. Check back later!
            </Text>
          </View>
        }
      />
    </SafeAreaView>
  );
}
