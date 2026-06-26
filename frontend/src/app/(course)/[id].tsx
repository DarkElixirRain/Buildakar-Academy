// app/course/[id].tsx
import React, { useCallback, useEffect, useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  Image,
  ActivityIndicator,
  StatusBar,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';

import { CourseVideoPlayer } from '../../components/course/CourseVideoPlayer';
import { LessonsList } from '../../components/course/LessonsList';
import { CommentsSection } from '../../components/course/CommentSection';
import { fetchCourseDetail } from '../../data/mockCourseData';
import { CourseDetail, Lesson } from '../../types/course';

type Tab = 'lessons' | 'comments';

export default function CourseDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();

  const [course, setCourse] = useState<CourseDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<Tab>('lessons');
  const [currentLessonId, setCurrentLessonId] = useState<string>('');

  useEffect(() => {
    let isMounted = true;
    setLoading(true);

    fetchCourseDetail(id as string).then((data) => {
      if (!isMounted) return;
      setCourse(data);
      setCurrentLessonId(data.lessons[0]?.id ?? '');
      setLoading(false);
    });

    return () => {
      isMounted = false;
    };
  }, [id]);

  const handleLessonPress = useCallback((lesson: Lesson) => {
    if (lesson.locked) return;
    setCurrentLessonId(lesson.id);
  }, []);

  // Mark the current lesson complete and auto-advance to the next
  // unlocked lesson when a video finishes playing.
  const handleLessonEnd = useCallback(() => {
    setCourse((prev) => {
      if (!prev) return prev;

      const currentIndex = prev.lessons.findIndex(
        (l) => l.id === currentLessonId
      );
      const lessons = prev.lessons.map((l) =>
        l.id === currentLessonId ? { ...l, completed: true } : l
      );

      const next = lessons[currentIndex + 1];
      if (next && !next.locked) {
        setCurrentLessonId(next.id);
      }

      return { ...prev, lessons };
    });
  }, [currentLessonId]);

  const handleAddComment = useCallback((text: string) => {
    setCourse((prev) => {
      if (!prev) return prev;
      const newComment = {
        id: `c-${Date.now()}`,
        userName: 'You',
        userAvatar: 'https://i.pravatar.cc/100?img=12',
        text,
        timestamp: 'Just now',
        likes: 0,
        likedByMe: false,
      };
      return { ...prev, comments: [newComment, ...prev.comments] };
    });
  }, []);

  const handleToggleLike = useCallback((commentId: string) => {
    setCourse((prev) => {
      if (!prev) return prev;
      const comments = prev.comments.map((c) =>
        c.id === commentId
          ? {
              ...c,
              likedByMe: !c.likedByMe,
              likes: c.likedByMe ? c.likes - 1 : c.likes + 1,
            }
          : c
      );
      return { ...prev, comments };
    });
  }, []);

  if (loading || !course) {
    return (
      <SafeAreaView className="flex-1 bg-white items-center justify-center">
        <ActivityIndicator size="large" color="#2563EB" />
      </SafeAreaView>
    );
  }

  const currentLesson =
    course.lessons.find((l) => l.id === currentLessonId) ?? course.lessons[0];
  const completedCount = course.lessons.filter((l) => l.completed).length;
  const overallProgress = Math.round(
    (completedCount / course.lessons.length) * 100
  );

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      <StatusBar barStyle="dark-content" />

      {/* Header */}
      <View className="flex-row items-center justify-between px-4 py-3 border-b border-[#E2E8F0]">
        <TouchableOpacity onPress={() => router.back()} className="p-1">
          <Ionicons name="arrow-back" size={22} color="#0F172A" />
        </TouchableOpacity>
        <Text
          className="text-[#0F172A] text-base font-bold flex-1 text-center mx-2"
          numberOfLines={1}
        >
          {currentLesson.title}
        </Text>
        <TouchableOpacity className="p-1">
          <Ionicons name="ellipsis-vertical" size={20} color="#0F172A" />
        </TouchableOpacity>
      </View>

      {/* Video player */}
      <CourseVideoPlayer
        youtubeId={currentLesson.youtubeId}
        onEnd={handleLessonEnd}
      />

      {/* Course info */}
      <View className="px-4 pt-3 pb-2 border-b border-[#E2E8F0]">
        <Text className="text-[#0F172A] text-lg font-bold mb-1" numberOfLines={2}>
          {course.title}
        </Text>
        <View className="flex-row items-center mb-2">
          <Image
            source={{ uri: course.instructorAvatar }}
            className="w-6 h-6 rounded-full mr-2"
          />
          <Text className="text-[#64748B] text-sm mr-3">
            {course.instructor}
          </Text>
          <Ionicons name="star" size={13} color="#F59E0B" />
          <Text className="text-[#64748B] text-xs ml-1">
            {course.rating.toFixed(1)}
          </Text>
          <Text className="text-[#94A3B8] text-xs ml-2">
            · {course.studentsCount.toLocaleString()} students
          </Text>
        </View>

        <View className="flex-row items-center">
          <View className="flex-1 h-1.5 bg-[#F1F5F9] rounded-full overflow-hidden mr-2">
            <View
              className="h-full bg-[#2563EB] rounded-full"
              style={{ width: `${overallProgress}%` }}
            />
          </View>
          <Text className="text-[#64748B] text-xs font-medium">
            {completedCount}/{course.lessons.length} lessons
          </Text>
        </View>
      </View>

      {/* Tabs */}
      <View className="flex-row px-4 border-b border-[#E2E8F0]">
        {(['lessons', 'comments'] as Tab[]).map((tab) => (
          <TouchableOpacity
            key={tab}
            onPress={() => setActiveTab(tab)}
            className="mr-6 py-3"
            activeOpacity={0.7}
          >
            <Text
              className={`text-sm font-semibold ${
                activeTab === tab ? 'text-[#2563EB]' : 'text-[#94A3B8]'
              }`}
            >
              {tab === 'lessons'
                ? `Lessons (${course.lessons.length})`
                : `Comments (${course.comments.length})`}
            </Text>
            {activeTab === tab && (
              <View className="h-0.5 bg-[#2563EB] rounded-full mt-1" />
            )}
          </TouchableOpacity>
        ))}
      </View>

      {/* Tab content */}
      {activeTab === 'lessons' ? (
        <ScrollView
          className="flex-1"
          contentContainerStyle={{ paddingVertical: 12, paddingBottom: 24 }}
        >
          {course.description ? (
            <Text className="text-[#475569] text-sm px-4 mb-3 leading-5">
              {course.description}
            </Text>
          ) : null}
          <LessonsList
            lessons={course.lessons}
            currentLessonId={currentLessonId}
            onLessonPress={handleLessonPress}
          />
        </ScrollView>
      ) : (
        <CommentsSection
          comments={course.comments}
          onAddComment={handleAddComment}
          onToggleLike={handleToggleLike}
        />
      )}
    </SafeAreaView>
  );
}