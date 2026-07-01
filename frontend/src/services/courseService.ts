// services/courseService.ts
import api from '../lib/api';

export interface CourseData {
  id: string;
  title: string;
  subtitle?: string;
  description: string;
  categoryId: string;
  level: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED' | 'ALL_LEVELS';
  price?: number;
  language?: string;
  whatYouWillLearn?: string[];
  requirements?: string[];
  targetAudience?: string[];
  thumbnail?: string; // Made optional to match the main file
  status?: 'DRAFT' | 'UNDER_REVIEW' | 'PUBLISHED' | 'REJECTED';
  isPublished?: boolean;
  sections?: any[];
  instructor?: any;
  instructorId?: string;
  category?: any;
  enrollments?: any[];
  averageRating?: number;
  totalReviews?: number;
  totalStudents?: number;
  createdAt?: string;
  updatedAt?: string;
  // Additional fields from backend response
  rating?: number;
  studentsCount?: number;
  _count?: {
    enrollments?: number;
    reviews?: number;
    lessons?: number;
  };
}

export interface CourseFilterOptions {
  page?: number;
  limit?: number;
  search?: string;
  categoryId?: string;
  status?: string;
  level?: string;
  sortBy?: 'newest' | 'popular' | 'rating' | 'price-low' | 'price-high';
  minPrice?: number;
  maxPrice?: number;
  instructorId?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

class CourseService {
  private baseUrl = '/api/courses';

  // Create a new course
  async createCourse(data: Partial<CourseData>): Promise<CourseData> {
    try {
      const response = await api.post(this.baseUrl, data);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get all courses with filters
  async getCourses(filters: CourseFilterOptions = {}): Promise<PaginatedResponse<CourseData>> {
    try {
      const queryParams = new URLSearchParams();
      
      if (filters.page) queryParams.append('page', filters.page.toString());
      if (filters.limit) queryParams.append('limit', filters.limit.toString());
      if (filters.search) queryParams.append('search', filters.search);
      if (filters.categoryId) queryParams.append('categoryId', filters.categoryId);
      if (filters.status) queryParams.append('status', filters.status);
      if (filters.level) queryParams.append('level', filters.level);
      if (filters.sortBy) queryParams.append('sortBy', filters.sortBy);
      if (filters.minPrice) queryParams.append('minPrice', filters.minPrice.toString());
      if (filters.maxPrice) queryParams.append('maxPrice', filters.maxPrice.toString());
      if (filters.instructorId) queryParams.append('instructorId', filters.instructorId);

      const url = `${this.baseUrl}?${queryParams.toString()}`;
      const response = await api.get(url);
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get public courses (published)
  async getPublicCourses(filters: CourseFilterOptions = {}): Promise<PaginatedResponse<CourseData>> {
    try {
      const queryParams = new URLSearchParams();
      
      if (filters.page) queryParams.append('page', filters.page.toString());
      if (filters.limit) queryParams.append('limit', filters.limit.toString());
      if (filters.search) queryParams.append('search', filters.search);
      if (filters.categoryId) queryParams.append('categoryId', filters.categoryId);
      if (filters.level) queryParams.append('level', filters.level);
      if (filters.sortBy) queryParams.append('sortBy', filters.sortBy);
      if (filters.minPrice) queryParams.append('minPrice', filters.minPrice.toString());
      if (filters.maxPrice) queryParams.append('maxPrice', filters.maxPrice.toString());

      const url = `${this.baseUrl}/public?${queryParams.toString()}`;
      const response = await api.get(url);
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get single course by ID
  async getCourseById(id: string): Promise<CourseData> {
    try {
      const response = await api.get(`${this.baseUrl}/${id}`);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Update course
  async updateCourse(id: string, data: Partial<CourseData>): Promise<CourseData> {
    try {
      const response = await api.put(`${this.baseUrl}/${id}`, data);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Delete course
  async deleteCourse(id: string): Promise<{ message: string }> {
    try {
      const response = await api.delete(`${this.baseUrl}/${id}`);
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Update course status
  async updateCourseStatus(id: string, status: string): Promise<CourseData> {
    try {
      const response = await api.patch(`${this.baseUrl}/${id}/status`, { status });
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get instructor stats
  async getInstructorStats(instructorId?: string): Promise<any> {
    try {
      const url = instructorId 
        ? `${this.baseUrl}/stats/${instructorId}`
        : `${this.baseUrl}/stats`;
      const response = await api.get(url);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Duplicate course
  async duplicateCourse(id: string): Promise<CourseData> {
    try {
      const response = await api.post(`${this.baseUrl}/${id}/duplicate`);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Upload course thumbnail
  async uploadThumbnail(courseId: string, file: File | Blob): Promise<{ url: string }> {
    try {
      const formData = new FormData();
      formData.append('thumbnail', file);

      const response = await api.post(
        `${this.baseUrl}/${courseId}/thumbnail`,
        formData,
        {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        }
      );
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get course progress for student
  async getCourseProgress(courseId: string): Promise<any> {
    try {
      const response = await api.get(`${this.baseUrl}/${courseId}/progress`);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get course analytics (instructor only)
  async getCourseAnalytics(courseId: string): Promise<any> {
    try {
      const response = await api.get(`${this.baseUrl}/${courseId}/analytics`);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get enrolled students (instructor only)
  async getEnrolledStudents(courseId: string, filters: any = {}): Promise<any> {
    try {
      const queryParams = new URLSearchParams();
      if (filters.page) queryParams.append('page', filters.page.toString());
      if (filters.limit) queryParams.append('limit', filters.limit.toString());
      if (filters.search) queryParams.append('search', filters.search);
      if (filters.status) queryParams.append('status', filters.status);

      const url = `${this.baseUrl}/${courseId}/students?${queryParams.toString()}`;
      const response = await api.get(url);
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Toggle course publish status
  async togglePublish(id: string): Promise<CourseData> {
    try {
      const response = await api.patch(`${this.baseUrl}/${id}/publish`);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get recommended courses
  async getRecommendedCourses(limit: number = 10): Promise<CourseData[]> {
    try {
      const response = await api.get(`${this.baseUrl}/recommended`, {
        params: { limit }
      });
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get popular courses
  async getPopularCourses(limit: number = 10): Promise<CourseData[]> {
    try {
      const response = await api.get(`${this.baseUrl}/popular`, {
        params: { limit }
      });
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get featured courses
  async getFeaturedCourses(limit: number = 10): Promise<CourseData[]> {
    try {
      const response = await api.get(`${this.baseUrl}/featured`, {
        params: { limit }
      });
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Search courses
  async searchCourses(query: string, filters: CourseFilterOptions = {}): Promise<PaginatedResponse<CourseData>> {
    try {
      const queryParams = new URLSearchParams();
      queryParams.append('q', query);
      
      if (filters.page) queryParams.append('page', filters.page.toString());
      if (filters.limit) queryParams.append('limit', filters.limit.toString());
      if (filters.categoryId) queryParams.append('categoryId', filters.categoryId);
      if (filters.level) queryParams.append('level', filters.level);
      if (filters.sortBy) queryParams.append('sortBy', filters.sortBy);

      const url = `${this.baseUrl}/search?${queryParams.toString()}`;
      const response = await api.get(url);
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get courses by instructor
  async getCoursesByInstructor(instructorId: string, filters: CourseFilterOptions = {}): Promise<PaginatedResponse<CourseData>> {
    try {
      const queryParams = new URLSearchParams();
      if (filters.page) queryParams.append('page', filters.page.toString());
      if (filters.limit) queryParams.append('limit', filters.limit.toString());
      if (filters.status) queryParams.append('status', filters.status);
      if (filters.search) queryParams.append('search', filters.search);

      const url = `${this.baseUrl}/instructor/${instructorId}?${queryParams.toString()}`;
      const response = await api.get(url);
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get course reviews
  async getCourseReviews(courseId: string, page: number = 1, limit: number = 10): Promise<any> {
    try {
      const response = await api.get(`${this.baseUrl}/${courseId}/reviews`, {
        params: { page, limit }
      });
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Add course review
  async addReview(courseId: string, rating: number, comment: string): Promise<any> {
    try {
      const response = await api.post(`${this.baseUrl}/${courseId}/reviews`, {
        rating,
        comment
      });
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Update course review
  async updateReview(courseId: string, reviewId: string, rating: number, comment: string): Promise<any> {
    try {
      const response = await api.put(`${this.baseUrl}/${courseId}/reviews/${reviewId}`, {
        rating,
        comment
      });
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Delete course review
  async deleteReview(courseId: string, reviewId: string): Promise<{ message: string }> {
    try {
      const response = await api.delete(`${this.baseUrl}/${courseId}/reviews/${reviewId}`);
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Enroll in course
  async enrollInCourse(courseId: string): Promise<any> {
    try {
      const response = await api.post(`${this.baseUrl}/${courseId}/enroll`);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Unenroll from course
  async unenrollFromCourse(courseId: string): Promise<{ message: string }> {
    try {
      const response = await api.delete(`${this.baseUrl}/${courseId}/enroll`);
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Check enrollment status
  async checkEnrollment(courseId: string): Promise<boolean> {
    try {
      const response = await api.get(`${this.baseUrl}/${courseId}/enrollment`);
      return response.data.data.isEnrolled;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Mark lesson as complete
  async markLessonComplete(courseId: string, lessonId: string): Promise<any> {
    try {
      const response = await api.post(`${this.baseUrl}/${courseId}/lessons/${lessonId}/complete`);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get next lesson
  async getNextLesson(courseId: string, currentLessonId?: string): Promise<any> {
    try {
      const url = currentLessonId 
        ? `${this.baseUrl}/${courseId}/next-lesson/${currentLessonId}`
        : `${this.baseUrl}/${courseId}/first-lesson`;
      const response = await api.get(url);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  private handleError(error: any): Error {
    if (error.response) {
      // Server responded with error
      const message = error.response.data?.message || 'An error occurred';
      const status = error.response.status;
      
      if (status === 401) {
        // Unauthorized - redirect to login
        // You might want to trigger a logout here
        console.error('Unauthorized access');
      } else if (status === 403) {
        console.error('Forbidden access');
      } else if (status === 404) {
        console.error('Resource not found');
      } else if (status === 422) {
        // Validation error
        const errors = error.response.data?.errors;
        if (errors) {
          return new Error(JSON.stringify(errors));
        }
      }
      
      return new Error(message);
    } else if (error.request) {
      // Request was made but no response
      return new Error('Network error. Please check your connection.');
    } else {
      // Something else happened
      return new Error(error.message || 'An unexpected error occurred');
    }
  }
}

export const courseService = new CourseService();
export default courseService;