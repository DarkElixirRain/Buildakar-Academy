// types/instructor.ts
export interface Instructor {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: 'STUDENT' | 'INSTRUCTOR' | 'ADMIN';
  title?: string;
  expertise?: string;
  bio?: string;
  photo?: string;
  socialLinks?: {
    website?: string;
    linkedin?: string;
    twitter?: string;
    youtube?: string;
    github?: string;
  };
  isVerifiedInstructor: boolean;
  averageRating: number;
  totalCourses: number;
  totalStudents: number;
  totalReviews: number;
  totalRevenue: number;
  createdAt: string;
  updatedAt: string;
}

export interface InstructorProfile extends Instructor {
  stripeAccountId?: string;
  payoutMethod?: string;
}

export interface CreateCourseInput {
  title: string;
  description?: string;
  thumbnail?: string;
  price?: number;
  originalPrice?: number;
  level?: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
  language?: string;
  duration?: string;
  totalHours?: number;
  categoryId: string;
}

export interface UpdateCourseInput extends Partial<CreateCourseInput> {
  status?: 'DRAFT' | 'UNDER_REVIEW' | 'PUBLISHED';
  isBestseller?: boolean;
  isTrending?: boolean;
}

export interface CreateSectionInput {
  title: string;
  description?: string;
  order?: number;
}

export interface UpdateSectionInput extends Partial<CreateSectionInput> {}

export interface CreateLessonInput {
  title: string;
  description?: string;
  videoUrl?: string;
  duration?: string;
  isPreview?: boolean;
  isFree?: boolean;
  order?: number;
}

export interface UpdateLessonInput extends Partial<CreateLessonInput> {}

export interface ReorderSectionsInput {
  sections: Array<{
    id: string;
    order: number;
  }>;
}

export interface ReorderLessonsInput {
  lessons: Array<{
    id: string;
    order: number;
  }>;
}

export interface VideoUploadInput {
  fileName: string;
  mimeType: string;
  fileSize: number;
}

export interface Course {
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
  status: 'DRAFT' | 'UNDER_REVIEW' | 'PUBLISHED';
  createdAt: string;
  updatedAt: string;
  instructorId: string;
  categoryId: string;
  category?: { id: string; name: string; slug: string };
  instructor?: { id: string; firstName: string; lastName: string; email: string };
  sections?: Section[];
  _count?: { enrollments: number; lessons: number; reviews: number };
}

export interface Section {
  id: string;
  title: string;
  description?: string;
  order: number;
  courseId: string;
  lessons?: Lesson[];
  _count?: { lessons: number };
  createdAt: string;
  updatedAt: string;
}

export interface Lesson {
  id: string;
  title: string;
  description?: string;
  videoUrl?: string;
  duration?: string;
  order: number;
  isPreview: boolean;
  isFree: boolean;
  sectionId: string;
  courseId: string;
  createdAt: string;
  updatedAt: string;
}

export interface InstructorStats {
  totalCourses: number;
  publishedCourses: number;
  draftCourses: number;
  underReviewCourses: number;
  totalStudents: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasMore: boolean;
  };
}

export interface VideoUploadResult {
  videoUrl: string;
  fileId: string;
  fileName: string;
  mimeType: string;
  size: number;
}

export interface VideoStreamUrl {
  url: string;
  expiresIn: number;
}

// Status badge colors
export const courseStatusColors: Record<string, { bg: string; text: string; dot: string }> = {
  DRAFT: { bg: '#FEF3C7', text: '#92400E', dot: '#F59E0B' },
  UNDER_REVIEW: { bg: '#DBEAFE', text: '#1E40AF', dot: '#3B82F6' },
  PUBLISHED: { bg: '#D1FAE5', text: '#065F46', dot: '#10B981' },
};

// Level colors
export const courseLevelColors: Record<string, { bg: string; text: string }> = {
  BEGINNER: { bg: '#D1FAE5', text: '#065F46' },
  INTERMEDIATE: { bg: '#DBEAFE', text: '#1E40AF' },
  ADVANCED: { bg: '#FCE7F3', text: '#9D174D' },
};