// components/home/TopInstructors.tsx
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image, ActivityIndicator, Alert, RefreshControl } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';
import { homeService } from '@/services/homeService';

export interface Instructor {
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

interface TopInstructorsProps {
  onFollowPress?: (instructorId: string) => void;
  onInstructorPress: (instructorId: string) => void;
  onSeeAll: () => void;
  limit?: number;
}

export const TopInstructors: React.FC<TopInstructorsProps> = ({
  onFollowPress,
  onInstructorPress,
  onSeeAll,
  limit = 10,
}) => {
  const [instructors, setInstructors] = useState<Instructor[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [following, setFollowing] = useState<Set<string>>(new Set());
  const [loadingFollow, setLoadingFollow] = useState<Set<string>>(new Set());
  const [imageErrors, setImageErrors] = useState<Set<string>>(new Set());
  const { isDarkMode, colors } = useTheme();

  // Load instructors on mount
  useEffect(() => {
    loadInstructors();
  }, []);

  const loadInstructors = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await homeService.getTopInstructors(limit);
      
      console.log('📊 Raw instructor data received:', data.length);
      if (data.length > 0) {
        console.log('📊 First instructor:', JSON.stringify(data[0], null, 2));
      }
      
      setInstructors(data);
      
      // Initialize following state from fetched data
      const followingIds = new Set(
        data.filter(inst => inst.isFollowing).map(inst => inst.id)
      );
      setFollowing(followingIds);
      
      console.log(`✅ Loaded ${data.length} top instructors`);
    } catch (error) {
      console.error('❌ Failed to load instructors:', error);
      setError('Failed to load instructors');
    } finally {
      setLoading(false);
    }
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await loadInstructors();
    setRefreshing(false);
  };

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
        console.log(`✅ Unfollowed instructor ${id}`);
      } else {
        await homeService.followInstructor(id);
        setFollowing(prev => new Set(prev).add(id));
        console.log(`✅ Followed instructor ${id}`);
      }
      
      onFollowPress?.(id);
      
      setInstructors(prev => 
        prev.map(inst => 
          inst.id === id 
            ? { ...inst, isFollowing: !isCurrentlyFollowing }
            : inst
        )
      );
      
    } catch (error: any) {
      console.error('❌ Failed to toggle follow:', error);
      Alert.alert(
        'Error',
        error.message || 'Failed to update follow status. Please try again.'
      );
    } finally {
      setLoadingFollow(prev => {
        const newSet = new Set(prev);
        newSet.delete(id);
        return newSet;
      });
    }
  };

  const handleImageError = (instructorId: string) => {
    setImageErrors(prev => new Set(prev).add(instructorId));
    console.log(`❌ Image failed to load for instructor ${instructorId}`);
  };

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  if (loading) {
    return (
      <View style={{ width: '100%', paddingVertical: 20 }}>
        <View className="flex-row justify-between items-center mb-3">
          <Text style={{
            fontSize: 20,
            fontWeight: 'bold',
            color: colors.text,
          }}>
            Top Instructors
          </Text>
          <TouchableOpacity onPress={onSeeAll} activeOpacity={0.7}>
            <Text style={{
              fontSize: 14,
              fontWeight: '600',
              color: colors.primary,
            }}>
              See All
            </Text>
          </TouchableOpacity>
        </View>
        <View className="flex-row justify-center items-center py-8">
          <ActivityIndicator size="large" color={colors.primary} />
        </View>
      </View>
    );
  }

  if (error) {
    return (
      <View style={{ width: '100%', paddingVertical: 20 }}>
        <View className="flex-row justify-between items-center mb-3">
          <Text style={{
            fontSize: 20,
            fontWeight: 'bold',
            color: colors.text,
          }}>
            Top Instructors
          </Text>
          <TouchableOpacity onPress={onSeeAll} activeOpacity={0.7}>
            <Text style={{
              fontSize: 14,
              fontWeight: '600',
              color: colors.primary,
            }}>
              See All
            </Text>
          </TouchableOpacity>
        </View>
        <View className="bg-red-50 p-4 rounded-lg items-center">
          <Text className="text-red-600 text-center">{error}</Text>
          <TouchableOpacity 
            onPress={loadInstructors}
            className="mt-2 px-4 py-2 bg-blue-500 rounded-lg"
          >
            <Text className="text-white font-semibold">Retry</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  if (instructors.length === 0) {
    return (
      <View style={{ width: '100%', paddingVertical: 20 }}>
        <View className="flex-row justify-between items-center mb-3">
          <Text style={{
            fontSize: 20,
            fontWeight: 'bold',
            color: colors.text,
          }}>
            Top Instructors
          </Text>
          <TouchableOpacity onPress={onSeeAll} activeOpacity={0.7}>
            <Text style={{
              fontSize: 14,
              fontWeight: '600',
              color: colors.primary,
            }}>
              See All
            </Text>
          </TouchableOpacity>
        </View>
        <View className="items-center py-8">
          <Ionicons name="people-outline" size={48} color={colors.textSecondary} />
          <Text style={{
            color: colors.textSecondary,
            marginTop: 8,
            fontSize: 14,
          }}>
            No instructors available
          </Text>
        </View>
      </View>
    );
  }

  return (
    <View style={{ width: '100%' }}>
      <View className="flex-row justify-between items-center mb-3">
        <Text style={{
          fontSize: 20,
          fontWeight: 'bold',
          color: colors.text,
        }}>
          Top Instructors
        </Text>
        <TouchableOpacity onPress={onSeeAll} activeOpacity={0.7}>
          <Text style={{
            fontSize: 14,
            fontWeight: '600',
            color: colors.primary,
          }}>
            See All
          </Text>
        </TouchableOpacity>
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} />
        }
      >
        {instructors.map((instructor) => {
          const isFollowing = following.has(instructor.id);
          const isFollowLoading = loadingFollow.has(instructor.id);
          const hasImageError = imageErrors.has(instructor.id);
          
          // Log the photo URL for debugging
          console.log(`🖼️ Instructor ${instructor.name} photo:`, instructor.photo);

          return (
            <TouchableOpacity
              key={instructor.id}
              style={{
                width: 192,
                marginRight: 16,
                borderRadius: 16,
                borderWidth: 1,
                padding: 16,
                alignItems: 'center',
                backgroundColor: colors.backgroundElement,
                borderColor: colors.backgroundSelected,
                shadowColor: isDarkMode ? '#000000' : '#0F172A',
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: isDarkMode ? 0.3 : 0.05,
                shadowRadius: 4,
                elevation: 2,
              }}
              onPress={() => onInstructorPress(instructor.id)}
              activeOpacity={0.8}
            >
              {/* Instructor Photo/Avatar */}
              <View style={{
                width: 80,
                height: 80,
                borderRadius: 40,
                marginBottom: 12,
                overflow: 'hidden',
                backgroundColor: colors.backgroundSelected,
                justifyContent: 'center',
                alignItems: 'center',
              }}>
                {instructor.photo && !hasImageError ? (
                  <Image
                    source={{ 
                      uri: instructor.photo,
                      // Add cache control for better loading
                      cache: 'force-cache',
                    }}
                    style={{
                      width: 80,
                      height: 80,
                      borderRadius: 40,
                    }}
                    onError={() => handleImageError(instructor.id)}
                    onLoad={() => console.log(`✅ Image loaded for ${instructor.name}`)}
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
                      {getInitials(instructor.name)}
                    </Text>
                  </View>
                )}
                
                {/* Verification Badge */}
                {instructor.isVerified && (
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
              
              <Text 
                numberOfLines={1}
                style={{
                  fontWeight: 'bold',
                  fontSize: 14,
                  textAlign: 'center',
                  color: colors.text,
                }}
              >
                {instructor.name}
              </Text>
              
              <Text 
                numberOfLines={1}
                style={{
                  fontSize: 12,
                  textAlign: 'center',
                  marginBottom: 4,
                  color: colors.textSecondary,
                }}
              >
                {instructor.expertise || 'Expert Instructor'}
              </Text>

              <View className="flex-row items-center mb-3">
                <Ionicons name="star" size={14} color="#FBBF24" />
                <Text style={{
                  fontSize: 12,
                  fontWeight: '500',
                  marginLeft: 2,
                  color: colors.text,
                }}>
                  {instructor.rating?.toFixed(1) || '0.0'}
                </Text>
                {instructor.studentsCount && instructor.studentsCount > 0 && (
                  <Text style={{
                    fontSize: 12,
                    marginLeft: 4,
                    color: colors.textSecondary,
                  }}>
                    • {instructor.studentsCount.toLocaleString()} students
                  </Text>
                )}
              </View>

              <TouchableOpacity 
                style={{
                  paddingVertical: 6,
                  paddingHorizontal: 16,
                  borderRadius: 20,
                  borderWidth: 1,
                  backgroundColor: isFollowing ? 'transparent' : colors.primary,
                  borderColor: isFollowing ? colors.primary : colors.primary,
                  opacity: isFollowLoading ? 0.5 : 1,
                }}
                onPress={() => handleFollow(instructor.id)}
                disabled={isFollowLoading}
              >
                <Text style={{
                  fontSize: 12,
                  fontWeight: 'bold',
                  color: isFollowing ? colors.primary : '#FFFFFF',
                }}>
                  {isFollowLoading ? '...' : isFollowing ? 'Following' : 'Follow'}
                </Text>
              </TouchableOpacity>
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </View>
  );
};