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
import { useTheme } from '@/context/themeContext';

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
const Skeleton = ({ className = '', bgColor = '#E2E8F0' }: { className?: string; bgColor?: string }) => (
  <View className={`rounded-lg animate-pulse ${className}`} style={{ backgroundColor: bgColor }} />
);

const SkeletonText = ({ className = '', bgColor = '#E2E8F0' }: { className?: string; bgColor?: string }) => (
  <View className={`rounded h-4 ${className}`} style={{ backgroundColor: bgColor }} />
);

const SkeletonCircle = ({ size = 28, bgColor = '#E2E8F0' }: { size?: number; bgColor?: string }) => (
  <View className="rounded-full" style={{ width: size, height: size, backgroundColor: bgColor }} />
);

export default function MyLearningScreen() {
  const insets = useSafeAreaInsets();
  const { isDarkMode, colors } = useTheme();
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
    
    if (activeFilter === 'in-progress') {
      filtered = filtered.filter(c => c.progress < 100 && c.progress > 0);
    } else if (activeFilter === 'completed') {
      filtered = filtered.filter(c => c.progress === 100);
    }
    
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
    const skeletonBg = isDarkMode ? '#1E293B' : '#E2E8F0';
    
    return (
      <TouchableOpacity
        className="rounded-2xl border overflow-hidden mb-4"
        style={{
          backgroundColor: colors.backgroundElement,
          borderColor: colors.backgroundSelected,
          shadowColor: isDarkMode ? '#000000' : '#0F172A',
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: isDarkMode ? 0.3 : 0.05,
          shadowRadius: 4,
          elevation: 2,
        }}
        onPress={() => handleCoursePress(item.id)}
        activeOpacity={0.8}
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
                <Text style={{ color: colors.text, fontWeight: '600', fontSize: 14 }} numberOfLines={1}>
                  {item.title}
                </Text>
                <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 2 }} numberOfLines={1}>
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
              <View className="px-2 py-0.5 rounded-full" style={{ backgroundColor: isDarkMode ? '#1E3A5F' : '#EFF6FF' }}>
                <Text style={{ color: colors.primary, fontSize: 10, fontWeight: '500' }}>
                  {item.category}
                </Text>
              </View>
              <View className="w-px h-3 mx-2" style={{ backgroundColor: colors.backgroundSelected }} />
              <Text style={{ color: colors.textSecondary, fontSize: 10 }}>
                {item.completedLessons}/{item.totalLessons} lessons
              </Text>
            </View>

            <View className="flex-row items-center justify-between mt-2">
              <View className="flex-row items-center">
                <Ionicons name="time-outline" size={12} color={colors.textSecondary} />
                <Text style={{ color: colors.textSecondary, fontSize: 10, marginLeft: 4 }}>
                  {isCompleted ? 'Completed' : item.remainingTime} left
                </Text>
              </View>
              <View className="flex-row items-center">
                <Ionicons name="calendar-outline" size={12} color={colors.textSecondary} />
                <Text style={{ color: colors.textSecondary, fontSize: 10, marginLeft: 4 }}>
                  {item.lastAccessed}
                </Text>
              </View>
            </View>

            <TouchableOpacity 
              className={`mt-2 py-1.5 rounded-full ${isCompleted ? 'bg-[#16A34A]' : ''}`}
              style={{ backgroundColor: isCompleted ? '#16A34A' : colors.primary }}
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
    const skeletonBg = isDarkMode ? '#1E293B' : '#E2E8F0';
    return (
      <SafeAreaView className="flex-1" style={{ backgroundColor: colors.background }}>
        <StatusBar style={isDarkMode ? 'light' : 'dark'} />
        
        {/* Header Skeleton */}
        <View className="flex-row items-center px-4 py-3 border-b" style={{
          backgroundColor: colors.backgroundElement,
          borderBottomColor: colors.backgroundSelected,
        }}>
          <SkeletonCircle size={40} bgColor={skeletonBg} />
          <SkeletonText className="w-32 h-6 ml-2" bgColor={skeletonBg} />
          <SkeletonText className="w-8 h-8 rounded-full ml-auto" bgColor={skeletonBg} />
        </View>

        <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
          {/* Stats Skeleton */}
          <View className="flex-row px-4 pt-4 gap-3">
            {[1, 2, 3, 4].map((i) => (
              <View key={i} className="flex-1 rounded-xl p-3 border" style={{
                backgroundColor: colors.backgroundElement,
                borderColor: colors.backgroundSelected,
              }}>
                <Skeleton className="w-8 h-8 rounded-full" bgColor={skeletonBg} />
                <SkeletonText className="w-12 h-5 mt-2" bgColor={skeletonBg} />
                <SkeletonText className="w-16 h-3 mt-1" bgColor={skeletonBg} />
              </View>
            ))}
          </View>

          {/* Filters Skeleton */}
          <View className="flex-row px-4 mt-4 gap-2">
            {[1, 2, 3].map((i) => (
              <Skeleton key={i} className="flex-1 h-10 rounded-full" bgColor={skeletonBg} />
            ))}
          </View>

          {/* Search Skeleton */}
          <View className="px-4 mt-4">
            <Skeleton className="h-11 rounded-xl" bgColor={skeletonBg} />
          </View>

          {/* Course Cards Skeleton */}
          <View className="px-4 pt-4">
            {[1, 2, 3].map((i) => (
              <View key={i} className="flex-row rounded-2xl mb-4 border overflow-hidden" style={{
                backgroundColor: colors.backgroundElement,
                borderColor: colors.backgroundSelected,
              }}>
                <Skeleton className="w-32 h-32" bgColor={skeletonBg} />
                <View className="flex-1 p-3">
                  <SkeletonText className="w-3/4 h-5" bgColor={skeletonBg} />
                  <SkeletonText className="w-1/2 h-4 mt-1" bgColor={skeletonBg} />
                  <View className="flex-row items-center mt-1.5">
                    <SkeletonText className="w-16 h-4" bgColor={skeletonBg} />
                    <SkeletonText className="w-20 h-4 ml-2" bgColor={skeletonBg} />
                  </View>
                  <View className="flex-row items-center mt-2">
                    <SkeletonText className="w-20 h-3" bgColor={skeletonBg} />
                    <SkeletonText className="w-20 h-3 ml-2" bgColor={skeletonBg} />
                  </View>
                  <Skeleton className="w-full h-8 rounded-full mt-2" bgColor={skeletonBg} />
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
    <SafeAreaView className="flex-1" style={{ backgroundColor: colors.background }}>
      <StatusBar style={isDarkMode ? 'light' : 'dark'} />

      {/* Header */}
      <View className="flex-row items-center px-4 py-3 border-b" style={{
        backgroundColor: colors.backgroundElement,
        borderBottomColor: colors.backgroundSelected,
      }}>
        <TouchableOpacity
          onPress={handleBack}
          className="w-10 h-10 rounded-full items-center justify-center"
          style={{ backgroundColor: colors.backgroundSelected }}
          activeOpacity={0.7}
        >
          <Ionicons name="chevron-back" size={24} color={colors.text} />
        </TouchableOpacity>
        <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold', marginLeft: 8, flex: 1 }}>
          My Learning
        </Text>
        <TouchableOpacity 
          className="w-10 h-10 rounded-full items-center justify-center"
          style={{ backgroundColor: colors.backgroundSelected }}
        >
          <Ionicons name="settings-outline" size={20} color={colors.text} />
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
            tintColor={colors.primary}
            colors={[colors.primary]}
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
                <View className="flex-1 rounded-xl p-3 border" style={{
                  backgroundColor: colors.backgroundElement,
                  borderColor: colors.backgroundSelected,
                }}>
                  <Ionicons name="book-outline" size={20} color={colors.primary} />
                  <Text style={{ color: colors.text, fontWeight: 'bold', fontSize: 18, marginTop: 4 }}>
                    {stats.totalCourses}
                  </Text>
                  <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Total Courses</Text>
                </View>
                <View className="flex-1 rounded-xl p-3 border" style={{
                  backgroundColor: colors.backgroundElement,
                  borderColor: colors.backgroundSelected,
                }}>
                  <Ionicons name="time-outline" size={20} color="#7C3AED" />
                  <Text style={{ color: colors.text, fontWeight: 'bold', fontSize: 18, marginTop: 4 }}>
                    {stats.totalHours}h
                  </Text>
                  <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Hours Learned</Text>
                </View>
                <View className="flex-1 rounded-xl p-3 border" style={{
                  backgroundColor: colors.backgroundElement,
                  borderColor: colors.backgroundSelected,
                }}>
                  <Ionicons name="ribbon-outline" size={20} color="#F59E0B" />
                  <Text style={{ color: colors.text, fontWeight: 'bold', fontSize: 18, marginTop: 4 }}>
                    {stats.certificates}
                  </Text>
                  <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Certificates</Text>
                </View>
                <View className="flex-1 rounded-xl p-3 border" style={{
                  backgroundColor: colors.backgroundElement,
                  borderColor: colors.backgroundSelected,
                }}>
                  <Ionicons name="flame-outline" size={20} color="#EF4444" />
                  <Text style={{ color: colors.text, fontWeight: 'bold', fontSize: 18, marginTop: 4 }}>
                    {stats.streak}
                  </Text>
                  <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Day Streak</Text>
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
                      ? ''
                      : 'border'
                  }`}
                  style={{
                    backgroundColor: activeFilter === filter.key ? colors.primary : 'transparent',
                    borderColor: colors.backgroundSelected,
                  }}
                  activeOpacity={0.7}
                >
                  <Text
                    style={{
                      textAlign: 'center',
                      fontSize: 14,
                      fontWeight: '500',
                      color: activeFilter === filter.key ? '#FFFFFF' : colors.textSecondary,
                    }}
                  >
                    {filter.label}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            {/* Search Bar */}
            <View className="mb-4">
              <View className="flex-row items-center rounded-xl px-3 border" style={{
                backgroundColor: colors.backgroundElement,
                borderColor: colors.backgroundSelected,
              }}>
                <Ionicons name="search-outline" size={20} color={colors.textSecondary} />
                <TextInput
                  className="flex-1 py-2.5 px-2 text-sm"
                  style={{ color: colors.text }}
                  placeholder="Search your courses..."
                  value={searchQuery}
                  onChangeText={setSearchQuery}
                  placeholderTextColor={colors.textSecondary}
                />
                {searchQuery.length > 0 && (
                  <TouchableOpacity onPress={() => setSearchQuery('')}>
                    <Ionicons name="close-circle" size={20} color={colors.textSecondary} />
                  </TouchableOpacity>
                )}
              </View>
            </View>

            {/* Results count */}
            {filteredCourses.length > 0 && (
              <View className="flex-row items-center justify-between mb-3">
                <Text style={{ color: colors.textSecondary, fontSize: 14 }}>
                  {filteredCourses.length} courses
                </Text>
                <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
                  {filteredCourses.filter(c => c.progress === 100).length} completed
                </Text>
              </View>
            )}
          </View>
        }
        ListEmptyComponent={
          <View className="items-center py-16">
            <View className="w-24 h-24 rounded-full items-center justify-center mb-4" style={{ backgroundColor: colors.backgroundSelected }}>
              <Ionicons name="book-outline" size={48} color={colors.textSecondary} />
            </View>
            <Text style={{ color: colors.text, fontSize: 20, fontWeight: 'bold' }}>
              No Courses Found
            </Text>
            <Text style={{ color: colors.textSecondary, textAlign: 'center', marginTop: 4, paddingHorizontal: 32 }}>
              {activeFilter === 'all' 
                ? "You haven't enrolled in any courses yet"
                : activeFilter === 'in-progress'
                ? "You don't have any courses in progress"
                : "You haven't completed any courses yet"}
            </Text>
            <TouchableOpacity
              className="mt-6 px-6 py-3 rounded-xl"
              style={{ backgroundColor: colors.primary }}
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