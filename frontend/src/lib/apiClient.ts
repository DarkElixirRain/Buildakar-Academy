// lib/apiClient.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Platform } from 'react-native';

// Your computer's IP from ifconfig
const YOUR_COMPUTER_IP = '192.168.1.10';
const BACKEND_PORT = 3000;

// Get the base URL based on platform
const getBaseURL = (): string => {
  // Check if running in development
  if (__DEV__) {
    // Web platform
    if (Platform.OS === 'web') {
      return process.env.EXPO_PUBLIC_API_URL_WEB || `http://localhost:${BACKEND_PORT}/api`;
    }
    
    // iOS simulator
    if (Platform.OS === 'ios') {
      return process.env.EXPO_PUBLIC_API_URL_IOS || `http://localhost:${BACKEND_PORT}/api`;
    }
    
    // Android (physical device or emulator)
    if (Platform.OS === 'android') {
      // For physical device - use your computer's IP
      return process.env.EXPO_PUBLIC_API_URL_ANDROID || `http://${YOUR_COMPUTER_IP}:${BACKEND_PORT}/api`;
      
      // For Android emulator, use this instead:
      // return process.env.EXPO_PUBLIC_API_URL_ANDROID || `http://10.0.2.2:${BACKEND_PORT}/api`;
    }
  }
  
  // Production - use your actual backend URL
  return process.env.EXPO_PUBLIC_API_URL || 'https://your-production-api.com/api';
};

interface ApiClientConfig {
  baseURL: string;
  timeout?: number;
  headers?: Record<string, string>;
}

class ApiClient {
  private baseURL: string;
  private timeout: number;
  private headers: Record<string, string>;

  constructor(config: ApiClientConfig) {
    this.baseURL = config.baseURL;
    this.timeout = config.timeout || 30000;
    this.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...config.headers,
    };
  }

  private async getToken(): Promise<string | null> {
    try {
      const token = await AsyncStorage.getItem('auth_token');
      return token;
    } catch {
      return null;
    }
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const token = await this.getToken();
    
    const url = `${this.baseURL}${endpoint}`;
    const headers = {
      ...this.headers,
      ...(token && { Authorization: `Bearer ${token}` }),
      ...options.headers,
    };

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);

    try {
      const response = await fetch(url, {
        ...options,
        headers,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      // Check if response is JSON
      const contentType = response.headers.get('content-type');
      if (!contentType || !contentType.includes('application/json')) {
        const text = await response.text();
        throw new Error('Server returned non-JSON response');
      }

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || data.error || `HTTP Error: ${response.status}`);
      }

      return data;
    } catch (error) {
      clearTimeout(timeoutId);
      
      if (error instanceof Error) {
        if (error.name === 'AbortError') {
          throw new Error('Request timeout - server may not be running');
        }
        throw error;
      }
      
      throw error;
    }
  }

  async get<T>(endpoint: string, params?: Record<string, any>): Promise<T> {
    const queryString = params 
      ? '?' + new URLSearchParams(params).toString()
      : '';
    return this.request<T>(`${endpoint}${queryString}`, {
      method: 'GET',
    });
  }

  async post<T>(endpoint: string, data?: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  async put<T>(endpoint: string, data?: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  async patch<T>(endpoint: string, data?: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'PATCH',
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  async delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'DELETE',
    });
  }

  // Helper method to test connection
  async testConnection(): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      const response = await this.get('/health');
      return { success: true, data: response };
    } catch (error) {
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Unknown error' 
      };
    }
  }
}

// Create and export the API client instance
export const apiClient = new ApiClient({
  baseURL: getBaseURL(),
  timeout: 30000,
});

// Export the base URL for reference
export const API_BASE_URL = getBaseURL();

// Export a function to change the base URL dynamically
export const updateApiBaseUrl = (newBaseUrl: string) => {
  // @ts-ignore - we're updating the private property for flexibility
  apiClient.baseURL = newBaseUrl;
};