import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Image,
  Dimensions,
} from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '@/hooks/use-theme';
import { useAuthStore } from '@/store/authStore';
import api from '@/lib/api';
import { Colors, Spacing } from '@/constants/Color';
import { ThemedView, ThemedText } from '@/components/themed-view';

interface RouteParams {
  courseId?: string;
  paymentId?: string;
  reason?: string;
}

export default function PaymentSuccessScreen() {
  const params = useLocalSearchParams<RouteParams>();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { isDarkMode, colors } = useTheme();
  const { user } = useAuthStore();

  const [course, setCourse] = useState<{
    id: string;
    title: string;
    thumbnail: string;
    instructor: { firstName: string; lastName: string; photo?: string };
  } | null>(null);
  const [animationScale, setAnimationScale] = useState(0);
  const [showContent, setShowContent] = useState(false);

  const { courseId, paymentId } = params;

  useEffect(() => {
    // Trigger entrance animation
    setTimeout(() => {
      setAnimationScale(1);
      setTimeout(() => {
        setShowContent(true);
      }, 300);
    }, 100);

    // Fetch course details
    if (courseId) {
      fetchCourseDetails();
    }
  }, [courseId]);

  const fetchCourseDetails = async () => {
    try {
      const response = await api.get(`/api/courses/${courseId}`);
      if (response.data.success) {
        setCourse(response.data.data);
      }
    } catch (error) {
      console.error('Failed to fetch course for success screen:', error);
    }
  };

  const getInstructorName = (instructor: { firstName: string; lastName: string }) => {
    if (!instructor) return 'Instructor';
    return `${instructor.firstName || ''} ${instructor.lastName || ''}`.trim() || 'Instructor';
  };

  const getInstructorAvatar = (instructor: { firstName: string; lastName: string; photo?: string }) => {
    if (!instructor) return 'https://ui-avatars.com/api/?name=Instructor&size=150&background=4F46E5&color=fff';
    const name = getInstructorName(instructor);
    return instructor.photo || 
      `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&size=150&background=4F46E5&color=fff`;
  };

  const handleStartLearning = () => {
    if (courseId) {
      router.push(`/course/${courseId}`);
    } else {
      router.replace('/(tabs)');
    }
  };

  const handleGoHome = () => {
    router.replace('/(tabs)');
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <View style={StyleSheet.absoluteFill}>
        <LinearGradient
          colors={isDarkMode 
            ? ['#0F172A', '#1E293B', '#0F172A'] 
            : ['#F8FAFC', '#EFF6FF', '#F8FAFC']
          }
          style={StyleSheet.absoluteFill}
        />
      </View>

      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', paddingHorizontal: Spacing.five }}>
        {/* Success Animation */}
        <View className="items-center mb-6">
          {/* Outer pulse rings */}
          <View style={styles.pulseRing}>
            <View style={[styles.pulseCircle, { 
              transform: [{ scale: animationScale }],
              opacity: animationScale > 0 ? 0.3 : 0,
            }]} />
          </View>
          <View style={styles.pulseRing}>
            <View style={[styles.pulseCircle, { 
              transform: [{ scale: animationScale * 0.8 }],
              opacity: animationScale > 0 ? 0.2 : 0,
            }]} />
          </View>
          
          {/* Main checkmark circle */}
          <View style={[styles.checkCircle, {
            transform: [{ scale: animationScale }],
          }]}>
            <Ionicons 
              name="checkmark" 
              size={60} 
              color="#FFFFFF" 
              style={{ 
                marginTop: 2,
                opacity: showContent ? 1 : 0,
              }}
            />
          </View>
        </View>

        {/* Success Message */}
        {showContent && (
          <View className="items-center px-4" style={{ maxWidth: 400 }}>
            <ThemedText type="h4" className="font-bold text-center mb-2">
              Payment Successful! 🎉
            </ThemedText>
            
            <ThemedText type="body" className="text-center mb-6" style={{ color: colors.textSecondary, lineHeight: 24 }}>
              Your payment has been processed successfully. 
              {course ? `"${course.title}"` : 'Your course'} is now ready for you to start learning.
            </ThemedText>

            {/* Course Card Preview */}
            {course && (
              <TouchableOpacity 
                onPress={handleStartLearning}
                className="w-full mb-6"
                activeOpacity={0.8}
              >
                <ThemedView type="backgroundElement" className="rounded-2xl overflow-hidden">
                  <View className="flex-row p-4">
                    <Image
                      source={{ uri: course.thumbnail || 'https://picsum.photos/seed/default/400/300' }}
                      className="w-20 h-20 rounded-xl"
                      resizeMode="cover"
                    />
                    <View className="flex-1 ml-4 justify-center">
                      <ThemedText type="h6" className="font-bold mb-1" numberOfLines={1}>
                        {course.title}
                      </ThemedText>
                      <ThemedText type="caption" style={{ color: colors.textSecondary }}>
                        By {getInstructorName(course.instructor)}
                      </ThemedText>
                    </View>
                    <Ionicons name="chevron-forward" size={24} color={colors.textSecondary} />
                  </View>
                </ThemedView>
              </TouchableOpacity>
            )}

            {/* Action Buttons */}
            <View className="w-full space-y-3">
              <TouchableOpacity
                onPress={handleStartLearning}
                className="w-full py-4 rounded-full items-center justify-center flex-row"
                style={{ backgroundColor: colors.primary }}
                activeOpacity={0.85}
              >
                <Ionicons name="play-circle" size={22} color="#FFFFFF" className="mr-2" />
                <ThemedText type="button" className="text-white font-bold">
                  Start Learning
                </ThemedText>
              </TouchableOpacity>

              <TouchableOpacity
                onPress={handleGoHome}
                className="w-full py-4 rounded-full items-center justify-center border-2"
                style={{ 
                  borderColor: colors.primary,
                  backgroundColor: isDarkMode ? 'rgba(96,165,250,0.1)' : 'rgba(37,99,235,0.1)',
                }}
                activeOpacity={0.85}
              >
                <ThemedText type="button" className="font-bold" style={{ color: colors.primary }}>
                  Back to Home
                </ThemedText>
              </TouchableOpacity>
            </View>

            {/* Payment Details */}
            {paymentId && (
              <ThemedView type="backgroundElement" className="w-full mt-6 rounded-xl p-4">
                <ThemedText type="caption" className="font-semibold mb-2" style={{ color: colors.textSecondary }}>
                  Order Details
                </ThemedText>
                <View className="flex-row justify-between mb-1">
                  <ThemedText type="caption" style={{ color: colors.textSecondary }}>Payment ID</ThemedText>
                  <ThemedText type="caption" className="font-mono font-medium">
                    {paymentId.slice(0, 12)}...
                  </ThemedText>
                </View>
                <View className="flex-row justify-between">
                  <ThemedText type="caption" style={{ color: colors.textSecondary }}>Status</ThemedText>
                  <ThemedText type="caption" className="font-medium text-green-600 dark:text-green-400">
                    Completed ✓
                  </ThemedText>
                </View>
              </ThemedView>
            )}
          </View>
        )}

        {/* Loading fallback */}
        {!showContent && animationScale === 0 && (
          <View className="items-center">
            <Ionicons name="checkmark-circle" size={80} color={colors.success} />
          </View>
        )}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  pulseRing: {
    position: 'absolute',
    width: 160,
    height: 160,
    borderRadius: 80,
    justifyContent: 'center',
    alignItems: 'center',
  },
  pulseCircle: {
    width: 160,
    height: 160,
    borderRadius: 80,
    backgroundColor: '#60A5FA',
  },
  checkCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: '#22C55E',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#22C55E',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.4,
    shadowRadius: 20,
    elevation: 8,
  },
});