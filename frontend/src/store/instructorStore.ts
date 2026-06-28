// store/instructorStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { Platform } from 'react-native';
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
} from '@/types/instructor';
import { instructorApi } from '@/services/instructorService';

interface InstructorState {
  // Courses
  courses: Course[];
  currentCourse: Course | null;
  coursesLoading: boolean;
  coursesError: string | null;
  coursesPagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasMore: boolean;
  } | null;

  // Sections
  sections: Section[];
  currentSection: Section | null;
  sectionsLoading: boolean;
  sectionsError: string | null;

  // Lessons
  lessons: Lesson[];
  currentLesson: Lesson | null;
  lessonsLoading: boolean;
  lessonsError: string | null;

  // Stats
  stats: InstructorStats | null;
  statsLoading: boolean;

  // Video upload
  uploadProgress: number;
  uploadLoading: boolean;
  uploadError: string | null;

  // UI state
  activeTab: 'courses' | 'sections' | 'lessons';
  editingCourseId: string | null;
  editingSectionId: string | null;
  editingLessonId: string | null;

  // Course actions
  fetchCourses: (params?: { page?: number; limit?: number; status?: string; search?: string }) => Promise<void>;
  fetchCourseById: (id: string) => Promise<Course | null>;
  createCourse: (data: CreateCourseInput) => Promise<Course>;
  updateCourse: (id: string, data: UpdateCourseInput) => Promise<Course>;
  deleteCourse: (id: string) => Promise<void>;
  updateCourseStatus: (id: string, status: 'DRAFT' | 'UNDER_REVIEW' | 'PUBLISHED') => Promise<Course>;
  duplicateCourse: (id: string) => Promise<Course>;
  fetchStats: () => Promise<void>;
  clearCourseError: () => void;
  setCurrentCourse: (course: Course | null) => void;

  // Section actions
  fetchSections: (courseId: string) => Promise<void>;
  fetchSectionById: (id: string) => Promise<Section | null>;
  createSection: (courseId: string, data: CreateSectionInput) => Promise<Section>;
  updateSection: (id: string, data: UpdateSectionInput) => Promise<Section>;
  deleteSection: (id: string) => Promise<void>;
  reorderSections: (courseId: string, sections: ReorderSectionsInput['sections']) => Promise<Section[]>;
  moveSection: (id: string, order: number) => Promise<Section[]>;
  clearSectionsError: () => void;
  setCurrentSection: (section: Section | null) => void;

  // Lesson actions
  fetchLessonsBySection: (sectionId: string) => Promise<void>;
  fetchLessonsByCourse: (courseId: string) => Promise<void>;
  fetchLessonById: (id: string) => Promise<Lesson | null>;
  createLesson: (sectionId: string, data: CreateLessonInput) => Promise<Lesson>;
  updateLesson: (id: string, data: UpdateLessonInput) => Promise<Lesson>;
  deleteLesson: (id: string) => Promise<void>;
  reorderLessons: (sectionId: string, lessons: ReorderLessonsInput['lessons']) => Promise<Lesson[]>;
  clearLessonsError: () => void;
  setCurrentLesson: (lesson: Lesson | null) => void;

  // Video upload
  uploadVideo: (lessonId: string, file: { uri: string; name: string; mimeType: string; size: number }) => Promise<void>;
  deleteVideo: (lessonId: string) => Promise<void>;
  getVideoStreamUrl: (lessonId: string) => Promise<string>;
  resetUploadProgress: () => void;

  // UI actions
  setActiveTab: (tab: 'courses' | 'sections' | 'lessons') => void;
  setEditingCourse: (id: string | null) => void;
  setEditingSection: (id: string | null) => void;
  setEditingLesson: (id: string | null) => void;

  // Reset
  reset: () => void;
}

// Platform-specific storage
const getStorage = () => {
  if (Platform.OS === 'web') {
    return {
      getItem: (name: string) => {
        try {
          const value = localStorage.getItem(name);
          return value ? Promise.resolve(JSON.parse(value)) : Promise.resolve(null);
        } catch {
          return Promise.resolve(null);
        }
      },
      setItem: (name: string, value: any) => {
        try {
          localStorage.setItem(name, JSON.stringify(value));
        } catch (error) {
          console.error('Error saving to localStorage:', error);
        }
        return Promise.resolve();
      },
      removeItem: (name: string) => {
        try {
          localStorage.removeItem(name);
        } catch (error) {
          console.error('Error removing from localStorage:', error);
        }
        return Promise.resolve();
      },
    };
  } else {
    const AsyncStorage = require('@react-native-async-storage/async-storage').default;
    return {
      getItem: AsyncStorage.getItem,
      setItem: AsyncStorage.setItem,
      removeItem: AsyncStorage.removeItem,
    };
  }
};

const initialState = {
  courses: [],
  currentCourse: null,
  coursesLoading: false,
  coursesError: null,
  coursesPagination: null,
  sections: [],
  currentSection: null,
  sectionsLoading: false,
  sectionsError: null,
  lessons: [],
  currentLesson: null,
  lessonsLoading: false,
  lessonsError: null,
  stats: null,
  statsLoading: false,
  uploadProgress: 0,
  uploadLoading: false,
  uploadError: null,
  activeTab: 'courses' as 'courses' | 'sections' | 'lessons',
  editingCourseId: null,
  editingSectionId: null,
  editingLessonId: null,
};

export const useInstructorStore = create<InstructorState>()(
  persist(
    (set, get) => ({
      ...initialState,

      // Course actions
      fetchCourses: async (params = {}) => {
        set({ coursesLoading: true, coursesError: null });
        try {
          const response = await instructorApi.getCourses(params);
          set({
            courses: params.page && params.page > 1 ? [...get().courses, ...response.data] : response.data,
            coursesPagination: response.pagination,
            coursesLoading: false,
            coursesError: null,
          });
        } catch (error: any) {
          set({
            coursesLoading: false,
            coursesError: error?.response?.data?.message || error?.message || 'Failed to fetch courses',
          });
        }
      },

      fetchCourseById: async (id: string) => {
        set({ coursesLoading: true, coursesError: null });
        try {
          const course = await instructorApi.getCourseById(id);
          set({ currentCourse: course, coursesLoading: false });
          return course;
        } catch (error: any) {
          set({
            coursesLoading: false,
            coursesError: error?.response?.data?.message || error?.message || 'Failed to fetch course',
          });
          return null;
        }
      },

      createCourse: async (data: CreateCourseInput) => {
        set({ coursesLoading: true, coursesError: null });
        try {
          const course = await instructorApi.createCourse(data);
          set((state) => ({
            courses: [course, ...state.courses],
            coursesLoading: false,
            coursesError: null,
          }));
          return course;
        } catch (error: any) {
          set({
            coursesLoading: false,
            coursesError: error?.response?.data?.message || error?.message || 'Failed to create course',
          });
          throw error;
        }
      },

      updateCourse: async (id: string, data: UpdateCourseInput) => {
        set({ coursesLoading: true, coursesError: null });
        try {
          const course = await instructorApi.updateCourse(id, data);
          set((state) => ({
            courses: state.courses.map((c) => (c.id === id ? course : c)),
            currentCourse: state.currentCourse?.id === id ? course : state.currentCourse,
            coursesLoading: false,
            coursesError: null,
          }));
          return course;
        } catch (error: any) {
          set({
            coursesLoading: false,
            coursesError: error?.response?.data?.message || error?.message || 'Failed to update course',
          });
          throw error;
        }
      },

      deleteCourse: async (id: string) => {
        set({ coursesLoading: true, coursesError: null });
        try {
          await instructorApi.deleteCourse(id);
          set((state) => ({
            courses: state.courses.filter((c) => c.id !== id),
            coursesLoading: false,
            coursesError: null,
          }));
        } catch (error: any) {
          set({
            coursesLoading: false,
            coursesError: error?.response?.data?.message || error?.message || 'Failed to delete course',
          });
          throw error;
        }
      },

      updateCourseStatus: async (id: string, status: 'DRAFT' | 'UNDER_REVIEW' | 'PUBLISHED') => {
        set({ coursesLoading: true, coursesError: null });
        try {
          const course = await instructorApi.updateCourseStatus(id, status);
          set((state) => ({
            courses: state.courses.map((c) => (c.id === id ? course : c)),
            currentCourse: state.currentCourse?.id === id ? course : state.currentCourse,
            coursesLoading: false,
            coursesError: null,
          }));
          return course;
        } catch (error: any) {
          set({
            coursesLoading: false,
            coursesError: error?.response?.data?.message || error?.message || 'Failed to update course status',
          });
          throw error;
        }
      },

      duplicateCourse: async (id: string) => {
        set({ coursesLoading: true, coursesError: null });
        try {
          const course = await instructorApi.duplicateCourse(id);
          set((state) => ({
            courses: [course, ...state.courses],
            coursesLoading: false,
            coursesError: null,
          }));
          return course;
        } catch (error: any) {
          set({
            coursesLoading: false,
            coursesError: error?.response?.data?.message || error?.message || 'Failed to duplicate course',
          });
          throw error;
        }
      },

      fetchStats: async () => {
        set({ statsLoading: true });
        try {
          const stats = await instructorApi.getStats();
          set({ stats, statsLoading: false });
        } catch (error: any) {
          set({ statsLoading: false, stats: null });
        }
      },

      clearCourseError: () => set({ coursesError: null }),
      setCurrentCourse: (course: Course | null) => set({ currentCourse: course }),

      // Section actions
      fetchSections: async (courseId: string) => {
        set({ sectionsLoading: true, sectionsError: null });
        try {
          const sections = await instructorApi.getSections(courseId);
          set({ sections, sectionsLoading: false, sectionsError: null });
        } catch (error: any) {
          set({
            sectionsLoading: false,
            sectionsError: error?.response?.data?.message || error?.message || 'Failed to fetch sections',
          });
        }
      },

      fetchSectionById: async (id: string) => {
        try {
          const section = await instructorApi.getSectionById(id);
          set({ currentSection: section });
          return section;
        } catch (error: any) {
          set({ sectionsError: error?.response?.data?.message || error?.message || 'Failed to fetch section' });
          return null;
        }
      },

      createSection: async (courseId: string, data: CreateSectionInput) => {
        set({ sectionsLoading: true, sectionsError: null });
        try {
          const section = await instructorApi.createSection(courseId, data);
          set((state) => ({
            sections: [...state.sections, section].sort((a, b) => a.order - b.order),
            sectionsLoading: false,
            sectionsError: null,
          }));
          return section;
        } catch (error: any) {
          set({
            sectionsLoading: false,
            sectionsError: error?.response?.data?.message || error?.message || 'Failed to create section',
          });
          throw error;
        }
      },

      updateSection: async (id: string, data: UpdateSectionInput) => {
        set({ sectionsLoading: true, sectionsError: null });
        try {
          const section = await instructorApi.updateSection(id, data);
          set((state) => ({
            sections: state.sections.map((s) => (s.id === id ? section : s)).sort((a, b) => a.order - b.order),
            currentSection: state.currentSection?.id === id ? section : state.currentSection,
            sectionsLoading: false,
            sectionsError: null,
          }));
          return section;
        } catch (error: any) {
          set({
            sectionsLoading: false,
            sectionsError: error?.response?.data?.message || error?.message || 'Failed to update section',
          });
          throw error;
        }
      },

      deleteSection: async (id: string) => {
        set({ sectionsLoading: true, sectionsError: null });
        try {
          await instructorApi.deleteSection(id);
          set((state) => ({
            sections: state.sections.filter((s) => s.id !== id),
            sectionsLoading: false,
            sectionsError: null,
          }));
        } catch (error: any) {
          set({
            sectionsLoading: false,
            sectionsError: error?.response?.data?.message || error?.message || 'Failed to delete section',
          });
          throw error;
        }
      },

      reorderSections: async (courseId: string, sections: ReorderSectionsInput['sections']) => {
        set({ sectionsLoading: true, sectionsError: null });
        try {
          const reordered = await instructorApi.reorderSections(courseId, sections);
          set({ sections: reordered, sectionsLoading: false, sectionsError: null });
          return reordered;
        } catch (error: any) {
          set({
            sectionsLoading: false,
            sectionsError: error?.response?.data?.message || error?.message || 'Failed to reorder sections',
          });
          throw error;
        }
      },

      moveSection: async (id: string, order: number) => {
        set({ sectionsLoading: true, sectionsError: null });
        try {
          const reordered = await instructorApi.moveSection(id, order);
          set({ sections: reordered, sectionsLoading: false, sectionsError: null });
          return reordered;
        } catch (error: any) {
          set({
            sectionsLoading: false,
            sectionsError: error?.response?.data?.message || error?.message || 'Failed to move section',
          });
          throw error;
        }
      },

      clearSectionsError: () => set({ sectionsError: null }),
      setCurrentSection: (section: Section | null) => set({ currentSection: section }),

      // Lesson actions
      fetchLessonsBySection: async (sectionId: string) => {
        set({ lessonsLoading: true, lessonsError: null });
        try {
          const lessons = await instructorApi.getLessonsBySection(sectionId);
          set({ lessons, lessonsLoading: false, lessonsError: null });
        } catch (error: any) {
          set({
            lessonsLoading: false,
            lessonsError: error?.response?.data?.message || error?.message || 'Failed to fetch lessons',
          });
        }
      },

      fetchLessonsByCourse: async (courseId: string) => {
        set({ lessonsLoading: true, lessonsError: null });
        try {
          const lessons = await instructorApi.getLessonsByCourse(courseId);
          set({ lessons, lessonsLoading: false, lessonsError: null });
        } catch (error: any) {
          set({
            lessonsLoading: false,
            lessonsError: error?.response?.data?.message || error?.message || 'Failed to fetch lessons',
          });
        }
      },

      fetchLessonById: async (id: string) => {
        try {
          const lesson = await instructorApi.getLessonById(id);
          set({ currentLesson: lesson });
          return lesson;
        } catch (error: any) {
          set({ lessonsError: error?.response?.data?.message || error?.message || 'Failed to fetch lesson' });
          return null;
        }
      },

      createLesson: async (sectionId: string, data: CreateLessonInput) => {
        set({ lessonsLoading: true, lessonsError: null });
        try {
          const lesson = await instructorApi.createLesson(sectionId, data);
          set((state) => ({
            lessons: [...state.lessons, lesson].sort((a, b) => a.order - b.order),
            lessonsLoading: false,
            lessonsError: null,
          }));
          return lesson;
        } catch (error: any) {
          set({
            lessonsLoading: false,
            lessonsError: error?.response?.data?.message || error?.message || 'Failed to create lesson',
          });
          throw error;
        }
      },

      updateLesson: async (id: string, data: UpdateLessonInput) => {
        set({ lessonsLoading: true, lessonsError: null });
        try {
          const lesson = await instructorApi.updateLesson(id, data);
          set((state) => ({
            lessons: state.lessons.map((l) => (l.id === id ? lesson : l)).sort((a, b) => a.order - b.order),
            currentLesson: state.currentLesson?.id === id ? lesson : state.currentLesson,
            lessonsLoading: false,
            lessonsError: null,
          }));
          return lesson;
        } catch (error: any) {
          set({
            lessonsLoading: false,
            lessonsError: error?.response?.data?.message || error?.message || 'Failed to update lesson',
          });
          throw error;
        }
      },

      deleteLesson: async (id: string) => {
        set({ lessonsLoading: true, lessonsError: null });
        try {
          await instructorApi.deleteLesson(id);
          set((state) => ({
            lessons: state.lessons.filter((l) => l.id !== id),
            lessonsLoading: false,
            lessonsError: null,
          }));
        } catch (error: any) {
          set({
            lessonsLoading: false,
            lessonsError: error?.response?.data?.message || error?.message || 'Failed to delete lesson',
          });
          throw error;
        }
      },

      reorderLessons: async (sectionId: string, lessons: ReorderLessonsInput['lessons']) => {
        set({ lessonsLoading: true, lessonsError: null });
        try {
          const reordered = await instructorApi.reorderLessons(sectionId, lessons);
          set({ lessons: reordered, lessonsLoading: false, lessonsError: null });
          return reordered;
        } catch (error: any) {
          set({
            lessonsLoading: false,
            lessonsError: error?.response?.data?.message || error?.message || 'Failed to reorder lessons',
          });
          throw error;
        }
      },

      clearLessonsError: () => set({ lessonsError: null }),
      setCurrentLesson: (lesson: Lesson | null) => set({ currentLesson: lesson }),

      // Video upload
      uploadVideo: async (lessonId: string, file: { uri: string; name: string; mimeType: string; size: number }) => {
        set({ uploadLoading: true, uploadProgress: 0, uploadError: null });
        try {
          const formData = new FormData();
          formData.append('video', {
            uri: file.uri,
            name: file.name,
            type: file.mimeType,
          } as any);

          // Note: axios doesn't support progress for FormData in React Native
          // You might need to use a different approach for progress tracking
          await instructorApi.uploadVideo(lessonId, formData);
          
          set({ uploadLoading: false, uploadProgress: 100, uploadError: null });
        } catch (error: any) {
          set({
            uploadLoading: false,
            uploadProgress: 0,
            uploadError: error?.response?.data?.message || error?.message || 'Failed to upload video',
          });
          throw error;
        }
      },

      deleteVideo: async (lessonId: string) => {
        set({ uploadLoading: true, uploadError: null });
        try {
          await instructorApi.deleteVideo(lessonId);
          set({ uploadLoading: false, uploadError: null });
        } catch (error: any) {
          set({
            uploadLoading: false,
            uploadError: error?.response?.data?.message || error?.message || 'Failed to delete video',
          });
          throw error;
        }
      },

      getVideoStreamUrl: async (lessonId: string) => {
        try {
          const result = await instructorApi.getVideoStreamUrl(lessonId);
          return result.url;
        } catch (error: any) {
          throw new Error(error?.response?.data?.message || error?.message || 'Failed to get video URL');
        }
      },

      resetUploadProgress: () => set({ uploadProgress: 0, uploadError: null, uploadLoading: false }),

      // UI actions
      setActiveTab: (tab: 'courses' | 'sections' | 'lessons') => set({ activeTab: tab }),
      setEditingCourse: (id: string | null) => set({ editingCourseId: id }),
      setEditingSection: (id: string | null) => set({ editingSectionId: id }),
      setEditingLesson: (id: string | null) => set({ editingLessonId: id }),

      // Reset
      reset: () => set(initialState),
    }),
    {
      name: 'instructor-storage',
      storage: createJSONStorage(() => getStorage()),
      partialize: (state) => ({
        // Only persist essential data
        activeTab: state.activeTab,
      }),
    }
  )
);

export default useInstructorStore;