// store/exploreStore.ts
import { create } from 'zustand';

interface ExploreState {
  loading: boolean;
  refreshing: boolean;
  error: string | null;
  data: any;
  categories: any[];
  courses: any[];
  popularCourses: any[];
  topInstructors: any[];
  fetchExploreData: () => Promise<void>;
  refreshExploreData: () => Promise<void>;
  loadMoreCourses: () => Promise<void>;
  clearError: () => void;
}

export const useExploreStore = create<ExploreState>((set, get) => ({
  loading: false,
  refreshing: false,
  error: null,
  data: null,
  categories: [],
  courses: [],
  popularCourses: [],
  topInstructors: [],

  fetchExploreData: async () => {
    set({ loading: true, error: null });
    try {
      // Replace with your actual API calls
      const response = await fetch('/api/explore');
      const data = await response.json();
      set({
        loading: false,
        data,
        categories: data.categories || [],
        courses: data.courses || [],
        popularCourses: data.popularCourses || [],
        topInstructors: data.topInstructors || [],
      });
    } catch (error) {
      set({ loading: false, error: 'Failed to load explore data' });
    }
  },

  refreshExploreData: async () => {
    set({ refreshing: true });
    try {
      const response = await fetch('/api/explore');
      const data = await response.json();
      set({
        refreshing: false,
        data,
        categories: data.categories || [],
        courses: data.courses || [],
        popularCourses: data.popularCourses || [],
        topInstructors: data.topInstructors || [],
      });
    } catch (error) {
      set({ refreshing: false, error: 'Failed to refresh explore data' });
    }
  },

  loadMoreCourses: async () => {
    // Implement pagination logic
    const { courses } = get();
    try {
      const response = await fetch(`/api/courses?page=${Math.ceil(courses.length / 10) + 1}`);
      const newCourses = await response.json();
      set({ courses: [...courses, ...newCourses] });
    } catch (error) {
      console.error('Failed to load more courses:', error);
    }
  },

  clearError: () => {
    set({ error: null });
  },
}));