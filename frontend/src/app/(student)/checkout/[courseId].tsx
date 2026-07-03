import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  Image,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
  StyleSheet,
  Alert,
  Modal,
  StatusBar,
} from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import EsewaWebView from '../../../components/payment/EsewaWebView';
import { useAuthStore } from '@/store/authStore';
import api from '@/lib/api';

// ─────────────────────────────────────────────
// TYPES
// ─────────────────────────────────────────────

interface Course {
  id: string;
  title: string;
  description: string;
  thumbnail: string | null;
  price: number;
  originalPrice: number | null;
  level: string;
  language: string;
  totalHours: number | null;
  rating: number;
  studentsCount: number;
  instructor: {
    firstName: string;
    lastName: string;
    title: string | null;
    photo: string | null;
  };
  category: {
    name: string;
  };
  sections: {
    id: string;
    title: string;
    lessons: { id: string }[];
  }[];
}

interface EsewaPayload {
  paymentId: string;
  payload: Record<string, string>;
  esewaUrl: string;
}

interface InitiatePaymentResponse {
  success: boolean;
  isFree: boolean;
  message: string;
  data: {
    paymentId: string;
    payload: Record<string, string>;
    esewaUrl: string;
  };
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

function formatPrice(price: number): string {
  return `Rs. ${price.toLocaleString('en-NP', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}`;
}

function getLevelLabel(level: string): string {
  const map: Record<string, string> = {
    BEGINNER: '🟢 Beginner',
    INTERMEDIATE: '🟡 Intermediate',
    ADVANCED: '🔴 Advanced',
  };
  return map[level] ?? level;
}

// ─────────────────────────────────────────────
// COMPONENT
// ─────────────────────────────────────────────

export default function CheckoutScreen() {
  const { courseId } = useLocalSearchParams<{ courseId: string }>();
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();

  const [course, setCourse] = useState<Course | null>(null);
  const [isLoadingCourse, setIsLoadingCourse] = useState(true);
  const [isInitiatingPayment, setIsInitiatingPayment] = useState(false);
  const [esewaPayload, setEsewaPayload] = useState<EsewaPayload | null>(null);
  const [showWebView, setShowWebView] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // ─── Fetch course details ─────────────────────

  useEffect(() => {
    if (!courseId) return;
    fetchCourse();
  }, [courseId]);

  async function fetchCourse() {
    try {
      setIsLoadingCourse(true);
      setError(null);

      const response = await api.get(`/api/courses/${courseId}`);

      if (!response.data.success) {
        throw new Error(response.data.message ?? 'Failed to load course');
      }

      setCourse(response.data.data);
    } catch (err: any) {
      setError(err.response?.data?.message ?? err.message ?? 'Failed to load course');
    } finally {
      setIsLoadingCourse(false);
    }
  }

  // ─── Initiate eSewa payment ───────────────────

  async function handlePayWithEsewa() {
    if (!courseId || !isAuthenticated) return;

    try {
      setIsInitiatingPayment(true);

      const response = await api.post<InitiatePaymentResponse>('/api/payments/initiate', { courseId });

      if (!response.data.success) {
        throw new Error(response.data.message ?? 'Failed to initiate payment');
      }

      // Free course — go straight to player
      if (response.data.isFree) {
        Alert.alert('Enrolled!', 'You have been enrolled in this course.', [
          {
            text: 'Start Learning',
            onPress: () =>
              router.replace(`/course/${courseId}`),
          },
        ]);
        return;
      }

      // Paid course — open eSewa WebView
      setEsewaPayload({
        paymentId: response.data.data.paymentId,
        payload: response.data.data.payload,
        esewaUrl: response.data.data.esewaUrl,
      });
      setShowWebView(true);
    } catch (err: any) {
      const message = err.response?.data?.message ?? err.message ?? 'Something went wrong';

      // Already enrolled — go to course instead of showing error
      if (message.includes('already enrolled')) {
        Alert.alert(
          'Already Enrolled',
          'You are already enrolled in this course.',
          [
            {
              text: 'Go to Course',
              onPress: () =>
                router.replace(`/course/${courseId}`),
            },
            { text: 'OK', style: 'cancel' },
          ]
        );
        return;
      }

      Alert.alert('Payment Error', message);
    } finally {
      setIsInitiatingPayment(false);
    }
  }

  // ─── WebView callbacks ────────────────────────

  function handlePaymentSuccess(paidCourseId: string, paymentId: string) {
    setShowWebView(false);
    router.replace(
      `/(student)/payment/success?courseId=${paidCourseId}&paymentId=${paymentId}`
    );
  }

  function handlePaymentFailure(reason: string) {
    setShowWebView(false);
    router.replace(
      `/(student)/payment/failure?reason=${encodeURIComponent(reason)}&courseId=${courseId}`
    );
  }

  function handleWebViewClose() {
    setShowWebView(false);
    setEsewaPayload(null);
  }

  // ─── Total lessons count ──────────────────────

  const totalLessons =
    course?.sections.reduce((sum, s) => sum + s.lessons.length, 0) ?? 0;

  // ─────────────────────────────────────────────
  // RENDER STATES
  // ─────────────────────────────────────────────

  if (isLoadingCourse) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color="#60BB46" />
        <Text style={styles.loadingText}>Loading course details...</Text>
      </View>
    );
  }

  if (error || !course) {
    return (
      <View style={styles.centered}>
        <Text style={styles.errorIcon}>⚠️</Text>
        <Text style={styles.errorTitle}>Failed to load course</Text>
        <Text style={styles.errorMessage}>{error}</Text>
        <TouchableOpacity style={styles.retryButton} onPress={fetchCourse}>
          <Text style={styles.retryButtonText}>Try Again</Text>
        </TouchableOpacity>
      </View>
    );
  }

  // ─────────────────────────────────────────────
  // MAIN RENDER
  // ─────────────────────────────────────────────

  return (
    <>
      <StatusBar barStyle="dark-content" />

      <ScrollView
        style={styles.container}
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        {/* Course Thumbnail */}
        {course.thumbnail ? (
          <Image
            source={{ uri: course.thumbnail }}
            style={styles.thumbnail}
            resizeMode="cover"
          />
        ) : (
          <View style={[styles.thumbnail, styles.thumbnailPlaceholder]}>
            <Text style={styles.thumbnailPlaceholderText}>📚</Text>
          </View>
        )}

        {/* Course Info */}
        <View style={styles.section}>
          <Text style={styles.categoryLabel}>{course.category.name}</Text>
          <Text style={styles.title}>{course.title}</Text>
          <Text style={styles.description} numberOfLines={3}>
            {course.description}
          </Text>
        </View>

        {/* Instructor */}
        <View style={styles.instructorRow}>
          {course.instructor.photo ? (
            <Image
              source={{ uri: course.instructor.photo }}
              style={styles.instructorPhoto}
            />
          ) : (
            <View style={styles.instructorPhotoPlaceholder}>
              <Text style={styles.instructorInitial}>
                {course.instructor.firstName[0]}
              </Text>
            </View>
          )}
          <View>
            <Text style={styles.instructorName}>
              {course.instructor.firstName} {course.instructor.lastName}
            </Text>
            {course.instructor.title && (
              <Text style={styles.instructorTitle}>
                  
                {course.instructor.title}
              </Text>
            )}
          </View>
        </View>

        {/* Stats row */}
        <View style={styles.statsRow}>
          <View style={styles.stat}>
            <Text style={styles.statValue}>⭐ {course.rating.toFixed(1)}</Text>
            <Text style={styles.statLabel}>Rating</Text>
          </View>
          <View style={styles.statDivider} />
          <View style={styles.stat}>
            <Text style={styles.statValue}>{course.studentsCount.toLocaleString()}</Text>
            <Text style={styles.statLabel}>Students</Text>
          </View>
          <View style={styles.statDivider} />
          <View style={styles.stat}>
            <Text style={styles.statValue}>{totalLessons}</Text>
            <Text style={styles.statLabel}>Lessons</Text>
          </View>
          <View style={styles.statDivider} />
          <View style={styles.stat}>
            <Text style={styles.statValue}>{getLevelLabel(course.level)}</Text>
            <Text style={styles.statLabel}>Level</Text>
          </View>
        </View>

        {/* Price Breakdown */}
        <View style={styles.priceCard}>
          <Text style={styles.priceCardTitle}>Order Summary</Text>

          <View style={styles.priceRow}>
            <Text style={styles.priceLabel}>Course price</Text>
            <Text style={styles.priceValue}>
              {course.originalPrice
                ? formatPrice(course.originalPrice)
                : formatPrice(course.price)}
            </Text>
          </View>

          {course.originalPrice && course.originalPrice > course.price && (
            <View style={styles.priceRow}>
              <Text style={[styles.priceLabel, { color: '#60BB46' }]}>
                Discount
              </Text>
              <Text style={[styles.priceValue, { color: '#60BB46' }]}>
                -{formatPrice(course.originalPrice - course.price)}
              </Text>
            </View>
          )}

          <View style={styles.priceRow}>
            <Text style={styles.priceLabel}>Tax</Text>
            <Text style={styles.priceValue}>Rs. 0.00</Text>
          </View>

          <View style={styles.priceDivider} />

          <View style={styles.priceRow}>
            <Text style={styles.totalLabel}>Total</Text>
            <Text style={styles.totalValue}>{formatPrice(course.price)}</Text>
          </View>
        </View>

        {/* Spacer for bottom button */}
        <View style={{ height: 100 }} />
      </ScrollView>

      {/* Sticky bottom Pay button */}
      <View style={styles.bottomBar}>
        <View style={styles.bottomBarPrice}>
          <Text style={styles.bottomBarPriceValue}>
            {formatPrice(course.price)}
          </Text>
          {course.originalPrice && course.originalPrice > course.price && (
            <Text style={styles.bottomBarOriginalPrice}>
              {formatPrice(course.originalPrice)}
            </Text>
          )}
        </View>

        <TouchableOpacity
          style={[
            styles.payButton,
            isInitiatingPayment && styles.payButtonDisabled,
          ]}
          onPress={handlePayWithEsewa}
          disabled={isInitiatingPayment}
          activeOpacity={0.8}
        >
          {isInitiatingPayment ? (
            <ActivityIndicator color="#fff" size="small" />
          ) : (
            <>
              <Text style={styles.payButtonText}>Pay with eSewa</Text>
              <Text style={styles.esewaLogo}>eSewa</Text>
            </>
          )}
        </TouchableOpacity>

        <Text style={styles.secureText}>🔒 Secure payment by eSewa</Text>
      </View>

      {/* eSewa WebView Modal */}
      <Modal
        visible={showWebView && esewaPayload !== null}
        animationType="slide"
        presentationStyle="fullScreen"
        onRequestClose={handleWebViewClose}
      >
        {esewaPayload && (
          <EsewaWebView
            payload={esewaPayload.payload}
            esewaUrl={esewaPayload.esewaUrl}
            onSuccess={handlePaymentSuccess}
            onFailure={handlePaymentFailure}
            onClose={handleWebViewClose}
          />
        )}
      </Modal>
    </>
  );
}

// ─────────────────────────────────────────────
// STYLES
// ─────────────────────────────────────────────

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  content: { paddingBottom: 20 },
  centered: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    backgroundColor: '#fff',
  },
  loadingText: { marginTop: 12, color: '#666', fontSize: 14 },
  errorIcon: { fontSize: 40, marginBottom: 12 },
  errorTitle: { fontSize: 18, fontWeight: '600', color: '#1a1a1a', marginBottom: 8 },
  errorMessage: { fontSize: 14, color: '#666', textAlign: 'center', marginBottom: 20 },
  retryButton: {
    backgroundColor: '#60BB46',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  retryButtonText: { color: '#fff', fontWeight: '600' },

  // Thumbnail
  thumbnail: { width: '100%', height: 220 },
  thumbnailPlaceholder: {
    backgroundColor: '#f0f0f0',
    alignItems: 'center',
    justifyContent: 'center',
  },
  thumbnailPlaceholderText: { fontSize: 48 },

  // Course info
  section: { padding: 16 },
  categoryLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: '#60BB46',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 6,
  },
  title: { fontSize: 20, fontWeight: '700', color: '#1a1a1a', marginBottom: 8, lineHeight: 28 },
  description: { fontSize: 14, color: '#666', lineHeight: 20 },

  // Instructor
  instructorRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingBottom: 16,
    gap: 10,
  },
  instructorPhoto: { width: 40, height: 40, borderRadius: 20 },
  instructorPhotoPlaceholder: {
    width: 40, height: 40, borderRadius: 20,
    backgroundColor: '#60BB46',
    alignItems: 'center', justifyContent: 'center',
  },
  instructorInitial: { color: '#fff', fontWeight: '700', fontSize: 16 },
  instructorName: { fontSize: 14, fontWeight: '600', color: '#1a1a1a' },
  instructorTitle: { fontSize: 12, color: '#888' },

  // Stats
  statsRow: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#f9f9f9',
    marginHorizontal: 16,
    borderRadius: 12,
    marginBottom: 16,
  },
  stat: { flex: 1, alignItems: 'center' },
  statValue: { fontSize: 13, fontWeight: '600', color: '#1a1a1a' },
  statLabel: { fontSize: 11, color: '#888', marginTop: 2 },
  statDivider: { width: 1, backgroundColor: '#e0e0e0', marginVertical: 4 },

  // Price card
  priceCard: {
    marginHorizontal: 16,
    padding: 16,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#f0f0f0',
    backgroundColor: '#fafafa',
  },
  priceCardTitle: { fontSize: 15, fontWeight: '700', color: '#1a1a1a', marginBottom: 12 },
  priceRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 8 },
  priceLabel: { fontSize: 14, color: '#666' },
  priceValue: { fontSize: 14, color: '#1a1a1a' },
  priceDivider: { height: 1, backgroundColor: '#e8e8e8', marginVertical: 8 },
  totalLabel: { fontSize: 15, fontWeight: '700', color: '#1a1a1a' },
  totalValue: { fontSize: 15, fontWeight: '700', color: '#1a1a1a' },

  // Bottom bar
  bottomBar: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: '#fff',
    padding: 16,
    paddingBottom: 32,
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 8,
  },
  bottomBarPrice: { flexDirection: 'row', alignItems: 'baseline', gap: 8, marginBottom: 10 },
  bottomBarPriceValue: { fontSize: 22, fontWeight: '800', color: '#1a1a1a' },
  bottomBarOriginalPrice: {
    fontSize: 14, color: '#aaa',
    textDecorationLine: 'line-through',
  },
  payButton: {
    backgroundColor: '#60BB46',
    borderRadius: 12,
    paddingVertical: 14,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  payButtonDisabled: { opacity: 0.6 },
  payButtonText: { color: '#fff', fontSize: 16, fontWeight: '700' },
  esewaLogo: {
    color: '#fff',
    fontSize: 13,
    fontWeight: '500',
    opacity: 0.85,
    backgroundColor: 'rgba(255,255,255,0.2)',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 4,
  },
  secureText: { textAlign: 'center', fontSize: 12, color: '#aaa', marginTop: 8 },
});