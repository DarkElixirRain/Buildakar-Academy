// services/homeService.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import { 
  HomeData, 
  Course, 
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
import { apiClient } from '@/lib/apiClient';
import { cacheManager } from '@/lib/cacheManager';

const CACHE_KEYS = {
  HOME_DATA: 'home_data',
  RECOMMENDATIONS: 'home_recommendations',
  POPULAR_COURSES: 'home_popular',
  CATEGORIES: 'home_categories',
  CONTINUE_LEARNING: 'home_continue_learning',
  LEARNING_PATHS: 'home_learning_paths',
  LIVE_CLASSES: 'home_live_classes',
  ACHIEVEMENTS: 'home_achievements',
  TOP_INSTRUCTORS: 'home_top_instructors',
  USER_PROGRESS: 'home_user_progress',
  NOTIFICATIONS: 'home_notifications',
  RECENTLY_VIEWED: 'home_recently_viewed',
};

const MOCK_DATA: HomeData = {
  featuredCourses: [
    {
      id: '1',
      title: 'The Complete React Native Course',
      instructor: 'John Doe',
      image: 'https://picsum.photos/seed/react/400/300',
      thumbnail: 'https://picsum.photos/seed/react/400/300',
      rating: 4.8,
      isBestseller: true,
    },
    {
      id: '2',
      title: 'Machine Learning A-Z',
      instructor: 'Jane Smith',
      image: 'https://picsum.photos/seed/ml/400/300',
      thumbnail: 'https://picsum.photos/seed/ml/400/300',
      rating: 4.9,
      isBestseller: true,
    },
    {
      id: '3',
      title: 'UI/UX Design Masterclass',
      instructor: 'Alice Johnson',
      image: 'https://picsum.photos/seed/design/400/300',
      thumbnail: 'https://picsum.photos/seed/design/400/300',
      rating: 4.7,
      isBestseller: false,
    },
  ],
  recommendedCourses: [
    {
      id: '4',
      title: 'Python for Data Science',
      instructor: 'Bob Wilson',
      thumbnail: 'https://picsum.photos/seed/python/400/300',
      rating: 4.6,
      students: 15400,
      duration: '12h 30m',
      isSaved: false,
    },
    {
      id: '5',
      title: 'JavaScript: The Advanced Concepts',
      instructor: 'Sarah Chen',
      thumbnail: 'https://picsum.photos/seed/js/400/300',
      rating: 4.8,
      students: 21300,
      duration: '15h 20m',
      isSaved: true,
    },
    {
      id: '6',
      title: 'DevOps with AWS',
      instructor: 'Mike Brown',
      thumbnail: 'https://picsum.photos/seed/aws/400/300',
      rating: 4.7,
      students: 8900,
      duration: '18h 45m',
      isSaved: false,
    },
  ],
  popularCourses: [
    {
      id: '8',
      title: 'Full Stack Web Development',
      instructor: 'Emily Davis',
      thumbnail: 'https://picsum.photos/seed/fullstack/400/300',
      rating: 4.9,
      students: 32100,
      isTrending: true,
    },
    {
      id: '9',
      title: 'Artificial Intelligence Fundamentals',
      instructor: 'David Kim',
      thumbnail: 'https://picsum.photos/seed/ai/400/300',
      rating: 4.8,
      students: 18700,
      isTrending: true,
    },
  ],
  categories: [
    { id: 'dev', name: 'Development', icon: 'code-slash', color: '#2563EB' },
    { id: 'ai', name: 'AI', icon: 'brain', color: '#7C3AED' },
    { id: 'data', name: 'Data Science', icon: 'bar-chart', color: '#22C55E' },
    { id: 'design', name: 'Design', icon: 'color-palette', color: '#F59E0B' },
    { id: 'marketing', name: 'Marketing', icon: 'megaphone', color: '#EF4444' },
    { id: 'business', name: 'Business', icon: 'briefcase', color: '#3B82F6' },
    { id: 'finance', name: 'Finance', icon: 'cash', color: '#10B981' },
    { id: 'languages', name: 'Languages', icon: 'language', color: '#EC4899' },
  ],
  continueLearning: [
    {
      id: '10',
      title: 'React Native Mastery',
      instructor: 'John Doe',
      thumbnail: 'https://picsum.photos/seed/rnmastery/400/300',
      progress: 65,
      remainingTime: '4h 20m',
    },
    {
      id: '11',
      title: 'Data Structures & Algorithms',
      instructor: 'Jane Smith',
      thumbnail: 'https://picsum.photos/seed/dsa/400/300',
      progress: 40,
      remainingTime: '10h 15m',
    },
  ],
  learningPaths: [
    {
      id: 'path1',
      title: 'Become React Native Developer',
      description: 'Master React Native from basics to advanced',
      courses: 12,
      duration: '6 months',
      image: 'https://picsum.photos/seed/path1/400/300',
    },
    {
      id: 'path2',
      title: 'Become AI Engineer',
      description: 'Learn AI, ML, and Deep Learning',
      courses: 15,
      duration: '8 months',
      image: 'https://picsum.photos/seed/path2/400/300',
    },
  ],
  liveClasses: [
    {
      id: 'live1',
      title: 'React Native Workshop',
      instructor: 'John Doe',
      date: 'Dec 15, 2024',
      time: '10:00 AM EST',
      image: 'https://picsum.photos/seed/live1/400/300',
      isLive: false,
    },
    {
      id: 'live2',
      title: 'Machine Learning Q&A',
      instructor: 'Jane Smith',
      date: 'Dec 16, 2024',
      time: '2:00 PM EST',
      image: 'https://picsum.photos/seed/live2/400/300',
      isLive: true,
    },
  ],
  achievements: {
    streak: 15,
    xp: 2500,
    badges: 8,
    nextBadge: '10 Courses Completed',
  },
  topInstructors: [
    {
      id: 'inst1',
      name: 'John Doe',
      expertise: 'React Native Expert',
      photo: 'https://picsum.photos/seed/john/200/200',
      rating: 4.9,
      isFollowing: false,
    },
    {
      id: 'inst2',
      name: 'Jane Smith',
      expertise: 'AI & ML Specialist',
      photo: 'https://picsum.photos/seed/jane/200/200',
      rating: 4.8,
      isFollowing: true,
    },
  ],
  userProgress: {
    streak: 15,
    enrolled: 8,
    completed: 5,
    hours: 42,
    weeklyGoal: 10,
    weeklyProgress: 6,
  },
  notifications: {
    id: 'notif1',
    unread: 3,
  },
  recentlyViewed: [
    {
        id: '13',
        title: 'React Native Performance Tips',
        thumbnail: 'https://picsum.photos/seed/recent1/400/300',
        lastOpened: '2 hours ago',
        instructor: ''
    },
    {
        id: '14',
        title: 'GraphQL for Beginners',
        thumbnail: 'https://picsum.photos/seed/recent2/400/300',
        lastOpened: '5 hours ago',
        instructor: ''
    },
  ],
};

export const homeService = {
  getHomeData: async (forceRefresh: boolean = false): Promise<HomeData> => {
    try {
      if (!forceRefresh) {
        const cachedData = await cacheManager.get<HomeData>(CACHE_KEYS.HOME_DATA);
        if (cachedData) {
          return cachedData;
        }
      }

      // In production: const response = await apiClient.get('/api/home');
      // const data = response.data;
      
      const data = MOCK_DATA;
      await cacheManager.set(CACHE_KEYS.HOME_DATA, data);
      return data;
    } catch (error) {
      console.error('Failed to fetch home data:', error);
      const cachedData = await cacheManager.get<HomeData>(CACHE_KEYS.HOME_DATA);
      if (cachedData) {
        return cachedData;
      }
      return MOCK_DATA;
    }
  },

  getRecommendedCourses: async (page: number = 1, limit: number = 10): Promise<RecommendedCourse[]> => {
    try {
      await new Promise(resolve => setTimeout(resolve, 500));
      
      const moreCourses: RecommendedCourse[] = Array.from({ length: Math.min(limit, 3) }, (_, i) => ({
        id: `rec_${page}_${i}`,
        title: `Recommended Course ${page}-${i + 1}`,
        instructor: `Instructor ${page}-${i + 1}`,
        thumbnail: `https://picsum.photos/seed/rec_${page}_${i}/400/300`,
        rating: 4.5 + Math.random() * 0.4,
        students: Math.floor(5000 + Math.random() * 15000),
        duration: `${Math.floor(8 + Math.random() * 20)}h ${Math.floor(Math.random() * 60)}m`,
        isSaved: Math.random() > 0.7,
      }));
      
      return moreCourses;
    } catch (error) {
      console.error('Failed to fetch recommended courses:', error);
      return [];
    }
  },

  getPopularCourses: async (): Promise<PopularCourse[]> => {
    try {
      return MOCK_DATA.popularCourses;
    } catch (error) {
      console.error('Failed to fetch popular courses:', error);
      return [];
    }
  },

  getCategories: async (): Promise<Category[]> => {
    try {
      return MOCK_DATA.categories;
    } catch (error) {
      console.error('Failed to fetch categories:', error);
      return [];
    }
  },

  getContinueLearning: async (): Promise<ContinueLearningCourse[]> => {
    try {
      return MOCK_DATA.continueLearning;
    } catch (error) {
      console.error('Failed to fetch continue learning:', error);
      return [];
    }
  },

  getLearningPaths: async (): Promise<LearningPath[]> => {
    try {
      return MOCK_DATA.learningPaths;
    } catch (error) {
      console.error('Failed to fetch learning paths:', error);
      return [];
    }
  },

  getLiveClasses: async (): Promise<LiveClass[]> => {
    try {
      return MOCK_DATA.liveClasses;
    } catch (error) {
      console.error('Failed to fetch live classes:', error);
      return [];
    }
  },

  getAchievements: async (): Promise<Achievement> => {
    try {
      return MOCK_DATA.achievements;
    } catch (error) {
      console.error('Failed to fetch achievements:', error);
      return MOCK_DATA.achievements;
    }
  },

  getTopInstructors: async (): Promise<Instructor[]> => {
    try {
      return MOCK_DATA.topInstructors;
    } catch (error) {
      console.error('Failed to fetch top instructors:', error);
      return [];
    }
  },

  getUserProgress: async (): Promise<UserProgress> => {
    try {
      return MOCK_DATA.userProgress;
    } catch (error) {
      console.error('Failed to fetch user progress:', error);
      return MOCK_DATA.userProgress;
    }
  },

  getNotifications: async (): Promise<Notification> => {
    try {
      return MOCK_DATA.notifications;
    } catch (error) {
      console.error('Failed to fetch notifications:', error);
      return MOCK_DATA.notifications;
    }
  },

  getRecentlyViewed: async (): Promise<RecentlyViewedCourse[]> => {
    try {
      return MOCK_DATA.recentlyViewed;
    } catch (error) {
      console.error('Failed to fetch recently viewed:', error);
      return [];
    }
  },

  toggleSaveCourse: async (courseId: string): Promise<void> => {
    try {
      console.log(`Toggled save for course ${courseId}`);
    } catch (error) {
      console.error('Failed to toggle save course:', error);
      throw error;
    }
  },

  followInstructor: async (instructorId: string): Promise<void> => {
    try {
      console.log(`Followed instructor ${instructorId}`);
    } catch (error) {
      console.error('Failed to follow instructor:', error);
      throw error;
    }
  },

  unfollowInstructor: async (instructorId: string): Promise<void> => {
    try {
      console.log(`Unfollowed instructor ${instructorId}`);
    } catch (error) {
      console.error('Failed to unfollow instructor:', error);
      throw error;
    }
  },

  markNotificationAsRead: async (notificationId: string): Promise<void> => {
    try {
      console.log(`Marked notification ${notificationId} as read`);
    } catch (error) {
      console.error('Failed to mark notification as read:', error);
      throw error;
    }
  },

  trackCourseView: async (courseId: string): Promise<void> => {
    try {
      console.log(`Tracked view for course ${courseId}`);
    } catch (error) {
      console.error('Failed to track course view:', error);
    }
  },

  updateCourseProgress: async (courseId: string, progress: number): Promise<void> => {
    try {
      console.log(`Updated progress for course ${courseId}: ${progress}%`);
    } catch (error) {
      console.error('Failed to update course progress:', error);
      throw error;
    }
  },
};