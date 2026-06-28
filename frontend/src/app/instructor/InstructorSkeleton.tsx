// components/instructor/InstructorSkeleton.tsx
import React from 'react';
import { View } from 'react-native';
import { useTheme } from '@/context/themeContext';

const InstructorSkeleton = () => {
  const { isDarkMode, colors } = useTheme();

  // Theme-based colors for skeleton
  const skeletonBg = isDarkMode ? '#1E293B' : '#E2E8F0';
  const cardBg = isDarkMode ? '#1E293B' : '#FFFFFF';
  const borderColor = isDarkMode ? '#334155' : '#E2E8F0';

  return (
    <View className="flex-1" style={{ backgroundColor: colors.background }}>
      {/* Header skeleton */}
      <View className="px-4 pt-12 pb-6 border-b" style={{
        backgroundColor: colors.backgroundElement,
        borderBottomColor: colors.backgroundSelected,
      }}>
        <View className="items-center">
          <View className="w-24 h-24 rounded-full mb-4" style={{ backgroundColor: skeletonBg }} />
          <View className="h-8 w-48 rounded mb-2" style={{ backgroundColor: skeletonBg }} />
          <View className="h-4 w-32 rounded mb-3" style={{ backgroundColor: skeletonBg }} />
          <View className="flex-row space-x-4">
            {[1, 2, 3].map((i) => (
              <View key={i} className="h-4 w-16 rounded" style={{ backgroundColor: skeletonBg }} />
            ))}
          </View>
        </View>
      </View>
      
      {/* Body skeleton */}
      <View className="p-4">
        {[1, 2, 3].map((i) => (
          <View key={i} className="rounded-xl border p-4 mb-3" style={{
            backgroundColor: colors.backgroundElement,
            borderColor: colors.backgroundSelected,
          }}>
            <View className="flex-row">
              <View className="w-20 h-20 rounded mr-3" style={{ backgroundColor: skeletonBg }} />
              <View className="flex-1">
                <View className="h-4 w-3/4 rounded mb-2" style={{ backgroundColor: skeletonBg }} />
                <View className="h-3 w-1/2 rounded" style={{ backgroundColor: skeletonBg }} />
              </View>
            </View>
          </View>
        ))}
      </View>
    </View>
  );
};

export default InstructorSkeleton;