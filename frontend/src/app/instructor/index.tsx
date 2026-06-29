// app/instructor/[id].tsx
import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Image,
  ScrollView,
  RefreshControl,
  SafeAreaView,
  ActivityIndicator,
  Alert,
  Linking,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { router, useLocalSearchParams } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useTheme } from '@/context/themeContext';
import { homeService } from '@/services/homeService';
import { Instructor, Course } from '@/types/home';

export default function InstructorDetailScreen() {
  const insets = useSafeAreaInsets();
  const { id } = useLocalSearchParams<{ id: string }>();
  const { isDarkMode, colors } = useTheme();

  const [instructor, setInstructor] = useState<Instructor | null>(null);
  const [courses, setCourses] = useState<Course[]>([]);
  const [loading, setLoading] = useState(true);
  const [coursesLoading, setCoursesLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isFollowing, setIsFollowing] = useState(false);
  const [followLoading, setFollowLoading] = useState(false);
  const [imageError, setImageError] = useState(false);

  const loadInstructor = useCallback(async () => {
    if (!id) return;
    try {
      setError(null);
      console.log(`🔍 Loading instructor detail for ${id}...`);

      const data = await homeService.getInstructorById(id);

      if (!data) {
        setError('Instructor not found.');
        setInstructor(null);
        return;
      }

      console.log('📊 Instructor data loaded:', JSON.stringify(data, null, 2));
      setInstructor(data);
      setIsFollowing(!!data.isFollowing);
      setImageError(false);
    } catch (err: any) {
      console.error('❌ Failed to load instructor:', err);
      setError(err.message || 'Failed to load instructor. Please try again.');
    }
  }, [id]);

  const loadCourses = useCallback(async () => {
    if (!id) return;
    try {
      setCoursesLoading(true);
      const data = await homeService.getInstructorCourses(id);
      setCourses(data);
      console.log(`📚 Loaded ${data.length} courses for instructor`);
    } catch (err: any) {
      console.error('❌ Failed to load instructor courses:', err);
    } finally {
      setCoursesLoading(false);
    }
  }, [id]);

  const loadAll = useCallback(async () => {
    setLoading(true);
    await Promise.all([loadInstructor(), loadCourses()]);
    setLoading(false);
  }, [loadInstructor, loadCourses]);

  useEffect(() => {
    loadAll();
  }, [loadAll]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadAll();
    setRefreshing(false);
  }, [loadAll]);

  const handleFollow = async () => {
    if (!instructor) return;
    try {
      setFollowLoading(true);
      if (isFollowing) {
        await homeService.unfollowInstructor(instructor.id);
        setIsFollowing(false);
        // Update instructor state
        setInstructor(prev => prev ? { ...prev, isFollowing: false } : null);
      } else {
        await homeService.followInstructor(instructor.id);
        setIsFollowing(true);
        setInstructor(prev => prev ? { ...prev, isFollowing: true } : null);
      }
    } catch (err: any) {
      console.error('❌ Failed to toggle follow:', err);
      Alert.alert('Error', err.message || 'Failed to update follow status. Please try again.');
    } finally {
      setFollowLoading(false);
    }
  };

  const openLink = (url?: string) => {
    if (!url) return;
    Linking.openURL(url).catch(() => {
      Alert.alert('Error', 'Could not open this link.');
    });
  };

  const handleCoursePress = (courseId: string) => {
    router.push(`/course/${courseId}` as any);
  };

  const getInitials = (name: string) => {
    if (!name) return '?';
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  // ---------------- Loading state ----------------
  if (loading) {
    return (
      <SafeAreaView className="flex-1" style={{ backgroundColor: colors.background }}>
        <StatusBar style={isDarkMode ? 'light' : 'dark'} />
        <View className="flex-1 justify-center items-center">
          <ActivityIndicator size="large" color={colors.primary} />
          <Text style={{ color: colors.textSecondary, marginTop: 16 }}>
            Loading instructor...
          </Text>
        </View>
      </SafeAreaView>
    );
  }

  // ---------------- Error state ----------------
  if (error || !instructor) {
    return (
      <SafeAreaView className="flex-1" style={{ backgroundColor: colors.background }}>
        <StatusBar style={isDarkMode ? 'light' : 'dark'} />
        <View className="flex-row items-center px-4 pt-4 pb-2">
          <TouchableOpacity onPress={() => router.back()} className="p-1">
            <Ionicons name="arrow-back" size={24} color={colors.text} />
          </TouchableOpacity>
        </View>
        <View className="flex-1 justify-center items-center px-4">
          <Ionicons name="alert-circle" size={64} color={colors.primary} />
          <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold', marginTop: 16 }}>
            Something went wrong
          </Text>
          <Text style={{ color: colors.textSecondary, fontSize: 14, marginTop: 8, textAlign: 'center' }}>
            {error || 'Instructor not found.'}
          </Text>
          <TouchableOpacity
            className="mt-6 px-6 py-3 rounded-xl"
            style={{ backgroundColor: colors.primary }}
            onPress={loadAll}
          >
            <Text className="text-white font-semibold">Try Again</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  // ---------------- Derived, fallback-safe display values ----------------
  const displayName = instructor.name || 
    `${instructor.firstName || ''} ${instructor.lastName || ''}`.trim() || 
    'Instructor';
  
  const displayRating = instructor.rating ?? instructor.averageRating ?? 0;
  const displayStudents = instructor.studentsCount ?? instructor.totalStudents ?? 0;
  const displayCourses = instructor.coursesCount ?? instructor.totalCourses ?? 0;
  const displayExpertise = instructor.expertise || 'Expert Instructor';

  // ---------------- Main content ----------------
  return (
    <SafeAreaView className="flex-1" style={{ backgroundColor: colors.background }}>
      <StatusBar style={isDarkMode ? 'light' : 'dark'} />

      {/* Header */}
      <View
        className="flex-row items-center justify-between px-4 pt-4 pb-2 border-b"
        style={{
          backgroundColor: colors.backgroundElement,
          borderBottomColor: colors.backgroundSelected,
        }}
      >
        <TouchableOpacity onPress={() => router.back()} className="p-1">
          <Ionicons name="arrow-back" size={24} color={colors.text} />
        </TouchableOpacity>
        <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold' }}>
          Instructor
        </Text>
        <View style={{ width: 24 }} />
      </View>

      <ScrollView
        contentContainerStyle={{ paddingBottom: insets.bottom + 32 }}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.primary}
            colors={[colors.primary]}
          />
        }
      >
        {/* Profile section */}
        <View className="items-center px-4 pt-6 pb-4">
          {/* Profile Image with fallback */}
          <View style={{
            width: 112,
            height: 112,
            borderRadius: 56,
            overflow: 'hidden',
            backgroundColor: colors.backgroundSelected,
            justifyContent: 'center',
            alignItems: 'center',
            borderWidth: 2,
            borderColor: colors.primary,
          }}>
            {!imageError && instructor.photo ? (
              <Image
                source={{ 
                  uri: instructor.photo,
                  cache: 'force-cache',
                }}
                style={{
                  width: 112,
                  height: 112,
                  borderRadius: 56,
                }}
                onError={() => {
                  console.log(`❌ Failed to load image for ${displayName}`);
                  setImageError(true);
                }}
                onLoad={() => {
                  console.log(`✅ Image loaded for ${displayName}`);
                }}
                resizeMode="cover"
              />
            ) : (
              <View style={{
                width: 112,
                height: 112,
                borderRadius: 56,
                backgroundColor: colors.primary,
                justifyContent: 'center',
                alignItems: 'center',
              }}>
                <Text style={{
                  color: '#FFFFFF',
                  fontSize: 40,
                  fontWeight: 'bold',
                }}>
                  {getInitials(displayName)}
                </Text>
              </View>
            )}
            
            {/* Verification Badge */}
            {instructor.isVerified && (
              <View style={{
                position: 'absolute',
                bottom: 4,
                right: 4,
                backgroundColor: '#3B82F6',
                borderRadius: 16,
                width: 32,
                height: 32,
                justifyContent: 'center',
                alignItems: 'center',
                borderWidth: 2,
                borderColor: colors.backgroundElement,
              }}>
                <Ionicons name="checkmark" size={18} color="#FFFFFF" />
              </View>
            )}
          </View>

          <View className="flex-row items-center mt-3">
            <Text style={{ color: colors.text, fontSize: 22, fontWeight: 'bold' }}>
              {displayName}
            </Text>
            {instructor.isVerified && (
              <Ionicons
                name="checkmark-circle"
                size={18}
                color={colors.primary}
                style={{ marginLeft: 6 }}
              />
            )}
          </View>

          <Text style={{ color: colors.textSecondary, fontSize: 14, marginTop: 2 }}>
            {displayExpertise}
          </Text>

          {/* Stats row */}
          <View className="flex-row items-center justify-center mt-4" style={{ gap: 24 }}>
            <View className="items-center">
              <View className="flex-row items-center">
                <Ionicons name="star" size={16} color="#FBBF24" />
                <Text style={{ color: colors.text, fontSize: 16, fontWeight: 'bold', marginLeft: 4 }}>
                  {displayRating.toFixed(1)}
                </Text>
              </View>
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 2 }}>
                Rating
              </Text>
            </View>

            <View className="items-center">
              <Text style={{ color: colors.text, fontSize: 16, fontWeight: 'bold' }}>
                {displayStudents.toLocaleString()}
              </Text>
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 2 }}>
                Students
              </Text>
            </View>

            <View className="items-center">
              <Text style={{ color: colors.text, fontSize: 16, fontWeight: 'bold' }}>
                {displayCourses}
              </Text>
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 2 }}>
                Courses
              </Text>
            </View>

            {instructor.followerCount !== undefined && instructor.followerCount > 0 && (
              <View className="items-center">
                <Text style={{ color: colors.text, fontSize: 16, fontWeight: 'bold' }}>
                  {instructor.followerCount.toLocaleString()}
                </Text>
                <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 2 }}>
                  Followers
                </Text>
              </View>
            )}
          </View>

          {/* Follow button */}
          <TouchableOpacity
            className="px-8 py-2.5 rounded-full border mt-5"
            style={{
              borderColor: colors.primary,
              backgroundColor: isFollowing ? 'transparent' : colors.primary,
              opacity: followLoading ? 0.6 : 1,
            }}
            onPress={handleFollow}
            disabled={followLoading}
          >
            <Text
              style={{
                fontSize: 14,
                fontWeight: 'bold',
                color: isFollowing ? colors.primary : '#FFFFFF',
              }}
            >
              {followLoading ? 'Please wait...' : isFollowing ? 'Following' : 'Follow'}
            </Text>
          </TouchableOpacity>

          {/* Social links */}
          {instructor.socialLinks && Object.values(instructor.socialLinks).some(Boolean) && (
            <View className="flex-row items-center mt-4" style={{ gap: 16 }}>
              {instructor.socialLinks.website && (
                <TouchableOpacity onPress={() => openLink(instructor.socialLinks?.website)}>
                  <Ionicons name="globe-outline" size={22} color={colors.textSecondary} />
                </TouchableOpacity>
              )}
              {instructor.socialLinks.youtube && (
                <TouchableOpacity onPress={() => openLink(instructor.socialLinks?.youtube)}>
                  <Ionicons name="logo-youtube" size={22} color={colors.textSecondary} />
                </TouchableOpacity>
              )}
              {instructor.socialLinks.twitter && (
                <TouchableOpacity onPress={() => openLink(instructor.socialLinks?.twitter)}>
                  <Ionicons name="logo-twitter" size={22} color={colors.textSecondary} />
                </TouchableOpacity>
              )}
              {instructor.socialLinks.linkedin && (
                <TouchableOpacity onPress={() => openLink(instructor.socialLinks?.linkedin)}>
                  <Ionicons name="logo-linkedin" size={22} color={colors.textSecondary} />
                </TouchableOpacity>
              )}
            </View>
          )}
        </View>

        {/* Bio */}
        {instructor.bio && (
          <View
            className="mx-4 mb-4 p-4 rounded-2xl border"
            style={{
              backgroundColor: colors.backgroundElement,
              borderColor: colors.backgroundSelected,
            }}
          >
            <Text style={{ color: colors.text, fontSize: 14, fontWeight: 'bold', marginBottom: 6 }}>
              About
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 13, lineHeight: 19 }}>
              {instructor.bio}
            </Text>
          </View>
        )}

        {/* Courses */}
        <View className="px-4">
          <Text style={{ color: colors.text, fontSize: 16, fontWeight: 'bold', marginBottom: 12 }}>
            Courses by {displayName}
          </Text>

          {coursesLoading ? (
            <View className="py-6 items-center">
              <ActivityIndicator color={colors.primary} />
            </View>
          ) : courses.length === 0 ? (
            <View className="py-8 items-center">
              <Ionicons name="book-outline" size={48} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, fontSize: 13, marginTop: 8 }}>
                No published courses yet.
              </Text>
            </View>
          ) : (
            courses.map((course) => (
              <TouchableOpacity
                key={course.id}
                className="flex-row rounded-2xl border p-3 mb-3"
                style={{
                  backgroundColor: colors.backgroundElement,
                  borderColor: colors.backgroundSelected,
                }}
                onPress={() => handleCoursePress(course.id)}
                activeOpacity={0.8}
              >
                <Image
                  source={{ 
                    uri: course.thumbnail || 'https://via.placeholder.com/80x64/4F46E5/FFFFFF?text=Course',
                    cache: 'force-cache',
                  }}
                  className="w-20 h-16 rounded-xl mr-3"
                  resizeMode="cover"
                  onError={() => console.log(`❌ Failed to load course thumbnail for ${course.title}`)}
                />
                <View className="flex-1">
                  <Text
                    style={{ color: colors.text, fontSize: 14, fontWeight: '600' }}
                    numberOfLines={2}
                  >
                    {course.title}
                  </Text>
                  <View className="flex-row items-center mt-2" style={{ gap: 12 }}>
                    <View className="flex-row items-center">
                      <Ionicons name="star" size={12} color="#FBBF24" />
                      <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 2 }}>
                        {(course.rating || 0).toFixed(1)}
                      </Text>
                    </View>
                    <View className="flex-row items-center">
                      <Ionicons name="people" size={12} color={colors.textSecondary} />
                      <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 2 }}>
                        {(course.students || 0).toLocaleString()}
                      </Text>
                    </View>
                    {course.price !== undefined && course.price > 0 && (
                      <Text style={{ color: colors.primary, fontSize: 13, fontWeight: 'bold' }}>
                        ${course.price}
                      </Text>
                    )}
                  </View>
                </View>
              </TouchableOpacity>
            ))
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}