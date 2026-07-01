// services/instructorService.ts
import api from '@/lib/api';
import {
  Course,
  Section,
  Lesson,
  InstructorStats,
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

class InstructorService {
  // ============================================
  // COURSES
  // ============================================

  async getCourses(filters: CourseFilterOptions = {}): Promise<PaginatedResponse<Course>> {
    const queryParams = new URLSearchParams();
    if (filters.page) queryParams.append('page', filters.page.toString());
    if (filters.limit) queryParams.append('limit', filters.limit.toString());
    if (filters.search) queryParams.append('search', filters.search);
    if (filters.status) queryParams.append('status', filters.status);
    if (filters.sortBy) queryParams.append('sortBy', filters.sortBy);

    const response = await api.get(`/api/courses?${queryParams.toString()}`);
    return response.data;
  }

  async getPublicCourses(filters: CourseFilterOptions = {}): Promise<PaginatedResponse<Course>> {
    const queryParams = new URLSearchParams();
    if (filters.page) queryParams.append('page', filters.page.toString());
    if (filters.limit) queryParams.append('limit', filters.limit.toString());
    if (filters.search) queryParams.append('search', filters.search);
    if (filters.sortBy) queryParams.append('sortBy', filters.sortBy);

    const response = await api.get(`/api/courses/public?${queryParams.toString()}`);
    return response.data;
  }

  async getCourseById(id: string): Promise<Course> {
    const response = await api.get(`/api/courses/${id}`);
    return response.data.data;
  }

  async createCourse(data: CreateCourseInput): Promise<Course> {
    const response = await api.post('/api/courses', data);
    return response.data.data;
  }

  async updateCourse(id: string, data: UpdateCourseInput): Promise<Course> {
    const response = await api.patch(`/api/courses/${id}`, data);
    return response.data.data;
  }

  async deleteCourse(id: string): Promise<void> {
    await api.delete(`/api/courses/${id}`);
  }

  async updateCourseStatus(id: string, status: 'DRAFT' | 'UNDER_REVIEW' | 'PUBLISHED'): Promise<Course> {
    const response = await api.patch(`/api/courses/${id}/status`, { status });
    return response.data.data;
  }

  async duplicateCourse(id: string): Promise<Course> {
    const response = await api.post(`/api/courses/${id}/duplicate`);
    return response.data.data;
  }

  async getStats(): Promise<InstructorStats> {
    const response = await api.get('/api/courses/stats');
    return response.data.data;
  }

  // ============================================
  // SECTIONS
  // ============================================

  async getSections(courseId: string): Promise<Section[]> {
    const response = await api.get(`/api/courses/${courseId}/sections`);
    return response.data.data;
  }

  async getSectionById(id: string): Promise<Section> {
    const response = await api.get(`/api/sections/${id}`);
    return response.data.data;
  }

  async createSection(courseId: string, data: CreateSectionInput): Promise<Section> {
    const response = await api.post(`/api/courses/${courseId}/sections`, data);
    return response.data.data;
  }

  async updateSection(id: string, data: UpdateSectionInput): Promise<Section> {
    const response = await api.patch(`/api/sections/${id}`, data);
    return response.data.data;
  }

  async deleteSection(id: string): Promise<void> {
    await api.delete(`/api/sections/${id}`);
  }

  async reorderSections(courseId: string, sections: ReorderSectionsInput['sections']): Promise<Section[]> {
    const response = await api.post(`/api/courses/${courseId}/sections/reorder`, { sections });
    return response.data.data;
  }

  async moveSection(id: string, order: number): Promise<Section[]> {
    const response = await api.post(`/api/sections/${id}/move`, { order });
    return response.data.data;
  }

  // ============================================
  // LESSONS
  // ============================================

  async getLessonsBySection(sectionId: string): Promise<Lesson[]> {
    const response = await api.get(`/api/sections/${sectionId}/lessons`);
    return response.data.data;
  }

  async getLessonsByCourse(courseId: string): Promise<Lesson[]> {
    const response = await api.get(`/api/courses/${courseId}/lessons`);
    return response.data.data;
  }

  async getLessonById(id: string): Promise<Lesson> {
    const response = await api.get(`/api/lessons/${id}`);
    return response.data.data;
  }

  async createLesson(sectionId: string, data: CreateLessonInput): Promise<Lesson> {
    const response = await api.post(`/api/sections/${sectionId}/lessons`, data);
    return response.data.data;
  }

  async updateLesson(id: string, data: UpdateLessonInput): Promise<Lesson> {
    const response = await api.patch(`/api/lessons/${id}`, data);
    return response.data.data;
  }

  async deleteLesson(id: string): Promise<void> {
    await api.delete(`/api/lessons/${id}`);
  }

  async reorderLessons(sectionId: string, lessons: ReorderLessonsInput['lessons']): Promise<Lesson[]> {
    const response = await api.post(`/api/sections/${sectionId}/lessons/reorder`, { lessons });
    return response.data.data;
  }

  // ============================================
  // VIDEO UPLOAD
  // ============================================

  async uploadVideo(lessonId: string, formData: FormData): Promise<VideoUploadResult> {
    const response = await api.post(`/api/lessons/${lessonId}/upload-video`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data.data;
  }

  async deleteVideo(lessonId: string): Promise<void> {
    await api.delete(`/api/lessons/${lessonId}/video`);
  }

  async getVideoStreamUrl(lessonId: string): Promise<VideoStreamUrl> {
    const response = await api.get(`/api/lessons/${lessonId}/stream-url`);
    return response.data.data;
  }
}

export const instructorApi = new InstructorService();
export default instructorApi;