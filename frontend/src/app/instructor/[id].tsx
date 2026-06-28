// app/instructors/[id].tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  Image,
  SafeAreaView,
  Share,
  Linking,
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

// Mock data - should match the data from the list
const MOCK_INSTRUCTOR_DATA: Record<string, Instructor> = {
  '1': {
    id: '1',
    name: 'Dr. Sarah Johnson',
    expertise: 'Data Science & AI',
    photo: 'https://randomuser.me/api/portraits/women/1.jpg',
    rating: 4.9,
    studentsCount: 24500,
    coursesCount: 28,
    bio: 'Leading AI researcher with 15+ years of experience in machine learning and deep learning. Passionate about making AI accessible to everyone. Published over 50 research papers and has been a keynote speaker at major AI conferences worldwide.',
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
  '2': {
    id: '2',
    name: 'Prof. Michael Chen',
    expertise: 'Web Development',
    photo: 'https://randomuser.me/api/portraits/men/2.jpg',
    rating: 4.8,
    studentsCount: 32000,
    coursesCount: 35,
    bio: 'Full-stack developer and educator with 10+ years of industry experience. Creator of popular React and Node.js courses. Previously worked at Google and Microsoft.',
    isFollowing: false,
    totalRevenue: '$3.1M',
    joinDate: '2019-06-20',
    socialLinks: {
      twitter: 'https://twitter.com',
      linkedin: 'https://linkedin.com',
      website: 'https://example.com',
    },
  },
};

// Mock courses for the instructor
const MOCK_COURSES = [
  {
    id: 'c1',
    title: 'Complete Data Science Bootcamp',
    thumbnail: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=300&fit=crop',
    rating: 4.9,
    students: 12450,
    price: 49.99,
  },
  {
    id: 'c2',
    title: 'Advanced Machine Learning',
    thumbnail: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=400&h=300&fit=crop',
    rating: 4.8,
    students: 8500,
    price: 59.99,
  },
  {
    id: 'c3',
    title: 'Deep Learning with PyTorch',
    thumbnail: 'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=400&h=300&fit=crop',
    rating: 4.7,
    students: 6200,
    price: 69.99,
  },
];

export default function InstructorProfileScreen() {
  const insets = useSafeAreaInsets();
  const { id } = useLocalSearchParams<{ id: string }>();
  const { isDarkMode, colors } = useTheme();
  const [instructor, setInstructor] = useState<Instructor | null>(null);
  const [isFollowing, setIsFollowing] = useState(false);
  const [activeTab, setActiveTab] = useState<'courses' | 'about' | 'reviews'>('courses');

  useEffect(() => {
    // Fetch instructor data
    const data = MOCK_INSTRUCTOR_DATA[id];
    if (data) {
      setInstructor(data);
      setIsFollowing(data.isFollowing);
    }
  }, [id]);

  const handleFollow = () => {
    setIsFollowing(!isFollowing);
    // Update following status in your state management
  };

  const handleShare = async () => {
    try {
      await Share.share({
        message: `Check out ${instructor?.name} on our platform!`,
        url: `https://yourapp.com/instructor/${id}`,
      });
    } catch (error) {
      console.error('Share error:', error);
    }
  };

  const handleSocialLink = (url: string) => {
    Linking.openURL(url).catch(() => {
      console.error('Failed to open URL');
    });
  };

  const handleCoursePress = (courseId: string) => {
    router.push(`/course/${courseId}` as any);
  };

  if (!instructor) {
    return (
      <SafeAreaView className="flex-1 items-center justify-center" style={{ backgroundColor: colors.background }}>
        <Text style={{ color: colors.textSecondary }}>Loading...</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView className="flex-1" style={{ backgroundColor: colors.background }}>
      <StatusBar style={isDarkMode ? 'light' : 'dark'} />

      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Header with Back Button */}
        <View className="absolute top-0 left-0 right-0 z-10 px-4 pt-4 flex-row justify-between">
          <TouchableOpacity
            className="w-10 h-10 rounded-full items-center justify-center"
            style={{ backgroundColor: isDarkMode ? 'rgba(30,41,59,0.9)' : 'rgba(255,255,255,0.9)' }}
            onPress={() => router.back()}
          >
            <Ionicons name="arrow-back" size={22} color={isDarkMode ? '#F1F5F9' : '#0F172A'} />
          </TouchableOpacity>
          <TouchableOpacity
            className="w-10 h-10 rounded-full items-center justify-center"
            style={{ backgroundColor: isDarkMode ? 'rgba(30,41,59,0.9)' : 'rgba(255,255,255,0.9)' }}
            onPress={handleShare}
          >
            <Ionicons name="share-outline" size={22} color={isDarkMode ? '#F1F5F9' : '#0F172A'} />
          </TouchableOpacity>
        </View>

        {/* Profile Header */}
        <View className="px-4 pt-12 pb-6" style={{ 
          backgroundColor: colors.backgroundElement,
          borderBottomWidth: 1,
          borderBottomColor: colors.backgroundSelected,
        }}>
          <View className="items-center">
            <Image
              source={{ uri: instructor.photo }}
              className="w-24 h-24 rounded-full mb-4"
            />
            
            <Text style={{ color: colors.text, fontSize: 24, fontWeight: 'bold' }}>
              {instructor.name}
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 16, marginTop: 2 }}>
              {instructor.expertise}
            </Text>

            <View className="flex-row items-center mt-2 space-x-4">
              <View className="flex-row items-center">
                <Ionicons name="star" size={16} color="#FBBF24" />
                <Text style={{ color: colors.text, fontWeight: '600', marginLeft: 4 }}>
                  {instructor.rating.toFixed(1)}
                </Text>
              </View>
              <View className="flex-row items-center">
                <Ionicons name="people" size={16} color={colors.textSecondary} />
                <Text style={{ color: colors.textSecondary, marginLeft: 4 }}>
                  {instructor.studentsCount.toLocaleString()} students
                </Text>
              </View>
              <View className="flex-row items-center">
                <Ionicons name="book" size={16} color={colors.textSecondary} />
                <Text style={{ color: colors.textSecondary, marginLeft: 4 }}>
                  {instructor.coursesCount} courses
                </Text>
              </View>
            </View>

            {/* Action Buttons */}
            <View className="flex-row items-center mt-4 space-x-3">
              <TouchableOpacity
                className={`flex-1 py-2.5 rounded-xl ${
                  isFollowing 
                    ? 'border' 
                    : ''
                }`}
                style={{
                  backgroundColor: isFollowing ? 'transparent' : colors.primary,
                  borderColor: colors.primary,
                }}
                onPress={handleFollow}
              >
                <Text
                  style={{
                    textAlign: 'center',
                    fontWeight: 'bold',
                    color: isFollowing ? colors.primary : '#FFFFFF',
                  }}
                >
                  {isFollowing ? 'Following' : 'Follow'}
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                className="flex-1 py-2.5 rounded-xl border"
                style={{
                  backgroundColor: isDarkMode ? 'rgba(96,165,250,0.1)' : '#EFF6FF',
                  borderColor: colors.primary,
                }}
                onPress={() => console.log('Message instructor')}
              >
                <Text style={{ textAlign: 'center', fontWeight: 'bold', color: colors.primary }}>
                  Message
                </Text>
              </TouchableOpacity>
            </View>

            {/* Social Links */}
            {instructor.socialLinks && (
              <View className="flex-row items-center mt-4 space-x-3">
                {instructor.socialLinks.youtube && (
                  <TouchableOpacity
                    className="w-10 h-10 rounded-full items-center justify-center"
                    style={{ backgroundColor: isDarkMode ? 'rgba(255,0,0,0.2)' : 'rgba(255,0,0,0.1)' }}
                    onPress={() => handleSocialLink(instructor.socialLinks!.youtube!)}
                  >
                    <Ionicons name="logo-youtube" size={20} color="#FF0000" />
                  </TouchableOpacity>
                )}
                {instructor.socialLinks.twitter && (
                  <TouchableOpacity
                    className="w-10 h-10 rounded-full items-center justify-center"
                    style={{ backgroundColor: isDarkMode ? 'rgba(29,161,242,0.2)' : 'rgba(29,161,242,0.1)' }}
                    onPress={() => handleSocialLink(instructor.socialLinks!.twitter!)}
                  >
                    <Ionicons name="logo-twitter" size={20} color="#1DA1F2" />
                  </TouchableOpacity>
                )}
                {instructor.socialLinks.linkedin && (
                  <TouchableOpacity
                    className="w-10 h-10 rounded-full items-center justify-center"
                    style={{ backgroundColor: isDarkMode ? 'rgba(10,102,194,0.2)' : 'rgba(10,102,194,0.1)' }}
                    onPress={() => handleSocialLink(instructor.socialLinks!.linkedin!)}
                  >
                    <Ionicons name="logo-linkedin" size={20} color="#0A66C2" />
                  </TouchableOpacity>
                )}
                {instructor.socialLinks.website && (
                  <TouchableOpacity
                    className="w-10 h-10 rounded-full items-center justify-center"
                    style={{ backgroundColor: isDarkMode ? 'rgba(96,165,250,0.2)' : 'rgba(37,99,235,0.1)' }}
                    onPress={() => handleSocialLink(instructor.socialLinks!.website!)}
                  >
                    <Ionicons name="globe-outline" size={20} color={colors.primary} />
                  </TouchableOpacity>
                )}
              </View>
            )}
          </View>
        </View>

        {/* Stats */}
        <View className="px-4 py-4" style={{ 
          backgroundColor: colors.backgroundElement,
          borderBottomWidth: 1,
          borderBottomColor: colors.backgroundSelected,
        }}>
          <View className="flex-row justify-around">
            <View className="items-center">
              <Text style={{ color: colors.text, fontSize: 20, fontWeight: 'bold' }}>
                {instructor.studentsCount.toLocaleString()}
              </Text>
              <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Students</Text>
            </View>
            <View className="items-center">
              <Text style={{ color: colors.text, fontSize: 20, fontWeight: 'bold' }}>
                {instructor.coursesCount}
              </Text>
              <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Courses</Text>
            </View>
            <View className="items-center">
              <Text style={{ color: colors.text, fontSize: 20, fontWeight: 'bold' }}>
                {instructor.totalRevenue || 'N/A'}
              </Text>
              <Text style={{ color: colors.textSecondary, fontSize: 12 }}>Revenue</Text>
            </View>
          </View>
        </View>

        {/* Tabs */}
        <View className="px-4" style={{ 
          backgroundColor: colors.backgroundElement,
          borderBottomWidth: 1,
          borderBottomColor: colors.backgroundSelected,
        }}>
          <View className="flex-row">
            {['courses', 'about', 'reviews'].map((tab) => (
              <TouchableOpacity
                key={tab}
                className={`py-3 px-4 ${activeTab === tab ? 'border-b-2' : ''}`}
                style={{ borderColor: activeTab === tab ? colors.primary : 'transparent' }}
                onPress={() => setActiveTab(tab as 'courses' | 'about' | 'reviews')}
              >
                <Text
                  style={{
                    fontSize: 14,
                    fontWeight: '500',
                    color: activeTab === tab ? colors.primary : colors.textSecondary,
                  }}
                >
                  {tab.charAt(0).toUpperCase() + tab.slice(1)}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Tab Content */}
        <View className="p-4">
          {activeTab === 'courses' && (
            <View>
              <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold', marginBottom: 16 }}>
                Courses by {instructor.name}
              </Text>
              {MOCK_COURSES.map((course) => (
                <TouchableOpacity
                  key={course.id}
                  className="rounded-xl border mb-3 overflow-hidden"
                  style={{
                    backgroundColor: colors.backgroundElement,
                    borderColor: colors.backgroundSelected,
                  }}
                  onPress={() => handleCoursePress(course.id)}
                >
                  <Image
                    source={{ uri: course.thumbnail }}
                    className="w-full h-40"
                    resizeMode="cover"
                  />
                  <View className="p-3">
                    <Text style={{ color: colors.text, fontWeight: '600', fontSize: 16 }} numberOfLines={1}>
                      {course.title}
                    </Text>
                    <View className="flex-row items-center mt-1 justify-between">
                      <View className="flex-row items-center">
                        <Ionicons name="star" size={14} color="#FBBF24" />
                        <Text style={{ color: colors.text, fontSize: 12, fontWeight: '500', marginLeft: 2 }}>
                          {course.rating.toFixed(1)}
                        </Text>
                        <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 4 }}>
                          ({course.students.toLocaleString()})
                        </Text>
                      </View>
                      <Text style={{ color: colors.primary, fontWeight: 'bold', fontSize: 14 }}>
                        ${course.price}
                      </Text>
                    </View>
                  </View>
                </TouchableOpacity>
              ))}
            </View>
          )}

          {activeTab === 'about' && (
            <View className="rounded-xl border p-4" style={{
              backgroundColor: colors.backgroundElement,
              borderColor: colors.backgroundSelected,
            }}>
              <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold', marginBottom: 12 }}>
                About
              </Text>
              <Text style={{ color: colors.textSecondary, lineHeight: 20 }}>
                {instructor.bio}
              </Text>
              
              <View className="mt-4 pt-4" style={{ borderTopWidth: 1, borderTopColor: colors.backgroundSelected }}>
                <View className="flex-row items-center mb-2">
                  <Ionicons name="calendar-outline" size={18} color={colors.textSecondary} />
                  <Text style={{ color: colors.textSecondary, fontSize: 14, marginLeft: 8 }}>
                    Joined {new Date(instructor.joinDate || '').toLocaleDateString('en-US', {
                      month: 'long',
                      year: 'numeric',
                    })}
                  </Text>
                </View>
                <View className="flex-row items-center">
                  <Ionicons name="trophy-outline" size={18} color={colors.textSecondary} />
                  <Text style={{ color: colors.textSecondary, fontSize: 14, marginLeft: 8 }}>
                    {instructor.studentsCount.toLocaleString()} students taught
                  </Text>
                </View>
              </View>
            </View>
          )}

          {activeTab === 'reviews' && (
            <View className="rounded-xl border p-4" style={{
              backgroundColor: colors.backgroundElement,
              borderColor: colors.backgroundSelected,
            }}>
              <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold', marginBottom: 16 }}>
                Reviews
              </Text>
              {[1, 2, 3].map((review) => (
                <View key={review} className="mb-4 pb-4" style={{ 
                  borderBottomWidth: review < 3 ? 1 : 0,
                  borderBottomColor: colors.backgroundSelected,
                }}>
                  <View className="flex-row items-center">
                    <Image
                      source={{ uri: `https://randomuser.me/api/portraits/men/${review}.jpg` }}
                      className="w-10 h-10 rounded-full"
                    />
                    <View className="ml-3 flex-1">
                      <Text style={{ color: colors.text, fontWeight: '600', fontSize: 14 }}>
                        Student {review}
                      </Text>
                      <View className="flex-row items-center">
                        {[1, 2, 3, 4, 5].map((star) => (
                          <Ionicons
                            key={star}
                            name={star <= 4 ? 'star' : 'star-outline'}
                            size={14}
                            color="#FBBF24"
                          />
                        ))}
                      </View>
                    </View>
                  </View>
                  <Text style={{ color: colors.textSecondary, fontSize: 14, marginTop: 8 }}>
                    Great instructor! Very clear explanations and practical examples.
                  </Text>
                </View>
              ))}
            </View>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}