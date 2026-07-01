// frontend/src/lib/api.ts
import axios from 'axios';
import { Platform } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

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
      return process.env.EXPO_PUBLIC_API_URL_ANDROID || `http://${YOUR_COMPUTER_IP}:${BACKEND_PORT}`;
    }
  }
  
  return process.env.EXPO_PUBLIC_API_URL || 'https://your-production-api.com';
};

// ✅ Create axios instance
const api = axios.create({
  baseURL: getBaseURL(),
  timeout: 300000, // 5 minutes for large file uploads
  headers: {
    'Accept': 'application/json',
  },
  withCredentials: true,
});

// ✅ FIXED: Get token from AsyncStorage (same as apiClient)
const getTokenFromStorage = async (): Promise<string | null> => {
  try {
    // Use the same storage key as apiClient
    if (Platform.OS === 'web') {
      // For web, check localStorage with the same key
      const token = localStorage.getItem('auth_token');
      console.log('🔑 Token from localStorage:', token ? `${token.substring(0, 20)}...` : 'null');
      return token;
    } else {
      // For native, use AsyncStorage
      const token = await AsyncStorage.getItem('auth_token');
      console.log('🔑 Token from AsyncStorage:', token ? `${token.substring(0, 20)}...` : 'null');
      return token;
    }
  } catch (error) {
    console.error('❌ Error getting token from storage:', error);
    return null;
  }
};

// ✅ Also check Zustand store as fallback
const getTokenFromStore = (): string | null => {
  try {
    const { useAuthStore } = require('@/store/authStore');
    const state = useAuthStore.getState();
    const token = state.token;
    if (token) {
      console.log('🔑 Token from Zustand store:', token.substring(0, 20) + '...');
    }
    return token;
  } catch (error) {
    return null;
  }
};

// Request interceptor to add token
api.interceptors.request.use(
  async (config) => {
    console.log(`📤 ${config.method?.toUpperCase()} ${config.url}`);
    
    // ✅ Try multiple sources for token
    let token = null;
    
    // 1. Try AsyncStorage first (same as apiClient)
    token = await getTokenFromStorage();
    
    // 2. If not found, try Zustand store
    if (!token) {
      token = getTokenFromStore();
    }
    
    // 3. If still not found, try the auth-storage key
    if (!token && Platform.OS === 'web') {
      try {
        const authStorage = localStorage.getItem('auth-storage');
        if (authStorage) {
          const parsed = JSON.parse(authStorage);
          if (parsed.state?.token) {
            token = parsed.state.token;
            console.log('🔑 Token from auth-storage fallback');
          }
        }
      } catch (e) {
        // Ignore
      }
    }
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
      console.log(`✅ Token added to ${config.url}`);
    } else {
      console.log(`⚠️ No token available for ${config.url}`);
    }
    
    return config;
  },
  (error) => {
    console.error('❌ Request interceptor error:', error);
    return Promise.reject(error);
  }
);

// Response interceptor to handle auth errors
api.interceptors.response.use(
  (response) => {
    console.log(`📥 ${response.status} ${response.config.url}`);
    return response;
  },
  async (error) => {
    if (error.response) {
      console.log(`❌ API Error ${error.response.status}: ${error.config?.url}`);
      
      if (error.response.status === 401) {
        console.log('🔴 401 Unauthorized - Token may be invalid or expired');
        // Clear token from all storage
        try {
          if (Platform.OS === 'web') {
            localStorage.removeItem('auth_token');
            localStorage.removeItem('auth-storage');
          } else {
            await AsyncStorage.removeItem('auth_token');
          }
        } catch (e) {
          console.error('Error clearing auth:', e);
        }
      }
    } else if (error.request) {
      console.log('❌ No response received:', error.message);
    } else {
      console.log('❌ Request error:', error.message);
    }
    
    return Promise.reject(error);
  }
);

// Debug helper
export const debugAuth = async () => {
  console.log('🔐 Auth Debug:');
  
  // Check AsyncStorage
  if (Platform.OS === 'web') {
    const token = localStorage.getItem('auth_token');
    console.log('  localStorage auth_token:', token ? '✅ Present' : '❌ Missing');
    if (token) {
      console.log('  Token preview:', token.substring(0, 30) + '...');
    }
    
    const authStorage = localStorage.getItem('auth-storage');
    console.log('  localStorage auth-storage:', authStorage ? '✅ Present' : '❌ Missing');
    if (authStorage) {
      try {
        const parsed = JSON.parse(authStorage);
        console.log('  auth-storage keys:', Object.keys(parsed));
        if (parsed.state) {
          console.log('  state keys:', Object.keys(parsed.state));
          console.log('  state.token:', parsed.state.token ? '✅ Present' : '❌ Missing');
        }
      } catch (e) {
        console.log('  Error parsing auth-storage');
      }
    }
  } else {
    const token = await AsyncStorage.getItem('auth_token');
    console.log('  AsyncStorage auth_token:', token ? '✅ Present' : '❌ Missing');
  }
  
  // Check Zustand store
  try {
    const { useAuthStore } = require('@/store/authStore');
    const state = useAuthStore.getState();
    console.log('  Zustand store token:', state.token ? '✅ Present' : '❌ Missing');
    console.log('  Zustand isAuthenticated:', state.isAuthenticated);
  } catch (e) {
    console.log('  Error accessing Zustand store:', e);
  }
};

export default api;