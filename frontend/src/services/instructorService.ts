// services/instructorService.ts
import api from '@/lib/api';
import { 
  CreateCourseInput, 
  UpdateCourseInput, 
  CreateSectionInput, 
  UpdateSectionInput,
  CreateLessonInput,
  UpdateLessonInput,
  ReorderSectionsInput,
  ReorderLessonsInput,
  VideoUploadInput,
} from '@/types/instructor';

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

// ============================================
// COURSE APIs
// ============================================

export const instructorApi = {
  // Get instructor's courses
  getCourses: async (params?: {
    page?: number;
    limit?: number;
    status?: string;
    sortBy?: string;
    search?: string;
  }): Promise<PaginatedResponse<Course>> => {
    const response = await api.get('/api/courses', { params });
    return response.data;
  },

  // Get public courses (for browsing)
  getPublicCourses: async (params?: {
    page?: number;
    limit?: number;
    categoryId?: string;
    search?: string;
    sortBy?: string;
  }): Promise<PaginatedResponse<Course>> => {
    const response = await api.get('/api/courses/public', { params });
    return response.data;
  },

  // Get single course by ID
  getCourseById: async (id: string): Promise<Course> => {
    const response = await api.get(`/api/courses/${id}`);
    return response.data.data;
  },

  // Create new course
  createCourse: async (data: CreateCourseInput): Promise<Course> => {
    const response = await api.post('/api/courses', data);
    return response.data.data;
  },

  // Update course
  updateCourse: async (id: string, data: UpdateCourseInput): Promise<Course> => {
    const response = await api.patch(`/api/courses/${id}`, data);
    return response.data.data;
  },

  // Delete course
  deleteCourse: async (id: string): Promise<void> => {
    await api.delete(`/api/courses/${id}`);
  },

  // Update course status
  updateCourseStatus: async (id: string, status: 'DRAFT' | 'UNDER_REVIEW' | 'PUBLISHED'): Promise<Course> => {
    const response = await api.patch(`/api/courses/${id}/status`, { status });
    return response.data.data;
  },

  // Duplicate course
  duplicateCourse: async (id: string): Promise<Course> => {
    const response = await api.post(`/api/courses/${id}/duplicate`);
    return response.data.data;
  },

  // Get instructor stats
  getStats: async (): Promise<InstructorStats> => {
    const response = await api.get('/api/courses/stats');
    return response.data.data;
  },

  // ============================================
  // SECTION APIs
  // ============================================

  // Get sections for a course
  getSections: async (courseId: string): Promise<Section[]> => {
    const response = await api.get(`/api/courses/${courseId}/sections`);
    return response.data.data;
  },

  // Create section
  createSection: async (courseId: string, data: CreateSectionInput): Promise<Section> => {
    const response = await api.post(`/api/courses/${courseId}/sections`, data);
    return response.data.data;
  },

  // Get section by ID
  getSectionById: async (id: string): Promise<Section> => {
    const response = await api.get(`/api/sections/${id}`);
    return response.data.data;
  },

  // Update section
  updateSection: async (id: string, data: UpdateSectionInput): Promise<Section> => {
    const response = await api.patch(`/api/sections/${id}`, data);
    return response.data.data;
  },

  // Delete section
  deleteSection: async (id: string): Promise<void> => {
    await api.delete(`/api/sections/${id}`);
  },

  // Reorder sections
  reorderSections: async (courseId: string, sections: ReorderSectionsInput['sections']): Promise<Section[]> => {
    const response = await api.post(`/api/courses/${courseId}/sections/reorder`, { sections });
    return response.data.data;
  },

  // Move section
  moveSection: async (id: string, order: number): Promise<Section[]> => {
    const response = await api.post(`/api/sections/${id}/move`, { order });
    return response.data.data;
  },

  // ============================================
  // LESSON APIs
  // ============================================

  // Get lessons for a section
  getLessonsBySection: async (sectionId: string): Promise<Lesson[]> => {
    const response = await api.get(`/api/sections/${sectionId}/lessons`);
    return response.data.data;
  },

  // Get all lessons for a course
  getLessonsByCourse: async (courseId: string): Promise<Lesson[]> => {
    const response = await api.get(`/api/courses/${courseId}/lessons`);
    return response.data.data;
  },

  // Create lesson
  createLesson: async (sectionId: string, data: CreateLessonInput): Promise<Lesson> => {
    const response = await api.post(`/api/sections/${sectionId}/lessons`, data);
    return response.data.data;
  },

  // Get lesson by ID
  getLessonById: async (id: string): Promise<Lesson> => {
    const response = await api.get(`/api/lessons/${id}`);
    return response.data.data;
  },

  // Update lesson
  updateLesson: async (id: string, data: UpdateLessonInput): Promise<Lesson> => {
    const response = await api.patch(`/api/lessons/${id}`, data);
    return response.data.data;
  },

  // Delete lesson
  deleteLesson: async (id: string): Promise<void> => {
    await api.delete(`/api/lessons/${id}`);
  },

  // Reorder lessons
  reorderLessons: async (sectionId: string, lessons: ReorderLessonsInput['lessons']): Promise<Lesson[]> => {
    const response = await api.post(`/api/sections/${sectionId}/lessons/reorder`, { lessons });
    return response.data.data;
  },

  // Upload video for lesson
  uploadVideo: async (lessonId: string, file: FormData): Promise<VideoUploadResult> => {
    const response = await api.post(`/api/lessons/${lessonId}/upload-video`, file, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data.data;
  },

  // Delete video from lesson
  deleteVideo: async (lessonId: string): Promise<void> => {
    await api.delete(`/api/lessons/${lessonId}/video`);
  },

  // Get video stream URL
  getVideoStreamUrl: async (lessonId: string, expiresIn?: number): Promise<VideoStreamUrl> => {
    const response = await api.get(`/api/lessons/${lessonId}/stream-url`, { 
      params: { expiresIn } 
    });
    return response.data.data;
  },
};

export default instructorApi;