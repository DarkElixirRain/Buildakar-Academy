// components/common/ErrorState.tsx
import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface ErrorStateProps {
  message: string;
  onRetry: () => void;
}

export const ErrorState: React.FC<ErrorStateProps> = ({ message, onRetry }) => {
  return (
    <View className="flex-1 items-center justify-center p-6">
      <View className="w-20 h-20 rounded-full bg-red-50 items-center justify-center mb-4">
        <Ionicons name="cloud-offline" size={40} color="#EF4444" />
      </View>
      <Text className="text-[#0F172A] text-xl font-bold text-center mb-2">
        Oops! Something went wrong
      </Text>
      <Text className="text-[#64748B] text-center mb-6 max-w-xs">
        {message || 'Unable to load content. Please try again.'}
      </Text>
      <TouchableOpacity
        className="bg-[#2563EB] px-8 py-3 rounded-xl"
        onPress={onRetry}
        activeOpacity={0.7}
      >
        <Text className="text-white font-bold text-base">
          Try Again
        </Text>
      </TouchableOpacity>
    </View>
  );
};