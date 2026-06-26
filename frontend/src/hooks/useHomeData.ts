// hooks/useHomeData.ts
import { useState, useEffect, useCallback } from 'react';
import { HomeData } from '@/types/home';
import { homeService } from '@/services/homeService';

interface UseHomeDataReturn {
  loading: boolean;
  error: string | null;
  data: HomeData | null;
  fetchHomeData: () => Promise<void>;
  refreshHomeData: () => Promise<void>;
  loadMoreRecommendations: () => Promise<void>;
}

export const useHomeData = (): UseHomeDataReturn => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [data, setData] = useState<HomeData | null>(null);
  const [page, setPage] = useState(1);

  const fetchHomeData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await homeService.getHomeData();
      setData(response);
    } catch (err: any) {
      setError(err?.message || 'Failed to load home data');
    } finally {
      setLoading(false);
    }
  }, []);

  const refreshHomeData = useCallback(async () => {
    try {
      setError(null);
      const response = await homeService.getHomeData();
      setData(response);
      setPage(1);
    } catch (err: any) {
      setError(err?.message || 'Failed to refresh home data');
    }
  }, []);

  const loadMoreRecommendations = useCallback(async () => {
    if (!data) return;
    
    try {
      const nextPage = page + 1;
      const moreCourses = await homeService.getRecommendedCourses(nextPage);
      
      setData(prev => ({
        ...prev!,
        recommendedCourses: [
          ...prev!.recommendedCourses,
          ...moreCourses,
        ],
      }));
      setPage(nextPage);
    } catch (err) {
      console.error('Failed to load more recommendations:', err);
    }
  }, [data, page]);

  useEffect(() => {
    fetchHomeData();
  }, []);

  return {
    loading,
    error,
    data,
    fetchHomeData,
    refreshHomeData,
    loadMoreRecommendations,
  };
}