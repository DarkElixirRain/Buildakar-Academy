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
  rating: number;
  students: number;
  duration?: string;
  isSaved?: boolean;
  isTrending?: boolean;
  lastOpened?: string;
  price: number;
  originalPrice?: number;
  status?: string;
  isPublished?: boolean;
  instructorId?: string;
  categoryId?: string;
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

export interface Category {
  id: string;
  name: string;
  slug?: string;
  icon: string;
  color: string;
  image?: string;
  courseCount?: number;
  description?: string;
  isActive?: boolean;
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
  studentsCount?: number;
  coursesCount?: number;
  bio?: string;
  isFollowing?: boolean;
  // API response fields
  firstName?: string;
  lastName?: string;
  totalStudents?: number;
  totalCourses?: number;
  averageRating?: number;
  isVerified?: boolean;
  followerCount?: number;
  email?: string;
  title?: string;
  totalRevenue?: number;
  totalReviews?: number;
  isVerifiedInstructor?: boolean;
  createdAt?: string;
  socialLinks?: {
    github?: string;
    linkedin?: string;
    twitter?: string;
    website?: string;
    youtube?: string;
  };
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
  achievements: Achievement | null;
  topInstructors: Instructor[];
  userProgress: UserProgress | null;
  notifications: Notification | null;
  recentlyViewed: RecentlyViewedCourse[];
}

// API Response Types
export interface ApiResponse<T = any> {
  success: boolean;
  data: T;
  message?: string;
  error?: string;
  pagination?: {
    total: number;
    limit: number;
    offset: number;
    hasMore: boolean;
  };
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

export interface InstructorApiResponse {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  photo?: string;
  expertise?: string;
  title?: string;
  bio?: string;
  averageRating: number;
  totalStudents: number;
  totalCourses: number;
  totalRevenue?: number;
  totalReviews?: number;
  isVerifiedInstructor: boolean;
  isFollowing?: boolean;
  followerCount?: number;
  createdAt?: string;
  socialLinks?: {
    github?: string;
    linkedin?: string;
    twitter?: string;
    website?: string;
  };
}

export interface LearningPathApiResponse {
  id: string;
  title: string;
  description: string;
  courses: number;
  duration: string;
  image: string;
}

export interface LiveClassApiResponse {
  id: string;
  title: string;
  instructor: string;
  date: string;
  time: string;
  image: string;
  isLive?: boolean;
}

export interface AchievementApiResponse {
  streak: number;
  xp: number;
  badges: number;
  nextBadge?: string;
}

export interface UserProgressApiResponse {
  streak: number;
  enrolled: number;
  completed: number;
  hours: number;
  weeklyGoal: number;
  weeklyProgress: number;
}

export interface NotificationApiResponse {
  id: string;
  unread: number;
  items?: NotificationItem[];
}

export interface ContinueLearningApiResponse {
  id: string;
  title: string;
  instructor: string;
  thumbnail: string;
  progress: number;
  remainingTime: string;
}