// components/home/Achievements.tsx
import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';

interface AchievementsProps {
  achievements: {
    streak: number;
    xp: number;
    badges: number;
    nextBadge?: string;
  };
  onPress: () => void;
}

export const Achievements: React.FC<AchievementsProps> = ({
  achievements,
  onPress,
}) => {
  return (
    <TouchableOpacity
      className="bg-white rounded-2xl border border-[#E2E8F0] p-4"
      onPress={onPress}
      activeOpacity={0.8}
      style={{
        shadowColor: '#0F172A',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
        elevation: 2,
      }}
    >
      <View className="flex-row items-center justify-between">
        <View className="flex-row items-center space-x-4">
          {/* Streak */}
          <View className="items-center">
            <View className="flex-row items-center">
              <Text className="text-2xl">🔥</Text>
              <Text className="text-2xl font-bold text-[#0F172A] ml-1">
                {achievements.streak}
              </Text>
            </View>
            <Text className="text-[#64748B] text-xs">Day Streak</Text>
          </View>

          {/* XP */}
          <View className="items-center">
            <Text className="text-2xl font-bold text-[#7C3AED]">
              ⭐ {achievements.xp}
            </Text>
            <Text className="text-[#64748B] text-xs">XP Points</Text>
          </View>

          {/* Badges */}
          <View className="items-center">
            <Text className="text-2xl font-bold text-[#F59E0B]">
              🏆 {achievements.badges}
            </Text>
            <Text className="text-[#64748B] text-xs">Badges</Text>
          </View>
        </View>

        <Ionicons name="chevron-forward" size={20} color="#94A3B8" />
      </View>

      {/* Next Badge Progress */}
      {achievements.nextBadge && (
        <View className="mt-3 pt-3 border-t border-[#F1F5F9]">
          <Text className="text-[#64748B] text-xs font-medium mb-1">
            Next Badge: {achievements.nextBadge}
          </Text>
          <View className="w-full h-1.5 bg-[#F1F5F9] rounded-full overflow-hidden">
            <LinearGradient
              colors={['#2563EB', '#7C3AED']}
              className="h-full rounded-full"
              style={{ width: '65%' }}
            />
          </View>
        </View>
      )}
    </TouchableOpacity>
  );
};