// components/home/LearningProgress.tsx
import React from 'react';
import { View, Text, TouchableOpacity, Dimensions } from 'react-native';
import { Ionicons, FontAwesome } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';

interface LearningProgressProps {
  progress: {
    streak: number;
    enrolled: number;
    completed: number;
    hours: number;
    weeklyGoal: number;
    weeklyProgress: number;
  };
  onContinue: () => void;
}

export const LearningProgress: React.FC<LearningProgressProps> = ({
  progress,
  onContinue,
}) => {
  const progressPercent = Math.min(
    (progress.weeklyProgress / progress.weeklyGoal) * 100,
    100
  );

  return (
    <LinearGradient
      colors={['#2563EB', '#7C3AED']}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
      className="rounded-3xl p-5 shadow-lg"
      style={{
        shadowColor: '#2563EB',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 12,
        elevation: 8,
      }}
    >
      {/* Stats Row */}
      <View className="flex-row justify-between mb-4">
        <View className="items-center">
          <View className="flex-row items-center">
            <Text className="text-2xl font-bold text-white">🔥</Text>
            <Text className="text-2xl font-bold text-white ml-1">
              {progress.streak}
            </Text>
          </View>
          <Text className="text-white/80 text-xs mt-0.5">Day Streak</Text>
        </View>

        <View className="items-center">
          <Text className="text-2xl font-bold text-white">
            {progress.enrolled}
          </Text>
          <Text className="text-white/80 text-xs mt-0.5">Enrolled</Text>
        </View>

        <View className="items-center">
          <Text className="text-2xl font-bold text-white">
            {progress.completed}
          </Text>
          <Text className="text-white/80 text-xs mt-0.5">Completed</Text>
        </View>

        <View className="items-center">
          <Text className="text-2xl font-bold text-white">
            {progress.hours}
          </Text>
          <Text className="text-white/80 text-xs mt-0.5">Hours</Text>
        </View>
      </View>

      {/* Weekly Goal Progress */}
      <View className="mb-4">
        <View className="flex-row justify-between items-center mb-1.5">
          <Text className="text-white text-sm font-medium">
            Weekly Goal
          </Text>
          <Text className="text-white/90 text-sm font-medium">
            {progress.weeklyProgress} / {progress.weeklyGoal} Hours
          </Text>
        </View>
        <View className="w-full h-2 bg-white/20 rounded-full overflow-hidden">
          <View 
            className="h-full bg-white rounded-full"
            style={{ width: `${progressPercent}%` }}
          />
        </View>
      </View>

      {/* Continue Button */}
      <TouchableOpacity
        className="bg-white/20 backdrop-blur-sm py-3.5 rounded-2xl border border-white/20"
        onPress={onContinue}
        activeOpacity={0.8}
      >
        <Text className="text-white text-center font-bold text-base">
          Continue Learning 🚀
        </Text>
      </TouchableOpacity>
    </LinearGradient>
  );
};