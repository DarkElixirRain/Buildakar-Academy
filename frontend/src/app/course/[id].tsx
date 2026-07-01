// app/course/[id].tsx
import React, { useMemo, useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  Image,
  TextInput,
  useWindowDimensions,
  RefreshControl,
  Dimensions,
  KeyboardAvoidingView,
  Platform,
  Alert,
} from 'react-native';
import { useLocalSearchParams, useRouter, Stack } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';

import { CustomVideoPlayer } from '../../components/course/CustomVideoPlayer';
import { LessonsList } from '../../components/course/LessonsList';
import { courseService, CourseData } from '@/services/courseService';

// Types
interface Instructor {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  photo?: string;
}

interface Category {
  id: string;
  name: string;
  slug: string;
}

interface Lesson {
  id: string;
  order: number;
  title: string;
  duration: string;
  videoUrl?: string;
  youtubeId?: string;
  completed: boolean;
  locked?: boolean;
  isPreview?: boolean;
  description?: string;
 
  content?: string;
}

interface Section {
  id: string;
  title: string;
  description?: string;
  order: number;
  lessons: Lesson[];
  _count?: {
    lessons: number;
  };
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

type Tab = 'lessons' | 'overview' | 'notes' | 'comments';

// Comment Interface
interface Comment {
  id: string;
  userId: string;
  userName: string;
  userAvatar: string;
  text: string;
  timestamp: string;
  likes: number;
  isLiked: boolean;
  replies?: Comment[];
}

export default function CourseScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { width, height } = useWindowDimensions();
  const { isDarkMode, colors } = useTheme();

  // State
  const [isLoading, setIsLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [courseData, setCourseData] = useState<CourseData | null>(null);
  const [videoHeight, setVideoHeight] = useState(width * (9 / 16));

  // Comments state
  const [comments, setComments] = useState<Comment[]>([]);
  const [newComment, setNewComment] = useState('');
  const [isReplying, setIsReplying] = useState<string | null>(null);
  const [replyText, setReplyText] = useState('');

  // Lesson state
  const [activeLessonId, setActiveLessonId] = useState('');
  const [completedIds, setCompletedIds] = useState<Set<string>>(new Set());
  const [activeTab, setActiveTab] = useState<Tab>('lessons');
  const [notes, setNotes] = useState('');

  // Update video height on orientation change
  useEffect(() => {
    const maxHeight = height * 0.6;
    const calculatedHeight = width * (9 / 16);
    setVideoHeight(Math.min(calculatedHeight, maxHeight));
  }, [width, height]);

  // Fetch course details from API
  const fetchCourseDetails = async () => {
    try {
      setIsLoading(true);
      console.log(`🌐 Fetching course details for ID: ${id}`);

      const result = await courseService.getCourseById(id!);

      if (!result) {
        throw new Error('Course not found');
      }

      console.log('✅ Course loaded:', result.title);
      setCourseData(result);

      // Initialize lessons
      const allLessons = getAllLessons(result.sections);
      const firstIncomplete = allLessons.find((l) => !l.completed && !l.locked);
      setActiveLessonId(firstIncomplete?.id ?? allLessons[0]?.id ?? '');
      setCompletedIds(new Set(allLessons.filter((l) => l.completed).map((l) => l.id)));

      // Fetch comments
      await fetchComments();
    } catch (error: any) {
      console.error('❌ Failed to fetch course:', error);
      Alert.alert(
        'Error',
        error.message || 'Failed to load course. Please try again.'
      );
    } finally {
      setIsLoading(false);
      setRefreshing(false);
    }
  };

  // Helper: Get all lessons from sections
  const getAllLessons = (sections?: Section[]): Lesson[] => {
    if (!sections) return [];
    const allLessons: Lesson[] = [];
    sections.forEach(section => {
      section.lessons?.forEach(lesson => {
        allLessons.push({
          ...lesson,
          completed: lesson.completed || false,
        });
      });
    });
    return allLessons;
  };

  // Helper: Get instructor name
  const getInstructorName = (instructor: Instructor) => {
    if (!instructor) return 'Instructor';
    const firstName = instructor.firstName || '';
    const lastName = instructor.lastName || '';
    return `${firstName} ${lastName}`.trim() || 'Instructor';
  };

  // Helper: Get instructor avatar
  const getInstructorAvatar = (instructor: Instructor) => {
    if (!instructor) return 'https://ui-avatars.com/api/?name=Instructor&size=150&background=4F46E5&color=fff';
    const name = getInstructorName(instructor);
    return instructor.photo || 
      `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&size=150&background=4F46E5&color=fff`;
  };

  // Fetch comments
  const fetchComments = async () => {
    try {
      // Simulate API call - TODO: Replace with real API
      const mockComments: Comment[] = [
        {
          id: '1',
          userId: 'user1',
          userName: 'John Doe',
          userAvatar: 'https://picsum.photos/seed/john/200/200',
          text: 'This course is really helpful! I finally understand the concepts.',
          timestamp: '2 hours ago',
          likes: 24,
          isLiked: false,
          replies: [
            {
              id: '1-1',
              userId: 'user2',
              userName: 'Sarah Chen',
              userAvatar: 'https://picsum.photos/seed/sarah/200/200',
              text: 'I agree! The explanations are very clear.',
              timestamp: '1 hour ago',
              likes: 12,
              isLiked: false,
            },
          ],
        },
        {
          id: '2',
          userId: 'user3',
          userName: 'Alex Johnson',
          userAvatar: 'https://picsum.photos/seed/alex/200/200',
          text: 'Can someone explain the difference between these concepts?',
          timestamp: '3 hours ago',
          likes: 8,
          isLiked: false,
          replies: [],
        },
      ];

      setComments(mockComments);
    } catch (error) {
      console.error('Failed to fetch comments:', error);
    }
  };

  // Initial fetch
  useEffect(() => {
    if (id) {
      fetchCourseDetails();
    }
  }, [id]);

  // Get current lesson
  const allLessons = courseData ? getAllLessons(courseData.sections) : [];
  const activeIndex = allLessons.findIndex((l) => l.id === activeLessonId);
  const activeLesson = allLessons[activeIndex];
  const nextLesson = allLessons[activeIndex + 1];
  const isActiveCompleted = completedIds.has(activeLessonId);
  const completedCount = allLessons.filter((l) => completedIds.has(l.id)).length;
  const overallProgress = allLessons.length > 0 ? Math.round((completedCount / allLessons.length) * 100) : 0;

  // Handlers
  const handleSelectLesson = (lessonId: string) => {
    setActiveLessonId(lessonId);
  };

  const handleMarkComplete = () => {
    if (isActiveCompleted) return;
    setCompletedIds((prev) => new Set(prev).add(activeLessonId));
  };

  const handleNext = () => {
    if (!nextLesson) return;
    if (!isActiveCompleted) {
      setCompletedIds((prev) => new Set(prev).add(activeLessonId));
    }
    setActiveLessonId(nextLesson.id);
  };

  const handleVideoEnd = () => {
    if (!isActiveCompleted) {
      setCompletedIds((prev) => new Set(prev).add(activeLessonId));
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchCourseDetails();
  };

  // Comment handlers
  const handleAddComment = () => {
    if (!newComment.trim()) return;
    
    const newCommentObj: Comment = {
      id: Date.now().toString(),
      userId: 'current-user',
      userName: 'You',
      userAvatar: 'https://picsum.photos/seed/you/200/200',
      text: newComment.trim(),
      timestamp: 'Just now',
      likes: 0,
      isLiked: false,
      replies: [],
    };
    
    setComments([newCommentObj, ...comments]);
    setNewComment('');
  };

  const handleAddReply = (parentId: string) => {
    if (!replyText.trim()) return;
    
    const newReply: Comment = {
      id: `${parentId}-${Date.now()}`,
      userId: 'current-user',
      userName: 'You',
      userAvatar: 'https://picsum.photos/seed/you/200/200',
      text: replyText.trim(),
      timestamp: 'Just now',
      likes: 0,
      isLiked: false,
    };
    
    setComments(prev => 
      prev.map(comment => 
        comment.id === parentId
          ? { ...comment, replies: [...(comment.replies || []), newReply] }
          : comment
      )
    );
    
    setReplyText('');
    setIsReplying(null);
  };

  const handleLikeComment = (commentId: string) => {
    setComments(prev => 
      prev.map(comment => {
        if (comment.id === commentId) {
          return {
            ...comment,
            likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
            isLiked: !comment.isLiked,
          };
        }
        return comment;
      })
    );
  };

  const handleLikeReply = (commentId: string, replyId: string) => {
    setComments(prev => 
      prev.map(comment => {
        if (comment.id === commentId && comment.replies) {
          return {
            ...comment,
            replies: comment.replies.map(reply => {
              if (reply.id === replyId) {
                return {
                  ...reply,
                  likes: reply.isLiked ? reply.likes - 1 : reply.likes + 1,
                  isLiked: !reply.isLiked,
                };
              }
              return reply;
            }),
          };
        }
        return comment;
      })
    );
  };

  const renderComment = (comment: Comment, isReply: boolean = false) => (
    <View key={comment.id} className={`${isReply ? 'ml-10 mt-3' : 'mb-4'}`}>
      <View className="flex-row items-start">
        <Image
          source={{ uri: comment.userAvatar }}
          className="w-8 h-8 rounded-full"
        />
        <View className="flex-1 ml-3">
          <View className="flex-row items-center">
            <Text style={{ color: colors.text, fontWeight: '600', fontSize: 14 }}>
              {comment.userName}
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 8 }}>
              {comment.timestamp}
            </Text>
          </View>
          <Text style={{ color: colors.textSecondary, fontSize: 14, marginTop: 2, lineHeight: 20 }}>
            {comment.text}
          </Text>
          <View className="flex-row items-center mt-1.5">
            <TouchableOpacity
              onPress={() => handleLikeComment(comment.id)}
              className="flex-row items-center"
            >
              <Ionicons
                name={comment.isLiked ? 'heart' : 'heart-outline'}
                size={16}
                color={comment.isLiked ? '#EF4444' : colors.textSecondary}
              />
              {comment.likes > 0 && (
                <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 4 }}>
                  {comment.likes}
                </Text>
              )}
            </TouchableOpacity>
            
            {!isReply && (
              <>
                <View style={{ width: 1, height: 12, backgroundColor: colors.backgroundSelected, marginHorizontal: 12 }} />
                <TouchableOpacity
                  onPress={() => setIsReplying(isReplying === comment.id ? null : comment.id)}
                >
                  <Text style={{ color: colors.textSecondary, fontSize: 12, fontWeight: '500' }}>
                    Reply
                  </Text>
                </TouchableOpacity>
              </>
            )}
          </View>

          {isReplying === comment.id && !isReply && (
            <View className="flex-row items-center mt-2">
              <TextInput
                value={replyText}
                onChangeText={setReplyText}
                placeholder="Write a reply..."
                placeholderTextColor={colors.textSecondary}
                style={{
                  flex: 1,
                  borderRadius: 8,
                  paddingHorizontal: 12,
                  paddingVertical: 8,
                  fontSize: 14,
                  backgroundColor: colors.backgroundSelected,
                  color: colors.text,
                }}
                multiline
              />
              <TouchableOpacity
                onPress={() => handleAddReply(comment.id)}
                className="ml-2 px-3 py-2 rounded-lg"
                style={{ backgroundColor: colors.primary }}
                disabled={!replyText.trim()}
              >
                <Text className="text-white text-sm font-semibold">Post</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>
      </View>

      {comment.replies && comment.replies.map(reply => renderComment(reply, true))}
    </View>
  );

  // Loading Skeleton
  if (isLoading) {
    const skeletonBg = isDarkMode ? '#1E293B' : '#E2E8F0';
    return (
      <View className="flex-1" style={{ backgroundColor: colors.background }}>
        <Stack.Screen options={{ headerShown: false }} />
        
        <View style={{ width, height: videoHeight, backgroundColor: '#1a1a1a' }}>
          <View className="absolute top-0 left-0 right-0 p-4" style={{ top: insets.top }}>
            <Skeleton className="w-10 h-10 rounded-full" bgColor={skeletonBg} />
          </View>
          <View className="absolute inset-0 items-center justify-center">
            <Skeleton className="w-16 h-16 rounded-full" bgColor={skeletonBg} />
          </View>
        </View>

        <View className="px-4 pt-4 pb-3" style={{ borderBottomWidth: 1, borderBottomColor: colors.backgroundSelected }}>
          <SkeletonText className="h-6 w-3/4 mb-2" bgColor={skeletonBg} />
          <View className="flex-row items-center mt-2">
            <SkeletonCircle size={28} bgColor={skeletonBg} />
            <SkeletonText className="w-32 ml-2" bgColor={skeletonBg} />
            <SkeletonText className="w-16 ml-auto" bgColor={skeletonBg} />
          </View>
          <View className="mt-3">
            <View className="flex-row justify-between mb-1">
              <SkeletonText className="w-32" bgColor={skeletonBg} />
              <SkeletonText className="w-12" bgColor={skeletonBg} />
            </View>
            <Skeleton className="h-1.5 w-full" bgColor={skeletonBg} />
          </View>
        </View>

        <View className="flex-row px-4" style={{ borderBottomWidth: 1, borderBottomColor: colors.backgroundSelected }}>
          {['lessons', 'overview', 'notes', 'comments'].map((tab) => (
            <View key={tab} className="mr-6 py-3">
              <SkeletonText className="w-16 h-5" bgColor={skeletonBg} />
            </View>
          ))}
        </View>

        <View className="px-4 py-4">
          {[1, 2, 3, 4, 5].map((i) => (
            <View key={i} className="flex-row items-center py-3" style={{ borderBottomWidth: 1, borderBottomColor: colors.backgroundSelected }}>
              <SkeletonCircle size={32} bgColor={skeletonBg} />
              <View className="flex-1 ml-3">
                <SkeletonText className="w-3/4 h-4" bgColor={skeletonBg} />
                <SkeletonText className="w-1/3 h-3 mt-1" bgColor={skeletonBg} />
              </View>
              <SkeletonCircle size={20} bgColor={skeletonBg} />
            </View>
          ))}
        </View>

        <View
          className="flex-row items-center px-4 py-3 border-t"
          style={{ 
            paddingBottom: Math.max(insets.bottom, 12),
            borderTopColor: colors.backgroundSelected,
            backgroundColor: colors.backgroundElement 
          }}
        >
          <Skeleton className="flex-1 h-12 mr-3 rounded-full" bgColor={skeletonBg} />
          <Skeleton className="flex-1 h-12 rounded-full" bgColor={skeletonBg} />
        </View>
      </View>
    );
  }

  // Handle case where course doesn't exist
  if (!courseData || !courseData.id || !allLessons.length) {
    return (
      <View className="flex-1 items-center justify-center" style={{ backgroundColor: colors.background }}>
        <Ionicons name="book-outline" size={64} color={colors.textSecondary} />
        <Text style={{ color: colors.textSecondary, fontSize: 18, marginTop: 16 }}>Course not found</Text>
        <TouchableOpacity 
          onPress={() => router.back()}
          className="mt-6 px-6 py-3 rounded-lg"
          style={{ backgroundColor: colors.primary }}
        >
          <Text className="text-white font-semibold">Go Back</Text>
        </TouchableOpacity>
      </View>
    );
  }

  const instructorName = getInstructorName(courseData.instructor);
  const instructorAvatar = getInstructorAvatar(courseData.instructor);

  return (
    <View className="flex-1" style={{ backgroundColor: colors.background }}>
      <Stack.Screen options={{ headerShown: false }} />

      <ScrollView 
        className="flex-1"
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.primary} />
        }
        showsVerticalScrollIndicator={false}
      >
        {/* Video player */}
        <View style={{ width, height: videoHeight, backgroundColor: '#000' }}>
          <CustomVideoPlayer
            key={activeLessonId}
            source={{ uri: activeLesson?.videoUrl || 'https://www.pexels.com/download/video/34279733/' }}
            title={activeLesson?.title}
            topInset={insets.top}
            onBack={() => router.back()}
            onEnd={handleVideoEnd}
          />
        </View>

        {/* Rest of content */}
        <View className="px-4 pt-4 pb-3" style={{ borderBottomWidth: 1, borderBottomColor: colors.backgroundSelected }}>
          <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold' }} numberOfLines={2}>
            {courseData.title}
          </Text>

          <View className="flex-row items-center mt-2">
            <Image
              source={{ uri: instructorAvatar }}
              className="w-7 h-7 rounded-full mr-2"
            />
            <Text style={{ color: colors.textSecondary, fontSize: 14, flex: 1 }} numberOfLines={1}>
              {instructorName}
            </Text>
            <Ionicons name="star" size={14} color="#F59E0B" />
            <Text style={{ color: colors.text, fontSize: 12, fontWeight: '600', marginLeft: 4 }}>
              {courseData.rating?.toFixed(1) || '0.0'}
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 8 }}>
              {courseData.studentsCount || 0} students
            </Text>
          </View>

          <View className="mt-3">
            <View className="flex-row justify-between mb-1">
              <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
                {completedCount} of {allLessons.length} lessons complete
              </Text>
              <Text style={{ color: colors.primary, fontSize: 12, fontWeight: '600' }}>{overallProgress}%</Text>
            </View>
            <View className="w-full h-1.5 rounded-full overflow-hidden" style={{ backgroundColor: colors.backgroundSelected }}>
              <View
                className="h-full rounded-full"
                style={{ width: `${overallProgress}%`, backgroundColor: colors.primary }}
              />
            </View>
          </View>
        </View>

        {/* Tabs */}
        <View className="flex-row px-4" style={{ borderBottomWidth: 1, borderBottomColor: colors.backgroundSelected }}>
          {(['lessons', 'overview', 'notes', 'comments'] as Tab[]).map((tab) => (
            <TouchableOpacity
              key={tab}
              onPress={() => setActiveTab(tab)}
              className={`mr-6 py-3 border-b-2 ${
                activeTab === tab ? 'border-[#2563EB]' : 'border-transparent'
              }`}
            >
              <Text
                className={`text-sm font-semibold capitalize ${
                  activeTab === tab ? 'text-[#2563EB]' : 'text-[#64748B]'
                }`}
              >
                {tab}
                {tab === 'comments' && comments.length > 0 && (
                  <View className="absolute -top-1 -right-4 bg-[#EF4444] rounded-full min-w-[18px] h-[18px] items-center justify-center px-1">
                    <Text className="text-white text-[10px] font-bold">
                      {comments.length}
                    </Text>
                  </View>
                )}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {activeTab === 'lessons' && (
          <LessonsList
            lessons={allLessons}
            activeLessonId={activeLessonId}
            onSelectLesson={handleSelectLesson}
          />
        )}

        {activeTab === 'overview' && (
          <View className="px-4 py-4">
            <Text style={{ color: colors.text, fontSize: 14, fontWeight: 'bold', marginBottom: 8 }}>
              About this course
            </Text>
            <Text style={{ color: colors.textSecondary, fontSize: 14, lineHeight: 20, marginBottom: 16 }}>
              {courseData.description || 'No description available.'}
            </Text>

            <Text style={{ color: colors.text, fontSize: 14, fontWeight: 'bold', marginBottom: 8 }}>
              What you'll learn
            </Text>
            {courseData.whatYouWillLearn && courseData.whatYouWillLearn.length > 0 ? (
              courseData.whatYouWillLearn.map((point, i) => (
                <View key={i} className="flex-row items-start mb-2">
                  <Ionicons
                    name="checkmark-circle"
                    size={16}
                    color="#16A34A"
                    style={{ marginTop: 2, marginRight: 8 }}
                  />
                  <Text style={{ color: colors.textSecondary, fontSize: 14, flex: 1, lineHeight: 20 }}>
                    {point}
                  </Text>
                </View>
              ))
            ) : (
              <Text style={{ color: colors.textSecondary, fontSize: 14 }}>
                No learning objectives listed.
              </Text>
            )}
          </View>
        )}

        {activeTab === 'notes' && (
          <View className="px-4 py-4">
            <Text style={{ color: colors.text, fontSize: 14, fontWeight: 'bold', marginBottom: 8 }}>
              Your notes for "{activeLesson?.title}"
            </Text>
            <TextInput
              value={notes}
              onChangeText={setNotes}
              placeholder="Jot down anything worth remembering from this lesson..."
              placeholderTextColor={colors.textSecondary}
              multiline
              textAlignVertical="top"
              style={{
                borderRadius: 12,
                padding: 12,
                fontSize: 14,
                minHeight: 140,
                backgroundColor: colors.backgroundSelected,
                color: colors.text,
              }}
            />
            <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 8 }}>
              Notes are kept on this screen only for now.
            </Text>
          </View>
        )}

        {activeTab === 'comments' && (
          <KeyboardAvoidingView
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
            keyboardVerticalOffset={100}
          >
            <View className="px-4 py-4">
              <View className="flex-row items-end mb-4">
                <View className="flex-1 mr-2">
                  <TextInput
                    value={newComment}
                    onChangeText={setNewComment}
                    placeholder="Ask a question or share your thoughts..."
                    placeholderTextColor={colors.textSecondary}
                    multiline
                    numberOfLines={3}
                    style={{
                      borderRadius: 12,
                      paddingHorizontal: 12,
                      paddingVertical: 8,
                      fontSize: 14,
                      maxHeight: 96,
                      backgroundColor: colors.backgroundSelected,
                      color: colors.text,
                    }}
                  />
                </View>
                <TouchableOpacity
                  onPress={handleAddComment}
                  className="w-10 h-10 rounded-full items-center justify-center"
                  style={{ backgroundColor: colors.primary }}
                  disabled={!newComment.trim()}
                  activeOpacity={0.7}
                >
                  <Ionicons name="send" size={18} color="#FFFFFF" />
                </TouchableOpacity>
              </View>

              <View className="space-y-4">
                {comments.length > 0 ? (
                  comments.map(comment => renderComment(comment))
                ) : (
                  <View className="items-center py-8">
                    <Ionicons name="chatbubbles-outline" size={48} color={colors.textSecondary} />
                    <Text style={{ color: colors.text, fontSize: 18, fontWeight: 'bold', marginTop: 16 }}>
                      No Comments Yet
                    </Text>
                    <Text style={{ color: colors.textSecondary, textAlign: 'center', marginTop: 4 }}>
                      Be the first to ask a question or share your thoughts
                    </Text>
                  </View>
                )}
              </View>
            </View>
          </KeyboardAvoidingView>
        )}
      </ScrollView>

      {/* Sticky bottom action bar */}
      <View
        className="flex-row items-center px-4 py-3 border-t"
        style={{
          paddingBottom: Math.max(insets.bottom, 12),
          borderTopColor: colors.backgroundSelected,
          backgroundColor: colors.backgroundElement,
        }}
      >
        <TouchableOpacity
          onPress={handleMarkComplete}
          disabled={isActiveCompleted}
          className={`flex-1 mr-3 py-3 rounded-full items-center border ${
            isActiveCompleted 
              ? 'border-[#16A34A] bg-[#F0FDF4]' 
              : isDarkMode ? 'border-[#334155] bg-[#1E293B]' : 'border-[#E2E8F0] bg-white'
          }`}
        >
          <Text
            className={`text-sm font-semibold ${
              isActiveCompleted ? 'text-[#16A34A]' : isDarkMode ? 'text-white' : 'text-[#0F172A]'
            }`}
          >
            {isActiveCompleted ? 'Completed ✓' : 'Mark as Complete'}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={handleNext}
          disabled={!nextLesson}
          className={`flex-1 py-3 rounded-full items-center flex-row justify-center ${
            nextLesson ? 'bg-[#2563EB]' : isDarkMode ? 'bg-[#334155]' : 'bg-[#E2E8F0]'
          }`}
        >
          <Text
            className={`text-sm font-semibold mr-1 ${
              nextLesson ? 'text-white' : isDarkMode ? 'text-[#64748B]' : 'text-[#94A3B8]'
            }`}
          >
            {nextLesson ? 'Next Lesson' : 'Course Complete 🎉'}
          </Text>
          {nextLesson && <Ionicons name="arrow-forward" size={16} color="#FFFFFF" />}
        </TouchableOpacity>
      </View>
    </View>
  );
}