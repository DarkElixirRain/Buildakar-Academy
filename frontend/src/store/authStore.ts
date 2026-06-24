import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface User {
  id: string;
  email: string;
  name?: string;
}

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  loading: boolean;
  initialized: boolean;
  login: (email: string, name?: string) => Promise<void>;
  signup: (email: string, name: string) => Promise<void>;
  logout: () => Promise<void>;
  setLoading: (loading: boolean) => void;
  initialize: () => Promise<void>;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      loading: false,
      initialized: false,
      login: async (email, name) => {
        set({ loading: true });
        // Simulate API call delay
        await new Promise((resolve) => setTimeout(resolve, 1500));
        set({
          user: { id: 'user_' + Date.now(), email, name: name || 'John Doe' },
          isAuthenticated: true,
          loading: false,
        });
      },
      signup: async (email, name) => {
        set({ loading: true });
        // Simulate API call delay
        await new Promise((resolve) => setTimeout(resolve, 1500));
        set({
          user: { id: 'user_' + Date.now(), email, name },
          isAuthenticated: true,
          loading: false,
        });
      },
      logout: async () => {
        set({ loading: true });
        await new Promise((resolve) => setTimeout(resolve, 500));
        set({ user: null, isAuthenticated: false, loading: false });
      },
      setLoading: (loading) => set({ loading }),
      initialize: async () => {
        // Hydration automatically takes care of loading state from AsyncStorage,
        // but we set initialized to true to indicate the app can start redirecting.
        set({ initialized: true });
      },
    }),
    {
      name: 'buildakar-auth-store',
      storage: createJSONStorage(() => AsyncStorage),
      onRehydrateStorage: () => (state) => {
        if (state) {
          state.initialize();
        }
      },
    }
  )
);
