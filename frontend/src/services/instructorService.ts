// services/instructorService.ts
import api from '@/lib/api';
import {
  Course,
  Section,
  Lesson,
  InstructorStats,
  CourseAnalytics,
  CreateCourseInput,
  UpdateCourseInput,
  CreateSectionInput,
  UpdateSectionInput,
  CreateLessonInput,
  UpdateLessonInput,
  ReorderSectionsInput,
  ReorderLessonsInput,
  PaginatedResponse,
  VideoUploadResult,
  VideoStreamUrl,
} from '@/types/instructor';

export interface CourseFilterOptions {
  page?: number;
  limit?: number;
  search?: string;
  status?: string;
  sortBy?: 'newest' | 'oldest' | 'title' | 'updatedAt';
}

export interface Instructor {
  name: any;
  avatar: string | undefined;
  averageRating: number;
  studentsCount: number;
  coursesCount: number;
  courses: never[];
  reviews: never[];
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  photo?: string;
  bio?: string;
  expertise?: string;
  rating: number;
  totalStudents: number;
  totalCourses: number;
  followerCount: number;
  isFollowing: boolean;
  isVerified: boolean;
  socialLinks?: {
    youtube?: string;
    twitter?: string;
    linkedin?: string;
    website?: string;
  };
  location?: string;
  languages?: string[];
  joinedDate?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface InstructorResponse {
  success: boolean;
  message: string;
  data: Instructor;
}

export interface InstructorsResponse {
  success: boolean;
  message: string;
  data: Instructor[];
  pagination: {
    total: number;
    limit: number;
    offset: number;
    hasMore: boolean;
  };
}

class InstructorService {
  // ============================================
  // INSTRUCTOR PROFILE & LISTING
  // ============================================

  /**
   * Get instructor by ID
   */
  async getInstructorById(id: string): Promise<Instructor> {
    try {
      const response = await api.get(`/api/instructors/${id}`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to get instructor by ID:', error);
      throw error;
    }
  }

  /**
   * Get all instructors with pagination and filters
   */
  async getInstructors(
    limit: number = 20,
    offset: number = 0,
    search?: string
  ): Promise<InstructorsResponse> {
    try {
      let url = `/api/instructors?limit=${limit}&offset=${offset}`;
      if (search) {
        url += `&search=${encodeURIComponent(search)}`;
      }
      const response = await api.get(url);
      return response.data;
    } catch (error) {
      console.error('❌ Failed to get instructors:', error);
      throw error;
    }
  }

  /**
   * Get top instructors for homepage
   */
  async getTopInstructors(limit: number = 10): Promise<Instructor[]> {
    try {
      const response = await api.get(`/api/instructors/top?limit=${limit}`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to get top instructors:', error);
      throw error;
    }
  }

  /**
   * Search instructors by query
   */
  async searchInstructors(query: string, limit: number = 10): Promise<Instructor[]> {
    try {
      const response = await api.get(`/api/instructors/search?q=${encodeURIComponent(query)}&limit=${limit}`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to search instructors:', error);
      throw error;
    }
  }

  /**
   * Follow an instructor
   */
  async followInstructor(instructorId: string): Promise<{ isFollowing: boolean }> {
    try {
      const response = await api.post(`/api/instructors/${instructorId}/follow`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to follow instructor:', error);
      throw error;
    }
  }

  /**
   * Unfollow an instructor
   */
  async unfollowInstructor(instructorId: string): Promise<{ isFollowing: boolean }> {
    try {
      const response = await api.delete(`/api/instructors/${instructorId}/follow`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to unfollow instructor:', error);
      throw error;
    }
  }

  /**
   * Get instructor's followers
   */
  async getFollowers(instructorId: string, limit: number = 20, offset: number = 0): Promise<any> {
    try {
      const response = await api.get(
        `/api/instructors/${instructorId}/followers?limit=${limit}&offset=${offset}`
      );
      return response.data;
    } catch (error) {
      console.error('❌ Failed to get followers:', error);
      throw error;
    }
  }

  /**
   * Update instructor profile (instructor only)
   */
  async updateProfile(data: {
    firstName?: string;
    lastName?: string;
    bio?: string;
    expertise?: string;
    location?: string;
    languages?: string[];
    socialLinks?: {
      youtube?: string;
      twitter?: string;
      linkedin?: string;
      website?: string;
    };
  }): Promise<Instructor> {
    try {
      const response = await api.put('/api/instructors/profile', data);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to update profile:', error);
      throw error;
    }
  }

  // ============================================
  // INSTRUCTOR DASHBOARD STATS
  // ============================================

  /**
   * Get instructor dashboard stats (instructor only)
   */
  async getStats(): Promise<InstructorStats> {
    try {
      const response = await api.get('/api/instructors/stats/dashboard');
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to get instructor stats:', error);
      throw error;
    }
  }

  /**
   * Get instructor course analytics (instructor only)
   */
  async getCourseAnalytics(courseId?: string): Promise<CourseAnalytics> {
    try {
      let url = '/api/instructors/analytics/courses';
      if (courseId) {
        url += `?courseId=${courseId}`;
      }
      const response = await api.get(url);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to get course analytics:', error);
      throw error;
    }
  }

  // ============================================
  // COURSES
  // ============================================

  /**
   * Get all courses for the authenticated instructor
   */
  async getCourses(filters: CourseFilterOptions = {}): Promise<PaginatedResponse<Course>> {
    try {
      const queryParams = new URLSearchParams();
      if (filters.page) queryParams.append('page', filters.page.toString());
      if (filters.limit) queryParams.append('limit', filters.limit.toString());
      if (filters.search) queryParams.append('search', filters.search);
      if (filters.status) queryParams.append('status', filters.status);
      if (filters.sortBy) queryParams.append('sortBy', filters.sortBy);

      const response = await api.get(`/api/courses?${queryParams.toString()}`);
      return response.data;
    } catch (error) {
      console.error('❌ Failed to get courses:', error);
      throw error;
    }
  }

  /**
   * Get public courses (no authentication required)
   */
  async getPublicCourses(filters: CourseFilterOptions = {}): Promise<PaginatedResponse<Course>> {
    try {
      const queryParams = new URLSearchParams();
      if (filters.page) queryParams.append('page', filters.page.toString());
      if (filters.limit) queryParams.append('limit', filters.limit.toString());
      if (filters.search) queryParams.append('search', filters.search);
      if (filters.sortBy) queryParams.append('sortBy', filters.sortBy);

      const response = await api.get(`/api/courses/public?${queryParams.toString()}`);
      return response.data;
    } catch (error) {
      console.error('❌ Failed to get public courses:', error);
      throw error;
    }
  }

  /**
   * Get course by ID
   */
  async getCourseById(id: string): Promise<Course> {
    try {
      const response = await api.get(`/api/courses/${id}`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to get course by ID:', error);
      throw error;
    }
  }

  /**
   * Create a new course (instructor only)
   */
  async createCourse(data: CreateCourseInput): Promise<Course> {
    try {
      const response = await api.post('/api/courses', data);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to create course:', error);
      throw error;
    }
  }

  /**
   * Update a course (instructor only)
   */
  async updateCourse(id: string, data: UpdateCourseInput): Promise<Course> {
    try {
      const response = await api.patch(`/api/courses/${id}`, data);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to update course:', error);
      throw error;
    }
  }

  /**
   * Delete a course (instructor only)
   */
  async deleteCourse(id: string): Promise<void> {
    try {
      await api.delete(`/api/courses/${id}`);
    } catch (error) {
      console.error('❌ Failed to delete course:', error);
      throw error;
    }
  }

  /**
   * Update course status (instructor only)
   */
  async updateCourseStatus(id: string, status: 'DRAFT' | 'UNDER_REVIEW' | 'PUBLISHED'): Promise<Course> {
    try {
      const response = await api.patch(`/api/courses/${id}/status`, { status });
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to update course status:', error);
      throw error;
    }
  }

  /**
   * Duplicate a course (instructor only)
   */
  async duplicateCourse(id: string): Promise<Course> {
    try {
      const response = await api.post(`/api/courses/${id}/duplicate`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to duplicate course:', error);
      throw error;
    }
  }

  // ============================================
  // SECTIONS
  // ============================================

  /**
   * Get all sections for a course
   */
  async getSections(courseId: string): Promise<Section[]> {
    try {
      const response = await api.get(`/api/courses/${courseId}/sections`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to get sections:', error);
      throw error;
    }
  }

  /**
   * Get section by ID
   */
  async getSectionById(id: string): Promise<Section> {
    try {
      const response = await api.get(`/api/sections/${id}`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to get section by ID:', error);
      throw error;
    }
  }

  /**
   * Create a new section (instructor only)
   */
  async createSection(courseId: string, data: CreateSectionInput): Promise<Section> {
    try {
      const response = await api.post(`/api/courses/${courseId}/sections`, data);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to create section:', error);
      throw error;
    }
  }

  /**
   * Update a section (instructor only)
   */
  async updateSection(id: string, data: UpdateSectionInput): Promise<Section> {
    try {
      const response = await api.patch(`/api/sections/${id}`, data);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to update section:', error);
      throw error;
    }
  }

  /**
   * Delete a section (instructor only)
   */
  async deleteSection(id: string): Promise<void> {
    try {
      await api.delete(`/api/sections/${id}`);
    } catch (error) {
      console.error('❌ Failed to delete section:', error);
      throw error;
    }
  }

  /**
   * Reorder sections (instructor only)
   */
  async reorderSections(courseId: string, sections: ReorderSectionsInput['sections']): Promise<Section[]> {
    try {
      const response = await api.post(`/api/courses/${courseId}/sections/reorder`, { sections });
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to reorder sections:', error);
      throw error;
    }
  }

  /**
   * Move a section to a specific order (instructor only)
   */
  async moveSection(id: string, order: number): Promise<Section[]> {
    try {
      const response = await api.post(`/api/sections/${id}/move`, { order });
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to move section:', error);
      throw error;
    }
  }

  // ============================================
  // LESSONS
  // ============================================

  /**
   * Get all lessons for a section
   */
  async getLessonsBySection(sectionId: string): Promise<Lesson[]> {
    try {
      const response = await api.get(`/api/sections/${sectionId}/lessons`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to get lessons by section:', error);
      throw error;
    }
  }

  /**
   * Get all lessons for a course
   */
  async getLessonsByCourse(courseId: string): Promise<Lesson[]> {
    try {
      const response = await api.get(`/api/courses/${courseId}/lessons`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to get lessons by course:', error);
      throw error;
    }
  }

  /**
   * Get lesson by ID
   */
  async getLessonById(id: string): Promise<Lesson> {
    try {
      const response = await api.get(`/api/lessons/${id}`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to get lesson by ID:', error);
      throw error;
    }
  }

  /**
   * Create a new lesson (instructor only)
   */
  async createLesson(sectionId: string, data: CreateLessonInput): Promise<Lesson> {
    try {
      const response = await api.post(`/api/sections/${sectionId}/lessons`, data);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to create lesson:', error);
      throw error;
    }
  }

  /**
   * Update a lesson (instructor only)
   */
  async updateLesson(id: string, data: UpdateLessonInput): Promise<Lesson> {
    try {
      const response = await api.patch(`/api/lessons/${id}`, data);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to update lesson:', error);
      throw error;
    }
  }

  /**
   * Delete a lesson (instructor only)
   */
  async deleteLesson(id: string): Promise<void> {
    try {
      await api.delete(`/api/lessons/${id}`);
    } catch (error) {
      console.error('❌ Failed to delete lesson:', error);
      throw error;
    }
  }

  /**
   * Reorder lessons in a section (instructor only)
   */
  async reorderLessons(sectionId: string, lessons: ReorderLessonsInput['lessons']): Promise<Lesson[]> {
    try {
      const response = await api.post(`/api/sections/${sectionId}/lessons/reorder`, { lessons });
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to reorder lessons:', error);
      throw error;
    }
  }

  // ============================================
  // VIDEO UPLOAD
  // ============================================

  /**
   * Upload a video for a lesson (instructor only)
   */
  async uploadVideo(lessonId: string, formData: FormData): Promise<VideoUploadResult> {
    try {
      const response = await api.post(`/api/lessons/${lessonId}/upload-video`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to upload video:', error);
      throw error;
    }
  }

  /**
   * Delete a video from a lesson (instructor only)
   */
  async deleteVideo(lessonId: string): Promise<void> {
    try {
      await api.delete(`/api/lessons/${lessonId}/video`);
    } catch (error) {
      console.error('❌ Failed to delete video:', error);
      throw error;
    }
  }

  /**
   * Get video stream URL for a lesson
   */
  async getVideoStreamUrl(lessonId: string): Promise<VideoStreamUrl> {
    try {
      const response = await api.get(`/api/lessons/${lessonId}/stream-url`);
      return response.data.data;
    } catch (error) {
      console.error('❌ Failed to get video stream URL:', error);
      throw error;
    }
  }
}

// Export a singleton instance
export const instructorApi = new InstructorService();
export default instructorApi;