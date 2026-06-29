// services/homeService.ts
import {
  HomeData,
  Instructor,
  Category,
  RecommendedCourse,
  PopularCourse,
  ContinueLearningCourse,
  LearningPath,
  LiveClass,
  Achievement,
  UserProgress,
  Notification,
  RecentlyViewedCourse,
  ApiResponse,
  CategoryApiResponse,
  InstructorApiResponse,
  Course,
  CourseApiResponse,
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

// Mock data for the pieces that don't have a real backend endpoint yet.
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
  ],
  achievements: {
    streak: 15,
    xp: 2500,
    badges: 8,
    nextBadge: '10 Courses Completed',
  },
  topInstructors: [],
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
      instructor: '',
    },
  ],
};

// ---------------------------------------------------------------------------
// Response-shape helpers
// ---------------------------------------------------------------------------

// Type guard for the standard { success, message, data } envelope
function isApiResponse<T>(response: any): response is ApiResponse<T> {
  return (
    response &&
    typeof response === 'object' &&
    'success' in response &&
    typeof response.success === 'boolean' &&
    'data' in response
  );
}

// Unwraps a list endpoint whether it comes back wrapped ({success, data: [...]})
// or as a bare array.
function extractList<T>(response: any): T[] {
  if (isApiResponse<T[]>(response)) {
    return response.success && Array.isArray(response.data) ? response.data : [];
  }
  if (Array.isArray(response)) {
    return response;
  }
  // If response is an object but not an array, try to find an array property
  if (response && typeof response === 'object') {
    const possibleArrays = ['instructors', 'items', 'results', 'rows', 'list', 'courses', 'categories'];
    for (const key of possibleArrays) {
      if (response[key] && Array.isArray(response[key])) {
        console.log(`🔍 Found array in response.${key}`);
        return response[key];
      }
    }
  }
  return [];
}

// Same idea, for single-item endpoints (e.g. GET /instructors/:id)
function extractItem<T>(response: any): T | null {
  if (isApiResponse<T>(response)) {
    return response.success ? (response.data ?? null) : null;
  }
  return (response ?? null) as T | null;
}

// ---------------------------------------------------------------------------
// Mapping Functions
// ---------------------------------------------------------------------------

// Shape of the social links bag on an instructor. Adjust this to match
// whatever `socialLinks` actually looks like on your Instructor type in
// types/home.ts if it differs.
interface InstructorSocialLinks {
  youtube?: string;
  twitter?: string;
  linkedin?: string;
  website?: string;
}

// Pulls social links out of whatever shape the API sends them in.
// Handles a nested `socialLinks` object, flat top-level fields, or
// alternate naming (e.g. `x` instead of `twitter`, `web` instead of `website`).
function mapSocialLinks(apiInstructor: any): InstructorSocialLinks {
  const raw = apiInstructor.socialLinks || apiInstructor.social || {};

  return {
    youtube: raw.youtube || apiInstructor.youtube || undefined,
    twitter: raw.twitter || raw.x || apiInstructor.twitter || apiInstructor.x || undefined,
    linkedin: raw.linkedin || apiInstructor.linkedin || undefined,
    website: raw.website || raw.web || apiInstructor.website || apiInstructor.web || undefined,
  };
}

// Map instructor from API response to Instructor type
function mapInstructor(apiInstructor: any): Instructor {
  // Debug logging to see what we're getting
  if (apiInstructor && typeof apiInstructor === 'object') {
    console.log('🔍 Mapping instructor with keys:', Object.keys(apiInstructor));
  }

  // Try multiple possible property names for each field
  const id = apiInstructor.id || apiInstructor._id || apiInstructor.instructorId || '';
  
  // Handle name - could be 'name', 'fullName', or firstName + lastName
  let name = '';
  if (apiInstructor.name) {
    name = apiInstructor.name;
  } else if (apiInstructor.fullName) {
    name = apiInstructor.fullName;
  } else if (apiInstructor.firstName || apiInstructor.lastName) {
    name = `${apiInstructor.firstName || ''} ${apiInstructor.lastName || ''}`.trim();
  } else {
    name = 'Instructor';
  }

  // Handle photo/avatar
  let photo = apiInstructor.photo || 
              apiInstructor.avatar || 
              apiInstructor.profileImage || 
              apiInstructor.image || 
              apiInstructor.profilePhoto ||
              apiInstructor.picture ||
              '';
  
  if (!photo) {
    photo = `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&size=150&background=4F46E5&color=fff`;
  }

  // Handle expertise
  const expertise = apiInstructor.expertise || 
                    apiInstructor.specialization || 
                    apiInstructor.field || 
                    apiInstructor.category || 
                    apiInstructor.specialty ||
                    'Expert Instructor';

  // Handle rating
  const rating = typeof apiInstructor.rating === 'number' ? apiInstructor.rating :
                 typeof apiInstructor.averageRating === 'number' ? apiInstructor.averageRating :
                 typeof apiInstructor.avgRating === 'number' ? apiInstructor.avgRating :
                 0;

  // Handle student count
  const studentsCount = typeof apiInstructor.studentsCount === 'number' ? apiInstructor.studentsCount :
                        typeof apiInstructor.totalStudents === 'number' ? apiInstructor.totalStudents :
                        typeof apiInstructor.studentCount === 'number' ? apiInstructor.studentCount :
                        0;

  // Handle course count
  const coursesCount = typeof apiInstructor.coursesCount === 'number' ? apiInstructor.coursesCount :
                       typeof apiInstructor.totalCourses === 'number' ? apiInstructor.totalCourses :
                       typeof apiInstructor.courseCount === 'number' ? apiInstructor.courseCount :
                       0;

  // Handle follow status
  const isFollowing = apiInstructor.isFollowing === true || 
                      apiInstructor.following === true || 
                      apiInstructor.isFollowed === true ||
                      false;

  // Handle bio
  const bio = apiInstructor.bio || 
              apiInstructor.biography || 
              apiInstructor.about || 
              '';

  // Handle verification status
  const isVerified = apiInstructor.isVerifiedInstructor === true || 
                     apiInstructor.isVerified === true ||
                     apiInstructor.verified === true ||
                     false;

  // Handle follower count
  const followerCount = typeof apiInstructor.followerCount === 'number' ? apiInstructor.followerCount :
                        typeof apiInstructor.followers === 'number' ? apiInstructor.followers :
                        0;

  // Handle social links (required field on Instructor)
  const socialLinks = mapSocialLinks(apiInstructor);

  const mappedInstructor: Instructor = {
    id,
    name,
    expertise,
    photo,
    rating,
    studentsCount,
    coursesCount,
    bio,
    isFollowing,
    // Additional fields that might be used elsewhere
    firstName: apiInstructor.firstName || '',
    lastName: apiInstructor.lastName || '',
    totalStudents: studentsCount,
    totalCourses: coursesCount,
    averageRating: rating,
    isVerified,
    followerCount,
    socialLinks,
  };

  console.log('✅ Mapped instructor:', { id: mappedInstructor.id, name: mappedInstructor.name, expertise: mappedInstructor.expertise });
  
  return mappedInstructor;
}

// Map category from API response to Category type
function mapCategory(apiCategory: any): Category {
  return {
    id: apiCategory.id || '',
    name: apiCategory.name || 'Category',
    slug: apiCategory.slug || '',
    icon: apiCategory.icon || 'book-outline',
    color: apiCategory.color || '#2563EB',
    image: apiCategory.image ?? undefined,
    courseCount: apiCategory._count?.courses || apiCategory.courseCount || 0,
    description: apiCategory.description || '',
    isActive: apiCategory.isActive !== undefined ? apiCategory.isActive : true,
  };
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

export const homeService = {
  // ---------------- Categories — real backend (GET /api/categories) ----------------
  getCategories: async (forceRefresh: boolean = false): Promise<Category[]> => {
    try {
      if (!forceRefresh) {
        const cached = await cacheManager.get<Category[]>(CACHE_KEYS.CATEGORIES);
        if (cached && cached.length > 0) {
          console.log('📦 Using cached categories');
          return cached;
        }
      }

      console.log('🌐 Fetching categories from backend...');
      const response = await apiClient.get('/api/categories');
      console.log('📥 Categories response received');
      
      const categories = extractList<any>(response).map(mapCategory);
      console.log(`✅ Fetched ${categories.length} categories from backend`);
      
      await cacheManager.set(CACHE_KEYS.CATEGORIES, categories);
      return categories;
    } catch (error: any) {
      console.error('❌ Failed to fetch categories:', error.message);
      const cached = await cacheManager.get<Category[]>(CACHE_KEYS.CATEGORIES);
      return cached ?? [];
    }
  },

  // ---------------- Top instructors — real backend (GET /api/instructors/top) ----------------
  getTopInstructors: async (limit: number = 10, forceRefresh: boolean = false): Promise<Instructor[]> => {
    try {
      if (!forceRefresh) {
        const cached = await cacheManager.get<Instructor[]>(CACHE_KEYS.TOP_INSTRUCTORS);
        if (cached && cached.length > 0) {
          console.log('📦 Using cached top instructors');
          return cached;
        }
      }

      console.log(`🌐 Fetching top ${limit} instructors from backend...`);
      
      // Make the API call
      const response = await apiClient.get('/api/instructors', { limit });
      
      console.log('📥 Instructors response received');
      
      // Extract the data from the response
      const extractedData = extractList<any>(response);
      
      console.log(`📥 Extracted ${extractedData.length} instructors from response`);
      
      // If we have data, log the first item to see its structure
      if (extractedData.length > 0) {
        console.log('📥 First instructor raw data:', JSON.stringify(extractedData[0], null, 2));
        console.log('📥 First instructor keys:', Object.keys(extractedData[0]));
      }
      
      // Map each instructor
      const instructors = extractedData.map(mapInstructor);
      
      console.log(`✅ Fetched ${instructors.length} top instructors from backend`);
      
      // Cache the results
      if (instructors.length > 0) {
        await cacheManager.set(CACHE_KEYS.TOP_INSTRUCTORS, instructors);
      }
      
      return instructors;
    } catch (error: any) {
      console.error('❌ Failed to fetch top instructors:', error.message);
      
      // Try to return cached data on error
      const cached = await cacheManager.get<Instructor[]>(CACHE_KEYS.TOP_INSTRUCTORS);
      if (cached && cached.length > 0) {
        console.log('📦 Returning cached instructors on error');
        return cached;
      }
      
      // Return empty array if no cache
      return [];
    }
  },

  // ---------------- Aggregate home data ----------------
  getHomeData: async (forceRefresh: boolean = false): Promise<HomeData> => {
    if (!forceRefresh) {
      const cached = await cacheManager.get<HomeData>(CACHE_KEYS.HOME_DATA);
      if (cached) {
        console.log('📦 Using cached home data');
        return cached;
      }
    }

    console.log('🌐 Fetching home data...');
    
    const [categories, topInstructors] = await Promise.all([
      homeService.getCategories(forceRefresh),
      homeService.getTopInstructors(10, forceRefresh),
    ]);

    const data: HomeData = { 
      ...MOCK_DATA, 
      categories, 
      topInstructors 
    };

    await cacheManager.set(CACHE_KEYS.HOME_DATA, data);
    console.log(
      `💾 Home data cached with ${categories.length} categories and ${topInstructors.length} instructors`
    );
    return data;
  },

  // ---------------- Follow / unfollow ----------------
  followInstructor: async (instructorId: string): Promise<void> => {
    try {
      console.log(`📌 Following instructor ${instructorId}...`);
      await apiClient.post(`/api/instructors/${instructorId}/follow`);
      console.log('✅ Followed successfully');
      
      // Invalidate caches
      await cacheManager.remove(CACHE_KEYS.TOP_INSTRUCTORS);
      await cacheManager.remove(CACHE_KEYS.HOME_DATA);
    } catch (error: any) {
      console.error('❌ Failed to follow instructor:', error.message);
      throw error;
    }
  },

  unfollowInstructor: async (instructorId: string): Promise<void> => {
    try {
      console.log(`📌 Unfollowing instructor ${instructorId}...`);
      await apiClient.post(`/api/instructors/${instructorId}/follow`);
      console.log('✅ Unfollowed successfully');
      
      // Invalidate caches
      await cacheManager.remove(CACHE_KEYS.TOP_INSTRUCTORS);
      await cacheManager.remove(CACHE_KEYS.HOME_DATA);
    } catch (error: any) {
      console.error('❌ Failed to unfollow instructor:', error.message);
      throw error;
    }
  },

  // ---------------- Single instructor / instructor courses ----------------
  getInstructorById: async (instructorId: string): Promise<Instructor | null> => {
    try {
      console.log(`🔍 Fetching instructor ${instructorId}...`);
      const response = await apiClient.get(`/api/instructors/${instructorId}`);
      const item = extractItem<any>(response);
      return item ? mapInstructor(item) : null;
    } catch (error: any) {
      console.error('❌ Failed to fetch instructor:', error.message);
      return null;
    }
  },

  getInstructorCourses: async (instructorId: string): Promise<Course[]> => {
    try {
      console.log(`📚 Fetching courses for instructor ${instructorId}...`);
      const response = await apiClient.get('/api/courses', { 
        instructorId, 
        status: 'PUBLISHED' 
      });
      
      const courses = extractList<any>(response).map((course: any) => ({
        id: course.id || '',
        title: course.title || 'Untitled Course',
        instructor: course.instructor
          ? `${course.instructor.firstName || ''} ${course.instructor.lastName || ''}`.trim()
          : 'Instructor',
        thumbnail: course.thumbnail || '',
        rating: course.rating || 0,
        students: course.studentsCount || 0,
        duration: course.duration || '',
        price: course.price || 0,
        level: course.level || 'Beginner',
      }));
      
      console.log(`✅ Fetched ${courses.length} courses for instructor`);
      return courses;
    } catch (error: any) {
      console.error('❌ Failed to fetch instructor courses:', error.message);
      return [];
    }
  },

  // ---------------- Mock data endpoints (to be replaced with real API calls) ----------------
  getRecommendedCourses: async (page: number = 1, limit: number = 10): Promise<RecommendedCourse[]> => {
    try {
      // Simulate API delay
      await new Promise((resolve) => setTimeout(resolve, 500));

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
      // TODO: Implement actual API call
    } catch (error) {
      console.error('Failed to toggle save course:', error);
      throw error;
    }
  },

  markNotificationAsRead: async (notificationId: string): Promise<void> => {
    try {
      console.log(`Marked notification ${notificationId} as read`);
      // TODO: Implement actual API call
    } catch (error) {
      console.error('Failed to mark notification as read:', error);
      throw error;
    }
  },

  trackCourseView: async (courseId: string): Promise<void> => {
    try {
      console.log(`Tracked view for course ${courseId}`);
      // TODO: Implement actual API call
    } catch (error) {
      console.error('Failed to track course view:', error);
    }
  },

  updateCourseProgress: async (courseId: string, progress: number): Promise<void> => {
    try {
      console.log(`Updated progress for course ${courseId}: ${progress}%`);
      // TODO: Implement actual API call
    } catch (error) {
      console.error('Failed to update course progress:', error);
      throw error;
    }
  },
};