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
  categories: [], // ✅ Empty array - no mock categories
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

// ✅ Helper function to extract categories from unknown response
function extractCategoriesFromResponse(response: any): any[] {
  console.log('🔍 Extracting categories from response:', JSON.stringify(response, null, 2));
  
  // Check if response is null or undefined
  if (!response) {
    console.log('⚠️ Response is null or undefined');
    return [];
  }
  
  // Case 1: Response has success and data (our API format)
  if (response.success === true && response.data) {
    if (Array.isArray(response.data)) {
      console.log('✅ Found categories in response.data (array)');
      return response.data;
    } else if (response.data.categories && Array.isArray(response.data.categories)) {
      console.log('✅ Found categories in response.data.categories');
      return response.data.categories;
    }
  }
  
  // Case 2: Response has data property directly
  if (response.data && Array.isArray(response.data)) {
    console.log('✅ Found categories in response.data');
    return response.data;
  }
  
  // Case 3: Response is directly an array
  if (Array.isArray(response)) {
    console.log('✅ Response is directly an array');
    return response;
  }
  
  // Case 4: Response has categories property
  if (response.categories && Array.isArray(response.categories)) {
    console.log('✅ Found categories in response.categories');
    return response.categories;
  }
  
  // Case 5: Response might have a property that is an array
  if (typeof response === 'object') {
    for (const key in response) {
      if (Array.isArray(response[key]) && response[key].length > 0) {
        console.log(`✅ Found categories in response.${key}`);
        return response[key];
      }
    }
  }
  
  console.log('⚠️ No categories found in response');
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

      // Start with mock data (categories empty)
      const data: HomeData = { ...MOCK_DATA, categories: [] };
      
      // ✅ Fetch categories from backend API - FIXED: Added /api prefix
      try {
        console.log('🌐 Fetching categories from backend...');
        const response = await apiClient.get('/api/categories'); // ✅ Fixed: added /api
        console.log('📥 Raw API response:', JSON.stringify(response, null, 2));
        
        // Extract categories from response using helper
        const categoriesData = extractCategoriesFromResponse(response);
        console.log('📊 Extracted categories count:', categoriesData.length);
        
        if (categoriesData.length > 0) {
          data.categories = categoriesData.map((cat: any) => ({
            id: cat.id || cat._id || String(cat.id),
            name: cat.name || 'Unnamed Category',
            slug: cat.slug || cat.name?.toLowerCase().replace(/\s+/g, '-') || 'uncategorized',
            icon: cat.icon || 'book-outline',
            color: cat.color || '#2563EB',
            image: cat.image || cat.thumbnail || null,
            courseCount: cat._count?.courses || cat.courseCount || 0,
            description: cat.description || '',
            isActive: cat.isActive !== undefined ? cat.isActive : true,
          }));
          console.log(`✅ Fetched ${data.categories.length} categories from backend`);
          console.log('✅ Categories:', JSON.stringify(data.categories, null, 2));
        } else {
          console.log('⚠️ No categories found in response');
          data.categories = [];
        }
      } catch (error: any) {
        console.error('❌ Failed to fetch categories from backend:', error);
        console.error('❌ Error details:', error.message);
        if (error.response) {
          console.error('❌ Response data:', error.response.data);
          console.error('❌ Response status:', error.response.status);
        }
        data.categories = [];
        console.log('⚠️ No categories available (API failed)');
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
      
      // Final fallback - no mock categories
      console.log('⚠️ Using mock data (no cache available)');
      return {
        ...MOCK_DATA,
        categories: [],
      };
    }
  },

  // ✅ Get categories only from API - no mock fallback
  getCategories: async (): Promise<Category[]> => {
    try {
      console.log('🌐 Fetching categories from backend...');
      const response = await apiClient.get('/api/categories'); // ✅ Fixed: added /api
      console.log('📥 Raw API response:', JSON.stringify(response, null, 2));
      
      // Extract categories from response using helper
      const categoriesData = extractCategoriesFromResponse(response);
      console.log('📊 Extracted categories count:', categoriesData.length);
      
      if (categoriesData.length === 0) {
        console.log('⚠️ No categories found in response');
        return [];
      }
      
      const categories: Category[] = categoriesData.map((cat: any) => ({
        id: cat.id || cat._id || String(cat.id),
        name: cat.name || 'Unnamed Category',
        slug: cat.slug || cat.name?.toLowerCase().replace(/\s+/g, '-') || 'uncategorized',
        icon: cat.icon || 'book-outline',
        color: cat.color || '#2563EB',
        image: cat.image || cat.thumbnail || null,
        courseCount: cat._count?.courses || cat.courseCount || 0,
        description: cat.description || '',
        isActive: cat.isActive !== undefined ? cat.isActive : true,
      }));
      
      console.log(`✅ Fetched ${categories.length} categories from backend`);
      console.log('✅ Categories:', JSON.stringify(categories, null, 2));
      return categories;
      
    } catch (error: any) {
      console.error('❌ Failed to fetch categories:', error);
      console.error('❌ Error details:', error.message);
      if (error.response) {
        console.error('❌ Response data:', error.response.data);
        console.error('❌ Response status:', error.response.status);
      }
      return [];
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