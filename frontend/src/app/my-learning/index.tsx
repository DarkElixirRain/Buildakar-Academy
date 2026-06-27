// app/my-learning.tsx
import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  Image,
  SafeAreaView,
  RefreshControl,
  Dimensions,
  FlatList,
  TextInput,
} from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { LinearGradient } from 'expo-linear-gradient';

const { width } = Dimensions.get('window');

interface LearningCourse {
  id: string;
  title: string;
  instructor: string;
  thumbnail: string;
  progress: number;
  remainingTime: string;
  lastAccessed: string;
  category: string;
  totalLessons: number;
  completedLessons: number;
  certificate?: boolean;
}

interface LearningStats {
  totalCourses: number;
  totalHours: number;
  certificates: number;
  streak: number;
}

// Skeleton Components
const Skeleton = ({ className = '' }: { className?: string }) => (
  <View className={`bg-[#E2E8F0] rounded-lg animate-pulse ${className}`} />
);

const SkeletonText = ({ className = '' }: { className?: string }) => (
  <View className={`bg-[#E2E8F0] rounded h-4 ${className}`} />
);

const SkeletonCircle = ({ size = 28 }: { size?: number }) => (
  <View className="bg-[#E2E8F0] rounded-full" style={{ width: size, height: size }} />
);

export default function MyLearningScreen() {
  const insets = useSafeAreaInsets();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [courses, setCourses] = useState<LearningCourse[]>([]);
  const [stats, setStats] = useState<LearningStats | null>(null);
  const [activeFilter, setActiveFilter] = useState<'all' | 'in-progress' | 'completed'>('all');
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    fetchLearningData();
  }, []);

  const fetchLearningData = async () => {
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const mockStats: LearningStats = {
        totalCourses: 8,
        totalHours: 42,
        certificates: 3,
        streak: 15,
      };

      const mockCourses: LearningCourse[] = [
        {
          id: '1',
          title: 'The Complete React Native Course',
          instructor: 'John Doe',
          thumbnail: 'https://picsum.photos/seed/react/400/300',
          progress: 75,
          remainingTime: '3h 20m',
          lastAccessed: '2 hours ago',
          category: 'Development',
          totalLessons: 45,
          completedLessons: 34,
          certificate: true,
        },
        {
          id: '2',
          title: 'JavaScript: The Advanced Concepts',
          instructor: 'Sarah Chen',
          thumbnail: 'https://picsum.photos/seed/js/400/300',
          progress: 45,
          remainingTime: '4h 15m',
          lastAccessed: 'Yesterday',
          category: 'Development',
          totalLessons: 30,
          completedLessons: 14,
        },
        {
          id: '3',
          title: 'Python for Data Science',
          instructor: 'Bob Wilson',
          thumbnail: 'https://picsum.photos/seed/python/400/300',
          progress: 100,
          remainingTime: 'Completed',
          lastAccessed: '3 days ago',
          category: 'Data Science',
          totalLessons: 28,
          completedLessons: 28,
          certificate: true,
        },
        {
          id: '4',
          title: 'UI/UX Design Masterclass',
          instructor: 'Emily Davis',
          thumbnail: 'https://picsum.photos/seed/uiux/400/300',
          progress: 20,
          remainingTime: '8h 30m',
          lastAccessed: '5 days ago',
          category: 'Design',
          totalLessons: 40,
          completedLessons: 8,
        },
        {
          id: '5',
          title: 'Machine Learning A-Z',
          instructor: 'Alex Johnson',
          thumbnail: 'https://picsum.photos/seed/ml/400/300',
          progress: 60,
          remainingTime: '5h 45m',
          lastAccessed: '1 week ago',
          category: 'AI',
          totalLessons: 50,
          completedLessons: 30,
          certificate: true,
        },
        {
          id: '6',
          title: 'Digital Marketing Mastery',
          instructor: 'Mike Brown',
          thumbnail: 'https://picsum.photos/seed/marketing/400/300',
          progress: 10,
          remainingTime: '9h 20m',
          lastAccessed: '2 weeks ago',
          category: 'Marketing',
          totalLessons: 35,
          completedLessons: 4,
        },
      ];

      setStats(mockStats);
      setCourses(mockCourses);
      setLoading(false);
    } catch (error) {
      console.error('Failed to fetch learning data:', error);
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchLearningData();
    setRefreshing(false);
  };

  const handleCoursePress = (courseId: string) => {
    router.push(`/course/${courseId}` as any);
  };

  const handleBack = () => {
    router.back();
  };

  const getFilteredCourses = () => {
    let filtered = courses;
    
    // Apply filter
    if (activeFilter === 'in-progress') {
      filtered = filtered.filter(c => c.progress < 100 && c.progress > 0);
    } else if (activeFilter === 'completed') {
      filtered = filtered.filter(c => c.progress === 100);
    }
    
    // Apply search
    if (searchQuery) {
      filtered = filtered.filter(c => 
        c.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        c.instructor.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }
    
    return filtered;
  };

  const renderCourseItem = ({ item }: { item: LearningCourse }) => {
    const isCompleted = item.progress === 100;
    
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
        <View className="flex-row">
          {/* Thumbnail */}
          <View className="relative w-32 h-32">
            <Image
              source={{ uri: item.thumbnail }}
              className="w-full h-full"
              resizeMode="cover"
            />
            {isCompleted && (
              <View className="absolute inset-0 bg-black/50 items-center justify-center">
                <Ionicons name="checkmark-circle" size={40} color="#16A34A" />
                <Text className="text-white text-xs font-semibold mt-1">Completed</Text>
              </View>
            )}
            <LinearGradient
              colors={['transparent', 'rgba(0,0,0,0.3)']}
              className="absolute inset-0"
            />
            <View className="absolute bottom-2 left-2 right-2">
              <View className="w-full h-1.5 bg-white/30 rounded-full overflow-hidden">
                <View 
                  className="h-full bg-white rounded-full"
                  style={{ width: `${item.progress}%` }}
                />
              </View>
            </View>
          </View>

          {/* Content */}
          <View className="flex-1 p-3">
            <View className="flex-row items-start justify-between">
              <View className="flex-1">
                <Text className="text-[#0F172A] font-semibold text-sm" numberOfLines={1}>
                  {item.title}
                </Text>
                <Text className="text-[#64748B] text-xs mt-0.5" numberOfLines={1}>
                  {item.instructor}
                </Text>
              </View>
              {item.certificate && (
                <View className="bg-[#FEF3C7] px-2 py-0.5 rounded-full ml-2">
                  <Text className="text-[#F59E0B] text-[8px] font-bold">CERT</Text>
                </View>
              )}
            </View>

            <View className="flex-row items-center mt-1.5">
              <View className="bg-[#EFF6FF] px-2 py-0.5 rounded-full">
                <Text className="text-[#2563EB] text-[10px] font-medium">
                  {item.category}
                </Text>
              </View>
              <View className="w-px h-3 bg-[#E2E8F0] mx-2" />
              <Text className="text-[#94A3B8] text-[10px]">
                {item.completedLessons}/{item.totalLessons} lessons
              </Text>
            </View>

            <View className="flex-row items-center justify-between mt-2">
              <View className="flex-row items-center">
                <Ionicons name="time-outline" size={12} color="#94A3B8" />
                <Text className="text-[#94A3B8] text-[10px] ml-1">
                  {isCompleted ? 'Completed' : item.remainingTime} left
                </Text>
              </View>
              <View className="flex-row items-center">
                <Ionicons name="calendar-outline" size={12} color="#94A3B8" />
                <Text className="text-[#94A3B8] text-[10px] ml-1">
                  {item.lastAccessed}
                </Text>
              </View>
            </View>

            <TouchableOpacity 
              className={`mt-2 py-1.5 rounded-full ${isCompleted ? 'bg-[#16A34A]' : 'bg-[#2563EB]'}`}
              onPress={(e) => {
                e.stopPropagation();
                handleCoursePress(item.id);
              }}
              activeOpacity={0.7}
            >
              <Text className="text-white text-center text-xs font-semibold">
                {isCompleted ? 'View Certificate' : 'Continue Learning'}
              </Text>
            </TouchableOpacity>
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
          <SkeletonText className="w-8 h-8 rounded-full ml-auto" />
        </View>

        <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
          {/* Stats Skeleton */}
          <View className="flex-row px-4 pt-4 gap-3">
            {[1, 2, 3, 4].map((i) => (
              <View key={i} className="flex-1 bg-white rounded-xl p-3 border border-[#E2E8F0]">
                <Skeleton className="w-8 h-8 rounded-full" />
                <SkeletonText className="w-12 h-5 mt-2" />
                <SkeletonText className="w-16 h-3 mt-1" />
              </View>
            ))}
          </View>

          {/* Filters Skeleton */}
          <View className="flex-row px-4 mt-4 gap-2">
            {[1, 2, 3].map((i) => (
              <Skeleton key={i} className="flex-1 h-10 rounded-full" />
            ))}
          </View>

          {/* Search Skeleton */}
          <View className="px-4 mt-4">
            <Skeleton className="h-11 rounded-xl" />
          </View>

          {/* Course Cards Skeleton */}
          <View className="px-4 pt-4">
            {[1, 2, 3].map((i) => (
              <View key={i} className="flex-row bg-white rounded-2xl mb-4 border border-[#E2E8F0] overflow-hidden">
                <Skeleton className="w-32 h-32" />
                <View className="flex-1 p-3">
                  <SkeletonText className="w-3/4 h-5" />
                  <SkeletonText className="w-1/2 h-4 mt-1" />
                  <View className="flex-row items-center mt-1.5">
                    <SkeletonText className="w-16 h-4" />
                    <SkeletonText className="w-20 h-4 ml-2" />
                  </View>
                  <View className="flex-row items-center mt-2">
                    <SkeletonText className="w-20 h-3" />
                    <SkeletonText className="w-20 h-3 ml-2" />
                  </View>
                  <Skeleton className="w-full h-8 rounded-full mt-2" />
                </View>
              </View>
            ))}
          </View>
        </ScrollView>
      </SafeAreaView>
    );
  }

  const filteredCourses = getFilteredCourses();

  return (
    <SafeAreaView className="flex-1 bg-[#F8FAFC]">
      <StatusBar style="dark" />

      {/* Header */}
      <View className="flex-row items-center px-4 py-3 bg-white border-b border-[#E2E8F0]">
        <TouchableOpacity
          onPress={handleBack}
          className="w-10 h-10 rounded-full bg-[#F1F5F9] items-center justify-center"
          activeOpacity={0.7}
        >
          <Ionicons name="chevron-back" size={24} color="#0F172A" />
        </TouchableOpacity>
        <Text className="text-[#0F172A] text-lg font-bold ml-2 flex-1">
          My Learning
        </Text>
        <TouchableOpacity className="w-10 h-10 rounded-full bg-[#F1F5F9] items-center justify-center">
          <Ionicons name="settings-outline" size={20} color="#0F172A" />
        </TouchableOpacity>
      </View>

      <FlatList
        data={filteredCourses}
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
          paddingHorizontal: 16,
          paddingTop: 16,
          paddingBottom: insets.bottom + 80,
        }}
        showsVerticalScrollIndicator={false}
        ListHeaderComponent={
          <View>
            {/* Stats Cards */}
            {stats && (
              <View className="flex-row gap-3 mb-4">
                <View className="flex-1 bg-white rounded-xl p-3 border border-[#E2E8F0]">
                  <Ionicons name="book-outline" size={20} color="#2563EB" />
                  <Text className="text-[#0F172A] font-bold text-lg mt-1">
                    {stats.totalCourses}
                  </Text>
                  <Text className="text-[#64748B] text-xs">Total Courses</Text>
                </View>
                <View className="flex-1 bg-white rounded-xl p-3 border border-[#E2E8F0]">
                  <Ionicons name="time-outline" size={20} color="#7C3AED" />
                  <Text className="text-[#0F172A] font-bold text-lg mt-1">
                    {stats.totalHours}h
                  </Text>
                  <Text className="text-[#64748B] text-xs">Hours Learned</Text>
                </View>
                <View className="flex-1 bg-white rounded-xl p-3 border border-[#E2E8F0]">
                  <Ionicons name="ribbon-outline" size={20} color="#F59E0B" />
                  <Text className="text-[#0F172A] font-bold text-lg mt-1">
                    {stats.certificates}
                  </Text>
                  <Text className="text-[#64748B] text-xs">Certificates</Text>
                </View>
                <View className="flex-1 bg-white rounded-xl p-3 border border-[#E2E8F0]">
                  <Ionicons name="flame-outline" size={20} color="#EF4444" />
                  <Text className="text-[#0F172A] font-bold text-lg mt-1">
                    {stats.streak}
                  </Text>
                  <Text className="text-[#64748B] text-xs">Day Streak</Text>
                </View>
              </View>
            )}

            {/* Filter Buttons */}
            <View className="flex-row gap-2 mb-4">
              {[
                { key: 'all', label: 'All Courses' },
                { key: 'in-progress', label: 'In Progress' },
                { key: 'completed', label: 'Completed' },
              ].map((filter) => (
                <TouchableOpacity
                  key={filter.key}
                  onPress={() => setActiveFilter(filter.key as any)}
                  className={`flex-1 py-2.5 rounded-full ${
                    activeFilter === filter.key
                      ? 'bg-[#2563EB]'
                      : 'bg-white border border-[#E2E8F0]'
                  }`}
                  activeOpacity={0.7}
                >
                  <Text
                    className={`text-center text-sm font-medium ${
                      activeFilter === filter.key ? 'text-white' : 'text-[#64748B]'
                    }`}
                  >
                    {filter.label}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            {/* Search Bar */}
            <View className="mb-4">
              <View className="flex-row items-center bg-white rounded-xl px-3 border border-[#E2E8F0]">
                <Ionicons name="search-outline" size={20} color="#94A3B8" />
                <TextInput
                  className="flex-1 py-2.5 px-2 text-[#0F172A] text-sm"
                  placeholder="Search your courses..."
                  value={searchQuery}
                  onChangeText={setSearchQuery}
                  placeholderTextColor="#94A3B8"
                />
                {searchQuery.length > 0 && (
                  <TouchableOpacity onPress={() => setSearchQuery('')}>
                    <Ionicons name="close-circle" size={20} color="#94A3B8" />
                  </TouchableOpacity>
                )}
              </View>
            </View>

            {/* Results count */}
            {filteredCourses.length > 0 && (
              <View className="flex-row items-center justify-between mb-3">
                <Text className="text-[#64748B] text-sm">
                  {filteredCourses.length} courses
                </Text>
                <Text className="text-[#94A3B8] text-xs">
                  {filteredCourses.filter(c => c.progress === 100).length} completed
                </Text>
              </View>
            )}
          </View>
        }
        ListEmptyComponent={
          <View className="items-center py-16">
            <View className="w-24 h-24 rounded-full bg-[#F1F5F9] items-center justify-center mb-4">
              <Ionicons name="book-outline" size={48} color="#94A3B8" />
            </View>
            <Text className="text-[#0F172A] text-xl font-bold">
              No Courses Found
            </Text>
            <Text className="text-[#64748B] text-center mt-1 px-8">
              {activeFilter === 'all' 
                ? "You haven't enrolled in any courses yet"
                : activeFilter === 'in-progress'
                ? "You don't have any courses in progress"
                : "You haven't completed any courses yet"}
            </Text>
            <TouchableOpacity
              className="mt-6 bg-[#2563EB] px-6 py-3 rounded-xl"
              onPress={() => router.push('/explore' as any)}
              activeOpacity={0.8}
            >
              <Text className="text-white font-semibold">Browse Courses</Text>
            </TouchableOpacity>
          </View>
        }
      />
    </SafeAreaView>
  );
}