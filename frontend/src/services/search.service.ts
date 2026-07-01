// frontend/src/services/search.service.ts
import api from '@/lib/api';
import { SearchResult } from '@/types/search';

export const searchService = {
  /**
   * Unified search - searches all types
   */
  async search(
    query: string,
    type: 'all' | 'courses' | 'instructors' | 'categories' = 'all',
    page: number = 1,
    limit: number = 20
  ): Promise<SearchResult> {
    const response = await api.get('/api/search', {
      params: { q: query, type, page, limit },
    });
    return response.data.data;
  },

  /**
   * Search courses only
   */
  async searchCourses(
    query: string,
    filters?: {
      category?: string;
      level?: string;
      price?: 'free' | 'paid';
      sortBy?: 'relevance' | 'rating' | 'students' | 'newest';
      page?: number;
      limit?: number;
    }
  ): Promise<SearchResult> {
    const response = await api.get('/api/search/courses', {
      params: { 
        q: query, 
        ...filters,
        page: filters?.page || 1,
        limit: filters?.limit || 20,
      },
    });
    return response.data.data;
  },

  /**
   * Search instructors only
   */
  async searchInstructors(query: string, page: number = 1, limit: number = 20): Promise<SearchResult> {
    const response = await api.get('/api/search/instructors', {
      params: { q: query, page, limit },
    });
    return response.data.data;
  },

  /**
   * Search categories only
   */
  async searchCategories(query: string, page: number = 1, limit: number = 20): Promise<SearchResult> {
    const response = await api.get('/api/search/categories', {
      params: { q: query, page, limit },
    });
    return response.data.data;
  },

  /**
   * Get autocomplete suggestions
   */
  async getSuggestions(query: string): Promise<any[]> {
    if (query.length < 2) return [];
    const response = await api.get('/api/search/suggestions', {
      params: { q: query },
    });
    return response.data.data;
  },

  /**
   * Get trending content
   */
  async getTrending(): Promise<any> {
    const response = await api.get('/api/search/trending');
    return response.data.data;
  },

  /**
   * ✅ Get recent searches (requires auth)
   */
  async getRecentSearches(): Promise<string[]> {
    try {
      const response = await api.get('/api/search/recent');
      return response.data.data || [];
    } catch (error) {
      console.error('❌ Failed to get recent searches:', error);
      return [];
    }
  },

  /**
   * ✅ Save a recent search (requires auth)
   */
  async saveRecentSearch(query: string): Promise<void> {
    try {
      await api.post('/api/search/recent', { query });
    } catch (error) {
      console.error('❌ Failed to save recent search:', error);
    }
  },

  /**
   * ✅ Clear all recent searches (requires auth)
   */
  async clearRecentSearches(): Promise<void> {
    try {
      await api.delete('/api/search/recent');
    } catch (error) {
      console.error('❌ Failed to clear recent searches:', error);
    }
  },
};