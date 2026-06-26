// components/home/HomeHeader.tsx
import React from 'react';
import { View, Text, TouchableOpacity, Image } from 'react-native';
import { Ionicons, Feather } from '@expo/vector-icons';
import { useAuthStore } from '@/store/authStore';

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
  
  const displayName = getDisplayName();
  const initials = getInitials();
  const greeting = getGreeting();

  return (
    <View className="px-4 py-4 bg-white border-b border-[#E2E8F0]">
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
            <Text className="text-[#64748B] text-sm font-medium">
              {greeting} 👋
            </Text>
            <Text className="text-[#0F172A] text-xl font-bold">
              {displayName}
            </Text>
            
          </View>
        </View>

        {/* Right: Actions */}
        <View className="flex-row items-center space-x-3">
          <TouchableOpacity 
            className="w-10 h-10 rounded-full bg-[#F1F5F9] items-center justify-center"
            onPress={onSearchPress}
          >
            <Feather name="search" size={20} color="#475569" />
          </TouchableOpacity>

          <TouchableOpacity 
            className="relative w-10 h-10 rounded-full bg-[#F1F5F9] items-center justify-center"
            onPress={onNotificationPress}
          >
            <Ionicons name="notifications-outline" size={22} color="#475569" />
            {notificationCount > 0 && (
              <View className="absolute -top-1 -right-1 w-5 h-5 rounded-full bg-[#2563EB] items-center justify-center">
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