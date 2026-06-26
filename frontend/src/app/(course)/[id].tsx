// app/course/[id].tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  Image,
  SafeAreaView,
  Dimensions,
  Share,
  Alert,
  ActivityIndicator,
  TextInput,
  KeyboardAvoidingView,
  Platform,
  Modal,
} from 'react-native';
import { router, useLocalSearchParams, Stack } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Video, ResizeMode } from 'expo-av';
import { useHomeStore } from '@/store/homeStore';
import { useAuthStore } from '@/store/authStore';

const { width } = Dimensions.get('window');

interface Comment {
  id: string;
  userId: string;
  userName: string;
  userAvatar?: string;
  text: string;
  timestamp: string;
  likes: number;
  isLiked: boolean;
  replies: Comment[];
  parentId?: string;
}

interface CourseDetail {
  id: string;
  title: string;
  instructor: string;
  instructorAvatar?: string;
  thumbnail: string;
  videoUrl?: string;
  progress: number;
  remainingTime: string;
  rating: number;
  students: number;
  duration: string;
  level: 'Beginner' | 'Intermediate' | 'Advanced';
  description: string;
  whatYouWillLearn: string[];
  curriculum: {
    title: string;
    duration: string;
    completed: boolean;
    videoId?: string;
  }[];
  reviews: {
    id: string;
    user: string;
    avatar?: string;
    rating: number;
    comment: string;
    date: string;
  }[];
  relatedCourses: {
    id: string;
    title: string;
    thumbnail: string;
    instructor: string;
    rating: number;
  }[];
}

export default function CourseDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const insets = useSafeAreaInsets();
  const { user, getDisplayName, getInitials } = useAuthStore();
  const { updateCourseProgress, updateContinueLearning } = useHomeStore();
  
  const [loading, setLoading] = useState(true);
  const [course, setCourse] = useState<CourseDetail | null>(null);
  const [activeTab, setActiveTab] = useState<'overview' | 'curriculum' | 'reviews' | 'comments'>('overview');
  const [isPlaying, setIsPlaying] = useState(false);
  const [isSaved, setIsSaved] = useState(false);
  const [isExpanded, setIsExpanded] = useState(false);
  
  // Comments state
  const [comments, setComments] = useState<Comment[]>([]);
  const [newComment, setNewComment] = useState('');
  const [replyingTo, setReplyingTo] = useState<string | null>(null);
  const [replyText, setReplyText] = useState('');
  const [isCommentModalVisible, setIsCommentModalVisible] = useState(false);
  const [selectedComment, setSelectedComment] = useState<Comment | null>(null);
  const [isLoadingComments, setIsLoadingComments] = useState(false);

  // Get user display info
  const displayName = getDisplayName();
  const userInitials = getInitials();
  const userAvatar = user?.avatar || 'https://picsum.photos/seed/default/200/200';

  useEffect(() => {
    if (id) {
      fetchCourseDetail();
      fetchComments();
    }
  }, [id]);

  const fetchCourseDetail = async () => {
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const mockCourse: CourseDetail = {
        id: id || '1',
        title: 'React Native Mastery: Build Production-Ready Apps',
        instructor: 'John Doe',
        instructorAvatar: 'https://picsum.photos/seed/john/200/200',
        thumbnail: 'https://picsum.photos/seed/rnmastery/800/400',
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
        progress: 65,
        remainingTime: '4h 20m',
        rating: 4.8,
        students: 15400,
        duration: '12h 30m',
        level: 'Intermediate',
        description: 'Master React Native from basics to advanced. Build real-world applications with modern practices, hooks, navigation, state management, and deployment.',
        whatYouWillLearn: [
          'Build production-ready React Native apps',
          'Master React Native Navigation',
          'State management with Redux Toolkit & Zustand',
          'Implement authentication and authorization',
          'Work with native APIs and device features',
          'Deploy apps to App Store and Google Play',
          'Write clean, maintainable code',
          'Implement push notifications and deep linking',
        ],
        curriculum: [
          { title: 'Introduction to React Native', duration: '15 min', completed: true, videoId: 'video1' },
          { title: 'Setting Up Development Environment', duration: '20 min', completed: true, videoId: 'video2' },
          { title: 'Understanding Components and Props', duration: '25 min', completed: true, videoId: 'video3' },
          { title: 'State Management with Hooks', duration: '30 min', completed: true, videoId: 'video4' },
          { title: 'Navigation with React Navigation', duration: '35 min', completed: false, videoId: 'video5' },
          { title: 'Working with APIs', duration: '40 min', completed: false, videoId: 'video6' },
          { title: 'Authentication Implementation', duration: '45 min', completed: false, videoId: 'video7' },
          { title: 'Deployment to App Stores', duration: '30 min', completed: false, videoId: 'video8' },
        ],
        reviews: [
          {
            id: '1',
            user: 'Alice Johnson',
            avatar: 'https://picsum.photos/seed/alice/200/200',
            rating: 5,
            comment: 'Excellent course! Very comprehensive and well-structured.',
            date: '2 days ago',
          },
          {
            id: '2',
            user: 'Bob Smith',
            avatar: 'https://picsum.photos/seed/bob/200/200',
            rating: 4,
            comment: 'Great content, but could use more real-world examples.',
            date: '1 week ago',
          },
        ],
        relatedCourses: [
          {
            id: '2',
            title: 'Advanced React Native Performance',
            thumbnail: 'https://picsum.photos/seed/rnperf/400/300',
            instructor: 'Jane Smith',
            rating: 4.9,
          },
          {
            id: '3',
            title: 'React Native for Web Developers',
            thumbnail: 'https://picsum.photos/seed/rnweb/400/300',
            instructor: 'Mike Brown',
            rating: 4.7,
          },
        ],
      };
      
      setCourse(mockCourse);
      setLoading(false);
    } catch (error) {
      console.error('Failed to fetch course:', error);
      setLoading(false);
    }
  };

  const fetchComments = async () => {
    setIsLoadingComments(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 800));
      
      const mockComments: Comment[] = [
        {
          id: 'c1',
          userId: 'u1',
          userName: 'Sarah Wilson',
          userAvatar: 'https://picsum.photos/seed/sarah/200/200',
          text: 'Great explanation! I finally understand React Native navigation. Can you explain more about deep linking?',
          timestamp: '2 hours ago',
          likes: 12,
          isLiked: false,
          replies: [
            {
              id: 'c1r1',
              userId: 'u2',
              userName: 'John Doe (Instructor)',
              userAvatar: 'https://picsum.photos/seed/john/200/200',
              text: 'Great question Sarah! Deep linking allows your app to respond to URLs. I\'ll cover it in the next video.',
              timestamp: '1 hour ago',
              likes: 5,
              isLiked: false,
              replies: [],
              parentId: 'c1',
            },
            {
              id: 'c1r2',
              userId: 'u3',
              userName: 'Mike Johnson',
              userAvatar: 'https://picsum.photos/seed/mike/200/200',
              text: 'I had the same question! Thanks for asking.',
              timestamp: '30 minutes ago',
              likes: 2,
              isLiked: false,
              replies: [],
              parentId: 'c1',
            },
          ],
        },
        {
          id: 'c2',
          userId: 'u4',
          userName: 'Emily Davis',
          userAvatar: 'https://picsum.photos/seed/emily/200/200',
          text: 'Is there a way to optimize performance for large lists in React Native?',
          timestamp: '5 hours ago',
          likes: 8,
          isLiked: true,
          replies: [
            {
              id: 'c2r1',
              userId: 'u2',
              userName: 'John Doe (Instructor)',
              userAvatar: 'https://picsum.photos/seed/john/200/200',
              text: 'Yes Emily! Use FlatList with proper key extraction, and consider using getItemLayout for better performance.',
              timestamp: '3 hours ago',
              likes: 6,
              isLiked: false,
              replies: [],
              parentId: 'c2',
            },
          ],
        },
        {
          id: 'c3',
          userId: 'u5',
          userName: 'Chris Brown',
          userAvatar: 'https://picsum.photos/seed/chris/200/200',
          text: 'This course is amazing! I\'ve already built my first app.',
          timestamp: '1 day ago',
          likes: 15,
          isLiked: false,
          replies: [],
        },
      ];
      
      setComments(mockComments);
    } catch (error) {
      console.error('Failed to fetch comments:', error);
    } finally {
      setIsLoadingComments(false);
    }
  };

  const handleAddComment = () => {
    if (!newComment.trim()) {
      Alert.alert('Error', 'Please enter a comment');
      return;
    }

    const newCommentObj: Comment = {
      id: `c${Date.now()}`,
      userId: user?.id || 'guest',
      userName: displayName || 'Anonymous Student',
      userAvatar: userAvatar,
      text: newComment.trim(),
      timestamp: 'Just now',
      likes: 0,
      isLiked: false,
      replies: [],
    };

    setComments([newCommentObj, ...comments]);
    setNewComment('');
    
    Alert.alert('Success', 'Your comment has been posted!');
  };

  const handleAddReply = (commentId: string) => {
    if (!replyText.trim()) {
      Alert.alert('Error', 'Please enter a reply');
      return;
    }

    const newReply: Comment = {
      id: `c${Date.now()}r${Math.random()}`,
      userId: user?.id || 'guest',
      userName: displayName || 'Anonymous Student',
      userAvatar: userAvatar,
      text: replyText.trim(),
      timestamp: 'Just now',
      likes: 0,
      isLiked: false,
      replies: [],
      parentId: commentId,
    };

    const updatedComments = comments.map(comment => {
      if (comment.id === commentId) {
        return {
          ...comment,
          replies: [...comment.replies, newReply],
        };
      }
      if (comment.replies) {
        const updatedReplies = comment.replies.map(reply => {
          if (reply.id === commentId) {
            return {
              ...reply,
              replies: [...reply.replies, newReply],
            };
          }
          return reply;
        });
        return {
          ...comment,
          replies: updatedReplies,
        };
      }
      return comment;
    });

    setComments(updatedComments);
    setReplyText('');
    setReplyingTo(null);
    
    Alert.alert('Success', 'Your reply has been posted!');
  };

  const handleLikeComment = (commentId: string) => {
    const updateLikes = (commentsList: Comment[]): Comment[] => {
      return commentsList.map(comment => {
        if (comment.id === commentId) {
          return {
            ...comment,
            likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
            isLiked: !comment.isLiked,
          };
        }
        if (comment.replies && comment.replies.length > 0) {
          return {
            ...comment,
            replies: updateLikes(comment.replies),
          };
        }
        return comment;
      });
    };

    setComments(updateLikes(comments));
  };

  const handleCommentPress = (comment: Comment) => {
    setSelectedComment(comment);
    setIsCommentModalVisible(true);
  };

  const handleShareComment = (comment: Comment) => {
    Alert.alert('Share Comment', `Share this comment: "${comment.text}"`);
  };

  const handleReportComment = (commentId: string) => {
    Alert.alert(
      'Report Comment',
      'Are you sure you want to report this comment?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Report', style: 'destructive', onPress: () => {
          Alert.alert('Reported', 'Thank you for reporting. We\'ll review it.');
        }},
      ]
    );
  };

  const handleDeleteComment = (commentId: string) => {
    const isUserComment = comments.some(c => c.id === commentId && c.userId === user?.id);
    if (!isUserComment) {
      Alert.alert('Error', 'You can only delete your own comments');
      return;
    }

    Alert.alert(
      'Delete Comment',
      'Are you sure you want to delete this comment?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete', style: 'destructive', onPress: () => {
          const filteredComments = comments.filter(c => c.id !== commentId);
          setComments(filteredComments);
          Alert.alert('Deleted', 'Comment deleted successfully');
        }},
      ]
    );
  };

  const renderComment = (comment: Comment, depth: number = 0) => {
    const isOwnComment = comment.userId === user?.id;
    const isInstructor = comment.userName.includes('Instructor');

    return (
      <View 
        key={comment.id} 
        className={`${depth > 0 ? 'ml-6 border-l-2 border-[#E2E8F0] pl-3' : ''} mb-3`}
      >
        <View className="bg-white rounded-xl p-3 border border-[#E2E8F0]">
          {/* Comment Header */}
          <View className="flex-row items-center justify-between mb-1">
            <View className="flex-row items-center">
              <Image
                source={{ uri: comment.userAvatar || 'https://picsum.photos/seed/default/200/200' }}
                className="w-8 h-8 rounded-full"
              />
              <View className="ml-2">
                <View className="flex-row items-center">
                  <Text className="text-[#0F172A] font-semibold text-sm">
                    {comment.userName}
                  </Text>
                  {isInstructor && (
                    <View className="ml-1 bg-[#2563EB] px-1.5 py-0.5 rounded-full">
                      <Text className="text-white text-[8px] font-bold">INSTRUCTOR</Text>
                    </View>
                  )}
                  {isOwnComment && (
                    <View className="ml-1 bg-[#22C55E] px-1.5 py-0.5 rounded-full">
                      <Text className="text-white text-[8px] font-bold">YOU</Text>
                    </View>
                  )}
                </View>
                <Text className="text-[#94A3B8] text-xs">
                  {comment.timestamp}
                </Text>
              </View>
            </View>
            
            <View className="flex-row items-center space-x-1">
              <TouchableOpacity
                onPress={() => handleLikeComment(comment.id)}
                className="flex-row items-center"
              >
                <Ionicons 
                  name={comment.isLiked ? 'heart' : 'heart-outline'} 
                  size={16} 
                  color={comment.isLiked ? '#EF4444' : '#94A3B8'} 
                />
                {comment.likes > 0 && (
                  <Text className="text-[#64748B] text-xs ml-0.5">
                    {comment.likes}
                  </Text>
                )}
              </TouchableOpacity>
              
              <TouchableOpacity
                onPress={() => setReplyingTo(comment.id)}
                className="ml-1"
              >
                <Ionicons name="chatbubble-outline" size={16} color="#94A3B8" />
              </TouchableOpacity>
              
              <TouchableOpacity
                onPress={() => handleShareComment(comment)}
                className="ml-1"
              >
                <Ionicons name="share-outline" size={16} color="#94A3B8" />
              </TouchableOpacity>
              
              {isOwnComment && (
                <TouchableOpacity
                  onPress={() => handleDeleteComment(comment.id)}
                  className="ml-1"
                >
                  <Ionicons name="trash-outline" size={16} color="#EF4444" />
                </TouchableOpacity>
              )}
            </View>
          </View>

          {/* Comment Text */}
          <TouchableOpacity onPress={() => handleCommentPress(comment)}>
            <Text className="text-[#0F172A] text-sm leading-5">
              {comment.text}
            </Text>
          </TouchableOpacity>
        </View>

        {/* Reply Input */}
        {replyingTo === comment.id && (
          <View className="mt-2 flex-row items-center space-x-2">
            <TextInput
              className="flex-1 bg-white rounded-xl border border-[#E2E8F0] px-3 py-2 text-[#0F172A] text-sm"
              placeholder="Write a reply..."
              value={replyText}
              onChangeText={setReplyText}
              multiline
            />
            <TouchableOpacity
              className="bg-[#2563EB] px-3 py-2 rounded-xl"
              onPress={() => handleAddReply(comment.id)}
            >
              <Ionicons name="send" size={16} color="white" />
            </TouchableOpacity>
            <TouchableOpacity
              className="bg-[#F1F5F9] px-2 py-2 rounded-xl"
              onPress={() => setReplyingTo(null)}
            >
              <Ionicons name="close" size={16} color="#64748B" />
            </TouchableOpacity>
          </View>
        )}

        {/* Render Replies */}
        {comment.replies && comment.replies.length > 0 && (
          <View className="mt-1">
            {comment.replies.map(reply => renderComment(reply, depth + 1))}
          </View>
        )}
      </View>
    );
  };

  if (loading) {
    return (
      <SafeAreaView className="flex-1 bg-[#F8FAFC] items-center justify-center">
        <ActivityIndicator size="large" color="#2563EB" />
        <Text className="mt-4 text-[#64748B] text-sm font-medium">
          Loading course...
        </Text>
      </SafeAreaView>
    );
  }

  if (!course) {
    return (
      <SafeAreaView className="flex-1 bg-[#F8FAFC] items-center justify-center p-4">
        <Ionicons name="alert-circle-outline" size={60} color="#EF4444" />
        <Text className="text-[#0F172A] text-xl font-bold mt-4">
          Course Not Found
        </Text>
        <TouchableOpacity
          className="mt-6 bg-[#2563EB] px-8 py-3 rounded-xl"
          onPress={() => router.back()}
        >
          <Text className="text-white font-bold">Go Back</Text>
        </TouchableOpacity>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView className="flex-1 bg-[#F8FAFC]">
      <Stack.Screen options={{ headerShown: false }} />
      
      {/* Header */}
      <View className="flex-row items-center justify-between px-4 py-3 bg-white border-b border-[#E2E8F0]">
        <TouchableOpacity
          onPress={() => router.back()}
          className="w-10 h-10 rounded-full bg-[#F1F5F9] items-center justify-center"
        >
          <Ionicons name="chevron-back" size={24} color="#0F172A" />
        </TouchableOpacity>
        
        <Text className="text-[#0F172A] text-lg font-bold flex-1 ml-2" numberOfLines={1}>
          Course Details
        </Text>
        
        <View className="flex-row items-center space-x-2">
          <TouchableOpacity
            onPress={() => setIsSaved(!isSaved)}
            className="w-10 h-10 rounded-full bg-[#F1F5F9] items-center justify-center"
          >
            <Ionicons 
              name={isSaved ? 'bookmark' : 'bookmark-outline'} 
              size={22} 
              color={isSaved ? '#2563EB' : '#0F172A'} 
            />
          </TouchableOpacity>
          
          <TouchableOpacity
            onPress={() => {
              Share.share({
                message: `Check out "${course.title}" on LearnApp!`,
                url: `https://learnapp.com/course/${course.id}`,
              });
            }}
            className="w-10 h-10 rounded-full bg-[#F1F5F9] items-center justify-center"
          >
            <Ionicons name="share-outline" size={22} color="#0F172A" />
          </TouchableOpacity>
        </View>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: insets.bottom + 100 }}
      >
        {/* Video/Thumbnail */}
        <View className="relative bg-black">
          {course.videoUrl ? (
            <Video
              source={{ uri: course.videoUrl }}
              style={{ width: width, height: width * 0.5625 }}
              useNativeControls
              resizeMode={ResizeMode.CONTAIN}
              isLooping={false}
              onPlaybackStatusUpdate={(status) => {
                if (status.isLoaded) {
                  setIsPlaying(status.isPlaying);
                }
              }}
            />
          ) : (
            <Image
              source={{ uri: course.thumbnail }}
              className="w-full"
              style={{ height: width * 0.5625 }}
              resizeMode="cover"
            />
          )}
          
          {course.progress > 0 && course.progress < 100 && (
            <View className="absolute bottom-0 left-0 right-0">
              <View className="h-1 bg-white/30">
                <View 
                  className="h-full bg-[#22C55E]"
                  style={{ width: `${course.progress}%` }}
                />
              </View>
            </View>
          )}
        </View>

        {/* Course Info */}
        <View className="p-4">
          <Text className="text-[#0F172A] text-2xl font-bold mb-2">
            {course.title}
          </Text>
          
          <View className="flex-row items-center mb-3">
            <View className="flex-row items-center">
              <Ionicons name="star" size={18} color="#FBBF24" />
              <Text className="text-[#0F172A] font-bold ml-1">
                {course.rating.toFixed(1)}
              </Text>
            </View>
            <Text className="text-[#64748B] text-sm ml-2">
              ({course.students.toLocaleString()} students)
            </Text>
            <View className="w-1 h-1 rounded-full bg-[#CBD5E1] mx-2" />
            <View className="bg-[#2563EB]/10 px-2 py-0.5 rounded-full">
              <Text className="text-[#2563EB] text-xs font-semibold">
                {course.level}
              </Text>
            </View>
          </View>

          {/* Instructor */}
          <TouchableOpacity 
            className="flex-row items-center mb-4"
            onPress={() => router.push(`/instructor/${course.id}`)}
          >
            <Image
              source={{ uri: course.instructorAvatar || 'https://picsum.photos/seed/default/200/200' }}
              className="w-10 h-10 rounded-full"
            />
            <View className="ml-3">
              <Text className="text-[#0F172A] font-semibold">
                {course.instructor}
              </Text>
              <Text className="text-[#64748B] text-xs">
                Instructor
              </Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color="#94A3B8" className="ml-auto" />
          </TouchableOpacity>

          {/* Progress & Action Buttons */}
          <View className="bg-white rounded-2xl border border-[#E2E8F0] p-4 mb-4">
            <View className="flex-row justify-between items-center mb-2">
              <Text className="text-[#0F172A] font-semibold">
                Your Progress
              </Text>
              <Text className="text-[#2563EB] font-bold">
                {course.progress}%
              </Text>
            </View>
            
            <View className="w-full h-2 bg-[#F1F5F9] rounded-full overflow-hidden mb-3">
              <View 
                className="h-full bg-[#2563EB] rounded-full"
                style={{ width: `${course.progress}%` }}
              />
            </View>
            
            <View className="flex-row items-center justify-between">
              <View className="flex-row items-center">
                <Ionicons name="time-outline" size={16} color="#64748B" />
                <Text className="text-[#64748B] text-sm ml-1">
                  {course.remainingTime} remaining
                </Text>
              </View>
              <Text className="text-[#64748B] text-sm">
                {course.duration} total
              </Text>
            </View>
          </View>

          {/* Action Buttons */}
          <View className="flex-row space-x-3 mb-4">
            <TouchableOpacity
              className="flex-1 bg-[#2563EB] py-3.5 rounded-xl flex-row items-center justify-center"
              onPress={() => router.push(`/course/${course.id}/player`)}
            >
              <Ionicons name="play-circle" size={20} color="white" />
              <Text className="text-white font-bold text-base ml-2">
                Continue Learning
              </Text>
            </TouchableOpacity>
            
            <TouchableOpacity
              className="bg-[#F1F5F9] px-4 py-3.5 rounded-xl items-center justify-center"
              onPress={() => Alert.alert('Download', 'Course will be downloaded for offline viewing')}
            >
              <Ionicons name="download-outline" size={20} color="#0F172A" />
            </TouchableOpacity>
          </View>

          {/* Tabs */}
          <View className="flex-row bg-[#F1F5F9] rounded-xl p-1 mb-4">
            {(['overview', 'curriculum', 'comments', 'reviews'] as const).map((tab) => (
              <TouchableOpacity
                key={tab}
                className={`flex-1 py-2 rounded-lg ${
                  activeTab === tab ? 'bg-white shadow-sm' : ''
                }`}
                onPress={() => setActiveTab(tab)}
              >
                <Text
                  className={`text-center font-semibold capitalize ${
                    activeTab === tab ? 'text-[#0F172A]' : 'text-[#64748B]'
                  }`}
                >
                  {tab === 'comments' ? 'Q&A' : tab}
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          {/* Tab Content */}
          {activeTab === 'overview' && (
            <View className="space-y-4">
              <View>
                <Text className="text-[#0F172A] font-bold text-lg mb-2">
                  Description
                </Text>
                <Text 
                  className="text-[#64748B] leading-5"
                  numberOfLines={isExpanded ? undefined : 3}
                >
                  {course.description}
                </Text>
                <TouchableOpacity onPress={() => setIsExpanded(!isExpanded)}>
                  <Text className="text-[#2563EB] font-semibold mt-1">
                    {isExpanded ? 'Show Less' : 'Show More'}
                  </Text>
                </TouchableOpacity>
              </View>

              <View>
                <Text className="text-[#0F172A] font-bold text-lg mb-3">
                  What You'll Learn
                </Text>
                {course.whatYouWillLearn.map((item, index) => (
                  <View key={index} className="flex-row items-start mb-2">
                    <Ionicons name="checkmark-circle" size={20} color="#22C55E" />
                    <Text className="text-[#64748B] flex-1 ml-2">
                      {item}
                    </Text>
                  </View>
                ))}
              </View>
            </View>
          )}

          {activeTab === 'curriculum' && (
            <View>
              <View className="flex-row justify-between items-center mb-3">
                <Text className="text-[#0F172A] font-bold text-lg">
                  Course Content
                </Text>
                <Text className="text-[#64748B] text-sm">
                  {course.curriculum.filter(c => c.completed).length} / {course.curriculum.length} complete
                </Text>
              </View>
              
              {course.curriculum.map((item, index) => (
                <TouchableOpacity
                  key={index}
                  className="flex-row items-center bg-white rounded-xl border border-[#E2E8F0] p-3 mb-2"
                  onPress={() => {
                    if (item.videoId) {
                      router.push(`/course/${course.id}/player?videoId=${item.videoId}`);
                    }
                  }}
                >
                  <View className="w-8 h-8 rounded-full bg-[#2563EB]/10 items-center justify-center mr-3">
                    <Text className="text-[#2563EB] font-bold text-xs">
                      {index + 1}
                    </Text>
                  </View>
                  <View className="flex-1">
                    <Text className="text-[#0F172A] font-medium">
                      {item.title}
                    </Text>
                    <Text className="text-[#64748B] text-xs">
                      {item.duration}
                    </Text>
                  </View>
                  {item.completed ? (
                    <Ionicons name="checkmark-circle" size={24} color="#22C55E" />
                  ) : (
                    <Ionicons name="play-circle-outline" size={24} color="#94A3B8" />
                  )}
                </TouchableOpacity>
              ))}
            </View>
          )}

          {activeTab === 'comments' && (
            <View>
              <View className="flex-row justify-between items-center mb-4">
                <Text className="text-[#0F172A] font-bold text-lg">
                  Q&A Discussion
                </Text>
                <Text className="text-[#64748B] text-sm">
                  {comments.length} questions
                </Text>
              </View>

              {/* Comment Input */}
              <View className="flex-row items-start space-x-2 mb-4">
                {userAvatar ? (
                  <Image
                    source={{ uri: userAvatar }}
                    className="w-10 h-10 rounded-full"
                  />
                ) : (
                  <View className="w-10 h-10 rounded-full bg-gradient-to-br from-[#2563EB] to-[#7C3AED] items-center justify-center">
                    <Text className="text-white font-bold text-sm">
                      {userInitials}
                    </Text>
                  </View>
                )}
                <View className="flex-1">
                  <TextInput
                    className="bg-white rounded-xl border border-[#E2E8F0] px-3 py-2 text-[#0F172A] text-sm"
                    placeholder="Ask a question or start a discussion..."
                    value={newComment}
                    onChangeText={setNewComment}
                    multiline
                    numberOfLines={3}
                    textAlignVertical="top"
                  />
                  <View className="flex-row justify-end mt-1">
                    <TouchableOpacity
                      className="bg-[#2563EB] px-4 py-1.5 rounded-lg"
                      onPress={handleAddComment}
                    >
                      <Text className="text-white text-sm font-semibold">Post</Text>
                    </TouchableOpacity>
                  </View>
                </View>
              </View>

              {/* Comments List */}
              {isLoadingComments ? (
                <View className="items-center py-4">
                  <ActivityIndicator size="small" color="#2563EB" />
                </View>
              ) : comments.length > 0 ? (
                comments.map(comment => renderComment(comment))
              ) : (
                <View className="items-center py-8">
                  <Ionicons name="chatbubbles-outline" size={50} color="#94A3B8" />
                  <Text className="text-[#64748B] text-center mt-2">
                    No questions yet. Be the first to ask!
                  </Text>
                </View>
              )}
            </View>
          )}

          {activeTab === 'reviews' && (
            <View>
              <View className="flex-row justify-between items-center mb-4">
                <Text className="text-[#0F172A] font-bold text-lg">
                  Student Reviews
                </Text>
                <View className="flex-row items-center">
                  <Ionicons name="star" size={18} color="#FBBF24" />
                  <Text className="text-[#0F172A] font-bold ml-1">
                    {course.rating.toFixed(1)}
                  </Text>
                  <Text className="text-[#64748B] text-sm ml-1">
                    ({course.reviews.length} reviews)
                  </Text>
                </View>
              </View>
              
              {course.reviews.map((review) => (
                <View key={review.id} className="bg-white rounded-xl border border-[#E2E8F0] p-4 mb-3">
                  <View className="flex-row items-center mb-2">
                    <Image
                      source={{ uri: review.avatar || 'https://picsum.photos/seed/default/200/200' }}
                      className="w-10 h-10 rounded-full"
                    />
                    <View className="ml-3 flex-1">
                      <Text className="text-[#0F172A] font-semibold">
                        {review.user}
                      </Text>
                      <Text className="text-[#64748B] text-xs">
                        {review.date}
                      </Text>
                    </View>
                    <View className="flex-row items-center">
                      <Ionicons name="star" size={16} color="#FBBF24" />
                      <Text className="text-[#0F172A] font-medium ml-1">
                        {review.rating}
                      </Text>
                    </View>
                  </View>
                  <Text className="text-[#64748B] leading-5">
                    {review.comment}
                  </Text>
                </View>
              ))}
            </View>
          )}
        </View>

        {/* Related Courses */}
        <View className="px-4 pb-4">
          <Text className="text-[#0F172A] font-bold text-xl mb-3">
            Related Courses
          </Text>
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ paddingRight: 20 }}
          >
            {course.relatedCourses.map((related) => (
              <TouchableOpacity
                key={related.id}
                className="w-48 mr-3 bg-white rounded-2xl border border-[#E2E8F0] overflow-hidden"
                onPress={() => router.push(`/course/${related.id}`)}
              >
                <Image
                  source={{ uri: related.thumbnail }}
                  className="w-full h-28"
                  resizeMode="cover"
                />
                <View className="p-3">
                  <Text className="text-[#0F172A] font-semibold text-sm" numberOfLines={1}>
                    {related.title}
                  </Text>
                  <Text className="text-[#64748B] text-xs mb-1">
                    {related.instructor}
                  </Text>
                  <View className="flex-row items-center">
                    <Ionicons name="star" size={14} color="#FBBF24" />
                    <Text className="text-[#0F172A] text-xs font-medium ml-0.5">
                      {related.rating.toFixed(1)}
                    </Text>
                  </View>
                </View>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>
      </ScrollView>

      {/* Comment Detail Modal */}
      <Modal
        visible={isCommentModalVisible}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setIsCommentModalVisible(false)}
      >
        <View className="flex-1 bg-black/50">
          <TouchableOpacity 
            className="flex-1" 
            onPress={() => setIsCommentModalVisible(false)}
          />
          <View className="bg-white rounded-t-3xl p-4 max-h-[70%]">
            <View className="flex-row justify-between items-center mb-3">
              <Text className="text-[#0F172A] font-bold text-lg">
                Comment Details
              </Text>
              <TouchableOpacity onPress={() => setIsCommentModalVisible(false)}>
                <Ionicons name="close" size={24} color="#64748B" />
              </TouchableOpacity>
            </View>
            
            {selectedComment && (
              <ScrollView showsVerticalScrollIndicator={false}>
                <View className="bg-[#F8FAFC] rounded-xl p-3 mb-3">
                  <View className="flex-row items-center mb-2">
                    <Image
                      source={{ uri: selectedComment.userAvatar || 'https://picsum.photos/seed/default/200/200' }}
                      className="w-8 h-8 rounded-full"
                    />
                    <View className="ml-2">
                      <Text className="text-[#0F172A] font-semibold text-sm">
                        {selectedComment.userName}
                      </Text>
                      <Text className="text-[#94A3B8] text-xs">
                        {selectedComment.timestamp}
                      </Text>
                    </View>
                  </View>
                  <Text className="text-[#0F172A] text-sm leading-5">
                    {selectedComment.text}
                  </Text>
                </View>
                
                <View className="flex-row justify-around py-2 border-t border-[#E2E8F0]">
                  <TouchableOpacity 
                    className="flex-row items-center"
                    onPress={() => {
                      handleLikeComment(selectedComment.id);
                      setIsCommentModalVisible(false);
                    }}
                  >
                    <Ionicons 
                      name={selectedComment.isLiked ? 'heart' : 'heart-outline'} 
                      size={20} 
                      color={selectedComment.isLiked ? '#EF4444' : '#64748B'} 
                    />
                    <Text className="text-[#64748B] ml-1">
                      {selectedComment.likes} Likes
                    </Text>
                  </TouchableOpacity>
                  
                  <TouchableOpacity 
                    className="flex-row items-center"
                    onPress={() => {
                      setReplyingTo(selectedComment.id);
                      setIsCommentModalVisible(false);
                    }}
                  >
                    <Ionicons name="chatbubble-outline" size={20} color="#64748B" />
                    <Text className="text-[#64748B] ml-1">Reply</Text>
                  </TouchableOpacity>
                  
                  <TouchableOpacity 
                    className="flex-row items-center"
                    onPress={() => handleReportComment(selectedComment.id)}
                  >
                    <Ionicons name="flag-outline" size={20} color="#64748B" />
                    <Text className="text-[#64748B] ml-1">Report</Text>
                  </TouchableOpacity>
                </View>
              </ScrollView>
            )}
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}