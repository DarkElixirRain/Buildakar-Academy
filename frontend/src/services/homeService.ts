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

// ✅ Mock data for everything except categories
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
  categories: [],
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

// ✅ Helper function for mock categories
function getMockCategories(): Category[] {
  return [
    { 
      id: 'dev', 
      name: 'Development', 
      icon: 'code-slash', 
      color: '#2563EB',
      slug: 'development',
      courseCount: 45,
      description: 'Learn programming and software development',
      isActive: true,
    },
    { 
      id: 'ai', 
      name: 'AI & Machine Learning', 
      icon: 'bulb-outline', 
      color: '#7C3AED',
      slug: 'ai-machine-learning',
      courseCount: 32,
      description: 'Artificial Intelligence and Machine Learning',
      isActive: true,
    },
    { 
      id: 'data', 
      name: 'Data Science', 
      icon: 'bar-chart-outline', 
      color: '#22C55E',
      slug: 'data-science',
      courseCount: 28,
      description: 'Data analysis, visualization, and statistics',
      isActive: true,
    },
    { 
      id: 'design', 
      name: 'Design', 
      icon: 'color-palette-outline', 
      color: '#F59E0B',
      slug: 'design',
      courseCount: 38,
      description: 'UI/UX, graphic design, and creative skills',
      isActive: true,
    },
    { 
      id: 'marketing', 
      name: 'Marketing', 
      icon: 'megaphone-outline', 
      color: '#EF4444',
      slug: 'marketing',
      courseCount: 25,
      description: 'Digital marketing, SEO, and social media',
      isActive: true,
    },
    { 
      id: 'business', 
      name: 'Business', 
      icon: 'briefcase-outline', 
      color: '#3B82F6',
      slug: 'business',
      courseCount: 30,
      description: 'Entrepreneurship and business management',
      isActive: true,
    },
    { 
      id: 'finance', 
      name: 'Finance', 
      icon: 'cash-outline', 
      color: '#10B981',
      slug: 'finance',
      courseCount: 20,
      description: 'Financial planning and investment strategies',
      isActive: true,
    },
    { 
      id: 'languages', 
      name: 'Languages', 
      icon: 'language-outline', 
      color: '#EC4899',
      slug: 'languages',
      courseCount: 15,
      description: 'Learn new languages and communication skills',
      isActive: true,
    },
  ];
}

// ✅ Helper function to extract categories from unknown response
function extractCategoriesFromResponse(response: any): any[] {
  // Check if response is null or undefined
  if (!response) return [];
  
  // Case 1: Direct array
  if (Array.isArray(response)) {
    return response;
  }
  
  // Case 2: Object with data property
  if (response.data && Array.isArray(response.data)) {
    return response.data;
  }
  
  // Case 3: Object with success and data
  if (response.success === true && response.data && Array.isArray(response.data)) {
    return response.data;
  }
  
  // Case 4: Object with categories property
  if (response.categories && Array.isArray(response.categories)) {
    return response.categories;
  }
  
  // Case 5: Response might have a property that is an array
  if (typeof response === 'object') {
    for (const key in response) {
      if (Array.isArray(response[key]) && response[key].length > 0) {
        return response[key];
      }
    }
  }
  
  // No categories found
  return [];
}

export const homeService = {
  // ✅ Get home data - categories from API, everything else from mock
  getHomeData: async (forceRefresh: boolean = false): Promise<HomeData> => {
    try {
      // Check cache first
      if (!forceRefresh) {
        const cachedData = await cacheManager.get<HomeData>(CACHE_KEYS.HOME_DATA);
        if (cachedData) {
          console.log('📦 Using cached home data');
          return cachedData;
        }
      }

      // Start with mock data
      const data: HomeData = { ...MOCK_DATA, categories: [] };
      
      // ✅ Fetch categories from backend API
      try {
        console.log('🌐 Fetching categories from backend...');
        const response = await apiClient.get('/api/categories');
        
        // Extract categories from response using helper
        const categoriesData = extractCategoriesFromResponse(response);
        
        if (categoriesData.length > 0) {
          data.categories = categoriesData.map((cat: any) => ({
            id: cat.id || cat._id,
            name: cat.name || 'Unnamed Category',
            slug: cat.slug || cat.name?.toLowerCase().replace(/\s+/g, '-') || 'uncategorized',
            icon: cat.icon || 'book-outline',
            color: cat.color || '#2563EB',
            image: cat.image || cat.thumbnail,
            courseCount: cat._count?.courses || cat.courseCount || 0,
            description: cat.description || '',
            isActive: cat.isActive !== undefined ? cat.isActive : true,
          }));
          console.log(`✅ Fetched ${data.categories.length} categories from backend`);
        } else {
          console.log('⚠️ No categories found in response, using mock data');
          data.categories = getMockCategories();
        }
      } catch (error) {
        console.error('❌ Failed to fetch categories from backend:', error);
        data.categories = getMockCategories();
        console.log('⚠️ Using mock categories (API failed)');
      }

      // Cache the data
      await cacheManager.set(CACHE_KEYS.HOME_DATA, data);
      console.log(`💾 Home data cached with ${data.categories.length} categories`);
      return data;
      
    } catch (error) {
      console.error('❌ Failed to fetch home data:', error);
      
      // Try to get from cache
      const cachedData = await cacheManager.get<HomeData>(CACHE_KEYS.HOME_DATA);
      if (cachedData) {
        console.log('📦 Using cached home data (API failed)');
        return cachedData;
      }
      
      // Final fallback with mock categories
      console.log('⚠️ Using mock data (no cache available)');
      return {
        ...MOCK_DATA,
        categories: getMockCategories(),
      };
    }
  },

  // ✅ Get categories only from API
  getCategories: async (): Promise<Category[]> => {
    try {
      console.log('🌐 Fetching categories from backend...');
      const response = await apiClient.get('/api/categories');
      
      // Extract categories from response using helper
      const categoriesData = extractCategoriesFromResponse(response);
      
      if (categoriesData.length === 0) {
        console.log('⚠️ No categories found in response, using mock data');
        return getMockCategories();
      }
      
      const categories: Category[] = categoriesData.map((cat: any) => ({
        id: cat.id || cat._id,
        name: cat.name || 'Unnamed Category',
        slug: cat.slug || cat.name?.toLowerCase().replace(/\s+/g, '-') || 'uncategorized',
        icon: cat.icon || 'book-outline',
        color: cat.color || '#2563EB',
        image: cat.image || cat.thumbnail,
        courseCount: cat._count?.courses || cat.courseCount || 0,
        description: cat.description || '',
        isActive: cat.isActive !== undefined ? cat.isActive : true,
      }));
      
      console.log(`✅ Fetched ${categories.length} categories from backend`);
      return categories;
      
    } catch (error) {
      console.error('❌ Failed to fetch categories:', error);
      return getMockCategories();
    }
  },

  // ✅ All other methods use mock data
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

  getAchievements: async (): Promise<Achievement | null> => {
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

  getUserProgress: async (): Promise<UserProgress | null> => {
    try {
      return MOCK_DATA.userProgress;
    } catch (error) {
      console.error('Failed to fetch user progress:', error);
      return MOCK_DATA.userProgress;
    }
  },

  getNotifications: async (): Promise<Notification | null> => {
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