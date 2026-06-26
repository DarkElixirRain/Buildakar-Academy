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

export interface Category {
  id: string;
  name: string;
  icon: string;
  color: string;
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
  achievements: Achievement;
  topInstructors: Instructor[];
  userProgress: UserProgress;
  notifications: Notification;
  recentlyViewed: RecentlyViewedCourse[];
}

export interface ApiResponse<T> {
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