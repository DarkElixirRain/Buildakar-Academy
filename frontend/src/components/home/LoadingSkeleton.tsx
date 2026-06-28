// components/home/LoadingSkeleton.tsx
import React from 'react';
import { View, ScrollView, Dimensions } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import Animated, { 
  useAnimatedStyle, 
  withRepeat, 
  withTiming,
  useSharedValue,
  withSequence,
} from 'react-native-reanimated';
import { useEffect } from 'react';
import { useTheme } from '@/context/themeContext';

const { width } = Dimensions.get('window');

const SkeletonItem: React.FC<{ 
  height: number; 
  width?: number; 
  className?: string;
  bgColor?: string;
}> = ({ 
  height, 
  width,
  className = '',
  bgColor = '#E2E8F0',
}) => {
  const opacity = useSharedValue(0.3);

  useEffect(() => {
    opacity.value = withRepeat(
      withSequence(
        withTiming(0.7, { duration: 800 }),
        withTiming(0.3, { duration: 800 })
      ),
      -1,
      true
    );
  }, []);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
  }));

  return (
    <Animated.View
      className={`rounded-xl ${className} ${width === undefined ? 'w-full' : ''}`}
      style={[
        animatedStyle,
        { 
          height, 
          backgroundColor: bgColor,
          ...(width !== undefined ? { width } : {}),
        },
      ]}
    />
  );
};

export const LoadingSkeleton: React.FC = () => {
  const { isDarkMode, colors } = useTheme();
  
  // Theme-based colors
  const bgColor = isDarkMode ? colors.background : colors.background;
  const skeletonBgColor = isDarkMode ? colors.backgroundElement : '#E2E8F0';

  return (
    <ScrollView 
      style={{
        flex: 1,
        paddingHorizontal: 16,
        paddingTop: 16,
        backgroundColor: bgColor,
      }}
      showsVerticalScrollIndicator={false}
      contentContainerStyle={{ paddingBottom: 80 }}
    >
      {/* Header Skeleton */}
      <View className="flex-row items-center justify-between mb-6">
        <View className="flex-row items-center space-x-3">
          <SkeletonItem 
            height={48} 
            width={48} 
            className="rounded-full" 
            bgColor={skeletonBgColor}
          />
          <View>
            <SkeletonItem 
              height={16} 
              width={100} 
              className="mb-1" 
              bgColor={skeletonBgColor}
            />
            <SkeletonItem 
              height={24} 
              width={120} 
              bgColor={skeletonBgColor}
            />
          </View>
        </View>
        <View className="flex-row space-x-3">
          <SkeletonItem 
            height={40} 
            width={40} 
            className="rounded-full" 
            bgColor={skeletonBgColor}
          />
          <SkeletonItem 
            height={40} 
            width={40} 
            className="rounded-full" 
            bgColor={skeletonBgColor}
          />
        </View>
      </View>

      {/* Search Bar Skeleton */}
      <SkeletonItem 
        height={48} 
        className="rounded-2xl mb-6" 
        bgColor={skeletonBgColor}
      />

      {/* Learning Progress Skeleton */}
      <SkeletonItem 
        height={180} 
        className="rounded-3xl mb-6" 
        bgColor={skeletonBgColor}
      />

      {/* Continue Learning Skeleton */}
      <View className="mb-4">
        <View className="flex-row justify-between items-center mb-3">
          <SkeletonItem 
            height={24} 
            width={150} 
            bgColor={skeletonBgColor}
          />
          <SkeletonItem 
            height={16} 
            width={60} 
            bgColor={skeletonBgColor}
          />
        </View>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {[1, 2, 3].map((i) => (
            <View key={i} className="w-64 mr-4">
              <SkeletonItem 
                height={160} 
                className="rounded-2xl" 
                bgColor={skeletonBgColor}
              />
            </View>
          ))}
        </ScrollView>
      </View>

      {/* Featured Courses Skeleton */}
      <View className="mb-4">
        <SkeletonItem 
          height={24} 
          width={160} 
          className="mb-3" 
          bgColor={skeletonBgColor}
        />
        <SkeletonItem 
          height={192} 
          width={width - 32} 
          className="rounded-3xl" 
          bgColor={skeletonBgColor}
        />
      </View>

      {/* Categories Skeleton */}
      <View className="mb-4">
        <View className="flex-row justify-between items-center mb-3">
          <SkeletonItem 
            height={24} 
            width={120} 
            bgColor={skeletonBgColor}
          />
          <SkeletonItem 
            height={16} 
            width={60} 
            bgColor={skeletonBgColor}
          />
        </View>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <View key={i} className="items-center mr-4">
              <SkeletonItem 
                height={64} 
                width={64} 
                className="rounded-2xl mb-1" 
                bgColor={skeletonBgColor}
              />
              <SkeletonItem 
                height={12} 
                width={48} 
                bgColor={skeletonBgColor}
              />
            </View>
          ))}
        </ScrollView>
      </View>

      {/* Recommended Courses Skeleton */}
      <View className="mb-4">
        <View className="flex-row justify-between items-center mb-3">
          <SkeletonItem 
            height={24} 
            width={160} 
            bgColor={skeletonBgColor}
          />
          <SkeletonItem 
            height={16} 
            width={60} 
            bgColor={skeletonBgColor}
          />
        </View>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {[1, 2, 3].map((i) => (
            <View key={i} className="w-64 mr-4">
              <SkeletonItem 
                height={200} 
                className="rounded-2xl" 
                bgColor={skeletonBgColor}
              />
            </View>
          ))}
        </ScrollView>
      </View>

      {/* Gradients for visual enhancement */}
      <LinearGradient
        colors={isDarkMode 
          ? ['transparent', 'rgba(15, 23, 42, 0.8)'] 
          : ['transparent', 'rgba(248, 250, 252, 0.8)']
        }
        style={{
          position: 'absolute',
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
        }}
      />
    </ScrollView>
  );
};