// app/live.tsx
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
  Modal,
} from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '@/context/themeContext';
import { HomeHeader } from '@/components/home/HomeHeader';

const { width } = Dimensions.get('window');

interface LiveClass {
  id: string;
  title: string;
  instructor: string;
  instructorAvatar: string;
  thumbnail: string;
  date: string;
  time: string;
  duration: string;
  participants: number;
  maxParticipants: number;
  status: 'upcoming' | 'live' | 'ended';
  category: string;
  description: string;
  level: 'Beginner' | 'Intermediate' | 'Advanced';
  tags: string[];
  isRegistered: boolean;
  isFavorite: boolean;
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

export default function LiveScreen() {
  const insets = useSafeAreaInsets();
  const { isDarkMode, colors } = useTheme();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [liveClasses, setLiveClasses] = useState<LiveClass[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilter, setActiveFilter] = useState<'all' | 'upcoming' | 'live' | 'ended'>('all');
  const [selectedClass, setSelectedClass] = useState<LiveClass | null>(null);
  const [modalVisible, setModalVisible] = useState(false);

  useEffect(() => {
    fetchLiveClasses();
  }, []);

  const fetchLiveClasses = async () => {
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const mockClasses: LiveClass[] = [
        {
          id: '1',
          title: 'React Native Advanced Patterns',
          instructor: 'John Doe',
          instructorAvatar: 'https://picsum.photos/seed/john/200/200',
          thumbnail: 'https://images.unsplash.com/photo-1633356122102-3fe601e05bd2?w=800&h=400&fit=crop',
          date: 'Today',
          time: '10:00 AM',
          duration: '1h 30m',
          participants: 156,
          maxParticipants: 500,
          status: 'live',
          category: 'Development',
          description: 'Master advanced React Native patterns including compound components, render props, and hooks optimization.',
          level: 'Advanced',
          tags: ['React Native', 'Mobile', 'Advanced'],
          isRegistered: true,
          isFavorite: false,
        },
        {
          id: '2',
          title: 'UI/UX Design Principles Workshop',
          instructor: 'Sarah Chen',
          instructorAvatar: 'https://picsum.photos/seed/sarah/200/200',
          thumbnail: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800&h=400&fit=crop',
          date: 'Today',
          time: '2:00 PM',
          duration: '2h',
          participants: 89,
          maxParticipants: 300,
          status: 'upcoming',
          category: 'Design',
          description: 'Learn essential UI/UX design principles and best practices for creating amazing user experiences.',
          level: 'Intermediate',
          tags: ['UI/UX', 'Design', 'Workshop'],
          isRegistered: false,
          isFavorite: true,
        },
        {
          id: '3',
          title: 'Machine Learning Fundamentals',
          instructor: 'Dr. Alex Johnson',
          instructorAvatar: 'https://picsum.photos/seed/alex/200/200',
          thumbnail: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800&h=400&fit=crop',
          date: 'Tomorrow',
          time: '11:00 AM',
          duration: '2h 30m',
          participants: 234,
          maxParticipants: 1000,
          status: 'upcoming',
          category: 'AI & ML',
          description: 'Introduction to machine learning concepts, algorithms, and real-world applications.',
          level: 'Beginner',
          tags: ['Machine Learning', 'AI', 'Data Science'],
          isRegistered: false,
          isFavorite: false,
        },
        {
          id: '4',
          title: 'Digital Marketing Masterclass',
          instructor: 'Mike Brown',
          instructorAvatar: 'https://picsum.photos/seed/mike/200/200',
          thumbnail: 'https://images.unsplash.com/photo-1432889821006-4ba4fa9c2a00?w=800&h=400&fit=crop',
          date: 'Yesterday',
          time: '3:00 PM',
          duration: '1h 45m',
          participants: 312,
          maxParticipants: 500,
          status: 'ended',
          category: 'Marketing',
          description: 'Complete guide to digital marketing strategies, SEO, social media, and analytics.',
          level: 'Intermediate',
          tags: ['Marketing', 'SEO', 'Social Media'],
          isRegistered: true,
          isFavorite: false,
        },
        {
          id: '5',
          title: 'Python for Data Science',
          instructor: 'Emily Davis',
          instructorAvatar: 'https://picsum.photos/seed/emily/200/200',
          thumbnail: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=400&fit=crop',
          date: 'Next Week',
          time: '9:00 AM',
          duration: '3h',
          participants: 67,
          maxParticipants: 200,
          status: 'upcoming',
          category: 'Data Science',
          description: 'Learn Python programming for data analysis, visualization, and machine learning.',
          level: 'Beginner',
          tags: ['Python', 'Data Science', 'Programming'],
          isRegistered: false,
          isFavorite: true,
        },
        {
          id: '6',
          title: 'Cloud Architecture Design Patterns',
          instructor: 'Chris Wilson',
          instructorAvatar: 'https://picsum.photos/seed/chris/200/200',
          thumbnail: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&h=400&fit=crop',
          date: 'Tomorrow',
          time: '4:00 PM',
          duration: '2h',
          participants: 45,
          maxParticipants: 150,
          status: 'upcoming',
          category: 'Cloud Computing',
          description: 'Design scalable and resilient cloud architectures using industry best practices.',
          level: 'Advanced',
          tags: ['Cloud', 'Architecture', 'AWS'],
          isRegistered: false,
          isFavorite: false,
        },
        {
          id: '7',
          title: 'Live Coding Session: Build a Chat App',
          instructor: 'Jane Smith',
          instructorAvatar: 'https://picsum.photos/seed/jane/200/200',
          thumbnail: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&h=400&fit=crop',
          date: 'Today',
          time: '6:00 PM',
          duration: '2h',
          participants: 423,
          maxParticipants: 1000,
          status: 'live',
          category: 'Development',
          description: 'Join this live coding session to build a real-time chat application from scratch.',
          level: 'Intermediate',
          tags: ['Live Coding', 'React', 'Node.js'],
          isRegistered: true,
          isFavorite: true,
        },
        {
          id: '8',
          title: 'Financial Planning for Beginners',
          instructor: 'Robert Lee',
          instructorAvatar: 'https://picsum.photos/seed/robert/200/200',
          thumbnail: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800&h=400&fit=crop',
          date: 'Next Week',
          time: '1:00 PM',
          duration: '1h 30m',
          participants: 28,
          maxParticipants: 100,
          status: 'upcoming',
          category: 'Finance',
          description: 'Learn the fundamentals of personal finance, investing, and wealth management.',
          level: 'Beginner',
          tags: ['Finance', 'Investing', 'Planning'],
          isRegistered: false,
          isFavorite: false,
        },
      ];

      setLiveClasses(mockClasses);
      setLoading(false);
    } catch (error) {
      console.error('Failed to fetch live classes:', error);
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchLiveClasses();
    setRefreshing(false);
  };

  const handleNotificationPress = () => {
    router.push('/(notifications)' as any);
  };

  const handleClassPress = (classItem: LiveClass) => {
    setSelectedClass(classItem);
    setModalVisible(true);
  };

  const handleJoinClass = (classId: string) => {
    router.push({
      pathname: '/(live)/[id]',
      params: { id: classId },
    } as any);
  };

  const handleRegister = (classId: string) => {
    setLiveClasses(prev => 
      prev.map(c => 
        c.id === classId 
          ? { ...c, isRegistered: !c.isRegistered }
          : c
      )
    );
  };

  const handleFavorite = (classId: string) => {
    setLiveClasses(prev => 
      prev.map(c => 
        c.id === classId 
          ? { ...c, isFavorite: !c.isFavorite }
          : c
      )
    );
  };

  const getFilteredClasses = () => {
    let filtered = liveClasses;
    
    if (activeFilter !== 'all') {
      filtered = filtered.filter(c => c.status === activeFilter);
    }
    
    if (searchQuery) {
      filtered = filtered.filter(c => 
        c.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        c.instructor.toLowerCase().includes(searchQuery.toLowerCase()) ||
        c.category.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }
    
    return filtered;
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'live':
        return '#EF4444';
      case 'upcoming':
        return colors.primary;
      case 'ended':
        return colors.textSecondary;
      default:
        return colors.textSecondary;
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'live':
        return '🔴 LIVE NOW';
      case 'upcoming':
        return 'Upcoming';
      case 'ended':
        return 'Ended';
      default:
        return '';
    }
  };

  const renderClassCard = ({ item }: { item: LiveClass }) => {
    const isLive = item.status === 'live';
    const isEnded = item.status === 'ended';
    const progress = Math.round((item.participants / item.maxParticipants) * 100);
    
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
        onPress={() => handleClassPress(item)}
        activeOpacity={0.8}
      >
        <View className="relative">
          <Image
            source={{ uri: item.thumbnail }}
            className="w-full h-48"
            resizeMode="cover"
          />
          <LinearGradient
            colors={['transparent', 'rgba(0,0,0,0.6)']}
            className="absolute inset-0"
          />
          
          {/* Status Badge */}
          <View 
            className="absolute top-3 left-3 px-3 py-1 rounded-full"
            style={{ backgroundColor: getStatusColor(item.status) }}
          >
            <Text className="text-white text-xs font-bold">
              {getStatusText(item.status)}
            </Text>
          </View>

          {/* Participant Progress */}
          <View className="absolute bottom-3 left-3 right-3">
            <View className="flex-row items-center justify-between mb-1">
              <Text className="text-white text-xs font-medium">
                {item.participants} / {item.maxParticipants} participants
              </Text>
              <Text className="text-white text-xs font-medium">
                {progress}%
              </Text>
            </View>
            <View className="w-full h-1.5 bg-white/30 rounded-full overflow-hidden">
              <View 
                className="h-full bg-white rounded-full"
                style={{ width: `${progress}%` }}
              />
            </View>
          </View>
        </View>

        <View className="p-4">
          <View className="flex-row items-start justify-between">
            <View className="flex-1">
              <Text style={{ color: colors.text, fontWeight: 'bold', fontSize: 16 }} numberOfLines={1}>
                {item.title}
              </Text>
              <View className="flex-row items-center mt-1">
                <Image
                  source={{ uri: item.instructorAvatar }}
                  className="w-5 h-5 rounded-full mr-1.5"
                />
                <Text style={{ color: colors.textSecondary, fontSize: 14 }} numberOfLines={1}>
                  {item.instructor}
                </Text>
              </View>
            </View>
            <TouchableOpacity
              onPress={() => handleFavorite(item.id)}
              className="ml-2"
            >
              <Ionicons 
                name={item.isFavorite ? 'heart' : 'heart-outline'} 
                size={22} 
                color={item.isFavorite ? '#EF4444' : colors.textSecondary} 
              />
            </TouchableOpacity>
          </View>

          <View className="flex-row items-center flex-wrap mt-2">
            <View className="flex-row items-center mr-3">
              <Ionicons name="calendar-outline" size={14} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 4 }}>{item.date}</Text>
            </View>
            <View className="flex-row items-center mr-3">
              <Ionicons name="time-outline" size={14} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 4 }}>{item.time}</Text>
            </View>
            <View className="flex-row items-center">
              <Ionicons name="hourglass-outline" size={14} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 4 }}>{item.duration}</Text>
            </View>
          </View>

          <View className="flex-row items-center justify-between mt-3">
            <View className="flex-row items-center">
              <View className="px-2 py-0.5 rounded-full" style={{ backgroundColor: isDarkMode ? '#1E3A5F' : '#EFF6FF' }}>
                <Text style={{ color: colors.primary, fontSize: 10, fontWeight: '500' }}>
                  {item.category}
                </Text>
              </View>
              <View className="w-px h-3 mx-2" style={{ backgroundColor: colors.backgroundSelected }} />
              <View className="px-2 py-0.5 rounded-full" style={{ backgroundColor: colors.backgroundSelected }}>
                <Text style={{ color: colors.textSecondary, fontSize: 10, fontWeight: '500' }}>
                  {item.level}
                </Text>
              </View>
            </View>
            
            {!isEnded && (
              <TouchableOpacity
                className="px-4 py-1.5 rounded-full"
                style={{ backgroundColor: isLive ? '#EF4444' : colors.primary }}
                onPress={() => handleJoinClass(item.id)}
                activeOpacity={0.7}
              >
                <Text className="text-white text-xs font-semibold">
                  {isLive ? 'Join Now' : 'Set Reminder'}
                </Text>
              </TouchableOpacity>
            )}
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
        
        {/* HomeHeader Skeleton */}
        <View className="px-4 py-3 border-b" style={{
          backgroundColor: colors.backgroundElement,
          borderBottomColor: colors.backgroundSelected,
        }}>
          <View className="flex-row items-center justify-between">
            <SkeletonText className="w-32 h-6" bgColor={skeletonBg} />
            <View className="flex-row items-center">
              <SkeletonCircle size={40} bgColor={skeletonBg} />
              <SkeletonCircle size={40} bgColor={skeletonBg} />
            </View>
          </View>
          <SkeletonText className="w-48 h-4 mt-1" bgColor={skeletonBg} />
        </View>

        <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
          {/* Filters Skeleton */}
          <View className="flex-row px-4 pt-4 gap-2">
            {[1, 2, 3, 4].map((i) => (
              <Skeleton key={i} className="flex-1 h-10 rounded-full" bgColor={skeletonBg} />
            ))}
          </View>

          {/* Search Skeleton */}
          <View className="px-4 mt-4">
            <Skeleton className="h-11 rounded-xl" bgColor={skeletonBg} />
          </View>

          {/* Live Now Banner Skeleton */}
          <View className="px-4 mt-4">
            <Skeleton className="w-full h-32 rounded-2xl" bgColor={skeletonBg} />
          </View>

          {/* Class Cards Skeleton */}
          <View className="px-4 pt-4">
            {[1, 2].map((i) => (
              <View key={i} className="rounded-2xl mb-4 border overflow-hidden" style={{
                backgroundColor: colors.backgroundElement,
                borderColor: colors.backgroundSelected,
              }}>
                <Skeleton className="w-full h-48" bgColor={skeletonBg} />
                <View className="p-4">
                  <SkeletonText className="w-3/4 h-5" bgColor={skeletonBg} />
                  <View className="flex-row items-center mt-1">
                    <SkeletonCircle size={20} bgColor={skeletonBg} />
                    <SkeletonText className="w-32 h-4 ml-1.5" bgColor={skeletonBg} />
                  </View>
                  <View className="flex-row items-center mt-2">
                    <SkeletonText className="w-16 h-3" bgColor={skeletonBg} />
                    <SkeletonText className="w-16 h-3 ml-3" bgColor={skeletonBg} />
                    <SkeletonText className="w-16 h-3 ml-3" bgColor={skeletonBg} />
                  </View>
                  <View className="flex-row items-center justify-between mt-3">
                    <SkeletonText className="w-20 h-4" bgColor={skeletonBg} />
                    <SkeletonText className="w-24 h-8 rounded-full" bgColor={skeletonBg} />
                  </View>
                </View>
              </View>
            ))}
          </View>
        </ScrollView>
      </SafeAreaView>
    );
  }

  const filteredClasses = getFilteredClasses();
  const liveClassesNow = liveClasses.filter(c => c.status === 'live');

  return (
    <SafeAreaView className="flex-1" style={{ backgroundColor: colors.background }}>
      <StatusBar style={isDarkMode ? 'light' : 'dark'} />

      {/* HomeHeader */}
      <HomeHeader
        notificationCount={3}
        onNotificationPress={handleNotificationPress}
      />

      <FlatList
        data={filteredClasses}
        renderItem={renderClassCard}
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
            {/* Filter Buttons */}
            <View className="flex-row gap-2 mb-4">
              {[
                { key: 'all', label: 'All' },
                { key: 'live', label: '🔴 Live Now' },
                { key: 'upcoming', label: 'Upcoming' },
                { key: 'ended', label: 'Ended' },
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
                  placeholder="Search live classes..."
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

            {/* Live Now Banner */}
            {liveClassesNow.length > 0 && activeFilter === 'all' && (
              <View className="mb-4">
                <LinearGradient
                  colors={['#EF4444', '#DC2626']}
                  start={{ x: 0, y: 0 }}
                  end={{ x: 1, y: 0 }}
                  className="rounded-2xl p-4"
                >
                  <View className="flex-row items-center justify-between">
                    <View>
                      <Text className="text-white text-sm font-semibold">
                        🔴 Live Now
                      </Text>
                      <Text className="text-white/90 text-lg font-bold mt-1">
                        {liveClassesNow.length} Class{liveClassesNow.length > 1 ? 'es' : ''} Live
                      </Text>
                      <Text className="text-white/70 text-xs mt-0.5">
                        Join before they end!
                      </Text>
                    </View>
                    <TouchableOpacity
                      className="bg-white/20 px-4 py-2 rounded-full"
                      onPress={() => setActiveFilter('live')}
                    >
                      <Text className="text-white text-xs font-semibold">
                        View All
                      </Text>
                    </TouchableOpacity>
                  </View>
                </LinearGradient>
              </View>
            )}

            {/* Results count */}
            {filteredClasses.length > 0 && (
              <View className="flex-row items-center justify-between mb-3">
                <Text style={{ color: colors.textSecondary, fontSize: 14 }}>
                  {filteredClasses.length} classes found
                </Text>
                <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
                  {filteredClasses.filter(c => c.status === 'live').length} live now
                </Text>
              </View>
            )}
          </View>
        }
        ListEmptyComponent={
          <View className="items-center py-16">
            <View className="w-24 h-24 rounded-full items-center justify-center mb-4" style={{ backgroundColor: colors.backgroundSelected }}>
              <Ionicons name="videocam-outline" size={48} color={colors.textSecondary} />
            </View>
            <Text style={{ color: colors.text, fontSize: 20, fontWeight: 'bold' }}>
              No Live Classes Found
            </Text>
            <Text style={{ color: colors.textSecondary, textAlign: 'center', marginTop: 4, paddingHorizontal: 32 }}>
              {searchQuery 
                ? `No classes matching "${searchQuery}"`
                : activeFilter === 'live'
                ? "No classes are currently live"
                : activeFilter === 'upcoming'
                ? "No upcoming classes scheduled"
                : activeFilter === 'ended'
                ? "No ended classes available"
                : "No live classes available at the moment"}
            </Text>
            <TouchableOpacity
              className="mt-6 px-6 py-3 rounded-xl"
              style={{ backgroundColor: colors.primary }}
              onPress={() => {
                setSearchQuery('');
                setActiveFilter('all');
              }}
              activeOpacity={0.8}
            >
              <Text className="text-white font-semibold">Browse All</Text>
            </TouchableOpacity>
          </View>
        }
      />

      {/* Class Detail Modal */}
      {selectedClass && (
        <Modal
          visible={modalVisible}
          animationType="slide"
          transparent={true}
          onRequestClose={() => setModalVisible(false)}
        >
          <View className="flex-1 bg-black/50 justify-end">
            <View className="rounded-t-3xl" style={{ 
              backgroundColor: colors.background,
              maxHeight: '90%' 
            }}>
              <View className="p-4">
                <View className="items-center mb-4">
                  <View className="w-12 h-1 rounded-full" style={{ backgroundColor: colors.backgroundSelected }} />
                </View>

                <ScrollView showsVerticalScrollIndicator={false}>
                  <Image
                    source={{ uri: selectedClass.thumbnail }}
                    className="w-full h-56 rounded-2xl"
                    resizeMode="cover"
                  />
                  
                  <View className="mt-4">
                    <View className="flex-row items-center justify-between">
                      <View className="flex-1">
                        <Text style={{ color: colors.text, fontSize: 20, fontWeight: 'bold' }}>
                          {selectedClass.title}
                        </Text>
                      </View>
                      <TouchableOpacity
                        onPress={() => handleFavorite(selectedClass.id)}
                        className="ml-2"
                      >
                        <Ionicons 
                          name={selectedClass.isFavorite ? 'heart' : 'heart-outline'} 
                          size={28} 
                          color={selectedClass.isFavorite ? '#EF4444' : colors.textSecondary} 
                        />
                      </TouchableOpacity>
                    </View>

                    <View className="flex-row items-center mt-2">
                      <Image
                        source={{ uri: selectedClass.instructorAvatar }}
                        className="w-8 h-8 rounded-full mr-2"
                      />
                      <Text style={{ color: colors.textSecondary, fontWeight: '500' }}>
                        {selectedClass.instructor}
                      </Text>
                    </View>

                    <View className="flex-row items-center flex-wrap mt-3">
                      <View className="px-3 py-1 rounded-full mr-2" style={{ backgroundColor: isDarkMode ? '#1E3A5F' : '#EFF6FF' }}>
                        <Text style={{ color: colors.primary, fontSize: 12, fontWeight: '500' }}>
                          {selectedClass.category}
                        </Text>
                      </View>
                      <View className="px-3 py-1 rounded-full" style={{ backgroundColor: colors.backgroundSelected }}>
                        <Text style={{ color: colors.textSecondary, fontSize: 12, fontWeight: '500' }}>
                          {selectedClass.level}
                        </Text>
                      </View>
                    </View>

                    <View className="flex-row items-center mt-3 p-3 rounded-xl" style={{ backgroundColor: colors.backgroundSelected }}>
                      <View className="flex-1">
                        <View className="flex-row items-center">
                          <Ionicons name="calendar-outline" size={16} color={colors.textSecondary} />
                          <Text style={{ color: colors.textSecondary, fontSize: 14, marginLeft: 4 }}>
                            {selectedClass.date} at {selectedClass.time}
                          </Text>
                        </View>
                        <View className="flex-row items-center mt-1">
                          <Ionicons name="time-outline" size={16} color={colors.textSecondary} />
                          <Text style={{ color: colors.textSecondary, fontSize: 14, marginLeft: 4 }}>
                            Duration: {selectedClass.duration}
                          </Text>
                        </View>
                      </View>
                      <View className="items-end">
                        <Text style={{ color: colors.text, fontWeight: 'bold' }}>
                          {selectedClass.participants}
                        </Text>
                        <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
                          participants
                        </Text>
                      </View>
                    </View>

                    <Text style={{ color: colors.text, fontWeight: 'bold', marginTop: 16, marginBottom: 8 }}>
                      About this class
                    </Text>
                    <Text style={{ color: colors.textSecondary, fontSize: 14, lineHeight: 20 }}>
                      {selectedClass.description}
                    </Text>

                    <View className="flex-row flex-wrap mt-3">
                      {selectedClass.tags.map((tag, index) => (
                        <View key={index} className="px-3 py-1 rounded-full mr-2 mb-2" style={{ backgroundColor: colors.backgroundSelected }}>
                          <Text style={{ color: colors.textSecondary, fontSize: 12 }}>#{tag}</Text>
                        </View>
                      ))}
                    </View>

                    <TouchableOpacity
                      className={`mt-4 py-3 rounded-xl ${
                        selectedClass.status === 'ended'
                          ? ''
                          : selectedClass.status === 'live'
                          ? 'bg-[#EF4444]'
                          : selectedClass.isRegistered
                          ? 'bg-[#16A34A]'
                          : ''
                      }`}
                      style={{
                        backgroundColor: selectedClass.status === 'ended'
                          ? colors.backgroundSelected
                          : selectedClass.status === 'live'
                          ? '#EF4444'
                          : selectedClass.isRegistered
                          ? '#16A34A'
                          : colors.primary,
                      }}
                      onPress={() => {
                        if (selectedClass.status === 'live') {
                          handleJoinClass(selectedClass.id);
                        } else if (selectedClass.status === 'upcoming') {
                          handleRegister(selectedClass.id);
                        }
                        setModalVisible(false);
                      }}
                      activeOpacity={0.8}
                    >
                      <Text className="text-white text-center font-bold">
                        {selectedClass.status === 'ended'
                          ? 'Class Ended'
                          : selectedClass.status === 'live'
                          ? '🔴 Join Class Now'
                          : selectedClass.isRegistered
                          ? '✅ Registered'
                          : 'Register for Class'}
                      </Text>
                    </TouchableOpacity>

                    <TouchableOpacity
                      className="mt-2 py-3 rounded-xl border"
                      style={{ borderColor: colors.backgroundSelected }}
                      onPress={() => setModalVisible(false)}
                    >
                      <Text style={{ color: colors.textSecondary, textAlign: 'center', fontWeight: '500' }}>
                        Close
                      </Text>
                    </TouchableOpacity>
                  </View>
                </ScrollView>
              </View>
            </View>
          </View>
        </Modal>
      )}
    </SafeAreaView>
  );
}