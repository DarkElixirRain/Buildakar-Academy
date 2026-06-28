// app/(tabs)/setting/index.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  Image,
  Switch,
  SafeAreaView,
  Alert,
  Share,
  Linking,
  Platform,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Updates from 'expo-updates';
import { useAuthStore } from '@/store/authStore';
import { useTheme } from '@/context/themeContext';
import { useHomeStore } from '@/store/homeStore';

// Types
interface SettingItem {
  id: string;
  icon: keyof typeof Ionicons.glyphMap;
  label: string;
  value?: string | boolean;
  type: 'toggle' | 'button' | 'link' | 'navigation';
  onPress?: () => void;
  onToggle?: (value: boolean) => void;
  destructive?: boolean;
  badge?: string | number;
}

interface Section {
  id: string;
  title: string;
  items: SettingItem[];
}

export default function SettingsPage() {
  const insets = useSafeAreaInsets();
  const { user, logout, getDisplayName, getInitials } = useAuthStore();
  const { isDarkMode, colors, toggleTheme, setTheme } = useTheme();
  const { reset: resetHomeStore } = useHomeStore();
  
  const [notifications, setNotifications] = useState(true);
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [autoPlay, setAutoPlay] = useState(false);
  const [offlineMode, setOfflineMode] = useState(false);
  const [language, setLanguage] = useState('English');
  const [isLoading, setIsLoading] = useState(false);

  // Get user display name and initials
  const displayName = getDisplayName();
  const initials = getInitials();

  // Handle logout
  const handleLogout = async () => {
    Alert.alert(
      'Logout',
      'Are you sure you want to logout?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Logout',
          style: 'destructive',
          onPress: async () => {
            try {
              await logout();
              resetHomeStore();
              router.replace('/(auth)/login');
            } catch (error) {
              Alert.alert('Error', 'Failed to logout. Please try again.');
            }
          },
        },
      ],
      { cancelable: true }
    );
  };

  // Handle clear cache
  const handleClearCache = () => {
    Alert.alert(
      'Clear Cache',
      'This will clear all cached data. Are you sure?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Clear',
          style: 'destructive',
          onPress: async () => {
            try {
              // Clear app cache
              if (Platform.OS === 'web') {
                localStorage.clear();
              }
              // Reset home store
              resetHomeStore();
              Alert.alert('Success', 'Cache cleared successfully');
            } catch (error) {
              Alert.alert('Error', 'Failed to clear cache');
            }
          },
        },
      ]
    );
  };

  // Handle share app
  const handleShareApp = async () => {
    try {
      await Share.share({
        message: 'Check out this amazing learning platform! 🚀\n\nDownload now and start learning: [App Link]',
        url: 'https://your-app-link.com',
        title: 'Share Learning Platform',
      });
    } catch (error) {
      console.error('Error sharing app:', error);
    }
  };

  // Handle rate app
  const handleRateApp = () => {
    const storeUrl = Platform.select({
      ios: 'https://apps.apple.com/app/id123456789',
      android: 'market://details?id=com.yourapp.learning',
      web: 'https://your-website.com',
    });
    Linking.openURL(storeUrl || 'https://your-website.com');
  };

  // Handle privacy policy
  const handlePrivacyPolicy = () => {
    Linking.openURL('https://your-website.com/privacy');
  };

  // Handle terms of service
  const handleTermsOfService = () => {
    Linking.openURL('https://your-website.com/terms');
  };

  // Handle help & support
  const handleHelpSupport = () => {
    router.push('/support' as any);
  };

  // Handle about
  const handleAbout = () => {
    router.push('/about' as any);
  };

  // Handle language selection
  const handleLanguageSelect = () => {
    Alert.alert(
      'Select Language',
      'Choose your preferred language',
      [
        { text: 'English', onPress: () => setLanguage('English') },
        { text: 'Spanish', onPress: () => setLanguage('Spanish') },
        { text: 'French', onPress: () => setLanguage('French') },
        { text: 'German', onPress: () => setLanguage('German') },
        { text: 'Chinese', onPress: () => setLanguage('Chinese') },
        { text: 'Hindi', onPress: () => setLanguage('Hindi') },
        { text: 'Cancel', style: 'cancel' },
      ]
    );
  };

  // Handle check for updates
  const handleCheckUpdates = async () => {
    if (Platform.OS === 'web') {
      Alert.alert('Info', 'Updates are available automatically on web');
      return;
    }
    
    try {
      setIsLoading(true);
      const update = await Updates.checkForUpdateAsync();
      if (update.isAvailable) {
        Alert.alert(
          'Update Available',
          'A new version is available. Would you like to update now?',
          [
            { text: 'Later', style: 'cancel' },
            {
              text: 'Update',
              onPress: async () => {
                await Updates.fetchUpdateAsync();
                await Updates.reloadAsync();
              },
            },
          ]
        );
      } else {
        Alert.alert('No Updates', 'You are using the latest version');
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to check for updates');
    } finally {
      setIsLoading(false);
    }
  };

  // Settings sections
  const sections: Section[] = [
    {
      id: 'preferences',
      title: 'Preferences',
      items: [
        {
          id: 'theme',
          icon: isDarkMode ? 'moon' : 'sunny',
          label: 'Dark Mode',
          type: 'toggle',
          value: isDarkMode,
          onToggle: toggleTheme,
        },
        {
          id: 'language',
          icon: 'language',
          label: 'Language',
          value: language,
          type: 'button',
          onPress: handleLanguageSelect,
        },
        {
          id: 'notifications',
          icon: 'notifications',
          label: 'Push Notifications',
          type: 'toggle',
          value: notifications,
          onToggle: setNotifications,
        },
        {
          id: 'sound',
          icon: 'volume-high',
          label: 'Sound Effects',
          type: 'toggle',
          value: soundEnabled,
          onToggle: setSoundEnabled,
        },
        {
          id: 'autoplay',
          icon: 'play-circle',
          label: 'Auto-Play Videos',
          type: 'toggle',
          value: autoPlay,
          onToggle: setAutoPlay,
        },
        {
          id: 'offline',
          icon: 'cloud-download',
          label: 'Offline Mode',
          type: 'toggle',
          value: offlineMode,
          onToggle: setOfflineMode,
        },
      ],
    },
    {
      id: 'account',
      title: 'Account',
      items: [
        {
          id: 'profile',
          icon: 'person-circle',
          label: 'Edit Profile',
          type: 'navigation',
          onPress: () => router.push('/profile/edit' as any),
        },
        {
          id: 'security',
          icon: 'shield-checkmark',
          label: 'Privacy & Security',
          type: 'navigation',
          onPress: () => router.push('/security' as any),
        },
        {
          id: 'notifications_settings',
          icon: 'notifications-circle',
          label: 'Notification Settings',
          type: 'navigation',
          onPress: () => router.push('/notifications-settings' as any),
        },
        {
          id: 'change_password',
          icon: 'key',
          label: 'Change Password',
          type: 'navigation',
          onPress: () => router.push('/change-password' as any),
        },
      ],
    },
    {
      id: 'support',
      title: 'Support',
      items: [
        {
          id: 'help',
          icon: 'help-circle',
          label: 'Help & Support',
          type: 'navigation',
          onPress: handleHelpSupport,
        },
        {
          id: 'feedback',
          icon: 'chatbubbles',
          label: 'Send Feedback',
          type: 'navigation',
          onPress: () => router.push('/feedback' as any),
        },
        {
          id: 'report',
          icon: 'flag',
          label: 'Report a Problem',
          type: 'navigation',
          onPress: () => router.push('/report' as any),
        },
        {
          id: 'faq',
          icon: 'information-circle',
          label: 'FAQ',
          type: 'navigation',
          onPress: () => router.push('/faq' as any),
        },
      ],
    },
    {
      id: 'app',
      title: 'App',
      items: [
        {
          id: 'cache',
          icon: 'trash',
          label: 'Clear Cache',
          type: 'button',
          onPress: handleClearCache,
          destructive: true,
        },
        {
          id: 'updates',
          icon: 'cloud-upload',
          label: 'Check for Updates',
          type: 'button',
          onPress: handleCheckUpdates,
          badge: isLoading ? '...' : undefined,
        },
        {
          id: 'rate',
          icon: 'star',
          label: 'Rate App',
          type: 'button',
          onPress: handleRateApp,
        },
        {
          id: 'share',
          icon: 'share-social',
          label: 'Share App',
          type: 'button',
          onPress: handleShareApp,
        },
        {
          id: 'about',
          icon: 'information-circle',
          label: 'About',
          type: 'navigation',
          onPress: handleAbout,
        },
      ],
    },
    {
      id: 'legal',
      title: 'Legal',
      items: [
        {
          id: 'privacy',
          icon: 'document-text',
          label: 'Privacy Policy',
          type: 'link',
          onPress: handlePrivacyPolicy,
        },
        {
          id: 'terms',
          icon: 'document',
          label: 'Terms of Service',
          type: 'link',
          onPress: handleTermsOfService,
        },
        {
          id: 'cookies',
          icon: 'document-text',
          label: 'Cookie Policy',
          type: 'link',
          onPress: () => Linking.openURL('https://your-website.com/cookies'),
        },
      ],
    },
  ];

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <StatusBar style={isDarkMode ? 'light' : 'dark'} />

      {/* Header */}
      <View style={{
        paddingHorizontal: 16,
        paddingVertical: 12,
        backgroundColor: colors.backgroundElement,
        borderBottomWidth: 1,
        borderBottomColor: colors.backgroundSelected,
      }}>
        <View className="flex-row items-center">
          <TouchableOpacity
            onPress={() => router.back()}
            style={{
              width: 40,
              height: 40,
              borderRadius: 20,
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: colors.backgroundSelected,
            }}
          >
            <Ionicons name="chevron-back" size={24} color={colors.text} />
          </TouchableOpacity>
          <Text style={{
            flex: 1,
            textAlign: 'center',
            fontSize: 18,
            fontWeight: 'bold',
            color: colors.text,
          }}>
            Settings
          </Text>
          <View className="w-10" />
        </View>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{
          paddingBottom: insets.bottom + 20,
        }}
      >
        {/* User Profile Section */}
        <View style={{
          marginHorizontal: 16,
          marginTop: 16,
          padding: 16,
          borderRadius: 16,
          backgroundColor: colors.backgroundElement,
          shadowColor: colors.text,
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: isDarkMode ? 0.1 : 0.05,
          shadowRadius: 8,
          elevation: 3,
        }}>
          <View className="flex-row items-center">
            {/* Avatar */}
            <TouchableOpacity 
              style={{
                width: 64,
                height: 64,
                borderRadius: 32,
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: isDarkMode ? colors.backgroundSelected : colors.backgroundSelected,
              }}
              onPress={() => router.push('/profile/edit' as any)}
            >
              {user?.avatar ? (
                <Image 
                  source={{ uri: user.avatar }} 
                  style={{ width: 64, height: 64, borderRadius: 32 }}
                />
              ) : (
                <Text style={{ color: colors.text, fontSize: 24, fontWeight: 'bold' }}>
                  {initials}
                </Text>
              )}
            </TouchableOpacity>

            {/* User Info */}
            <View className="ml-4 flex-1">
              <Text style={{ fontSize: 18, fontWeight: 'bold', color: colors.text }}>
                {displayName}
              </Text>
              <Text style={{ fontSize: 14, color: colors.textSecondary }}>
                {user?.email || 'user@email.com'}
              </Text>
            </View>

            <TouchableOpacity
              onPress={() => router.push('/profile/edit' as any)}
              style={{
                paddingHorizontal: 12,
                paddingVertical: 8,
                borderRadius: 8,
                backgroundColor: colors.backgroundSelected,
              }}
            >
              <Text style={{ fontSize: 14, fontWeight: '500', color: colors.text }}>
                Edit
              </Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Settings Sections */}
        {sections.map((section) => (
          <View key={section.id} className="mt-6">
            <Text style={{
              paddingHorizontal: 16,
              fontSize: 12,
              fontWeight: '600',
              textTransform: 'uppercase',
              letterSpacing: 0.5,
              color: colors.textSecondary,
            }}>
              {section.title}
            </Text>
            <View style={{
              marginHorizontal: 16,
              marginTop: 8,
              borderRadius: 16,
              overflow: 'hidden',
              backgroundColor: colors.backgroundElement,
            }}>
              {section.items.map((item, index) => {
                const isLast = index === section.items.length - 1;
                const IconComponent = Ionicons;
                
                return (
                  <TouchableOpacity
                    key={item.id}
                    onPress={item.type !== 'toggle' ? item.onPress : undefined}
                    disabled={item.type === 'toggle'}
                    style={{
                      flexDirection: 'row',
                      alignItems: 'center',
                      paddingHorizontal: 16,
                      paddingVertical: 14,
                      borderBottomWidth: !isLast ? 1 : 0,
                      borderBottomColor: colors.backgroundSelected,
                    }}
                    activeOpacity={item.type === 'toggle' ? 1 : 0.7}
                  >
                    <View className="w-8">
                      <IconComponent
                        name={item.icon}
                        size={22}
                        color={item.destructive ? '#EF4444' : colors.textSecondary}
                      />
                    </View>
                    
                    <View className="flex-1">
                      <Text style={{
                        fontSize: 16,
                        color: item.destructive ? '#EF4444' : colors.text,
                      }}>
                        {item.label}
                      </Text>
                    </View>

                    {/* Right Side Content */}
                    <View className="flex-row items-center">
                      {item.badge && (
                        <View style={{
                          marginRight: 8,
                          paddingHorizontal: 8,
                          paddingVertical: 2,
                          borderRadius: 12,
                          backgroundColor: colors.text,
                        }}>
                          <Text style={{ color: colors.background, fontSize: 12 }}>{item.badge}</Text>
                        </View>
                      )}
                      
                      {item.value && item.type === 'button' && (
                        <Text style={{
                          fontSize: 14,
                          marginRight: 8,
                          color: colors.textSecondary,
                        }}>
                          {item.value}
                        </Text>
                      )}

                      {item.type === 'toggle' && (
                        <Switch
                          value={item.value as boolean}
                          onValueChange={item.onToggle}
                          trackColor={{ false: '#CBD5E1', true: colors.text }}
                          thumbColor={Platform.OS === 'ios' ? '#FFFFFF' : (item.value as boolean ? '#FFFFFF' : '#F4F3F4')}
                          ios_backgroundColor="#CBD5E1"
                        />
                      )}

                      {(item.type === 'button' || item.type === 'link' || item.type === 'navigation') && (
                        <Ionicons
                          name={item.type === 'link' ? 'open-outline' : 'chevron-forward'}
                          size={20}
                          color={colors.textSecondary}
                        />
                      )}
                    </View>
                  </TouchableOpacity>
                );
              })}
            </View>
          </View>
        ))}

        {/* Version Info */}
        <View className="items-center mt-8 mb-4">
          <Text style={{ fontSize: 12, color: colors.textSecondary }}>
            Version 1.0.0
          </Text>
          <Text style={{ fontSize: 12, color: colors.textSecondary }}>
            Built with ❤️
          </Text>
        </View>

        {/* Logout Button */}
        <TouchableOpacity
          onPress={handleLogout}
          style={{
            marginHorizontal: 16,
            marginTop: 16,
            padding: 16,
            borderRadius: 16,
            backgroundColor: '#FEE2E2',
            borderWidth: 1,
            borderColor: '#FECACA',
          }}
          activeOpacity={0.7}
        >
          <View className="flex-row items-center justify-center">
            <Ionicons name="log-out-outline" size={22} color="#DC2626" />
            <Text style={{ marginLeft: 8, color: '#DC2626', fontWeight: '600', fontSize: 16 }}>
              Logout
            </Text>
          </View>
        </TouchableOpacity>

        {/* Delete Account Button */}
        <TouchableOpacity
          onPress={() => {
            Alert.alert(
              'Delete Account',
              'Are you sure you want to delete your account? This action cannot be undone.',
              [
                { text: 'Cancel', style: 'cancel' },
                {
                  text: 'Delete',
                  style: 'destructive',
                  onPress: () => {
                    Alert.alert('Account Deleted', 'Your account has been deleted successfully');
                  },
                },
              ]
            );
          }}
          style={{
            marginHorizontal: 16,
            marginTop: 8,
            padding: 12,
            borderRadius: 16,
          }}
          activeOpacity={0.7}
        >
          <View className="flex-row items-center justify-center">
            <Text style={{ color: '#EF4444', fontSize: 14, fontWeight: '500' }}>
              Delete Account
            </Text>
          </View>
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
}