// services/categoryService.ts
import api from '../lib/api';

export interface CategoryData {
  id: string;
  name: string;
  slug: string;
  description?: string;
  icon?: string;
  color?: string;
  parentId?: string | null;
  parent?: CategoryData | null;
  children?: CategoryData[];
  courseCount?: number;
  createdAt?: string;
  updatedAt?: string;
}

class CategoryService {
  private baseUrl = '/categories';

  // Get all categories
  async getCategories(params?: { includeInactive?: boolean }): Promise<CategoryData[]> {
    try {
      const response = await api.get(this.baseUrl, { params });
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get category tree (hierarchical)
  async getCategoryTree(): Promise<CategoryData[]> {
    try {
      const response = await api.get(`${this.baseUrl}/tree`);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get single category by ID
  async getCategoryById(id: string): Promise<CategoryData> {
    try {
      const response = await api.get(`${this.baseUrl}/${id}`);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get category by slug
  async getCategoryBySlug(slug: string): Promise<CategoryData> {
    try {
      const response = await api.get(`${this.baseUrl}/slug/${slug}`);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Create category (admin only)
  async createCategory(data: Partial<CategoryData>): Promise<CategoryData> {
    try {
      const response = await api.post(this.baseUrl, data);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Update category (admin only)
  async updateCategory(id: string, data: Partial<CategoryData>): Promise<CategoryData> {
    try {
      const response = await api.put(`${this.baseUrl}/${id}`, data);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Delete category (admin only)
  async deleteCategory(id: string): Promise<{ message: string }> {
    try {
      const response = await api.delete(`${this.baseUrl}/${id}`);
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get courses by category
  async getCoursesByCategory(
    categoryId: string,
    params?: { page?: number; limit?: number; search?: string; level?: string; sortBy?: string }
  ): Promise<any> {
    try {
      const queryParams = new URLSearchParams();
      if (params?.page) queryParams.append('page', params.page.toString());
      if (params?.limit) queryParams.append('limit', params.limit.toString());
      if (params?.search) queryParams.append('search', params.search);
      if (params?.level) queryParams.append('level', params.level);
      if (params?.sortBy) queryParams.append('sortBy', params.sortBy);

      const url = `${this.baseUrl}/${categoryId}/courses?${queryParams.toString()}`;
      const response = await api.get(url);
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get popular categories
  async getPopularCategories(limit: number = 10): Promise<CategoryData[]> {
    try {
      const response = await api.get(`${this.baseUrl}/popular`, { params: { limit } });
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Get category statistics (admin only)
  async getCategoryStats(): Promise<any> {
    try {
      const response = await api.get(`${this.baseUrl}/stats`);
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Search categories
  async searchCategories(query: string, limit: number = 20): Promise<CategoryData[]> {
    try {
      const response = await api.get(`${this.baseUrl}/search`, {
        params: { q: query, limit }
      });
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Bulk create categories (admin only)
  async bulkCreateCategories(categories: Partial<CategoryData>[]): Promise<CategoryData[]> {
    try {
      const response = await api.post(`${this.baseUrl}/bulk`, { categories });
      return response.data.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Reorder categories (admin only)
  async reorderCategories(orderedIds: string[]): Promise<{ message: string }> {
    try {
      const response = await api.patch(`${this.baseUrl}/reorder`, { orderedIds });
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  private handleError(error: any): Error {
    if (error.response) {
      const message = error.response.data?.message || 'An error occurred';
      const status = error.response.status;
      
      if (status === 401) {
        console.error('Unauthorized access');
      } else if (status === 403) {
        console.error('Forbidden access');
      } else if (status === 404) {
        console.error('Resource not found');
      } else if (status === 422) {
        const errors = error.response.data?.errors;
        if (errors) {
          return new Error(JSON.stringify(errors));
        }
      }
      
      return new Error(message);
    } else if (error.request) {
      return new Error('Network error. Please check your connection.');
    } else {
      return new Error(error.message || 'An unexpected error occurred');
    }
  }
}

export const categoryService = new CategoryService();
export default categoryService;