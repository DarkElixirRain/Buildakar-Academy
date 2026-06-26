import AsyncStorage from '@react-native-async-storage/async-storage';

const TOKEN_KEY = 'auth-storage';

interface AuthData {
  state: {
    user: any;
    token: string | null;
    isAuthenticated: boolean;
  };
}

export const tokenManager = {
  getToken: async (): Promise<string | null> => {
    try {
      const stored = await AsyncStorage.getItem(TOKEN_KEY);
      if (!stored) return null;
      const data: AuthData = JSON.parse(stored);
      return data.state?.token || null;
    } catch (error) {
      console.log('Error getting token:', error);
      return null;
    }
  },

  setToken: async (token: string): Promise<void> => {
    try {
      const stored = await AsyncStorage.getItem(TOKEN_KEY);
      if (stored) {
        const data: AuthData = JSON.parse(stored);
        data.state.token = token;
        await AsyncStorage.setItem(TOKEN_KEY, JSON.stringify(data));
      }
    } catch (error) {
      console.log('Error setting token:', error);
    }
  },

  removeToken: async (): Promise<void> => {
    try {
      const stored = await AsyncStorage.getItem(TOKEN_KEY);
      if (stored) {
        const data: AuthData = JSON.parse(stored);
        data.state.token = null;
        data.state.isAuthenticated = false;
        await AsyncStorage.setItem(TOKEN_KEY, JSON.stringify(data));
      }
    } catch (error) {
      console.log('Error removing token:', error);
    }
  },

  getStoredAuth: async (): Promise<AuthData | null> => {
    try {
      const stored = await AsyncStorage.getItem(TOKEN_KEY);
      if (!stored) return null;
      return JSON.parse(stored);
    } catch (error) {
      console.log('Error getting stored auth:', error);
      return null;
    }
  }
};