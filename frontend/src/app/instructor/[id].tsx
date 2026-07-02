// app/instructor/[id].tsx
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
  Dimensions,
  Linking,
  Share,
  Alert,
} from 'react-native';
import { Ionicons, FontAwesome } from '@expo/vector-icons';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { useTheme } from '@/context/themeContext';
import { useAuthStore } from '@/store/authStore';
import { StatusBar } from 'expo-status-bar';
import { instructorApi } from '@/services/instructorService';

const { width } = Dimensions.get('window');

interface InstructorProfile {
  id: string;
  firstName: string;
  lastName: string;
  email?: string;
  photo?: string;
  bio?: string;
  expertise?: string;
  rating: number;
  totalStudents: number;
  totalCourses: number;
  followerCount: number;
  isFollowing: boolean;
  isVerified: boolean;
  socialLinks?: {
    youtube?: string;
    twitter?: string;
    linkedin?: string;
    website?: string;
  };
  courses?: any[];
  reviews?: any[];
  joinedDate?: string;
  location?: string;
  languages?: string[];
}

export default function InstructorProfilePage() {
  const router = useRouter();
  const { id } = useLocalSearchParams();
  const { isDarkMode, colors } = useTheme();
  const { user, isAuthenticated } = useAuthStore();

  const [instructor, setInstructor] = useState<InstructorProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [following, setFollowing] = useState(false);
  const [loadingFollow, setLoadingFollow] = useState(false);
  const [activeTab, setActiveTab] = useState<'courses' | 'reviews' | 'about'>('courses');
  const [error, setError] = useState<string | null>(null);

  // Fetch instructor data using the correct API
  const loadInstructor = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Use the correct endpoint for instructor profile
      const data = await instructorApi.getInstructorById(id as string);
      
      console.log('📊 Instructor data:', data);
      
      // Map the response to our interface
      setInstructor({
        id: data.id,
        firstName: data.firstName || data.name?.split(' ')[0] || 'Instructor',
        lastName: data.lastName || data.name?.split(' ').slice(1).join(' ') || '',
        photo: data.photo || data.avatar || '',
        bio: data.bio || '',
        expertise: data.expertise || '',
        rating: data.rating || data.averageRating || 0,
        totalStudents: data.totalStudents || data.studentsCount || 0,
        totalCourses: data.totalCourses || data.coursesCount || 0,
        followerCount: data.followerCount || 0,
        isFollowing: data.isFollowing || false,
        isVerified: data.isVerified || false,
        socialLinks: data.socialLinks || {},
        courses: data.courses || [],
        reviews: data.reviews || [],
        joinedDate: data.joinedDate || data.createdAt,
        location: data.location || '',
        languages: data.languages || [],
      });
      
      setFollowing(data.isFollowing || false);
    } catch (error: any) {
      console.error('❌ Failed to load instructor:', error);
      setError(error.message || 'Failed to load instructor profile');
      Alert.alert('Error', 'Failed to load instructor profile');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    loadInstructor();
  }, [loadInstructor]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadInstructor();
    setRefreshing(false);
  }, [loadInstructor]);

  const handleFollow = async () => {
    if (!isAuthenticated) {
      Alert.alert('Login Required', 'Please login to follow instructors');
      return;
    }

    try {
      setLoadingFollow(true);
      
      if (following) {
        await instructorApi.unfollowInstructor(id as string);
        setFollowing(false);
        setInstructor(prev => prev ? {
          ...prev,
          followerCount: (prev.followerCount || 1) - 1
        } : null);
      } else {
        await instructorApi.followInstructor(id as string);
        setFollowing(true);
        setInstructor(prev => prev ? {
          ...prev,
          followerCount: (prev.followerCount || 0) + 1
        } : null);
      }
    } catch (error) {
      console.error('❌ Failed to toggle follow:', error);
      Alert.alert('Error', 'Failed to update follow status');
    } finally {
      setLoadingFollow(false);
    }
  };

  const handleShare = async () => {
    try {
      await Share.share({
        message: `Check out ${instructor?.firstName} ${instructor?.lastName} on our platform!`,
        url: `https://yourapp.com/instructor/${id}`,
      });
    } catch (error) {
      console.error('Failed to share:', error);
    }
  };

  const handleSocialLink = (url: string) => {
    if (url) {
      Linking.openURL(url).catch(() => {
        Alert.alert('Error', 'Cannot open this link');
      });
    }
  };

  const handleCoursePress = (courseId: string) => {
    router.push(`/course-details/${courseId}` as any);
  };

  const getInitials = (firstName: string, lastName: string) => {
    return `${firstName?.[0] || ''}${lastName?.[0] || ''}`.toUpperCase();
  };

  const getExpertiseArray = (expertise: string | undefined): string[] => {
    if (!expertise) return [];
    if (Array.isArray(expertise)) return expertise;
    return expertise.split(',').map(s => s.trim()).filter(Boolean);
  };

  const renderStatItem = (label: string, value: number | string, icon: string) => (
    <View style={{ alignItems: 'center', flex: 1 }}>
      <View style={{
        width: 48,
        height: 48,
        borderRadius: 24,
        backgroundColor: `${colors.primary}20`,
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: 6,
      }}>
        <Ionicons name={icon as any} size={24} color={colors.primary} />
      </View>
      <Text style={{ color: colors.text, fontSize: 20, fontWeight: 'bold' }}>
        {typeof value === 'number' ? value.toLocaleString() : value}
      </Text>
      <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 2 }}>
        {label}
      </Text>
    </View>
  );

  const renderCoursesTab = () => {
    if (!instructor?.courses || instructor.courses.length === 0) {
      return (
        <View style={{ alignItems: 'center', paddingVertical: 40 }}>
          <Ionicons name="book-outline" size={48} color={colors.textSecondary} />
          <Text style={{ color: colors.textSecondary, marginTop: 12 }}>
            No courses available
          </Text>
        </View>
      );
    }

    return instructor.courses.map((course: any) => (
      <TouchableOpacity
        key={course.id}
        style={{
          backgroundColor: colors.backgroundElement,
          borderRadius: 12,
          marginBottom: 12,
          borderWidth: 1,
          borderColor: colors.backgroundSelected,
          overflow: 'hidden',
        }}
        onPress={() => handleCoursePress(course.id)}
        activeOpacity={0.8}
      >
        {course.thumbnail && (
          <Image
            source={{ uri: course.thumbnail }}
            style={{ width: '100%', height: 150 }}
            resizeMode="cover"
          />
        )}
        <View style={{ padding: 12 }}>
          <Text style={{ color: colors.text, fontSize: 16, fontWeight: '600' }}>
            {course.title}
          </Text>
          <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 4 }}>
            <Ionicons name="star" size={14} color="#FBBF24" />
            <Text style={{ color: colors.text, fontSize: 12, marginLeft: 4 }}>
              {course.rating?.toFixed(1) || '0.0'}
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 8 }}>
              {course.studentsCount?.toLocaleString() || 0} students
            </Text>
          </View>
          {course.price && (
            <Text style={{ color: colors.primary, fontSize: 16, fontWeight: 'bold', marginTop: 4 }}>
              ${course.price}
            </Text>
          )}
        </View>
      </TouchableOpacity>
    ));
  };

  const renderReviewsTab = () => {
    if (!instructor?.reviews || instructor.reviews.length === 0) {
      return (
        <View style={{ alignItems: 'center', paddingVertical: 40 }}>
          <Ionicons name="chatbubbles-outline" size={48} color={colors.textSecondary} />
          <Text style={{ color: colors.textSecondary, marginTop: 12 }}>
            No reviews yet
          </Text>
        </View>
      );
    }

    return instructor.reviews.map((review: any, index: number) => (
      <View
        key={index}
        style={{
          backgroundColor: colors.backgroundElement,
          borderRadius: 12,
          padding: 12,
          marginBottom: 12,
          borderWidth: 1,
          borderColor: colors.backgroundSelected,
        }}
      >
        <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 8 }}>
          <Text style={{ color: colors.text, fontWeight: '600', flex: 1 }}>
            {review.userName || review.user?.name || 'Anonymous'}
          </Text>
          <View style={{ flexDirection: 'row', alignItems: 'center' }}>
            <Ionicons name="star" size={14} color="#FBBF24" />
            <Text style={{ color: colors.text, marginLeft: 4 }}>
              {review.rating?.toFixed(1) || '0.0'}
            </Text>
          </View>
        </View>
        <Text style={{ color: colors.textSecondary, fontSize: 14 }}>
          {review.comment || review.content || 'No comment provided'}
        </Text>
        <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 4 }}>
          {review.createdAt ? new Date(review.createdAt).toLocaleDateString() : ''}
        </Text>
      </View>
    ));
  };

  const renderAboutTab = () => {
    if (!instructor) return null;

    const expertiseArray = getExpertiseArray(instructor.expertise);

    return (
      <View style={{ marginTop: 8 }}>
        <View style={{
          backgroundColor: colors.backgroundElement,
          borderRadius: 12,
          padding: 16,
          borderWidth: 1,
          borderColor: colors.backgroundSelected,
        }}>
          <Text style={{ color: colors.text, fontSize: 16, fontWeight: 'bold', marginBottom: 8 }}>
            About
          </Text>
          <Text style={{ color: colors.textSecondary, lineHeight: 22 }}>
            {instructor.bio || 'No bio available'}
          </Text>

          {expertiseArray.length > 0 && (
            <View style={{ marginTop: 16 }}>
              <Text style={{ color: colors.text, fontSize: 14, fontWeight: '600', marginBottom: 8 }}>
                Expertise
              </Text>
              <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
                {expertiseArray.map((skill, index) => (
                  <View
                    key={index}
                    style={{
                      backgroundColor: `${colors.primary}20`,
                      paddingHorizontal: 12,
                      paddingVertical: 6,
                      borderRadius: 16,
                      marginRight: 8,
                      marginBottom: 8,
                    }}
                  >
                    <Text style={{ color: colors.primary, fontSize: 12 }}>
                      {skill}
                    </Text>
                  </View>
                ))}
              </View>
            </View>
          )}

          {instructor.languages && instructor.languages.length > 0 && (
            <View style={{ marginTop: 16 }}>
              <Text style={{ color: colors.text, fontSize: 14, fontWeight: '600', marginBottom: 8 }}>
                Languages
              </Text>
              <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
                {instructor.languages.map((language, index) => (
                  <View
                    key={index}
                    style={{
                      backgroundColor: colors.backgroundSelected,
                      paddingHorizontal: 12,
                      paddingVertical: 6,
                      borderRadius: 16,
                      marginRight: 8,
                      marginBottom: 8,
                    }}
                  >
                    <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
                      {language}
                    </Text>
                  </View>
                ))}
              </View>
            </View>
          )}

          {instructor.location && (
            <View style={{ marginTop: 16, flexDirection: 'row', alignItems: 'center' }}>
              <Ionicons name="location-outline" size={18} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, marginLeft: 8 }}>
                {instructor.location}
              </Text>
            </View>
          )}

          {instructor.joinedDate && (
            <View style={{ marginTop: 8, flexDirection: 'row', alignItems: 'center' }}>
              <Ionicons name="calendar-outline" size={18} color={colors.textSecondary} />
              <Text style={{ color: colors.textSecondary, marginLeft: 8 }}>
                Joined {new Date(instructor.joinedDate).toLocaleDateString('en-US', {
                  month: 'long',
                  year: 'numeric'
                })}
              </Text>
            </View>
          )}
        </View>

        {instructor.socialLinks && Object.values(instructor.socialLinks).some(link => link) && (
          <View style={{
            backgroundColor: colors.backgroundElement,
            borderRadius: 12,
            padding: 16,
            marginTop: 12,
            borderWidth: 1,
            borderColor: colors.backgroundSelected,
          }}>
            <Text style={{ color: colors.text, fontSize: 16, fontWeight: 'bold', marginBottom: 12 }}>
              Connect
            </Text>
            <View style={{ flexDirection: 'row', justifyContent: 'space-around' }}>
              {instructor.socialLinks.youtube && (
                <TouchableOpacity
                  onPress={() => handleSocialLink(instructor.socialLinks!.youtube!)}
                  style={{ alignItems: 'center' }}
                >
                  <View style={{
                    width: 44,
                    height: 44,
                    borderRadius: 22,
                    backgroundColor: '#FF000020',
                    justifyContent: 'center',
                    alignItems: 'center',
                  }}>
                    <FontAwesome name="youtube" size={22} color="#FF0000" />
                  </View>
                  <Text style={{ color: colors.textSecondary, fontSize: 10, marginTop: 4 }}>
                    YouTube
                  </Text>
                </TouchableOpacity>
              )}
              {instructor.socialLinks.twitter && (
                <TouchableOpacity
                  onPress={() => handleSocialLink(instructor.socialLinks!.twitter!)}
                  style={{ alignItems: 'center' }}
                >
                  <View style={{
                    width: 44,
                    height: 44,
                    borderRadius: 22,
                    backgroundColor: '#1DA1F220',
                    justifyContent: 'center',
                    alignItems: 'center',
                  }}>
                    <FontAwesome name="twitter" size={22} color="#1DA1F2" />
                  </View>
                  <Text style={{ color: colors.textSecondary, fontSize: 10, marginTop: 4 }}>
                    Twitter
                  </Text>
                </TouchableOpacity>
              )}
              {instructor.socialLinks.linkedin && (
                <TouchableOpacity
                  onPress={() => handleSocialLink(instructor.socialLinks!.linkedin!)}
                  style={{ alignItems: 'center' }}
                >
                  <View style={{
                    width: 44,
                    height: 44,
                    borderRadius: 22,
                    backgroundColor: '#0A66C220',
                    justifyContent: 'center',
                    alignItems: 'center',
                  }}>
                    <FontAwesome name="linkedin" size={22} color="#0A66C2" />
                  </View>
                  <Text style={{ color: colors.textSecondary, fontSize: 10, marginTop: 4 }}>
                    LinkedIn
                  </Text>
                </TouchableOpacity>
              )}
              {instructor.socialLinks.website && (
                <TouchableOpacity
                  onPress={() => handleSocialLink(instructor.socialLinks!.website!)}
                  style={{ alignItems: 'center' }}
                >
                  <View style={{
                    width: 44,
                    height: 44,
                    borderRadius: 22,
                    backgroundColor: colors.backgroundSelected,
                    justifyContent: 'center',
                    alignItems: 'center',
                  }}>
                    <Ionicons name="globe-outline" size={22} color={colors.text} />
                  </View>
                  <Text style={{ color: colors.textSecondary, fontSize: 10, marginTop: 4 }}>
                    Website
                  </Text>
                </TouchableOpacity>
              )}
            </View>
          </View>
        )}
      </View>
    );
  };

  if (loading) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
        <StatusBar style={isDarkMode ? 'light' : 'dark'} />
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
          <ActivityIndicator size="large" color={colors.primary} />
        </View>
      </SafeAreaView>
    );
  }

  if (!instructor || error) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
        <StatusBar style={isDarkMode ? 'light' : 'dark'} />
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', padding: 20 }}>
          <Ionicons name="person-outline" size={64} color={colors.textSecondary} />
          <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold', marginTop: 16 }}>
            {error || 'Instructor not found'}
          </Text>
          <TouchableOpacity
            onPress={() => router.back()}
            style={{
              marginTop: 24,
              backgroundColor: colors.primary,
              paddingHorizontal: 32,
              paddingVertical: 12,
              borderRadius: 12,
            }}
          >
            <Text style={{ color: '#FFFFFF', fontWeight: '600' }}>Go Back</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  const fullName = `${instructor.firstName} ${instructor.lastName}`;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <StatusBar style={isDarkMode ? 'light' : 'dark'} />

      <View style={{
        paddingHorizontal: 16,
        paddingTop: 12,
        paddingBottom: 16,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        borderBottomWidth: 1,
        borderBottomColor: colors.backgroundSelected,
      }}>
        <TouchableOpacity onPress={() => router.back()} style={{ padding: 4 }}>
          <Ionicons name="arrow-back" size={24} color={colors.text} />
        </TouchableOpacity>
        <Text style={{ color: colors.text, fontSize: 18, fontWeight: '600', flex: 1, marginLeft: 12 }}>
          Profile
        </Text>
        <TouchableOpacity onPress={handleShare} style={{ padding: 4 }}>
          <Ionicons name="share-outline" size={24} color={colors.text} />
        </TouchableOpacity>
      </View>

      <ScrollView
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.primary}
            colors={[colors.primary]}
          />
        }
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: 40 }}
      >
        <View style={{ alignItems: 'center', paddingTop: 24, paddingHorizontal: 20 }}>
          <TouchableOpacity>
            <View style={{
              width: 120,
              height: 120,
              borderRadius: 60,
              overflow: 'hidden',
              backgroundColor: colors.backgroundSelected,
              borderWidth: 4,
              borderColor: colors.primary,
            }}>
              {instructor.photo ? (
                <Image
                  source={{ uri: instructor.photo }}
                  style={{ width: 120, height: 120 }}
                  resizeMode="cover"
                />
              ) : (
                <View style={{
                  flex: 1,
                  backgroundColor: colors.primary,
                  justifyContent: 'center',
                  alignItems: 'center',
                }}>
                  <Text style={{ color: '#FFFFFF', fontSize: 40, fontWeight: 'bold' }}>
                    {getInitials(instructor.firstName, instructor.lastName)}
                  </Text>
                </View>
              )}
            </View>
          </TouchableOpacity>

          {instructor.isVerified && (
            <View style={{
              position: 'absolute',
              top: 124,
              right: width / 2 - 60,
              backgroundColor: '#3B82F6',
              borderRadius: 14,
              width: 28,
              height: 28,
              justifyContent: 'center',
              alignItems: 'center',
              borderWidth: 3,
              borderColor: colors.background,
            }}>
              <Ionicons name="checkmark" size={16} color="#FFFFFF" />
            </View>
          )}

          <Text style={{ color: colors.text, fontSize: 24, fontWeight: 'bold', marginTop: 16 }}>
            {fullName}
          </Text>

          {instructor.expertise && (
            <Text style={{ color: colors.textSecondary, fontSize: 16, marginTop: 4 }}>
              {instructor.expertise}
            </Text>
          )}

          {instructor.bio && (
            <Text style={{
              color: colors.textSecondary,
              fontSize: 14,
              textAlign: 'center',
              marginTop: 8,
              paddingHorizontal: 20,
            }}>
              {instructor.bio}
            </Text>
          )}

          <View style={{ flexDirection: 'row', marginTop: 16 }}>
            <TouchableOpacity
              style={{
                backgroundColor: following ? 'transparent' : colors.primary,
                paddingHorizontal: 32,
                paddingVertical: 10,
                borderRadius: 25,
                borderWidth: 1,
                borderColor: following ? colors.primary : colors.primary,
                flexDirection: 'row',
                alignItems: 'center',
                opacity: loadingFollow ? 0.5 : 1,
              }}
              onPress={handleFollow}
              disabled={loadingFollow}
            >
              {loadingFollow ? (
                <ActivityIndicator size="small" color={following ? colors.primary : '#FFFFFF'} />
              ) : (
                <>
                  <Ionicons
                    name={following ? 'checkmark' : 'person-add'}
                    size={18}
                    color={following ? colors.primary : '#FFFFFF'}
                  />
                  <Text style={{
                    color: following ? colors.primary : '#FFFFFF',
                    fontWeight: '600',
                    marginLeft: 8,
                  }}>
                    {following ? 'Following' : 'Follow'}
                  </Text>
                </>
              )}
            </TouchableOpacity>

            <TouchableOpacity
              style={{
                backgroundColor: colors.backgroundElement,
                paddingHorizontal: 20,
                paddingVertical: 10,
                borderRadius: 25,
                borderWidth: 1,
                borderColor: colors.backgroundSelected,
                marginLeft: 12,
              }}
              onPress={() => {
                Alert.alert('Message', 'Messaging feature coming soon!');
              }}
            >
              <Ionicons name="chatbubble-outline" size={20} color={colors.text} />
            </TouchableOpacity>
          </View>
        </View>

        <View style={{
          flexDirection: 'row',
          marginTop: 24,
          paddingVertical: 16,
          paddingHorizontal: 20,
          backgroundColor: colors.backgroundElement,
          borderTopWidth: 1,
          borderBottomWidth: 1,
          borderColor: colors.backgroundSelected,
        }}>
          {renderStatItem('Students', instructor.totalStudents || 0, 'people-outline')}
          {renderStatItem('Courses', instructor.totalCourses || 0, 'book-outline')}
          {renderStatItem('Followers', instructor.followerCount || 0, 'heart-outline')}
        </View>

        <View style={{
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'center',
          paddingVertical: 12,
        }}>
          <Ionicons name="star" size={20} color="#FBBF24" />
          <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold', marginLeft: 8 }}>
            {instructor.rating?.toFixed(1) || '0.0'}
          </Text>
          <Text style={{ color: colors.textSecondary, fontSize: 14, marginLeft: 4 }}>
            ({instructor.reviews?.length || 0} reviews)
          </Text>
        </View>

        <View style={{
          flexDirection: 'row',
          paddingHorizontal: 20,
          marginTop: 8,
          borderBottomWidth: 1,
          borderBottomColor: colors.backgroundSelected,
        }}>
          {['courses', 'reviews', 'about'].map((tab) => (
            <TouchableOpacity
              key={tab}
              style={{
                flex: 1,
                paddingVertical: 12,
                borderBottomWidth: 2,
                borderBottomColor: activeTab === tab ? colors.primary : 'transparent',
              }}
              onPress={() => setActiveTab(tab as any)}
            >
              <Text style={{
                color: activeTab === tab ? colors.primary : colors.textSecondary,
                textAlign: 'center',
                fontWeight: activeTab === tab ? '600' : '500',
                fontSize: 14,
                textTransform: 'capitalize',
              }}>
                {tab}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        <View style={{ paddingHorizontal: 20, paddingTop: 16 }}>
          {activeTab === 'courses' && renderCoursesTab()}
          {activeTab === 'reviews' && renderReviewsTab()}
          {activeTab === 'about' && renderAboutTab()}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}