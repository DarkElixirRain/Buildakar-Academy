// store/homeStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { Platform } from 'react-native';
import { 
  HomeData, 
  Category, 
  LearningPath, 
  LiveClass, 
  Instructor, 
  Achievement, 
  UserProgress, 
  Notification,
  RecentlyViewedCourse,
  FeaturedCourse,
  PopularCourse,
  RecommendedCourse,
  ContinueLearningCourse
} from '@/types/home';
import { homeService } from '@/services/homeService';

// Platform-specific storage
const getStorage = () => {
  if (Platform.OS === 'web') {
    return {
      getItem: (name: string) => {
        try {
          const value = localStorage.getItem(name);
          return value ? Promise.resolve(JSON.parse(value)) : Promise.resolve(null);
        } catch {
          return Promise.resolve(null);
        }
      },
      setItem: (name: string, value: any) => {
        try {
          localStorage.setItem(name, JSON.stringify(value));
        } catch (error) {
          console.error('Error saving to localStorage:', error);
        }
        return Promise.resolve();
      },
      removeItem: (name: string) => {
        try {
          localStorage.removeItem(name);
        } catch (error) {
          console.error('Error removing from localStorage:', error);
        }
        return Promise.resolve();
      },
    };
  } else {
    const AsyncStorage = require('@react-native-async-storage/async-storage').default;
    return {
      getItem: AsyncStorage.getItem,
      setItem: AsyncStorage.setItem,
      removeItem: AsyncStorage.removeItem,
    };
  }
};

interface HomeState {
  data: HomeData | null;
  featuredCourses: FeaturedCourse[];
  recommendedCourses: RecommendedCourse[];
  popularCourses: PopularCourse[];
  categories: Category[];
  continueLearning: ContinueLearningCourse[];
  learningPaths: LearningPath[];
  liveClasses: LiveClass[];
  achievements: Achievement | null;
  topInstructors: Instructor[];
  userProgress: UserProgress | null;
  notifications: Notification | null;
  recentlyViewed: RecentlyViewedCourse[];
  loading: boolean;
  refreshing: boolean;
  error: string | null;
  isLoadingMore: boolean;
  hasMoreRecommendations: boolean;
  recommendationsPage: number;
  
  // Actions
  fetchHomeData: () => Promise<void>;
  refreshHomeData: () => Promise<void>;
  loadMoreRecommendations: () => Promise<void>;
  updateCourseProgress: (courseId: string, progress: number) => void;
  toggleSaveCourse: (courseId: string) => void;
  followInstructor: (instructorId: string) => Promise<void>;
  unfollowInstructor: (instructorId: string) => Promise<void>;
  markNotificationAsRead: (notificationId: string) => void;
  clearError: () => void;
  reset: () => void;
  updateRecentlyViewed: (course: { id: string; title: string; thumbnail: string; lastOpened?: string; instructor?: string }) => void;
  updateContinueLearning: (courseId: string, progress: number, remainingTime: string) => void;
  getContinueLearningProgress: (courseId: string) => number;
  getCourseById: (courseId: string) => RecommendedCourse | FeaturedCourse | PopularCourse | null;
  getFeaturedCourseById: (courseId: string) => FeaturedCourse | null;
  getRecommendedCourseById: (courseId: string) => RecommendedCourse | null;
  getPopularCourseById: (courseId: string) => PopularCourse | null;
  refreshTopInstructors: () => Promise<void>;
}

const initialState = {
  data: null,
  featuredCourses: [],
  recommendedCourses: [],
  popularCourses: [],
  categories: [],
  continueLearning: [],
  learningPaths: [],
  liveClasses: [],
  achievements: null,
  topInstructors: [],
  userProgress: null,
  notifications: null,
  recentlyViewed: [],
  loading: false,
  refreshing: false,
  error: null,
  isLoadingMore: false,
  hasMoreRecommendations: true,
  recommendationsPage: 1,
};

export const useHomeStore = create<HomeState>()(
  persist(
    (set, get) => ({
      ...initialState,

      fetchHomeData: async () => {
        try {
          set({ loading: true, error: null });
          
          // Fetch home data
          const data = await homeService.getHomeData();
          
          // Fetch top instructors separately to ensure real data
          const instructors = await homeService.getTopInstructors(10);
          
          set({
            data,
            featuredCourses: data.featuredCourses || [],
            recommendedCourses: data.recommendedCourses || [],
            popularCourses: data.popularCourses || [],
            categories: data.categories || [],
            continueLearning: data.continueLearning || [],
            learningPaths: data.learningPaths || [],
            liveClasses: data.liveClasses || [],
            achievements: data.achievements || null,
            topInstructors: instructors.length > 0 ? instructors : data.topInstructors || [],
            userProgress: data.userProgress || null,
            notifications: data.notifications || null,
            recentlyViewed: data.recentlyViewed || [],
            loading: false,
            error: null,
          });
          
          console.log(`✅ Home data loaded: ${instructors.length} instructors`);
        } catch (error: any) {
          console.error('Error fetching home data:', error);
          set({
            loading: false,
            error: error?.message || 'Failed to load home data',
          });
        }
      },

      refreshHomeData: async () => {
        try {
          set({ refreshing: true, error: null });
          
          // Refresh home data
          const data = await homeService.getHomeData(true);
          
          // Refresh top instructors
          const instructors = await homeService.getTopInstructors(10);
          
          set({
            data,
            featuredCourses: data.featuredCourses || [],
            recommendedCourses: data.recommendedCourses || [],
            popularCourses: data.popularCourses || [],
            categories: data.categories || [],
            continueLearning: data.continueLearning || [],
            learningPaths: data.learningPaths || [],
            liveClasses: data.liveClasses || [],
            achievements: data.achievements || null,
            topInstructors: instructors.length > 0 ? instructors : data.topInstructors || [],
            userProgress: data.userProgress || null,
            notifications: data.notifications || null,
            recentlyViewed: data.recentlyViewed || [],
            refreshing: false,
            error: null,
            recommendationsPage: 1,
            hasMoreRecommendations: true,
          });
          
          console.log(`✅ Home data refreshed: ${instructors.length} instructors`);
        } catch (error: any) {
          console.error('Error refreshing home data:', error);
          set({
            refreshing: false,
            error: error?.message || 'Failed to refresh home data',
          });
        }
      },

      refreshTopInstructors: async () => {
        try {
          console.log('🔄 Refreshing top instructors...');
          const instructors = await homeService.getTopInstructors(10);
          
          set({
            topInstructors: instructors,
          });
          
          // Update data object as well
          const currentData = get().data;
          if (currentData) {
            const updatedData = { ...currentData, topInstructors: instructors };
            set({ data: updatedData });
          }
          
          console.log(`✅ Refreshed ${instructors.length} instructors`);
        } catch (error) {
          console.error('❌ Failed to refresh instructors:', error);
        }
      },

      loadMoreRecommendations: async () => {
        const { isLoadingMore, hasMoreRecommendations, recommendationsPage, recommendedCourses } = get();
        
        if (isLoadingMore || !hasMoreRecommendations) {
          return;
        }
        
        try {
          set({ isLoadingMore: true });
          
          const nextPage = recommendationsPage + 1;
          const moreCourses = await homeService.getRecommendedCourses(nextPage);
          
          if (moreCourses.length === 0) {
            set({ hasMoreRecommendations: false, isLoadingMore: false });
            return;
          }
          
          set({
            recommendedCourses: [...recommendedCourses, ...moreCourses],
            recommendationsPage: nextPage,
            isLoadingMore: false,
          });
        } catch (error) {
          console.error('Error loading more recommendations:', error);
          set({ isLoadingMore: false });
        }
      },

      updateCourseProgress: (courseId: string, progress: number) => {
        const clampedProgress = Math.min(Math.max(progress, 0), 100);
        
        set((state) => ({
          continueLearning: state.continueLearning.map((course) =>
            course.id === courseId
              ? { ...course, progress: clampedProgress }
              : course
          ),
        }));
        
        const currentData = get().data;
        if (currentData) {
          const updatedData = { ...currentData };
          updatedData.continueLearning = updatedData.continueLearning.map((course) =>
            course.id === courseId
              ? { ...course, progress: clampedProgress }
              : course
          );
          set({ data: updatedData });
        }
      },

      toggleSaveCourse: (courseId: string) => {
        set((state) => ({
          recommendedCourses: state.recommendedCourses.map((course) =>
            course.id === courseId
              ? { ...course, isSaved: !course.isSaved }
              : course
          ),
        }));
        
        const currentData = get().data;
        if (currentData) {
          const updatedData = { ...currentData };
          updatedData.recommendedCourses = updatedData.recommendedCourses.map((course) =>
            course.id === courseId
              ? { ...course, isSaved: !course.isSaved }
              : course
          );
          set({ data: updatedData });
        }
        
        homeService.toggleSaveCourse(courseId).catch((error) => {
          console.error('Error toggling save:', error);
          set((state) => ({
            recommendedCourses: state.recommendedCourses.map((course) =>
              course.id === courseId
                ? { ...course, isSaved: !course.isSaved }
                : course
            ),
          }));
        });
      },

      followInstructor: async (instructorId: string) => {
        try {
          // Optimistically update UI
          set((state) => ({
            topInstructors: state.topInstructors.map((instructor) =>
              instructor.id === instructorId
                ? { ...instructor, isFollowing: true }
                : instructor
            ),
          }));
          
          // Update data object as well
          const currentData = get().data;
          if (currentData) {
            const updatedData = { ...currentData };
            updatedData.topInstructors = updatedData.topInstructors.map((instructor) =>
              instructor.id === instructorId
                ? { ...instructor, isFollowing: true }
                : instructor
            );
            set({ data: updatedData });
          }
          
          // Call API
          await homeService.followInstructor(instructorId);
          console.log(`✅ Followed instructor ${instructorId}`);
          
          // Refresh instructors to get updated data
          await get().refreshTopInstructors();
          
        } catch (error) {
          console.error('Error following instructor:', error);
          // Revert optimistic update
          set((state) => ({
            topInstructors: state.topInstructors.map((instructor) =>
              instructor.id === instructorId
                ? { ...instructor, isFollowing: false }
                : instructor
            ),
          }));
          throw error;
        }
      },

      unfollowInstructor: async (instructorId: string) => {
        try {
          // Optimistically update UI
          set((state) => ({
            topInstructors: state.topInstructors.map((instructor) =>
              instructor.id === instructorId
                ? { ...instructor, isFollowing: false }
                : instructor
            ),
          }));
          
          // Update data object as well
          const currentData = get().data;
          if (currentData) {
            const updatedData = { ...currentData };
            updatedData.topInstructors = updatedData.topInstructors.map((instructor) =>
              instructor.id === instructorId
                ? { ...instructor, isFollowing: false }
                : instructor
            );
            set({ data: updatedData });
          }
          
          // Call API
          await homeService.unfollowInstructor(instructorId);
          console.log(`✅ Unfollowed instructor ${instructorId}`);
          
          // Refresh instructors to get updated data
          await get().refreshTopInstructors();
          
        } catch (error) {
          console.error('Error unfollowing instructor:', error);
          // Revert optimistic update
          set((state) => ({
            topInstructors: state.topInstructors.map((instructor) =>
              instructor.id === instructorId
                ? { ...instructor, isFollowing: true }
                : instructor
            ),
          }));
          throw error;
        }
      },

      markNotificationAsRead: (notificationId: string) => {
        set((state) => ({
          notifications: state.notifications
            ? {
                ...state.notifications,
                unread: Math.max(0, state.notifications.unread - 1),
              }
            : null,
        }));
        
        const currentData = get().data;
        if (currentData?.notifications) {
          const updatedData = { ...currentData };
          updatedData.notifications = {
            ...currentData.notifications,
            unread: Math.max(0, currentData.notifications.unread - 1),
          };
          set({ data: updatedData });
        }
        
        homeService.markNotificationAsRead(notificationId).catch((error) => {
          console.error('Error marking notification as read:', error);
        });
      },

      clearError: () => {
        set({ error: null });
      },

      reset: () => {
        set(initialState);
      },

      updateRecentlyViewed: (course: { id: string; title: string; thumbnail: string; lastOpened?: string; instructor?: string }) => {
        set((state) => {
          const recentlyViewedCourse: RecentlyViewedCourse = {
            id: course.id,
            title: course.title,
            thumbnail: course.thumbnail,
            lastOpened: course.lastOpened || new Date().toLocaleString(),
            instructor: course.instructor || '',
          };

          const filtered = state.recentlyViewed.filter(c => c.id !== course.id);
          const updated = [recentlyViewedCourse, ...filtered].slice(0, 10);
          
          if (state.data) {
            const updatedData = { ...state.data };
            updatedData.recentlyViewed = updated;
            return { 
              recentlyViewed: updated,
              data: updatedData 
            };
          }
          
          return { recentlyViewed: updated };
        });
        
        homeService.trackCourseView(course.id).catch((error) => {
          console.error('Error tracking course view:', error);
        });
      },

      updateContinueLearning: (courseId: string, progress: number, remainingTime: string) => {
        const clampedProgress = Math.min(Math.max(progress, 0), 100);
        
        set((state) => ({
          continueLearning: state.continueLearning.map((course) =>
            course.id === courseId
              ? { ...course, progress: clampedProgress, remainingTime }
              : course
          ),
        }));
        
        const currentData = get().data;
        if (currentData) {
          const updatedData = { ...currentData };
          updatedData.continueLearning = updatedData.continueLearning.map((course) =>
            course.id === courseId
              ? { ...course, progress: clampedProgress, remainingTime }
              : course
          );
          set({ data: updatedData });
        }
      },

      getContinueLearningProgress: (courseId: string) => {
        const course = get().continueLearning.find(c => c.id === courseId);
        return course?.progress || 0;
      },

      getCourseById: (courseId: string) => {
        const state = get();
        const found = state.recommendedCourses.find(c => c.id === courseId) ||
                      state.featuredCourses.find(c => c.id === courseId) ||
                      state.popularCourses.find(c => c.id === courseId);
        return found || null;
      },

      getFeaturedCourseById: (courseId: string) => {
        return get().featuredCourses.find(c => c.id === courseId) || null;
      },

      getRecommendedCourseById: (courseId: string) => {
        return get().recommendedCourses.find(c => c.id === courseId) || null;
      },

      getPopularCourseById: (courseId: string) => {
        return get().popularCourses.find(c => c.id === courseId) || null;
      },
    }),
    {
      name: 'home-storage',
      storage: createJSONStorage(() => getStorage()),
      partialize: (state) => ({
        continueLearning: state.continueLearning,
        recentlyViewed: state.recentlyViewed,
        userProgress: state.userProgress,
        achievements: state.achievements,
        notifications: state.notifications,
        featuredCourses: state.featuredCourses,
        recommendedCourses: state.recommendedCourses,
        popularCourses: state.popularCourses,
        topInstructors: state.topInstructors,
        learningPaths: state.learningPaths,
      }),
    }
  )
);