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
} from 'react-native';
import { useLocalSearchParams, useRouter, Stack } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';

import { CustomVideoPlayer } from '../../components/course/CustomVideoPlayer';
import { LessonsList } from '../../components/course/LessonsList';
import { getCourseById, getLessonVideoSource } from '../../data/courseData';

// Skeleton Components
const Skeleton = ({ className = '' }: { className?: string }) => (
  <View className={`bg-[#E2E8F0] rounded-lg animate-pulse ${className}`} />
);

const SkeletonText = ({ className = '' }: { className?: string }) => (
  <View className={`bg-[#E2E8F0] rounded h-4 ${className}`} />
);

const SkeletonCircle = ({ size = 28 }: { size?: number }) => (
  <View className="bg-[#E2E8F0] rounded-full" style={{ width: size, height: size }} />
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

  // Loading state
  const [isLoading, setIsLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [videoHeight, setVideoHeight] = useState(width * (9 / 16));

  // Comments state
  const [comments, setComments] = useState<Comment[]>([]);
  const [newComment, setNewComment] = useState('');
  const [isReplying, setIsReplying] = useState<string | null>(null);
  const [replyText, setReplyText] = useState('');

  // Replace with a real fetch (React Query, SWR, your API client, etc).
  const course = useMemo(() => getCourseById(id ?? 'unknown'), [id]);

  // Simulate loading
  useEffect(() => {
    setIsLoading(true);
    // Simulate network delay
    const timer = setTimeout(() => {
      setIsLoading(false);
    }, 1500);
    return () => clearTimeout(timer);
  }, [id]);

  // Update video height on orientation change or window resize
  useEffect(() => {
    const maxHeight = height * 0.6; // Maximum 60% of screen height
    const calculatedHeight = width * (9 / 16);
    setVideoHeight(Math.min(calculatedHeight, maxHeight));
  }, [width, height]);


  const fetchComments = async () => {
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500));
      
      const mockComments: Comment[] = [
        {
          id: '1',
          userId: 'user1',
          userName: 'John Doe',
          userAvatar: 'https://picsum.photos/seed/john/200/200',
          text: 'This lesson is really helpful! I finally understand React Native navigation.',
          timestamp: '2 hours ago',
          likes: 24,
          isLiked: false,
          replies: [
            {
              id: '1-1',
              userId: 'user2',
              userName: 'Sarah Chen',
              userAvatar: 'https://picsum.photos/seed/sarah/200/200',
              text: 'I agree! The explanation of stack navigator was very clear.',
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
          text: 'Can someone explain the difference between useNavigation and useRouter?',
          timestamp: '3 hours ago',
          likes: 8,
          isLiked: false,
          replies: [],
        },
        {
          id: '3',
          userId: 'user4',
          userName: 'Emily Davis',
          userAvatar: 'https://picsum.photos/seed/emily/200/200',
          text: 'Great content! Looking forward to the next lesson on navigation.',
          timestamp: '5 hours ago',
          likes: 15,
          isLiked: true,
          replies: [],
        },
      ];

      setComments(mockComments);
    } catch (error) {
      console.error('Failed to fetch comments:', error);
    }
  };

  const firstIncomplete = course?.lessons?.find((l) => !l.completed && !l.locked);
  const [activeLessonId, setActiveLessonId] = useState(
    firstIncomplete?.id ?? course?.lessons?.[0]?.id ?? ''
  );
  const [completedIds, setCompletedIds] = useState(
    () => new Set(course?.lessons?.filter((l) => l.completed).map((l) => l.id) ?? [])
  );
  const [activeTab, setActiveTab] = useState<Tab>('lessons');
  const [notes, setNotes] = useState('');

  // Update active lesson when course loads
  useEffect(() => {
    if (course?.lessons?.length) {
      const firstIncomplete = course.lessons.find((l) => !l.completed && !l.locked);
      setActiveLessonId(firstIncomplete?.id ?? course.lessons[0].id);
      setCompletedIds(new Set(course.lessons.filter((l) => l.completed).map((l) => l.id)));
    }
  }, [course]);

  const activeIndex = course?.lessons?.findIndex((l) => l.id === activeLessonId) ?? -1;
  const activeLesson = course?.lessons?.[activeIndex];
  const nextLesson = course?.lessons?.[activeIndex + 1];
  const isActiveCompleted = completedIds.has(activeLessonId);

  const lessons = course?.lessons?.map((l) => ({ ...l, completed: completedIds.has(l.id) })) ?? [];
  const completedCount = lessons.filter((l) => l.completed).length;
  const overallProgress = lessons.length > 0 ? Math.round((completedCount / lessons.length) * 100) : 0;

  const handleSelectLesson = (lessonId: string) => {
    setActiveLessonId(lessonId);
  };

  const handleMarkComplete = () => {
    setCompletedIds((prev) => new Set(prev).add(activeLessonId));
  };

  const handleNext = () => {
    if (!nextLesson) return;
    setCompletedIds((prev) => new Set(prev).add(activeLessonId));
    setActiveLessonId(nextLesson.id);
  };

  const handleVideoEnd = () => {
    setCompletedIds((prev) => new Set(prev).add(activeLessonId));
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await new Promise(resolve => setTimeout(resolve, 1500));
    await fetchComments();
    setRefreshing(false);
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
            <Text className="text-[#0F172A] font-semibold text-sm">
              {comment.userName}
            </Text>
            <Text className="text-[#94A3B8] text-xs ml-2">
              {comment.timestamp}
            </Text>
          </View>
          <Text className="text-[#475569] text-sm mt-0.5 leading-5">
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
                color={comment.isLiked ? '#EF4444' : '#94A3B8'}
              />
              {comment.likes > 0 && (
                <Text className="text-[#94A3B8] text-xs ml-1">
                  {comment.likes}
                </Text>
              )}
            </TouchableOpacity>
            
            {!isReply && (
              <>
                <View className="w-px h-3 bg-[#E2E8F0] mx-3" />
                <TouchableOpacity
                  onPress={() => setIsReplying(isReplying === comment.id ? null : comment.id)}
                >
                  <Text className="text-[#64748B] text-xs font-medium">
                    Reply
                  </Text>
                </TouchableOpacity>
              </>
            )}
          </View>

          {/* Reply input */}
          {isReplying === comment.id && !isReply && (
            <View className="flex-row items-center mt-2">
              <TextInput
                value={replyText}
                onChangeText={setReplyText}
                placeholder="Write a reply..."
                placeholderTextColor="#94A3B8"
                className="flex-1 bg-[#F1F5F9] rounded-lg px-3 py-2 text-sm"
                multiline
              />
              <TouchableOpacity
                onPress={() => handleAddReply(comment.id)}
                className="ml-2 bg-[#2563EB] px-3 py-2 rounded-lg"
                disabled={!replyText.trim()}
              >
                <Text className="text-white text-sm font-semibold">Post</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>
      </View>

      {/* Replies */}
      {comment.replies && comment.replies.map(reply => renderComment(reply, true))}
    </View>
  );

  // Loading Skeleton
  if (isLoading) {
    return (
      <View className="flex-1 bg-white">
        <Stack.Screen options={{ headerShown: false }} />
        
        {/* Video Player Skeleton */}
        <View style={{ width, height: videoHeight, backgroundColor: '#1a1a1a' }}>
          <View className="absolute top-0 left-0 right-0 p-4" style={{ top: insets.top }}>
            <Skeleton className="w-10 h-10 rounded-full" />
          </View>
          <View className="absolute inset-0 items-center justify-center">
            <Skeleton className="w-16 h-16 rounded-full" />
          </View>
        </View>

        {/* Course Header Skeleton */}
        <View className="px-4 pt-4 pb-3 border-b border-[#E2E8F0]">
          <SkeletonText className="h-6 w-3/4 mb-2" />
          <View className="flex-row items-center mt-2">
            <SkeletonCircle size={28} />
            <SkeletonText className="w-32 ml-2" />
            <SkeletonText className="w-16 ml-auto" />
          </View>
          <View className="mt-3">
            <View className="flex-row justify-between mb-1">
              <SkeletonText className="w-32" />
              <SkeletonText className="w-12" />
            </View>
            <Skeleton className="h-1.5 w-full" />
          </View>
        </View>

        {/* Tabs Skeleton */}
        <View className="flex-row px-4 border-b border-[#E2E8F0]">
          {['lessons', 'overview', 'notes', 'comments'].map((tab) => (
            <View key={tab} className="mr-6 py-3">
              <SkeletonText className="w-16 h-5" />
            </View>
          ))}
        </View>

        {/* Content Skeleton */}
        <View className="px-4 py-4">
          {[1, 2, 3, 4, 5].map((i) => (
            <View key={i} className="flex-row items-center py-3 border-b border-[#F1F5F9]">
              <SkeletonCircle size={32} />
              <View className="flex-1 ml-3">
                <SkeletonText className="w-3/4 h-4" />
                <SkeletonText className="w-1/3 h-3 mt-1" />
              </View>
              <SkeletonCircle size={20} />
            </View>
          ))}
        </View>

        {/* Bottom Bar Skeleton */}
        <View
          className="flex-row items-center px-4 py-3 border-t border-[#E2E8F0] bg-white"
          style={{ paddingBottom: Math.max(insets.bottom, 12) }}
        >
          <Skeleton className="flex-1 h-12 mr-3 rounded-full" />
          <Skeleton className="flex-1 h-12 rounded-full" />
        </View>
      </View>
    );
  }

  // Handle case where course doesn't exist
  if (!course || !course.id || !course.lessons?.length) {
    return (
      <View className="flex-1 bg-white items-center justify-center">
        <Ionicons name="book-outline" size={64} color="#94A3B8" />
        <Text className="text-lg text-gray-600 mt-4">Course not found</Text>
        <TouchableOpacity 
          onPress={() => router.back()}
          className="mt-6 px-6 py-3 bg-blue-500 rounded-lg"
        >
          <Text className="text-white font-semibold">Go Back</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-white">
      <Stack.Screen options={{ headerShown: false }} />

      <ScrollView 
        className="flex-1"
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        showsVerticalScrollIndicator={false}
      >
        {/* Video player - now scrollable */}
        <View style={{ width, height: videoHeight, backgroundColor: '#000' }}>
          <CustomVideoPlayer
            key={activeLessonId}
            source={getLessonVideoSource(activeLessonId)}
            title={activeLesson?.title}
            topInset={insets.top}
            onBack={() => router.back()}
            onEnd={handleVideoEnd}
            onProgress={(_currentTime, _duration) => {
              // Save progress
            }}
          />
        </View>

        {/* Rest of content */}
        <View className="px-4 pt-4 pb-3 border-b border-[#E2E8F0]">
          <Text className="text-[#0F172A] text-lg font-bold" numberOfLines={2}>
            {course.title}
          </Text>

          <View className="flex-row items-center mt-2">
            <Image
              source={{ uri: course.instructorAvatar }}
              className="w-7 h-7 rounded-full mr-2"
            />
            <Text className="text-[#64748B] text-sm flex-1" numberOfLines={1}>
              {course.instructor}
            </Text>
            <Ionicons name="star" size={14} color="#F59E0B" />
            <Text className="text-[#0F172A] text-xs font-semibold ml-1">{course.rating}</Text>
            <Text className="text-[#64748B] text-xs ml-2">
              {course.studentsCount.toLocaleString()} students
            </Text>
          </View>

          <View className="mt-3">
            <View className="flex-row justify-between mb-1">
              <Text className="text-[#64748B] text-xs">
                {completedCount} of {lessons.length} lessons complete
              </Text>
              <Text className="text-[#2563EB] text-xs font-semibold">{overallProgress}%</Text>
            </View>
            <View className="w-full h-1.5 bg-[#F1F5F9] rounded-full overflow-hidden">
              <View
                className="h-full bg-[#2563EB] rounded-full"
                style={{ width: `${overallProgress}%` }}
              />
            </View>
          </View>
        </View>

        {/* Tabs */}
        <View className="flex-row px-4 border-b border-[#E2E8F0]">
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
            lessons={lessons}
            activeLessonId={activeLessonId}
            onSelectLesson={handleSelectLesson}
          />
        )}

        {activeTab === 'overview' && (
          <View className="px-4 py-4">
            <Text className="text-[#0F172A] text-sm font-bold mb-2">About this course</Text>
            <Text className="text-[#475569] text-sm leading-5 mb-4">{course.description}</Text>

            <Text className="text-[#0F172A] text-sm font-bold mb-2">What you'll learn</Text>
            {course.whatYouWillLearn.map((point, i) => (
              <View key={i} className="flex-row items-start mb-2">
                <Ionicons
                  name="checkmark-circle"
                  size={16}
                  color="#16A34A"
                  style={{ marginTop: 2, marginRight: 8 }}
                />
                <Text className="text-[#475569] text-sm flex-1 leading-5">{point}</Text>
              </View>
            ))}
          </View>
        )}

        {activeTab === 'notes' && (
          <View className="px-4 py-4">
            <Text className="text-[#0F172A] text-sm font-bold mb-2">
              Your notes for "{activeLesson?.title}"
            </Text>
            <TextInput
              value={notes}
              onChangeText={setNotes}
              placeholder="Jot down anything worth remembering from this lesson..."
              placeholderTextColor="#94A3B8"
              multiline
              textAlignVertical="top"
              className="bg-[#F1F5F9] rounded-xl p-3 text-sm text-[#0F172A] min-h-[140px]"
            />
            <Text className="text-[#94A3B8] text-xs mt-2">
              Notes are kept on this screen only for now — save them to AsyncStorage or your
              backend to persist across sessions.
            </Text>
          </View>
        )}

        {activeTab === 'comments' && (
          <KeyboardAvoidingView
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
            keyboardVerticalOffset={100}
          >
            <View className="px-4 py-4">
              {/* Comment Input */}
              <View className="flex-row items-end mb-4">
                <View className="flex-1 mr-2">
                  <TextInput
                    value={newComment}
                    onChangeText={setNewComment}
                    placeholder="Ask a question or share your thoughts..."
                    placeholderTextColor="#94A3B8"
                    multiline
                    numberOfLines={3}
                    className="bg-[#F1F5F9] rounded-xl px-3 py-2 text-sm text-[#0F172A] max-h-24"
                  />
                </View>
                <TouchableOpacity
                  onPress={handleAddComment}
                  className="bg-[#2563EB] w-10 h-10 rounded-full items-center justify-center"
                  disabled={!newComment.trim()}
                  activeOpacity={0.7}
                >
                  <Ionicons name="send" size={18} color="#FFFFFF" />
                </TouchableOpacity>
              </View>

              {/* Comments List */}
              <View className="space-y-4">
                {comments.length > 0 ? (
                  comments.map(comment => renderComment(comment))
                ) : (
                  <View className="items-center py-8">
                    <Ionicons name="chatbubbles-outline" size={48} color="#94A3B8" />
                    <Text className="text-[#0F172A] text-lg font-bold mt-4">
                      No Comments Yet
                    </Text>
                    <Text className="text-[#64748B] text-center mt-1">
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
        className="flex-row items-center px-4 py-3 border-t border-[#E2E8F0] bg-white"
        style={{ paddingBottom: Math.max(insets.bottom, 12) }}
      >
        <TouchableOpacity
          onPress={handleMarkComplete}
          disabled={isActiveCompleted}
          className={`flex-1 mr-3 py-3 rounded-full items-center border ${
            isActiveCompleted ? 'border-[#16A34A] bg-[#F0FDF4]' : 'border-[#E2E8F0] bg-white'
          }`}
        >
          <Text
            className={`text-sm font-semibold ${
              isActiveCompleted ? 'text-[#16A34A]' : 'text-[#0F172A]'
            }`}
          >
            {isActiveCompleted ? 'Completed' : 'Mark as Complete'}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={handleNext}
          disabled={!nextLesson}
          className={`flex-1 py-3 rounded-full items-center flex-row justify-center ${
            nextLesson ? 'bg-[#2563EB]' : 'bg-[#E2E8F0]'
          }`}
        >
          <Text
            className={`text-sm font-semibold mr-1 ${
              nextLesson ? 'text-white' : 'text-[#94A3B8]'
            }`}
          >
            {nextLesson ? 'Next Lesson' : 'Course Complete'}
          </Text>
          {nextLesson && <Ionicons name="arrow-forward" size={16} color="#FFFFFF" />}
        </TouchableOpacity>
      </View>
    </View>
  );
}