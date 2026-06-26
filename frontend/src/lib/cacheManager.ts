// lib/cacheManager.ts
import AsyncStorage from '@react-native-async-storage/async-storage';

interface CacheItem<T> {
  data: T;
  timestamp: number;
  expiresAt: number;
}

interface CacheConfig {
  ttl: number;
  maxItems: number;
}

class CacheManager {
  private defaultConfig: CacheConfig = {
    ttl: 5 * 60 * 1000,
    maxItems: 100,
  };

  private configs: Map<string, CacheConfig> = new Map();

  constructor() {
    this.configs.set('home_data', { ttl: 10 * 60 * 1000, maxItems: 1 });
    this.configs.set('home_recommendations', { ttl: 5 * 60 * 1000, maxItems: 20 });
    this.configs.set('home_popular', { ttl: 15 * 60 * 1000, maxItems: 1 });
    this.configs.set('home_categories', { ttl: 30 * 60 * 1000, maxItems: 1 });
  }

  getConfig(key: string): CacheConfig {
    return this.configs.get(key) || this.defaultConfig;
  }

  async set<T>(key: string, data: T, config?: Partial<CacheConfig>): Promise<void> {
    try {
      const cacheConfig = { ...this.getConfig(key), ...config };
      const item: CacheItem<T> = {
        data,
        timestamp: Date.now(),
        expiresAt: Date.now() + cacheConfig.ttl,
      };

      await this.cleanup(key, cacheConfig.maxItems);
      await AsyncStorage.setItem(`cache_${key}`, JSON.stringify(item));
    } catch (error) {
      console.error(`Failed to cache key "${key}":`, error);
    }
  }

  async get<T>(key: string): Promise<T | null> {
    try {
      const cached = await AsyncStorage.getItem(`cache_${key}`);
      if (!cached) return null;

      const item: CacheItem<T> = JSON.parse(cached);

      if (Date.now() > item.expiresAt) {
        await this.remove(key);
        return null;
      }

      return item.data;
    } catch (error) {
      console.error(`Failed to get cached key "${key}":`, error);
      return null;
    }
  }

  async remove(key: string): Promise<void> {
    try {
      await AsyncStorage.removeItem(`cache_${key}`);
    } catch (error) {
      console.error(`Failed to remove cached key "${key}":`, error);
    }
  }

  async clear(): Promise<void> {
    try {
      const keys = await AsyncStorage.getAllKeys();
      const cacheKeys = keys.filter(key => key.startsWith('cache_'));
      await Promise.all(cacheKeys.map(key => AsyncStorage.removeItem(key)));
    } catch (error) {
      console.error('Failed to clear cache:', error);
    }
  }

  async getStats(): Promise<{ total: number; keys: string[] }> {
    try {
      const keys = await AsyncStorage.getAllKeys();
      const cacheKeys = keys.filter(key => key.startsWith('cache_'));
      return {
        total: cacheKeys.length,
        keys: cacheKeys.map(key => key.replace('cache_', '')),
      };
    } catch (error) {
      console.error('Failed to get cache stats:', error);
      return { total: 0, keys: [] };
    }
  }

  private async cleanup(key: string, maxItems: number): Promise<void> {
    try {
      const keys = await AsyncStorage.getAllKeys();
      const cacheKeys = keys.filter(k => k.startsWith('cache_'));
      
      if (cacheKeys.length >= maxItems) {
        const toRemove = cacheKeys.slice(0, cacheKeys.length - maxItems + 1);
        await Promise.all(toRemove.map(k => AsyncStorage.removeItem(k)));
      }
    } catch (error) {
      console.error(`Failed to cleanup cache for key "${key}":`, error);
    }
  }

  async getBatch<T>(keys: string[]): Promise<Map<string, T | null>> {
    const results = new Map<string, T | null>();
    
    try {
      const promises = keys.map(async (key) => {
        const value = await AsyncStorage.getItem(`cache_${key}`);
        return { key, value };
      });
      
      const items = await Promise.all(promises);
      
      items.forEach(({ key, value }) => {
        const originalKey = key.replace('cache_', '');
        if (value) {
          try {
            const item: CacheItem<T> = JSON.parse(value);
            if (Date.now() <= item.expiresAt) {
              results.set(originalKey, item.data);
            } else {
              results.set(originalKey, null);
              AsyncStorage.removeItem(`cache_${originalKey}`).catch(console.error);
            }
          } catch {
            results.set(originalKey, null);
          }
        } else {
          results.set(originalKey, null);
        }
      });
    } catch (error) {
      console.error('Failed to get batch cache:', error);
    }
    
    return results;
  }

  async setBatch(items: Record<string, any>, config?: Partial<CacheConfig>): Promise<void> {
    try {
      const promises = Object.entries(items).map(([key, data]) =>
        this.set(key, data, config)
      );
      await Promise.all(promises);
    } catch (error) {
      console.error('Failed to set batch cache:', error);
    }
  }
}

export const cacheManager = new CacheManager();