// components/instructor/InstructorSkeleton.tsx
import React from 'react';
import { View } from 'react-native';

export const InstructorSkeleton = () => {
  return (
    <View className="bg-[#F8FAFC] flex-1">
      {/* Header skeleton */}
      <View className="bg-white px-4 pt-12 pb-6 border-b border-[#E2E8F0]">
        <View className="items-center">
          <View className="w-24 h-24 rounded-full bg-gray-200 mb-4" />
          <View className="h-8 w-48 bg-gray-200 rounded mb-2" />
          <View className="h-4 w-32 bg-gray-200 rounded mb-3" />
          <View className="flex-row space-x-4">
            {[1, 2, 3].map((i) => (
              <View key={i} className="h-4 w-16 bg-gray-200 rounded" />
            ))}
          </View>
        </View>
      </View>
      
      {/* Body skeleton */}
      <View className="p-4">
        {[1, 2, 3].map((i) => (
          <View key={i} className="bg-white rounded-xl border border-[#E2E8F0] p-4 mb-3">
            <View className="flex-row">
              <View className="w-20 h-20 bg-gray-200 rounded mr-3" />
              <View className="flex-1">
                <View className="h-4 w-3/4 bg-gray-200 rounded mb-2" />
                <View className="h-3 w-1/2 bg-gray-200 rounded" />
              </View>
            </View>
          </View>
        ))}
      </View>
    </View>
  );
};