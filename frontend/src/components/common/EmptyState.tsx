// components/common/EmptyState.tsx
import React from 'react';
import { View, Text, TouchableOpacity, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface EmptyStateProps {
  title: string;
  description: string;
  buttonText: string;
  onPress: () => void;
  icon?: string;
}

export const EmptyState: React.FC<EmptyStateProps> = ({
  title,
  description,
  buttonText,
  onPress,
  icon = 'school-outline',
}) => {
  return (
    <View className="flex-1 items-center justify-center p-6">
      <View className="w-24 h-24 rounded-full bg-[#2563EB]/10 items-center justify-center mb-6">
        <Ionicons name={icon as any} size={48} color="#2563EB" />
      </View>
      <Text className="text-[#0F172A] text-2xl font-bold text-center mb-2">
        {title}
      </Text>
      <Text className="text-[#64748B] text-center mb-8 max-w-xs">
        {description}
      </Text>
      <TouchableOpacity
        className="bg-[#2563EB] px-8 py-3 rounded-xl"
        onPress={onPress}
        activeOpacity={0.7}
      >
        <Text className="text-white font-bold text-base">
          {buttonText}
        </Text>
      </TouchableOpacity>
    </View>
  );
};