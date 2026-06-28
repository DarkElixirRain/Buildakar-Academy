// components/home/HomeHeader.tsx
import React from 'react';
import { View, Text, TouchableOpacity, Image } from 'react-native';
import { Ionicons, Feather } from '@expo/vector-icons';
import { useAuthStore } from '@/store/authStore';
import { useTheme } from '@/context/themeContext';

interface HomeHeaderProps {
  notificationCount: number;
  onNotificationPress: () => void;
  onProfilePress?: () => void;
  onSearchPress?: () => void;
}

export const HomeHeader: React.FC<HomeHeaderProps> = ({
  notificationCount,
  onNotificationPress,
  onProfilePress,
  onSearchPress,
}) => {
  const { user, isAuthenticated, getDisplayName, getInitials } = useAuthStore();
  const { isDarkMode, colors } = useTheme();
  
  const displayName = getDisplayName();
  const initials = getInitials();
  const greeting = getGreeting();

  return (
    <View style={{
      paddingHorizontal: 16,
      paddingVertical: 16,
      borderBottomWidth: 1,
      backgroundColor: colors.background,
      borderBottomColor: colors.backgroundElement,
    }}>
      <View className="flex-row items-center justify-between">
        {/* Left: Avatar and Greeting */}
        <View className="flex-row items-center space-x-3">
          <TouchableOpacity 
            className="w-12 h-12 rounded-full bg-gradient-to-br from-[#2563EB] to-[#7C3AED] items-center justify-center"
            onPress={onProfilePress}
          >
            {user?.avatar ? (
              <Image 
                source={{ uri: user.avatar }} 
                className="w-12 h-12 rounded-full"
              />
            ) : (
              <Text className="text-white font-bold text-lg">
                {initials}
              </Text>
            )}
          </TouchableOpacity>

          <View>
            <Text style={{ 
              fontSize: 14, 
              fontWeight: '500', 
              color: colors.textSecondary 
            }}>
              {greeting} 👋
            </Text>
            <Text style={{ 
              fontSize: 20, 
              fontWeight: 'bold', 
              color: colors.text 
            }}>
              {displayName}
            </Text>
          </View>
        </View>

        {/* Right: Actions */}
        <View className="flex-row items-center space-x-3">
          <TouchableOpacity 
            style={{
              width: 40,
              height: 40,
              borderRadius: 20,
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: colors.backgroundElement,
            }}
            onPress={onSearchPress}
          >
            <Feather name="search" size={20} color={colors.textSecondary} />
          </TouchableOpacity>

          <TouchableOpacity 
            style={{
              width: 40,
              height: 40,
              borderRadius: 20,
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: colors.backgroundElement,
              position: 'relative',
            }}
            onPress={onNotificationPress}
          >
            <Ionicons name="notifications-outline" size={22} color={colors.textSecondary} />
            {notificationCount > 0 && (
              <View style={{
                position: 'absolute',
                top: -4,
                right: -4,
                width: 20,
                height: 20,
                borderRadius: 10,
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: colors.primary,
              }}>
                <Text className="text-white text-xs font-bold">
                  {notificationCount > 9 ? '9+' : notificationCount}
                </Text>
              </View>
            )}
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
};

function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}