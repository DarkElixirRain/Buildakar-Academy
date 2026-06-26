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
    // Use localStorage for web
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
    // Use AsyncStorage for native platforms
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
  followInstructor: (instructorId: string) => void;
  unfollowInstructor: (instructorId: string) => void;
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
          
          console.log('[HomeStore] Fetching home data...');
          const data = await homeService.getHomeData();
          
          console.log('[HomeStore] Home data fetched successfully');
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
            topInstructors: data.topInstructors || [],
            userProgress: data.userProgress || null,
            notifications: data.notifications || null,
            recentlyViewed: data.recentlyViewed || [],
            loading: false,
            error: null,
          });
        } catch (error: any) {
          console.error('[HomeStore] Error fetching home data:', error);
          set({
            loading: false,
            error: error?.message || 'Failed to load home data',
          });
        }
      },

      refreshHomeData: async () => {
        try {
          set({ refreshing: true, error: null });
          
          console.log('[HomeStore] Refreshing home data...');
          const data = await homeService.getHomeData(true);
          
          console.log('[HomeStore] Home data refreshed successfully');
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
            topInstructors: data.topInstructors || [],
            userProgress: data.userProgress || null,
            notifications: data.notifications || null,
            recentlyViewed: data.recentlyViewed || [],
            refreshing: false,
            error: null,
            recommendationsPage: 1,
            hasMoreRecommendations: true,
          });
        } catch (error: any) {
          console.error('[HomeStore] Error refreshing home data:', error);
          set({
            refreshing: false,
            error: error?.message || 'Failed to refresh home data',
          });
        }
      },

      loadMoreRecommendations: async () => {
        const { isLoadingMore, hasMoreRecommendations, recommendationsPage, recommendedCourses } = get();
        
        if (isLoadingMore || !hasMoreRecommendations) {
          console.log('[HomeStore] No more recommendations to load');
          return;
        }
        
        try {
          set({ isLoadingMore: true });
          console.log('[HomeStore] Loading more recommendations, page:', recommendationsPage + 1);
          
          const nextPage = recommendationsPage + 1;
          const moreCourses = await homeService.getRecommendedCourses(nextPage);
          
          if (moreCourses.length === 0) {
            console.log('[HomeStore] No more recommendations available');
            set({ hasMoreRecommendations: false, isLoadingMore: false });
            return;
          }
          
          console.log('[HomeStore] Loaded', moreCourses.length, 'more recommendations');
          set({
            recommendedCourses: [...recommendedCourses, ...moreCourses],
            recommendationsPage: nextPage,
            isLoadingMore: false,
          });
        } catch (error) {
          console.error('[HomeStore] Error loading more recommendations:', error);
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
        
        // Update data object as well
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
        console.log('[HomeStore] Toggling save for course:', courseId);
        
        set((state) => ({
          recommendedCourses: state.recommendedCourses.map((course) =>
            course.id === courseId
              ? { ...course, isSaved: !course.isSaved }
              : course
          ),
        }));
        
        // Update data object as well
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
        
        // Call service to persist the change
        homeService.toggleSaveCourse(courseId).catch((error) => {
          console.error('[HomeStore] Error toggling save:', error);
          // Revert the change if API call fails
          set((state) => ({
            recommendedCourses: state.recommendedCourses.map((course) =>
              course.id === courseId
                ? { ...course, isSaved: !course.isSaved }
                : course
            ),
          }));
        });
      },

      followInstructor: (instructorId: string) => {
        console.log('[HomeStore] Following instructor:', instructorId);
        
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
        
        homeService.followInstructor(instructorId).catch((error) => {
          console.error('[HomeStore] Error following instructor:', error);
          // Revert the change if API call fails
          set((state) => ({
            topInstructors: state.topInstructors.map((instructor) =>
              instructor.id === instructorId
                ? { ...instructor, isFollowing: false }
                : instructor
            ),
          }));
        });
      },

      unfollowInstructor: (instructorId: string) => {
        console.log('[HomeStore] Unfollowing instructor:', instructorId);
        
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
        
        homeService.unfollowInstructor(instructorId).catch((error) => {
          console.error('[HomeStore] Error unfollowing instructor:', error);
          // Revert the change if API call fails
          set((state) => ({
            topInstructors: state.topInstructors.map((instructor) =>
              instructor.id === instructorId
                ? { ...instructor, isFollowing: true }
                : instructor
            ),
          }));
        });
      },

      markNotificationAsRead: (notificationId: string) => {
        console.log('[HomeStore] Marking notification as read:', notificationId);
        
        set((state) => ({
          notifications: state.notifications
            ? {
                ...state.notifications,
                unread: Math.max(0, state.notifications.unread - 1),
              }
            : null,
        }));
        
        // Update data object as well
        const currentData = get().data;
        if (currentData?.notifications) {
          const updatedData = { ...currentData };
          updatedData.notifications = {
            ...updatedData.notifications,
            unread: Math.max(0, updatedData.notifications.unread - 1),
          };
          set({ data: updatedData });
        }
        
        homeService.markNotificationAsRead(notificationId).catch((error) => {
          console.error('[HomeStore] Error marking notification as read:', error);
        });
      },

      clearError: () => {
        set({ error: null });
      },

      reset: () => {
        console.log('[HomeStore] Resetting state');
        set(initialState);
      },

      updateRecentlyViewed: (course: { id: string; title: string; thumbnail: string; lastOpened?: string; instructor?: string }) => {
        console.log('[HomeStore] Updating recently viewed:', course.id);
        
        set((state) => {
          const recentlyViewedCourse: RecentlyViewedCourse = {
            id: course.id,
            title: course.title,
            thumbnail: course.thumbnail,
            lastOpened: course.lastOpened || new Date().toLocaleString(),
            instructor: course.instructor || '',
          };

          // Remove duplicate if exists
          const filtered = state.recentlyViewed.filter(c => c.id !== course.id);
          // Add to front and limit to 10
          const updated = [recentlyViewedCourse, ...filtered].slice(0, 10);
          
          // Update data object as well
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
        
        // Track view in background
        homeService.trackCourseView(course.id).catch((error) => {
          console.error('[HomeStore] Error tracking course view:', error);
        });
      },

      updateContinueLearning: (courseId: string, progress: number, remainingTime: string) => {
        const clampedProgress = Math.min(Math.max(progress, 0), 100);
        console.log('[HomeStore] Updating continue learning:', courseId, clampedProgress);
        
        set((state) => ({
          continueLearning: state.continueLearning.map((course) =>
            course.id === courseId
              ? { ...course, progress: clampedProgress, remainingTime }
              : course
          ),
        }));
        
        // Update data object as well
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