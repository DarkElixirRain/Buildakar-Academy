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
  Course,
  CourseApiResponse,
  InstructorApiResponse,
  CategoryApiResponse,
  ContinueLearningApiResponse,
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
  continueLearning: [],
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

function isApiResponse<T>(response: any): response is ApiResponse<T> {
  return (
    response &&
    typeof response === 'object' &&
    'success' in response &&
    typeof response.success === 'boolean' &&
    'data' in response
  );
}

function extractList<T>(response: any): T[] {
  if (isApiResponse<T[]>(response)) {
    return response.success && Array.isArray(response.data) ? response.data : [];
  }
  if (Array.isArray(response)) {
    return response;
  }
  if (response && typeof response === 'object') {
    const possibleArrays = ['instructors', 'items', 'results', 'rows', 'list', 'courses', 'categories', 'data'];
    for (const key of possibleArrays) {
      if (response[key] && Array.isArray(response[key])) {
        console.log(`🔍 Found array in response.${key}`);
        return response[key];
      }
    }
  }
  return [];
}

function extractItem<T>(response: any): T | null {
  if (isApiResponse<T>(response)) {
    return response.success ? (response.data ?? null) : null;
  }
  return (response ?? null) as T | null;
}

// ---------------------------------------------------------------------------
// Mapping Functions
// ---------------------------------------------------------------------------

interface InstructorSocialLinks {
  youtube?: string;
  twitter?: string;
  linkedin?: string;
  website?: string;
}

function mapSocialLinks(apiInstructor: any): InstructorSocialLinks {
  const raw = apiInstructor.socialLinks || apiInstructor.social || {};

  return {
    youtube: raw.youtube || apiInstructor.youtube || undefined,
    twitter: raw.twitter || raw.x || apiInstructor.twitter || apiInstructor.x || undefined,
    linkedin: raw.linkedin || apiInstructor.linkedin || undefined,
    website: raw.website || raw.web || apiInstructor.website || apiInstructor.web || undefined,
  };
}

function mapInstructor(apiInstructor: any): Instructor {
  if (apiInstructor && typeof apiInstructor === 'object') {
    console.log('🔍 Mapping instructor with keys:', Object.keys(apiInstructor));
  }

  const id = apiInstructor.id || apiInstructor._id || apiInstructor.instructorId || '';
  
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

  const expertise = apiInstructor.expertise || 
                    apiInstructor.specialization || 
                    apiInstructor.field || 
                    apiInstructor.category || 
                    apiInstructor.specialty ||
                    'Expert Instructor';

  const rating = typeof apiInstructor.rating === 'number' ? apiInstructor.rating :
                 typeof apiInstructor.averageRating === 'number' ? apiInstructor.averageRating :
                 typeof apiInstructor.avgRating === 'number' ? apiInstructor.avgRating :
                 0;

  const studentsCount = typeof apiInstructor.studentsCount === 'number' ? apiInstructor.studentsCount :
                        typeof apiInstructor.totalStudents === 'number' ? apiInstructor.totalStudents :
                        typeof apiInstructor.studentCount === 'number' ? apiInstructor.studentCount :
                        0;

  const coursesCount = typeof apiInstructor.coursesCount === 'number' ? apiInstructor.coursesCount :
                       typeof apiInstructor.totalCourses === 'number' ? apiInstructor.totalCourses :
                       typeof apiInstructor.courseCount === 'number' ? apiInstructor.courseCount :
                       0;

  const isFollowing = apiInstructor.isFollowing === true || 
                      apiInstructor.following === true || 
                      apiInstructor.isFollowed === true ||
                      false;

  const bio = apiInstructor.bio || 
              apiInstructor.biography || 
              apiInstructor.about || 
              '';

  const isVerified = apiInstructor.isVerifiedInstructor === true || 
                     apiInstructor.isVerified === true ||
                     apiInstructor.verified === true ||
                     false;

  const followerCount = typeof apiInstructor.followerCount === 'number' ? apiInstructor.followerCount :
                        typeof apiInstructor.followers === 'number' ? apiInstructor.followers :
                        0;

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

// ✅ Calculate remaining time based on progress
function calculateRemainingTime(progress: number): string {
  if (progress >= 100) return 'Completed ✅';
  if (progress === 0) return 'Not started';
  
  // Estimate remaining time (assuming 40 hours total course)
  const totalHours = 40;
  const remainingPercent = (100 - progress) / 100;
  const remainingHours = Math.round(totalHours * remainingPercent);
  
  if (remainingHours > 24) {
    return `${Math.round(remainingHours / 24)} days left`;
  } else if (remainingHours > 1) {
    return `${remainingHours}h left`;
  } else if (remainingHours === 1) {
    return '1h left';
  } else {
    return '< 1h left';
  }
}

// ✅ Map continue learning from API response
function mapContinueLearning(apiItem: any): ContinueLearningCourse {
  // The API returns an object with course data and enrollment data
  const course = apiItem.course || apiItem;
  const instructor = course.instructor || {};
  
  // Calculate remaining time based on progress
  const progress = apiItem.progress || 0;
  const remainingTime = calculateRemainingTime(progress);
  
  // Get the course ID from the enrollment or course object
  const courseId = course.id || apiItem.courseId || apiItem.id || '';
  
  // Get instructor name
  const instructorName = instructor.name || 
                         `${instructor.firstName || ''} ${instructor.lastName || ''}`.trim() || 
                         'Instructor';
  
  return {
    id: apiItem.id || courseId, // Enrollment ID if available, otherwise course ID
    courseId: courseId, // Store the actual course ID separately
    title: course.title || 'Untitled Course',
    instructor: instructorName,
    thumbnail: course.thumbnail || 'https://via.placeholder.com/400x300',
    progress: progress,
    remainingTime: remainingTime,
    // Additional fields
    isCompleted: apiItem.isCompleted || false,
    enrolledAt: apiItem.enrolledAt || null,
    completedAt: apiItem.completedAt || null,
    lastAccessed: apiItem.updatedAt || null,
    level: course.level || 'BEGINNER',
    category: course.category?.name || '',
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
      const response = await apiClient.get('/api/instructors', { limit });
      console.log('📥 Instructors response received');
      
      const extractedData = extractList<any>(response);
      console.log(`📥 Extracted ${extractedData.length} instructors from response`);
      
      if (extractedData.length > 0) {
        console.log('📥 First instructor keys:', Object.keys(extractedData[0]));
      }
      
      const instructors = extractedData.map(mapInstructor);
      console.log(`✅ Fetched ${instructors.length} top instructors from backend`);
      
      if (instructors.length > 0) {
        await cacheManager.set(CACHE_KEYS.TOP_INSTRUCTORS, instructors);
      }
      
      return instructors;
    } catch (error: any) {
      console.error('❌ Failed to fetch top instructors:', error.message);
      const cached = await cacheManager.get<Instructor[]>(CACHE_KEYS.TOP_INSTRUCTORS);
      if (cached && cached.length > 0) {
        console.log('📦 Returning cached instructors on error');
        return cached;
      }
      return [];
    }
  },

  // ---------------- ✅ Continue Learning — real backend (GET /api/enroll/continue-learning) ----------------
  getContinueLearning: async (limit: number = 10, forceRefresh: boolean = false): Promise<ContinueLearningCourse[]> => {
    try {
      // Check cache first
      if (!forceRefresh) {
        const cached = await cacheManager.get<ContinueLearningCourse[]>(CACHE_KEYS.CONTINUE_LEARNING);
        if (cached && cached.length > 0) {
          console.log('📦 Using cached continue learning');
          return cached;
        }
      }

      console.log(`🌐 Fetching continue learning from backend (limit: ${limit})...`);
      
      // Make the API call to the real endpoint
      const response = await apiClient.get(`/api/enroll/continue-learning?limit=${limit}`);
      
      console.log('📥 Continue learning response received');
      
      // Extract the data from the response
      const extractedData = extractList<any>(response);
      
      console.log(`📥 Extracted ${extractedData.length} continue learning items from response`);
      
      // Log the first item to debug
      if (extractedData.length > 0) {
        console.log('📥 First item keys:', Object.keys(extractedData[0]));
        console.log('📥 First item sample:', JSON.stringify(extractedData[0], null, 2));
      }
      
      // Map each item to ContinueLearningCourse
      const continueLearning = extractedData.map(mapContinueLearning);
      
      console.log(`✅ Fetched ${continueLearning.length} continue learning courses from backend`);
      
      // Cache the results
      if (continueLearning.length > 0) {
        await cacheManager.set(CACHE_KEYS.CONTINUE_LEARNING, continueLearning);
      }
      
      return continueLearning;
    } catch (error: any) {
      console.error('❌ Failed to fetch continue learning:', error.message);
      
      // Try to return cached data on error
      const cached = await cacheManager.get<ContinueLearningCourse[]>(CACHE_KEYS.CONTINUE_LEARNING);
      if (cached && cached.length > 0) {
        console.log('📦 Returning cached continue learning on error');
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
    
    const [categories, topInstructors, continueLearning] = await Promise.all([
      homeService.getCategories(forceRefresh),
      homeService.getTopInstructors(10, forceRefresh),
      homeService.getContinueLearning(10, forceRefresh),
    ]);

    const data: HomeData = { 
      ...MOCK_DATA, 
      categories, 
      topInstructors,
      continueLearning,
    };

    await cacheManager.set(CACHE_KEYS.HOME_DATA, data);
    console.log(
      `💾 Home data cached with ${categories.length} categories, ` +
      `${topInstructors.length} instructors, and ${continueLearning.length} continue learning courses`
    );
    return data;
  },

  // ---------------- Follow / unfollow ----------------
  followInstructor: async (instructorId: string): Promise<void> => {
    try {
      console.log(`📌 Following instructor ${instructorId}...`);
      await apiClient.post(`/api/instructors/${instructorId}/follow`);
      console.log('✅ Followed successfully');
      
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
        isPublished: course.isPublished || false,
        instructorId: course.instructorId || '',
        categoryId: course.categoryId || '',
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