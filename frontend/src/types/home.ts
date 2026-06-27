// types/home.ts
export interface UserProgress {
  streak: number;
  enrolled: number;
  completed: number;
  hours: number;
  weeklyGoal: number;
  weeklyProgress: number;
}

export interface BaseCourse {
  id: string;
  title: string;
  instructor: string;
  thumbnail: string;
}

export interface Course extends BaseCourse {
  progress?: number;
  remainingTime?: string;
  rating?: number;
  students?: number;
  duration?: string;
  isSaved?: boolean;
  isTrending?: boolean;
  lastOpened?: string;
}

export interface FeaturedCourse extends BaseCourse {
  image: string;
  rating: number;
  isBestseller: boolean;
}

export interface PopularCourse extends BaseCourse {
  rating: number;
  students: number;
  isTrending: boolean;
}

export interface RecommendedCourse extends BaseCourse {
  rating: number;
  students: number;
  duration: string;
  isSaved: boolean;
}

export interface ContinueLearningCourse extends BaseCourse {
  progress: number;
  remainingTime: string;
}

export interface RecentlyViewedCourse extends BaseCourse {
  lastOpened: string;
}

// ✅ Updated Category interface with all fields
export interface Category {
  id: string;
  name: string;
  slug?: string; // Added slug
  icon: string;
  color: string;
  image?: string; // Added image
  courseCount?: number; // Added courseCount
  description?: string; // Added description
  isActive?: boolean; // Added isActive
}

export interface LearningPath {
  id: string;
  title: string;
  description: string;
  courses: number;
  duration: string;
  image: string;
}

export interface LiveClass {
  id: string;
  title: string;
  instructor: string;
  date: string;
  time: string;
  image: string;
  isLive?: boolean;
}

export interface Achievement {
  streak: number;
  xp: number;
  badges: number;
  nextBadge?: string;
}

export interface Instructor {
  id: string;
  name: string;
  expertise: string;
  photo: string;
  rating: number;
  isFollowing?: boolean;
}

export interface Notification {
  id: string;
  unread: number;
  items?: NotificationItem[];
}

export interface NotificationItem {
  id: string;
  type: 'course' | 'achievement' | 'instructor' | 'system';
  title: string;
  message: string;
  timestamp: string;
  read: boolean;
  data?: any;
}

export interface HomeData {
  featuredCourses: FeaturedCourse[];
  recommendedCourses: RecommendedCourse[];
  popularCourses: PopularCourse[];
  categories: Category[];
  continueLearning: ContinueLearningCourse[];
  learningPaths: LearningPath[];
  liveClasses: LiveClass[];
  achievements: Achievement | null; // Made nullable
  topInstructors: Instructor[];
  userProgress: UserProgress | null; // Made nullable
  notifications: Notification | null; // Made nullable
  recentlyViewed: RecentlyViewedCourse[];
}

// ✅ API Response Types
export interface ApiResponse<T = any> {
  success: boolean;
  data: T;
  message?: string;
  error?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    hasMore: boolean;
  };
}

// ✅ Category API Response (matches your backend)
export interface CategoryApiResponse {
  id: string;
  name: string;
  slug: string;
  description?: string;
  icon?: string;
  color?: string;
  image?: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  createdById: string;
  _count?: {
    courses: number;
  };
  courseCount?: number;
}

// ✅ Course API Response
export interface CourseApiResponse {
  id: string;
  title: string;
  description?: string;
  thumbnail?: string;
  price: number;
  originalPrice?: number;
  level: string;
  language: string;
  duration?: string;
  totalHours?: number;
  rating: number;
  studentsCount: number;
  isPublished: boolean;
  isBestseller: boolean;
  isTrending: boolean;
  createdAt: string;
  updatedAt: string;
  instructorId: string;
  categoryId: string;
  instructor?: {
    id: string;
    firstName: string;
    lastName: string;
  };
  category?: CategoryApiResponse;
  _count?: {
    enrollments: number;
    lessons: number;
    reviews: number;
  };
}

// ✅ Instructor API Response
export interface InstructorApiResponse {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  photo?: string;
  expertise?: string;
  rating?: number;
  isFollowing?: boolean;
  _count?: {
    courses: number;
    students: number;
  };
}

// ✅ Learning Path API Response
export interface LearningPathApiResponse {
  id: string;
  title: string;
  description: string;
  courses: number;
  duration: string;
  image: string;
}

// ✅ Live Class API Response
export interface LiveClassApiResponse {
  id: string;
  title: string;
  instructor: string;
  date: string;
  time: string;
  image: string;
  isLive?: boolean;
}

// ✅ Achievement API Response
export interface AchievementApiResponse {
  streak: number;
  xp: number;
  badges: number;
  nextBadge?: string;
}

// ✅ User Progress API Response
export interface UserProgressApiResponse {
  streak: number;
  enrolled: number;
  completed: number;
  hours: number;
  weeklyGoal: number;
  weeklyProgress: number;
}

// ✅ Notification API Response
export interface NotificationApiResponse {
  id: string;
  unread: number;
  items?: NotificationItem[];
}

// ✅ Continue Learning API Response
export interface ContinueLearningApiResponse {
  id: string;
  title: string;
  instructor: string;
  thumbnail: string;
  progress: number;
  remainingTime: string;
}