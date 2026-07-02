// app/instructor/index.tsx
import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  SafeAreaView,
  ScrollView,
  Image,
  ActivityIndicator,
  RefreshControl,
  TextInput,
  FlatList,
  Dimensions,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useTheme } from '@/context/themeContext';
import { homeService } from '@/services/homeService';
import { StatusBar } from 'expo-status-bar';

const { width } = Dimensions.get('window');

interface Instructor {
  id: string;
  name: string;
  expertise: string;
  photo: string;
  rating: number;
  studentsCount?: number;
  coursesCount?: number;
  bio?: string;
  isFollowing?: boolean;
  firstName?: string;
  lastName?: string;
  totalStudents?: number;
  totalCourses?: number;
  averageRating?: number;
  isVerified?: boolean;
  followerCount?: number;
  socialLinks?: {
    youtube?: string;
    twitter?: string;
    linkedin?: string;
    website?: string;
  };
}

export default function InstructorsPage() {
  const router = useRouter();
  const { isDarkMode, colors } = useTheme();

  // State
  const [instructors, setInstructors] = useState<Instructor[]>([]);
  const [filteredInstructors, setFilteredInstructors] = useState<Instructor[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [following, setFollowing] = useState<Set<string>>(new Set());
  const [loadingFollow, setLoadingFollow] = useState<Set<string>>(new Set());
  const [imageErrors, setImageErrors] = useState<Set<string>>(new Set());
  const [selectedFilter, setSelectedFilter] = useState<'all' | 'following' | 'top'>('all');
  const [error, setError] = useState<string | null>(null);

  // Load instructors
  const loadInstructors = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await homeService.getTopInstructors(50);
      
      console.log('📊 Loaded instructors:', data.length);
      setInstructors(data);
      setFilteredInstructors(data);
      
      const followingIds = new Set(
        data.filter(inst => inst.isFollowing).map(inst => inst.id)
      );
      setFollowing(followingIds);
    } catch (error) {
      console.error('❌ Failed to load instructors:', error);
      setError('Failed to load instructors. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Load on mount
  useEffect(() => {
    loadInstructors();
  }, []);

  // Handle search and filters
  useEffect(() => {
    let filtered = instructors;
    
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase().trim();
      filtered = filtered.filter(inst => 
        inst.name.toLowerCase().includes(query) ||
        inst.expertise?.toLowerCase().includes(query) ||
        inst.bio?.toLowerCase().includes(query)
      );
    }
    
    if (selectedFilter === 'following') {
      filtered = filtered.filter(inst => following.has(inst.id));
    } else if (selectedFilter === 'top') {
      filtered = filtered.filter(inst => (inst.rating || 0) >= 4.5);
    }
    
    setFilteredInstructors(filtered);
  }, [searchQuery, selectedFilter, instructors, following]);

  // Refresh
  const handleRefresh = async () => {
    setRefreshing(true);
    await loadInstructors();
    setRefreshing(false);
  };

  // Follow/Unfollow
  const handleFollow = async (id: string) => {
    try {
      setLoadingFollow(prev => new Set(prev).add(id));
      
      const isCurrentlyFollowing = following.has(id);
      
      if (isCurrentlyFollowing) {
        await homeService.unfollowInstructor(id);
        setFollowing(prev => {
          const newSet = new Set(prev);
          newSet.delete(id);
          return newSet;
        });
      } else {
        await homeService.followInstructor(id);
        setFollowing(prev => new Set(prev).add(id));
      }
      
      setInstructors(prev => 
        prev.map(inst => 
          inst.id === id 
            ? { ...inst, isFollowing: !isCurrentlyFollowing }
            : inst
        )
      );
      
    } catch (error: any) {
      console.error('❌ Failed to toggle follow:', error);
      Alert.alert('Error', error.message || 'Failed to update follow status.');
    } finally {
      setLoadingFollow(prev => {
        const newSet = new Set(prev);
        newSet.delete(id);
        return newSet;
      });
    }
  };

  // Navigate to instructor profile
  const handleInstructorPress = (instructorId: string) => {
    router.push(`/instructor/${instructorId}` as any);
  };

  // Get initials
  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  // Render instructor card
  const renderInstructorCard = ({ item }: { item: Instructor }) => {
    const isFollowing = following.has(item.id);
    const isFollowLoading = loadingFollow.has(item.id);
    const hasImageError = imageErrors.has(item.id);

    return (
      <View
        style={{
          width: width - 32,
          marginHorizontal: 16,
          marginBottom: 16,
          borderRadius: 16,
          borderWidth: 1,
          padding: 16,
          backgroundColor: colors.backgroundElement,
          borderColor: colors.backgroundSelected,
          shadowColor: isDarkMode ? '#000000' : '#0F172A',
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: isDarkMode ? 0.3 : 0.05,
          shadowRadius: 4,
          elevation: 2,
        }}
      >
        {/* Top row: Avatar + Info */}
        <View style={{ flexDirection: 'row', alignItems: 'flex-start' }}>
          {/* Avatar */}
          <TouchableOpacity
            onPress={() => handleInstructorPress(item.id)}
            activeOpacity={0.7}
          >
            <View style={{
              width: 80,
              height: 80,
              borderRadius: 40,
              overflow: 'hidden',
              backgroundColor: colors.backgroundSelected,
              justifyContent: 'center',
              alignItems: 'center',
            }}>
              {item.photo && !hasImageError ? (
                <Image
                  source={{ uri: item.photo }}
                  style={{
                    width: 80,
                    height: 80,
                    borderRadius: 40,
                  }}
                  onError={() => {
                    setImageErrors(prev => new Set(prev).add(item.id));
                  }}
                  resizeMode="cover"
                />
              ) : (
                <View style={{
                  width: 80,
                  height: 80,
                  borderRadius: 40,
                  backgroundColor: colors.primary,
                  justifyContent: 'center',
                  alignItems: 'center',
                }}>
                  <Text style={{
                    color: '#FFFFFF',
                    fontSize: 28,
                    fontWeight: 'bold',
                  }}>
                    {getInitials(item.name)}
                  </Text>
                </View>
              )}
              
              {/* Verified Badge */}
              {item.isVerified && (
                <View style={{
                  position: 'absolute',
                  bottom: 0,
                  right: 0,
                  backgroundColor: '#3B82F6',
                  borderRadius: 12,
                  width: 24,
                  height: 24,
                  justifyContent: 'center',
                  alignItems: 'center',
                  borderWidth: 2,
                  borderColor: colors.backgroundElement,
                }}>
                  <Ionicons name="checkmark" size={14} color="#FFFFFF" />
                </View>
              )}
            </View>
          </TouchableOpacity>

          {/* Info */}
          <View style={{ flex: 1, marginLeft: 16 }}>
            <TouchableOpacity
              onPress={() => handleInstructorPress(item.id)}
              activeOpacity={0.7}
            >
              <Text
                numberOfLines={1}
                style={{
                  fontWeight: 'bold',
                  fontSize: 18,
                  color: colors.text,
                }}
              >
                {item.name}
              </Text>
            </TouchableOpacity>
            
            <Text
              numberOfLines={1}
              style={{
                fontSize: 14,
                color: colors.textSecondary,
                marginTop: 2,
              }}
            >
              {item.expertise || 'Expert Instructor'}
            </Text>

            <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 4 }}>
              <Ionicons name="star" size={16} color="#FBBF24" />
              <Text style={{
                fontSize: 14,
                fontWeight: '600',
                marginLeft: 4,
                color: colors.text,
              }}>
                {(item.rating || item.averageRating || 0).toFixed(1)}
              </Text>
              <Text style={{
                fontSize: 12,
                marginLeft: 4,
                color: colors.textSecondary,
              }}>
                • {(item.studentsCount || item.totalStudents || 0).toLocaleString()} students
              </Text>
            </View>

            {item.bio && (
              <Text
                numberOfLines={2}
                style={{
                  fontSize: 13,
                  color: colors.textSecondary,
                  marginTop: 4,
                }}
              >
                {item.bio}
              </Text>
            )}
          </View>
        </View>

        {/* Stats */}
        <View style={{
          flexDirection: 'row',
          marginTop: 16,
          paddingTop: 16,
          borderTopWidth: 1,
          borderTopColor: colors.backgroundSelected,
        }}>
          <View style={{ flex: 1, alignItems: 'center' }}>
            <Text style={{ color: colors.text, fontWeight: 'bold', fontSize: 16 }}>
              {(item.coursesCount || item.totalCourses || 0)}
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Courses</Text>
          </View>
          <View style={{ flex: 1, alignItems: 'center' }}>
            <Text style={{ color: colors.text, fontWeight: 'bold', fontSize: 16 }}>
              {(item.studentsCount || item.totalStudents || 0).toLocaleString()}
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Students</Text>
          </View>
          <View style={{ flex: 1, alignItems: 'center' }}>
            <Text style={{ color: colors.text, fontWeight: 'bold', fontSize: 16 }}>
              {(item.followerCount || 0).toLocaleString()}
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Followers</Text>
          </View>
        </View>

        {/* Follow Button */}
        <TouchableOpacity
          style={{
            marginTop: 12,
            paddingVertical: 10,
            borderRadius: 12,
            backgroundColor: isFollowing ? 'transparent' : colors.primary,
            borderWidth: 1,
            borderColor: isFollowing ? colors.primary : colors.primary,
            opacity: isFollowLoading ? 0.5 : 1,
          }}
          onPress={() => handleFollow(item.id)}
          disabled={isFollowLoading}
        >
          <Text style={{
            fontSize: 14,
            fontWeight: 'bold',
            textAlign: 'center',
            color: isFollowing ? colors.primary : '#FFFFFF',
          }}>
            {isFollowLoading ? 'Loading...' : isFollowing ? 'Following' : 'Follow'}
          </Text>
        </TouchableOpacity>
      </View>
    );
  };

  // Loading state
  if (loading) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
        <StatusBar style={isDarkMode ? 'light' : 'dark'} />
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
          <ActivityIndicator size="large" color={colors.primary} />
          <Text style={{ color: colors.textSecondary, marginTop: 12 }}>
            Loading instructors...
          </Text>
        </View>
      </SafeAreaView>
    );
  }

  // Error state
  if (error) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
        <StatusBar style={isDarkMode ? 'light' : 'dark'} />
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24 }}>
          <Ionicons name="alert-circle-outline" size={64} color={colors.textSecondary} />
          <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold', marginTop: 16 }}>
            Oops! Something went wrong
          </Text>
          <Text style={{ color: colors.textSecondary, textAlign: 'center', marginTop: 8 }}>
            {error}
          </Text>
          <TouchableOpacity
            style={{
              marginTop: 24,
              backgroundColor: colors.primary,
              paddingHorizontal: 32,
              paddingVertical: 12,
              borderRadius: 12,
            }}
            onPress={loadInstructors}
          >
            <Text style={{ color: '#FFFFFF', fontWeight: '600' }}>Try Again</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <StatusBar style={isDarkMode ? 'light' : 'dark'} />

      {/* Header */}
      <View style={{
        paddingHorizontal: 16,
        paddingTop: 12,
        paddingBottom: 16,
        borderBottomWidth: 1,
        borderBottomColor: colors.backgroundSelected,
      }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
          <View style={{ flexDirection: 'row', alignItems: 'center' }}>
            <TouchableOpacity
              onPress={() => router.back()}
              style={{ marginRight: 12 }}
            >
              <Ionicons name="arrow-back" size={24} color={colors.text} />
            </TouchableOpacity>
            <Text style={{
              fontSize: 24,
              fontWeight: 'bold',
              color: colors.text,
            }}>
              Instructors
            </Text>
          </View>
          <Text style={{
            fontSize: 14,
            color: colors.textSecondary,
          }}>
            {filteredInstructors.length} instructors
          </Text>
        </View>

        {/* Search Bar */}
        <View style={{
          flexDirection: 'row',
          alignItems: 'center',
          marginTop: 12,
          borderRadius: 12,
          paddingHorizontal: 12,
          backgroundColor: colors.backgroundElement,
          borderWidth: 1,
          borderColor: colors.backgroundSelected,
        }}>
          <Ionicons name="search" size={20} color={colors.textSecondary} />
          <TextInput
            style={{
              flex: 1,
              paddingVertical: 10,
              paddingHorizontal: 8,
              fontSize: 16,
              color: colors.text,
            }}
            placeholder="Search instructors..."
            placeholderTextColor={colors.textSecondary}
            value={searchQuery}
            onChangeText={setSearchQuery}
          />
          {searchQuery.length > 0 && (
            <TouchableOpacity onPress={() => setSearchQuery('')}>
              <Ionicons name="close-circle" size={20} color={colors.textSecondary} />
            </TouchableOpacity>
          )}
        </View>

        {/* Filter Tabs */}
        <View style={{ flexDirection: 'row', marginTop: 12 }}>
          {['all', 'following', 'top'].map((filter) => (
            <TouchableOpacity
              key={filter}
              style={{
                paddingHorizontal: 16,
                paddingVertical: 6,
                borderRadius: 20,
                marginRight: 8,
                backgroundColor: selectedFilter === filter ? colors.primary : colors.backgroundElement,
                borderWidth: 1,
                borderColor: selectedFilter === filter ? colors.primary : colors.backgroundSelected,
              }}
              onPress={() => setSelectedFilter(filter as any)}
            >
              <Text style={{
                fontSize: 13,
                fontWeight: '500',
                color: selectedFilter === filter ? '#FFFFFF' : colors.text,
              }}>
                {filter.charAt(0).toUpperCase() + filter.slice(1)}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      {/* Instructor List */}
      <FlatList
        data={filteredInstructors}
        renderItem={renderInstructorCard}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ paddingTop: 16, paddingBottom: 80 }}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={handleRefresh}
            tintColor={colors.primary}
            colors={[colors.primary]}
          />
        }
        ListEmptyComponent={
          <View style={{ alignItems: 'center', justifyContent: 'center', paddingVertical: 48 }}>
            <Ionicons name="people-outline" size={64} color={colors.textSecondary} />
            <Text style={{
              color: colors.text,
              fontSize: 18,
              fontWeight: 'bold',
              marginTop: 16,
            }}>
              No instructors found
            </Text>
            <Text style={{
              color: colors.textSecondary,
              textAlign: 'center',
              marginTop: 8,
            }}>
              {searchQuery ? 'Try adjusting your search' : 'No instructors available'}
            </Text>
          </View>
        }
      />
    </SafeAreaView>
  );
}