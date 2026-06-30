// frontend/src/lib/api.ts
import axios from 'axios';
import { Platform } from 'react-native';

// Your computer's IP from ifconfig (for Android physical device)
const YOUR_COMPUTER_IP = '192.168.1.10';
const BACKEND_PORT = 3000;

// Get the base URL based on platform
const getBaseURL = () => {
  if (__DEV__) {
    if (Platform.OS === 'web') {
      return process.env.EXPO_PUBLIC_API_URL_WEB || `http://localhost:${BACKEND_PORT}`;
    }
    
    if (Platform.OS === 'ios') {
      return process.env.EXPO_PUBLIC_API_URL_IOS || `http://localhost:${BACKEND_PORT}`;
    }
    
    if (Platform.OS === 'android') {
      // For physical device - use your computer's IP
      return process.env.EXPO_PUBLIC_API_URL_ANDROID || `http://${YOUR_COMPUTER_IP}:${BACKEND_PORT}`;
      // For Android emulator, use: `http://10.0.2.2:${BACKEND_PORT}`
    }
  }
  
  return process.env.EXPO_PUBLIC_API_URL || 'https://your-production-api.com';
};

// Platform-specific storage utility
const getStorage = () => {
  if (Platform.OS === 'web') {
    return {
      getItem: (name: string) => {
        try {
          const value = localStorage.getItem(name);
          return value ? JSON.parse(value) : null;
        } catch {
          return null;
        }
      },
      setItem: (name: string, value: any) => {
        try {
          localStorage.setItem(name, JSON.stringify(value));
        } catch (error) {
          console.error('Error saving to localStorage:', error);
        }
      },
      removeItem: (name: string) => {
        try {
          localStorage.removeItem(name);
        } catch (error) {
          console.error('Error removing from localStorage:', error);
        }
      },
    };
  } else {
    try {
      const AsyncStorage = require('@react-native-async-storage/async-storage').default;
      return {
        getItem: (name: string) => AsyncStorage.getItem(name).then((value: string) => value ? JSON.parse(value) : null),
        setItem: (name: string, value: any) => AsyncStorage.setItem(name, JSON.stringify(value)),
        removeItem: (name: string) => AsyncStorage.removeItem(name),
      };
    } catch {
      return {
        getItem: async () => null,
        setItem: async () => {},
        removeItem: async () => {},
      };
    }
  }
};

// ✅ FIXED: Create axios instance WITHOUT default Content-Type
const api = axios.create({
  baseURL: getBaseURL(),
  timeout: 300000, // 5 minutes for large file uploads
  headers: {
    'Accept': 'application/json',
    // ❌ REMOVED: 'Content-Type': 'application/json',
  },
  withCredentials: true,
});

// Helper to get token from storage
const getTokenFromStorage = async (): Promise<string | null> => {
  try {
    const storage = getStorage();
    const data = await storage.getItem('auth-storage');
    if (data && data.state && data.state.token) {
      return data.state.token;
    }
    return null;
  } catch {
    return null;
  }
};

// Helper to clear auth from storage
const clearAuthFromStorage = async (): Promise<void> => {
  try {
    const storage = getStorage();
    await storage.removeItem('auth-storage');
  } catch (error) {
    console.error('Error clearing auth from storage:', error);
  }
};

// Request interceptor to add token
api.interceptors.request.use(
  async (config) => {
    if (!config.headers.Authorization) {
      try {
        const token = await getTokenFromStorage();
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
      } catch (error) {
        console.error('Error getting token for request:', error);
      }
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle auth errors
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      await clearAuthFromStorage();
      console.log('Authentication error - token cleared');
    }
    return Promise.reject(error);
  }
);

export default api;