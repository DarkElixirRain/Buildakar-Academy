// store/authStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { Platform } from 'react-native';
import api from '@/lib/api';

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

interface User {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  avatar?: string;
  role?: 'STUDENT' | 'INSTRUCTOR' | 'ADMIN';
  isVerified?: boolean;
  isActive?: boolean;
  hasCompletedOnboarding?: boolean;
  createdAt: string;
  updatedAt?: string;
}

type SignupRole = 'STUDENT' | 'INSTRUCTOR';

interface LoginResponse {
  user: User;
  token: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  loading: boolean;
  initialized: boolean;
  requiresRoleSelection: boolean;
  login: (email: string, password: string) => Promise<LoginResponse>;
  signup: (
    email: string,
    firstName: string,
    lastName: string,
    password: string,
    role?: SignupRole
  ) => Promise<LoginResponse>;
  updateRole: (role: SignupRole) => Promise<User>;
  logout: () => Promise<void>;
  checkAuth: () => Promise<void>;
  refreshUser: () => Promise<User | null>;
  setUser: (user: User | null) => void;
  setInitialized: () => void;
  setPendingRoleSelection: (value: boolean) => void;
  clearAuth: () => void;
  getDisplayName: () => string;
  getInitials: () => string;
  getFullName: () => string;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      loading: false,
      initialized: false,
      requiresRoleSelection: false,

      login: async (email: string, password: string): Promise<LoginResponse> => {
        set({ loading: true });

        try {
          const response = await api.post('/api/auth/login', { email, password });

          if (response.data.success) {
            const { user, token } = response.data.data;

            set({
              user,
              token,
              isAuthenticated: true,
              loading: false,
              initialized: true,
              requiresRoleSelection: false,
            });

            return { user, token };
          }

          set({ loading: false });
          throw new Error(response.data.message || 'Login failed');
        } catch (error: any) {
          set({ loading: false });
          const errorMessage =
            error.response?.data?.message || error.message || 'Login failed. Please try again.';
          throw new Error(errorMessage);
        }
      },

      signup: async (
        email: string,
        firstName: string,
        lastName: string,
        password: string
      ): Promise<LoginResponse> => {
        set({ loading: true });

        try {
          const response = await api.post('/api/auth/register', {
            email,
            firstName,
            lastName,
            password,
          });

          if (response.data.success) {
            const { user, token } = response.data.data;

            set({
              user,
              token,
              isAuthenticated: true,
              loading: false,
              initialized: true,
              requiresRoleSelection: true,
            });

            return { user, token };
          }

          set({ loading: false });
          throw new Error(response.data.message || 'Signup failed');
        } catch (error: any) {
          set({ loading: false });
          const errorMessage =
            error.response?.data?.message || error.message || 'Signup failed. Please try again.';
          throw new Error(errorMessage);
        }
      },

      logout: async () => {
        set({ loading: true });

        try {
          const { token } = get();
          if (token) {
            try {
              await api.post(
                '/api/auth/logout',
                {},
                {
                  headers: { Authorization: `Bearer ${token}` },
                }
              );
            } catch (error: any) {
              if (error.response?.status === 404) {
                // Continue with client-side logout
              }
            }
          }
        } catch (error) {
          // Ignore errors during logout
        }

        set({
          user: null,
          token: null,
          isAuthenticated: false,
          loading: false,
          initialized: true,
          requiresRoleSelection: false,
        });

        try {
          const storage = getStorage();
          await storage.removeItem('auth-storage');
        } catch (error) {
          // Ignore storage errors
        }
      },

      clearAuth: () => {
        set({
          user: null,
          token: null,
          isAuthenticated: false,
          loading: false,
          initialized: true,
          requiresRoleSelection: false,
        });

        try {
          const storage = getStorage();
          storage.removeItem('auth-storage').catch(() => {});
        } catch (error) {
          // Ignore storage errors
        }
      },

      checkAuth: async (): Promise<void> => {
        const { token, isAuthenticated } = get();

        if (token && isAuthenticated) {
          try {
            const response = await api.get('/api/auth/me', {
              headers: { Authorization: `Bearer ${token}` },
            });

            if (response.data.success) {
              set({
                user: response.data.data,
                isAuthenticated: true,
                initialized: true,
                requiresRoleSelection: get().requiresRoleSelection,
              });
              return;
            }
          } catch (error) {
            set({
              user: null,
              token: null,
              isAuthenticated: false,
              initialized: true,
              requiresRoleSelection: false,
            });
            try {
              const storage = getStorage();
              await storage.removeItem('auth-storage');
            } catch {
              // Ignore storage errors
            }
          }
        } else if (token) {
          try {
            const response = await api.get('/api/auth/me', {
              headers: { Authorization: `Bearer ${token}` },
            });

            if (response.data.success) {
              set({
                user: response.data.data,
                isAuthenticated: true,
                initialized: true,
                requiresRoleSelection: get().requiresRoleSelection,
              });
              return;
            }
          } catch (error) {
            set({
              user: null,
              token: null,
              isAuthenticated: false,
              initialized: true,
              requiresRoleSelection: false,
            });
            try {
              const storage = getStorage();
              await storage.removeItem('auth-storage');
            } catch {
              // Ignore storage errors
            }
          }
        }

        set({
          user: null,
          token: null,
          isAuthenticated: false,
          initialized: true,
          requiresRoleSelection: false,
        });
      },

      refreshUser: async (): Promise<User | null> => {
        const { token } = get();

        if (!token) {
          return null;
        }

        try {
          const response = await api.get('/api/auth/me', {
            headers: { Authorization: `Bearer ${token}` },
          });

          if (response.data.success) {
            const user = response.data.data;
            set({ user });
            return user;
          }

          return null;
        } catch {
          return null;
        }
      },

      setUser: (user: User | null) => {
        set({ user });
      },

      setInitialized: () => {
        set({ initialized: true });
      },

      setPendingRoleSelection: (value: boolean) => {
        set({ requiresRoleSelection: value });
      },

      updateRole: async (role: SignupRole): Promise<User> => {
        const { token } = get();
        
        if (!token) {
          throw new Error('Not authenticated');
        }

        set({ loading: true });

        try {
          const response = await api.put('/api/auth/role', { role }, {
            headers: { Authorization: `Bearer ${token}` },
          });

          if (response.data.success) {
            const user = response.data.data;
            
            set({
              user,
              loading: false,
              requiresRoleSelection: false,
            });
            
            return user;
          }

          set({ loading: false });
          throw new Error(response.data.message || 'Failed to update role');
        } catch (error: any) {
          set({ loading: false });
          const errorMessage =
            error.response?.data?.message || error.message || 'Failed to update role. Please try again.';
          throw new Error(errorMessage);
        }
      },

      getDisplayName: (): string => {
        const { user, isAuthenticated } = get();
        if (!isAuthenticated || !user) return 'Guest';

        if (user.firstName && user.lastName) {
          return `${user.firstName} ${user.lastName}`;
        }
        if (user.firstName) {
          return user.firstName;
        }
        return user.email?.split('@')[0] || 'User';
      },

      getInitials: (): string => {
        const { user, isAuthenticated } = get();
        if (!isAuthenticated || !user) return '?';

        if (user.firstName && user.lastName) {
          return (user.firstName[0] + user.lastName[0]).toUpperCase();
        }
        if (user.firstName) {
          return user.firstName.slice(0, 2).toUpperCase();
        }
        if (user.email) {
          return user.email[0].toUpperCase();
        }

        return '?';
      },

      getFullName: (): string => {
        const { user, isAuthenticated } = get();
        if (!isAuthenticated || !user) return '';

        if (user.firstName && user.lastName) {
          return `${user.firstName} ${user.lastName}`;
        }
        if (user.firstName) {
          return user.firstName;
        }
        return user.email?.split('@')[0] || '';
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => getStorage()),
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        isAuthenticated: state.isAuthenticated,
        requiresRoleSelection: state.requiresRoleSelection,
      }),
    }
  )
);
