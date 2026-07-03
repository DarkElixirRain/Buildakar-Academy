// app/(student)/payment/success.tsx
import React, { useEffect, useState } from 'react';
import {
  View,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Image,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';
import api from '@/lib/api';
import { ThemedView } from '@/components/themed-view';
import { ThemedText } from '@/components/themed-text';

// ─────────────────────────────────────────────
// TYPES
// ─────────────────────────────────────────────

interface RouteParams {
  courseId?: string;
  paymentId?: string;
  reason?: string;
}

interface CoursePreview {
  id: string;
  title: string;
  thumbnail: string;
  instructor: {
    firstName: string;
    lastName: string;
    photo?: string;
  };
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

function getInstructorName(instructor: {
  firstName: string;
  lastName: string;
}): string {
  if (!instructor) return 'Instructor';
  return `${instructor.firstName || ''} ${instructor.lastName || ''}`.trim() || 'Instructor';
}

// ─────────────────────────────────────────────
// COMPONENT
// ─────────────────────────────────────────────

export default function PaymentSuccessScreen() {
  const router = useRouter();
  const { isDarkMode, colors } = useTheme();

  const [course, setCourse] = useState<CoursePreview | null>(null);
  const [animationScale, setAnimationScale] = useState(0);
  const [showContent, setShowContent] = useState(false);

  const {
  courseId,
  paymentId,
  reason,
} = useLocalSearchParams<{
  courseId: string;
  paymentId: string;
  reason: string;
}>();

  // ─── Entrance animation ──────────────────────

  useEffect(() => {
    const t1 = setTimeout(() => setAnimationScale(1), 100);
    const t2 = setTimeout(() => setShowContent(true), 400);
    return () => {
      clearTimeout(t1);
      clearTimeout(t2);
    };
  }, []);

  // ─── Fetch course details ────────────────────

  useEffect(() => {
    if (courseId) fetchCourseDetails();
  }, [courseId]);

  async function fetchCourseDetails() {
    try {
      const response = await api.get(`/api/courses/${courseId}`);
      if (response.data.success) {
        setCourse(response.data.data);
      }
    } catch (error) {
      console.error('Failed to fetch course for success screen:', error);
    }
  }

  // ─── Navigation ──────────────────────────────

  function handleStartLearning() {
    if (courseId) {
      router.push(`/course/${courseId}` as any);
    } else {
      router.replace('/(tabs)' as any);
    }
  }

  function handleGoHome() {
    router.replace('/(tabs)' as any);
  }

  // ─────────────────────────────────────────────
  // RENDER
  // ─────────────────────────────────────────────

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      {/* Background gradient */}
      <LinearGradient
        colors={
          isDarkMode
            ? ['#0F172A', '#1E293B', '#0F172A']
            : ['#F8FAFC', '#EFF6FF', '#F8FAFC']
        }
        style={StyleSheet.absoluteFill}
      />

      <View style={styles.inner}>

        {/* ─── Checkmark animation ──────────── */}
        <View style={styles.animationContainer}>
          <View
            style={[
              styles.pulseRing,
              {
                transform: [{ scale: animationScale }],
                opacity: animationScale > 0 ? 0.3 : 0,
              },
            ]}
          />
          <View
            style={[
              styles.pulseRingInner,
              {
                transform: [{ scale: animationScale * 0.8 }],
                opacity: animationScale > 0 ? 0.2 : 0,
              },
            ]}
          />
          <View
            style={[
              styles.checkCircle,
              { transform: [{ scale: animationScale }] },
            ]}
          >
            <Ionicons
              name="checkmark"
              size={60}
              color="#FFFFFF"
              style={{ opacity: showContent ? 1 : 0 }}
            />
          </View>
        </View>

        {/* ─── Content ─────────────────────── */}
        {showContent && (
          <View style={styles.content}>

            <ThemedText
              type="h4"
              style={[styles.title, { color: colors.text }]}
            >
              Payment Successful! 🎉
            </ThemedText>

            <ThemedText
              type="body"
              style={[styles.subtitle, { color: colors.textSecondary }]}
            >
              Your payment has been processed successfully.{' '}
              {course ? `"${course.title}"` : 'Your course'} is now ready
              for you to start learning.
            </ThemedText>

            {/* Course preview card */}
            {course && (
              <TouchableOpacity
                onPress={handleStartLearning}
                activeOpacity={0.8}
                style={styles.courseCardWrapper}
              >
                <ThemedView type="backgroundElement" style={styles.courseCard}>
                  <Image
                    source={{
                      uri:
                        course.thumbnail ||
                        'https://picsum.photos/seed/default/400/300',
                    }}
                    style={styles.courseThumb}
                    resizeMode="cover"
                  />
                  <View style={styles.courseInfo}>
                    <ThemedText
                      type="h6"
                      style={styles.courseTitle}
                      numberOfLines={2}
                    >
                      {course.title}
                    </ThemedText>
                    <ThemedText
                      type="caption"
                      style={{ color: colors.textSecondary }}
                    >
                      By {getInstructorName(course.instructor)}
                    </ThemedText>
                  </View>
                  <Ionicons
                    name="chevron-forward"
                    size={24}
                    color={colors.textSecondary}
                  />
                </ThemedView>
              </TouchableOpacity>
            )}

            {/* Primary button */}
            <TouchableOpacity
              onPress={handleStartLearning}
              activeOpacity={0.85}
              style={[styles.primaryButton, { backgroundColor: colors.primary }]}
            >
              <Ionicons
                name="play-circle"
                size={22}
                color="#FFFFFF"
                style={{ marginRight: 8 }}
              />
              <ThemedText type="button" style={styles.primaryButtonText}>
                Start Learning
              </ThemedText>
            </TouchableOpacity>

            {/* Secondary button */}
            <TouchableOpacity
              onPress={handleGoHome}
              activeOpacity={0.85}
              style={[
                styles.secondaryButton,
                {
                  borderColor: colors.primary,
                  backgroundColor: isDarkMode
                    ? 'rgba(96,165,250,0.1)'
                    : 'rgba(37,99,235,0.1)',
                },
              ]}
            >
              <ThemedText
                type="button"
                style={[styles.secondaryButtonText, { color: colors.primary }]}
              >
                Back to Home
              </ThemedText>
            </TouchableOpacity>

            {/* Payment details */}
            {paymentId && (
              <ThemedView type="backgroundElement" style={styles.paymentDetails}>
                <ThemedText
                  type="caption"
                  style={[styles.detailsLabel, { color: colors.textSecondary }]}
                >
                  Order Details
                </ThemedText>

                <View style={styles.detailRow}>
                  <ThemedText type="caption" style={{ color: colors.textSecondary }}>
                    Payment ID
                  </ThemedText>
                  <ThemedText type="caption" style={styles.detailValue}>
                    {paymentId.slice(0, 12)}...
                  </ThemedText>
                </View>

                <View style={styles.detailRow}>
                  <ThemedText type="caption" style={{ color: colors.textSecondary }}>
                    Status
                  </ThemedText>
                  <ThemedText type="caption" style={styles.statusText}>
                    Completed ✓
                  </ThemedText>
                </View>
              </ThemedView>
            )}
          </View>
        )}

        {/* Fallback while animating */}
        {!showContent && animationScale === 0 && (
          <Ionicons name="checkmark-circle" size={80} color="#22C55E" />
        )}
      </View>
    </SafeAreaView>
  );
}

// ─────────────────────────────────────────────
// STYLES
// ─────────────────────────────────────────────

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  inner: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
  },
  animationContainer: {
    width: 160,
    height: 160,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 24,
  },
  pulseRing: {
    position: 'absolute',
    width: 160,
    height: 160,
    borderRadius: 80,
    backgroundColor: '#60A5FA',
  },
  pulseRingInner: {
    position: 'absolute',
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
  content: {
    width: '100%',
    alignItems: 'center',
    maxWidth: 400,
  },
  title: {
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 8,
  },
  subtitle: {
    textAlign: 'center',
    lineHeight: 24,
    marginBottom: 24,
  },
  courseCardWrapper: {
    width: '100%',
    marginBottom: 24,
  },
  courseCard: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderRadius: 16,
  },
  courseThumb: {
    width: 80,
    height: 80,
    borderRadius: 12,
  },
  courseInfo: {
    flex: 1,
    marginLeft: 16,
    justifyContent: 'center',
  },
  courseTitle: {
    fontWeight: 'bold',
    marginBottom: 4,
  },
  primaryButton: {
    width: '100%',
    paddingVertical: 14,
    borderRadius: 100,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  primaryButtonText: {
    color: '#fff',
    fontWeight: 'bold',
  },
  secondaryButton: {
    width: '100%',
    paddingVertical: 14,
    borderRadius: 100,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    marginBottom: 24,
  },
  secondaryButtonText: {
    fontWeight: 'bold',
  },
  paymentDetails: {
    width: '100%',
    borderRadius: 12,
    padding: 16,
  },
  detailsLabel: {
    fontWeight: '600',
    marginBottom: 8,
  },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 4,
  },
  detailValue: {
    fontFamily: 'monospace',
    fontWeight: '500',
  },
  statusText: {
    fontWeight: '500',
    color: '#16A34A',
  },
});