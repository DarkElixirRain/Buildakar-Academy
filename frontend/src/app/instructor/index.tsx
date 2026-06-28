// app/(tabs)/instructors.tsx (or app/instructors/index.tsx)
import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  Image,
  TextInput,
  RefreshControl,
  SafeAreaView,
  FlatList,
  ActivityIndicator,
} from 'react-native';
import { Ionicons, Feather, MaterialIcons } from '@expo/vector-icons';
import { router, useLocalSearchParams } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useTheme } from '@/context/themeContext';

interface Instructor {
  id: string;
  name: string;
  expertise: string;
  photo: string;
  rating: number;
  studentsCount: number;
  coursesCount: number;
  bio: string;
  isFollowing: boolean;
  totalRevenue?: string;
  joinDate?: string;
  socialLinks?: {
    youtube?: string;
    twitter?: string;
    linkedin?: string;
    website?: string;
  };
}

// Mock data - replace with your actual data
const MOCK_INSTRUCTORS: Instructor[] = [
  {
    id: '1',
    name: 'Dr. Sarah Johnson',
    expertise: 'Data Science & AI',
    photo: 'https://randomuser.me/api/portraits/women/1.jpg',
    rating: 4.9,
    studentsCount: 24500,
    coursesCount: 28,
    bio: 'Leading AI researcher with 15+ years of experience in machine learning and deep learning. Passionate about making AI accessible to everyone.',
    isFollowing: false,
    totalRevenue: '$2.4M',
    joinDate: '2020-01-15',
    socialLinks: {
      youtube: 'https://youtube.com',
      twitter: 'https://twitter.com',
      linkedin: 'https://linkedin.com',
      website: 'https://example.com',
    },
  },
  {
    id: '2',
    name: 'Prof. Michael Chen',
    expertise: 'Web Development',
    photo: 'https://randomuser.me/api/portraits/men/2.jpg',
    rating: 4.8,
    studentsCount: 32000,
    coursesCount: 35,
    bio: 'Full-stack developer and educator with 10+ years of industry experience. Creator of popular React and Node.js courses.',
    isFollowing: false,
    totalRevenue: '$3.1M',
    joinDate: '2019-06-20',
    socialLinks: {
      twitter: 'https://twitter.com',
      linkedin: 'https://linkedin.com',
      website: 'https://example.com',
    },
  },
  {
    id: '3',
    name: 'Prof. Emily Rodriguez',
    expertise: 'UX/UI Design',
    photo: 'https://randomuser.me/api/portraits/women/3.jpg',
    rating: 4.7,
    studentsCount: 18000,
    coursesCount: 22,
    bio: 'Award-winning UX designer and design educator. Focused on human-centered design and design thinking.',
    isFollowing: false,
    totalRevenue: '$1.8M',
    joinDate: '2020-08-10',
  },
  {
    id: '4',
    name: 'Dr. James Wilson',
    expertise: 'Machine Learning',
    photo: 'https://randomuser.me/api/portraits/men/4.jpg',
    rating: 4.9,
    studentsCount: 28000,
    coursesCount: 30,
    bio: 'Machine Learning engineer with PhD from Stanford. Specializing in NLP and computer vision.',
    isFollowing: false,
    totalRevenue: '$2.9M',
    joinDate: '2019-03-05',
  },
  {
    id: '5',
    name: 'Prof. Lisa Thompson',
    expertise: 'Digital Marketing',
    photo: 'https://randomuser.me/api/portraits/women/5.jpg',
    rating: 4.6,
    studentsCount: 15000,
    coursesCount: 18,
    bio: 'Digital marketing strategist with 12+ years of experience. Helped 500+ businesses grow their online presence.',
    isFollowing: false,
    totalRevenue: '$1.5M',
    joinDate: '2021-01-15',
  },
];

export default function InstructorsScreen() {
  const insets = useSafeAreaInsets();
  const params = useLocalSearchParams();
  const { isDarkMode, colors } = useTheme();
  const [instructors, setInstructors] = useState<Instructor[]>(MOCK_INSTRUCTORS);
  const [filteredInstructors, setFilteredInstructors] = useState<Instructor[]>(MOCK_INSTRUCTORS);
  const [searchQuery, setSearchQuery] = useState('');
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(false);
  const [sortBy, setSortBy] = useState<'popular' | 'rating' | 'newest'>('popular');
  const [showSortModal, setShowSortModal] = useState(false);
  const [followingMap, setFollowingMap] = useState<Set<string>>(new Set());

  // Load following status from storage or state
  useEffect(() => {
    // Load instructors with following status
    const loadedInstructors = MOCK_INSTRUCTORS.map(instructor => ({
      ...instructor,
      isFollowing: followingMap.has(instructor.id),
    }));
    setInstructors(loadedInstructors);
    setFilteredInstructors(loadedInstructors);
  }, []);

  // Handle search
  const handleSearch = (query: string) => {
    setSearchQuery(query);
    const filtered = instructors.filter(
      instructor =>
        instructor.name.toLowerCase().includes(query.toLowerCase()) ||
        instructor.expertise.toLowerCase().includes(query.toLowerCase()) ||
        instructor.bio.toLowerCase().includes(query.toLowerCase())
    );
    setFilteredInstructors(filtered);
  };

  // Handle refresh
  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1500));
    setRefreshing(false);
  }, []);

  // Handle follow/unfollow
  const handleFollow = (instructorId: string) => {
    setFollowingMap(prev => {
      const newSet = new Set(prev);
      if (newSet.has(instructorId)) {
        newSet.delete(instructorId);
      } else {
        newSet.add(instructorId);
      }
      
      // Update instructors
      setInstructors(prevInstructors =>
        prevInstructors.map(instructor =>
          instructor.id === instructorId
            ? { ...instructor, isFollowing: newSet.has(instructorId) }
            : instructor
        )
      );
      setFilteredInstructors(prevFiltered =>
        prevFiltered.map(instructor =>
          instructor.id === instructorId
            ? { ...instructor, isFollowing: newSet.has(instructorId) }
            : instructor
        )
      );
      
      return newSet;
    });
  };

  // Handle sort
  const handleSort = (type: 'popular' | 'rating' | 'newest') => {
    setSortBy(type);
    const sorted = [...filteredInstructors];
    if (type === 'popular') {
      sorted.sort((a, b) => b.studentsCount - a.studentsCount);
    } else if (type === 'rating') {
      sorted.sort((a, b) => b.rating - a.rating);
    } else if (type === 'newest') {
      sorted.sort((a, b) => new Date(b.joinDate || '').getTime() - new Date(a.joinDate || '').getTime());
    }
    setFilteredInstructors(sorted);
    setShowSortModal(false);
  };

  // Navigate to instructor profile
  const handleInstructorPress = (instructorId: string) => {
    router.push(`/instructor/${instructorId}` as any);
  };

  // Render instructor card
  const renderInstructorCard = ({ item }: { item: Instructor }) => {
    const isFollowing = followingMap.has(item.id);

    return (
      <TouchableOpacity
        className="rounded-2xl border p-4 mb-4"
        style={{
          backgroundColor: colors.backgroundElement,
          borderColor: colors.backgroundSelected,
          shadowColor: isDarkMode ? '#000000' : '#0F172A',
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: isDarkMode ? 0.3 : 0.05,
          shadowRadius: 4,
          elevation: 2,
        }}
        onPress={() => handleInstructorPress(item.id)}
        activeOpacity={0.8}
      >
        <View className="flex-row items-start">
          <Image
            source={{ uri: item.photo }}
            className="w-20 h-20 rounded-full mr-4"
          />
          <View className="flex-1">
            <View className="flex-row items-center justify-between">
              <Text style={{ color: colors.text, fontWeight: 'bold', fontSize: 16, flex: 1, marginRight: 8 }}>
                {item.name}
              </Text>
              <TouchableOpacity
                className={`px-3 py-1 rounded-full border ${
                  isFollowing
                    ? 'bg-transparent'
                    : ''
                }`}
                style={{
                  borderColor: colors.primary,
                  backgroundColor: isFollowing ? 'transparent' : colors.primary,
                }}
                onPress={() => handleFollow(item.id)}
              >
                <Text
                  style={{
                    fontSize: 12,
                    fontWeight: 'bold',
                    color: isFollowing ? colors.primary : '#FFFFFF',
                  }}
                >
                  {isFollowing ? 'Following' : 'Follow'}
                </Text>
              </TouchableOpacity>
            </View>

            <Text style={{ color: colors.textSecondary, fontSize: 14, marginTop: 2 }}>
              {item.expertise}
            </Text>

            <View className="flex-row items-center mt-1 space-x-3">
              <View className="flex-row items-center">
                <Ionicons name="star" size={14} color="#FBBF24" />
                <Text style={{ color: colors.text, fontSize: 12, fontWeight: '500', marginLeft: 2 }}>
                  {item.rating.toFixed(1)}
                </Text>
              </View>
              <View className="flex-row items-center">
                <Ionicons name="people" size={14} color={colors.textSecondary} />
                <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 2 }}>
                  {item.studentsCount.toLocaleString()} students
                </Text>
              </View>
              <View className="flex-row items-center">
                <Ionicons name="book" size={14} color={colors.textSecondary} />
                <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 2 }}>
                  {item.coursesCount} courses
                </Text>
              </View>
            </View>

            <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 6 }} numberOfLines={2}>
              {item.bio}
            </Text>
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  // Sort options
  const SortOptions = () => (
    <View className="flex-row items-center space-x-2 ml-2">
      <TouchableOpacity
        className="flex-row items-center rounded-full px-3 py-1.5 border"
        style={{
          backgroundColor: colors.backgroundElement,
          borderColor: colors.backgroundSelected,
        }}
        onPress={() => setShowSortModal(!showSortModal)}
      >
        <Ionicons name="options-outline" size={16} color={colors.textSecondary} />
        <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 4 }}>
          {sortBy === 'popular' ? 'Popular' : sortBy === 'rating' ? 'Top Rated' : 'Newest'}
        </Text>
      </TouchableOpacity>
    </View>
  );

  // Sort Modal
  const SortModal = () => (
    <View className="absolute top-12 right-0 rounded-xl border p-2 z-10 w-40 shadow-lg"
      style={{
        backgroundColor: colors.backgroundElement,
        borderColor: colors.backgroundSelected,
      }}
    >
      {['popular', 'rating', 'newest'].map((type) => (
        <TouchableOpacity
          key={type}
          className={`px-3 py-2 rounded-lg ${sortBy === type ? 'bg-[#EFF6FF]' : ''}`}
          style={{ backgroundColor: sortBy === type ? (isDarkMode ? '#1E3A5F' : '#EFF6FF') : 'transparent' }}
          onPress={() => handleSort(type as 'popular' | 'rating' | 'newest')}
        >
          <Text style={{
            fontSize: 14,
            color: sortBy === type ? colors.primary : colors.textSecondary,
            fontWeight: sortBy === type ? 'bold' : 'normal',
          }}>
            {type === 'popular' ? 'Most Popular' : type === 'rating' ? 'Top Rated' : 'Newest'}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  );

  return (
    <SafeAreaView className="flex-1" style={{ backgroundColor: colors.background }}>
      <StatusBar style={isDarkMode ? 'light' : 'dark'} />

      {/* Header */}
      <View className="px-4 pt-4 pb-2 border-b" style={{
        backgroundColor: colors.backgroundElement,
        borderBottomColor: colors.backgroundSelected,
      }}>
        <View className="flex-row items-center justify-between">
          <TouchableOpacity onPress={() => router.back()} className="p-1">
            <Ionicons name="arrow-back" size={24} color={colors.text} />
          </TouchableOpacity>
          <Text style={{ color: colors.text, fontSize: 20, fontWeight: 'bold' }}>
            Top Instructors
          </Text>
          <TouchableOpacity className="p-1">
            <Ionicons name="notifications-outline" size={24} color={colors.text} />
          </TouchableOpacity>
        </View>

        {/* Search Bar */}
        <View className="flex-row items-center rounded-xl px-3 py-2 mt-3" style={{
          backgroundColor: colors.backgroundSelected,
        }}>
          <Ionicons name="search" size={20} color={colors.textSecondary} />
          <TextInput
            className="flex-1 ml-2 text-sm"
            style={{ color: colors.text }}
            placeholder="Search instructors..."
            placeholderTextColor={colors.textSecondary}
            value={searchQuery}
            onChangeText={handleSearch}
          />
          {searchQuery.length > 0 && (
            <TouchableOpacity onPress={() => handleSearch('')}>
              <Ionicons name="close-circle" size={20} color={colors.textSecondary} />
            </TouchableOpacity>
          )}
        </View>

        {/* Filter Row */}
        <View className="flex-row items-center justify-between mt-3">
          <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
            {filteredInstructors.length} instructors
          </Text>
          <View className="relative">
            <SortOptions />
            {showSortModal && <SortModal />}
          </View>
        </View>
      </View>

      {/* Instructor List */}
      <FlatList
        data={filteredInstructors}
        renderItem={renderInstructorCard}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ padding: 16, paddingBottom: insets.bottom + 80 }}
        refreshControl={
          <RefreshControl 
            refreshing={refreshing} 
            onRefresh={onRefresh} 
            tintColor={colors.primary}
            colors={[colors.primary]}
          />
        }
        ListEmptyComponent={
          <View className="items-center justify-center py-10">
            <Ionicons name="people" size={64} color={colors.textSecondary} />
            <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold', marginTop: 16 }}>
              No Instructors Found
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 14, marginTop: 4, textAlign: 'center' }}>
              Try adjusting your search terms
            </Text>
          </View>
        }
        ListFooterComponent={
          loading ? (
            <View className="py-4">
              <ActivityIndicator color={colors.primary} />
            </View>
          ) : null
        }
      />
    </SafeAreaView>
  );
}