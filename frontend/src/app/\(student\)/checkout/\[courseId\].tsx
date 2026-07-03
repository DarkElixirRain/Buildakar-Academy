import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  Image,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  StyleSheet,
  SafeAreaView,
  KeyboardAvoidingView,
  Platform,
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
import { EsewaWebView } from '@/components/payment/EsewaWebView';

interface ApiCourse {
  id: string;
  title: string;
  description: string;
  thumbnail: string;
  price: number;
  originalPrice?: number;
  currency: string;
  level: string;
  language: string;
  duration?: string;
  totalHours?: number;
  rating: number;
  studentsCount: number;
  isPublished: boolean;
  isBestseller: boolean;
  isTrending: boolean;
  status: string;
  instructorId: string;
  categoryId: string;
  instructor: {
    id: string;
    firstName: string;
    lastName: string;
    email: string;
    photo?: string;
  };
  category: {
    id: string;
    name: string;
    slug: string;
  };
}

interface PaymentInitiateResponse {
  success: boolean;
  isFree: boolean;
  message: string;
  data: {
    paymentId: string;
    payload: Record<string, string>;
    esewaUrl: string;
  };
}

export default function CheckoutScreen() {
  const { courseId } = useLocalSearchParams<{ courseId: string }>();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { isDarkMode, colors } = useTheme();
  const { isAuthenticated, token, user } = useAuthStore();

  const [isLoading, setIsLoading] = useState(true);
  const [course, setCourse] = useState<ApiCourse | null>(null);
  const [isProcessingPayment, setIsProcessingPayment] = useState(false);
  const [showWebView, setShowWebView] = useState(false);
  const [webViewData, setWebViewData] = useState<{
    paymentId: string;
    payload: Record<string, string>;
    esewaUrl: string;
  } | null>(null);

  const fetchCourseDetails = async () => {
    try {
      setIsLoading(true);
      console.log(`🌐 Fetching course details for checkout: ${courseId}`);

      const response = await api.get(`/api/courses/${courseId}`);

      if (!response.data.success) {
        throw new Error(response.data.message || 'Failed to fetch course');
      }

      console.log('✅ Course loaded for checkout:', response.data.data.title);
      setCourse(response.data.data);
    } catch (error: any) {
      console.error('❌ Failed to fetch course:', error);
      Alert.alert(
        'Error',
        error.response?.data?.message || error.message || 'Failed to load course. Please try again.',
        [{ text: 'Go Back', onPress: () => router.back() }]
      );
    } finally {
      setIsLoading(false);
    }
  };

  const handlePayment = async () => {
    if (!isAuthenticated) {
      Alert.alert(
        'Login Required',
        'Please login to purchase this course.',
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Login', onPress: () => router.push('/(auth)/login') }
        ]
      );
      return;
    }

    if (!course) return;

    setIsProcessingPayment(true);

    try {
      console.log(`💳 Initiating payment for course: ${courseId}`);
      const response = await api.post('/api/payments/initiate', { courseId });

      if (!response.data.success) {
        throw new Error(response.data.message || 'Failed to initiate payment');
      }

      // Free course - already enrolled
      if (response.data.isFree) {
        Alert.alert(
          'Enrolled Successfully! 🎉',
          'You have been enrolled in this free course.',
          [
            {
              text: 'Start Learning',
              onPress: () => router.push(`/course/${courseId}`)
            },
            { text: 'Continue Browsing', style: 'cancel', onPress: () => router.back() }
          ]
        );
        return;
      }

      // Paid course - show WebView
      const { paymentId, payload, esewaUrl } = response.data.data;
      setWebViewData({ paymentId, payload, esewaUrl });
      setShowWebView(true);
    } catch (error: any) {
      console.error('❌ Payment initiation failed:', error);
      
      let errorMessage = 'Failed to initiate payment. Please try again.';
      if (error.response?.status === 400) {
        errorMessage = error.response.data.message || errorMessage;
      } else if (error.response?.status === 404) {
        errorMessage = 'Course not found.';
      } else if (error.response?.status === 503) {
        errorMessage = 'Payment service temporarily unavailable. Please try again later.';
      }
      
      Alert.alert('Payment Error', errorMessage);
    } finally {
      setIsProcessingPayment(false);
    }
  };

  const handlePaymentSuccess = (returnedCourseId: string, paymentId: string) => {
    console.log('✅ Payment success:', { returnedCourseId, paymentId });
    setShowWebView(false);
    setWebViewData(null);
    
    // Navigate to success screen
    router.push(`/payment/success?courseId=${returnedCourseId}&paymentId=${paymentId}`);
  };

  const handlePaymentFailure = (reason: string) => {
    console.log('❌ Payment failure:', reason);
    setShowWebView(false);
    setWebViewData(null);
    
    // Navigate to failure screen
    router.push(`/payment/failure?reason=${encodeURIComponent(reason)}`);
  };

  useEffect(() => {
    if (courseId) {
      fetchCourseDetails();
    }
  }, [courseId]);

  const getInstructorName = (instructor: ApiCourse['instructor']) => {
    if (!instructor) return 'Unknown Instructor';
    const firstName = instructor.firstName || '';
    const lastName = instructor.lastName || '';
    return `${firstName} ${lastName}`.trim() || 'Instructor';
  };

  const getInstructorAvatar = (instructor: ApiCourse['instructor']) => {
    if (!instructor) return 'https://ui-avatars.com/api/?name=Instructor&size=150&background=4F46E5&color=fff';
    const name = getInstructorName(instructor);
    return instructor.photo || 
      `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&size=150&background=4F46E5&color=fff`;
  };

  const formatPrice = (price: number, currency = 'NPR') => {
    if (currency === 'NPR') {
      return `Rs. ${price.toLocaleString()}`;
    }
    return `${currency} ${price.toFixed(2)}`;
  };

  // Skeleton loading
  if (isLoading) {
    const skeletonBg = isDarkMode ? '#1E293B' : '#E2E8F0';
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()} className="p-2">
            <Ionicons name={Platform.OS === 'ios' ? 'chevron-back' : 'arrow-back'} size={24} color={colors.text} />
          </TouchableOpacity>
          <ThemedText type="h6" className="flex-1 text-center">Checkout</ThemedText>
          <View style={{ width: 44 }} />
        </View>
        <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
          <View style={{ height: 200, backgroundColor: skeletonBg }} />
          <View className="p-4">
            <View style={{ height: 24, width: '70%', backgroundColor: skeletonBg, borderRadius: 4, marginBottom: 8 }} />
            <View style={{ height: 16, width: '40%', backgroundColor: skeletonBg, borderRadius: 4, marginBottom: 16 }} />
            <View className="flex-row items-center" style={{ marginBottom: 16 }}>
              <View style={{ width: 40, height: 40, borderRadius: 20, backgroundColor: skeletonBg, marginRight: 12 }} />
              <View style={{ height: 16, width: 100, backgroundColor: skeletonBg, borderRadius: 4 }} />
            </View>
            <View style={{ height: 32, width: '50%', backgroundColor: skeletonBg, borderRadius: 8 }} />
          </View>
        </ScrollView>
        <View className="p-4" style={{ borderTopWidth: 1, borderTopColor: colors.backgroundSelected }}>
          <View className="h-14 rounded-full" style={{ backgroundColor: skeletonBg }} />
        </View>
      </SafeAreaView>
    );
  }

  if (!course) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.background, alignItems: 'center', justifyContent: 'center' }}>
        <Ionicons name="book-outline" size={64} color={colors.textSecondary} />
        <ThemedText type="h6" className="mt-4">Course not found</ThemedText>
        <TouchableOpacity 
          onPress={() => router.back()}
          className="mt-4 px-6 py-3 rounded-lg"
          style={{ backgroundColor: colors.primary }}
        >
          <ThemedText type="button" className="text-white">Go Back</ThemedText>
        </TouchableOpacity>
      </SafeAreaView>
    );
  }

  const instructorName = getInstructorName(course.instructor);
  const instructorAvatar = getInstructorAvatar(course.instructor);
  const discountPercent = course.originalPrice && course.originalPrice > course.price
    ? Math.round((1 - course.price / course.originalPrice) * 100)
    : 0;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} className="p-2">
          <Ionicons name={Platform.OS === 'ios' ? 'chevron-back' : 'arrow-back'} size={24} color={colors.text} />
        </TouchableOpacity>
        <ThemedText type="h6" className="flex-1 text-center">Checkout</ThemedText>
        <View style={{ width: 44 }} />
      </View>

      <ScrollView className="flex-1" showsVerticalScrollIndicator={false} contentContainerStyle={styles.scrollContent}>
        {/* Course Thumbnail */}
        <View style={{ height: 200, backgroundColor: isDarkMode ? '#1a1a2e' : '#000' }}>
          <Image
            source={{ uri: course.thumbnail || 'https://picsum.photos/seed/default/800/600' }}
            style={StyleSheet.absoluteFill}
            resizeMode="cover"
          />
          <LinearGradient
            colors={['rgba(15,23,42,0.45)', 'transparent', 'rgba(15,23,42,0.6)']}
            style={StyleSheet.absoluteFill}
          />
          {course.isBestseller && (
            <View style={styles.badge}>
              <ThemedText type="caption" className="text-white font-bold">BESTSELLER</ThemedText>
            </View>
          )}
        </View>

        {/* Course Details */}
        <View className="p-4">
          <ThemedText type="h5" className="mb-2" numberOfLines={2}>{course.title}</ThemedText>
          
          <TouchableOpacity className="flex-row items-center mb-4" onPress={() => router.push(`/instructor/${course.instructorId}`)}>
            <Image
              source={{ uri: instructorAvatar }}
              className="w-10 h-10 rounded-full mr-3"
            />
            <View>
              <ThemedText type="body" className="font-medium">Created by {instructorName}</ThemedText>
              <ThemedText type="caption" style={{ color: colors.textSecondary }}>
                {course.studentsCount || 0} students • {course.rating?.toFixed(1) || '0.0'} ⭐
              </ThemedText>
            </View>
          </TouchableOpacity>

          {/* Price Section */}
          <ThemedView type="backgroundElement" className="rounded-xl p-4 mb-4">
            <View className="flex-row items-baseline justify-between mb-2">
              <View>
                <ThemedText type="h4" className="font-bold" style={{ color: colors.primary }}>
                  {formatPrice(course.price, course.currency)}
                </ThemedText>
                {course.originalPrice && course.originalPrice > course.price && (
                  <ThemedText type="body" className="ml-2" style={{ 
                    color: colors.textSecondary, 
                    textDecorationLine: 'line-through' 
                  }}>
                    {formatPrice(course.originalPrice, course.currency)}
                  </ThemedText>
                )}
              </View>
              {discountPercent > 0 && (
                <View className="bg-green-100 dark:bg-green-900/30 px-3 py-1 rounded-full">
                  <ThemedText type="caption" className="font-bold text-green-600 dark:text-green-400">
                    {discountPercent}% OFF
                  </ThemedText>
                </View>
              )}
            </View>
            
            <View style={{ borderTopWidth: 1, borderTopColor: colors.backgroundSelected, paddingTop: 12 }}>
              <View className="flex-row justify-between mb-1">
                <ThemedText type="body">Course Price</ThemedText>
                <ThemedText type="body" className="font-medium">
                  {formatPrice(course.price, course.currency)}
                </ThemedText>
              </View>
              {course.originalPrice && course.originalPrice > course.price && (
                <View className="flex-row justify-between mb-1">
                  <ThemedText type="body" style={{ color: colors.textSecondary }}>Discount</ThemedText>
                  <ThemedText type="body" className="font-medium text-green-600 dark:text-green-400">
                    -{formatPrice(course.originalPrice - course.price, course.currency)}
                  </ThemedText>
                </View>
              )}
              <View style={{ borderTopWidth: 1, borderTopColor: colors.backgroundSelected, paddingTop: 12, marginTop: 12 }}>
                <View className="flex-row justify-between">
                  <ThemedText type="h6" className="font-bold">Total</ThemedText>
                  <ThemedText type="h6" className="font-bold" style={{ color: colors.primary }}>
                    {formatPrice(course.price, course.currency)}
                  </ThemedText>
                </View>
              </View>
            </View>
          </ThemedView>

          {/* Course Info */}
          <ThemedView type="backgroundElement" className="rounded-xl p-4 mb-4">
            <ThemedText type="h6" className="font-bold mb-3">What you'll get</ThemedText>
            <View className="space-y-2">
              {[
                { icon: 'play-circle', text: 'Full lifetime access to all course content' },
                { icon: 'phone-portrait', text: 'Access on mobile and TV' },
                { icon: 'document-text', text: 'Certificate of completion' },
                { icon: 'lock-closed', text: '30-day money-back guarantee' },
              ].map((item, index) => (
                <View key={index} className="flex-row items-center">
                  <Ionicons name={item.icon} size={20} color={colors.primary} className="mr-3 w-6" />
                  <ThemedText type="body" style={{ flex: 1 }}>{item.text}</ThemedText>
                </View>
              ))}
            </View>
          </ThemedView>

          {/* Payment Method */}
          <ThemedView type="backgroundElement" className="rounded-xl p-4 mb-4">
            <ThemedText type="h6" className="font-bold mb-3">Payment Method</ThemedText>
            <TouchableOpacity className="flex-row items-center p-3 rounded-lg" style={{ backgroundColor: isDarkMode ? '#1E293B' : '#F8FAFC' }}>
              <View className="w-12 h-12 rounded-lg items-center justify-center mr-3" style={{ backgroundColor: '#E62B1E' }}>
                <Ionicons name="logo-usd" size={24} color="#FFFFFF" />
              </View>
              <View className="flex-1">
                <ThemedText type="body" className="font-medium">eSewa</ThemedText>
                <ThemedText type="caption" style={{ color: colors.textSecondary }}>
                  Nepal's leading digital wallet
                </ThemedText>
              </View>
              <Ionicons name="checkmark-circle" size={24} color={colors.primary} />
            </TouchableOpacity>
          </ThemedView>
        </View>
      </ScrollView>

      {/* Sticky Pay Button */}
      <View className="p-4" style={{ 
        borderTopWidth: 1, 
        borderTopColor: colors.backgroundSelected,
        backgroundColor: colors.backgroundElement,
        paddingBottom: Math.max(insets.bottom, 12) + 16,
      }}>
        <TouchableOpacity
          onPress={handlePayment}
          disabled={isProcessingPayment}
          className="flex-1 py-4 rounded-full items-center justify-center flex-row"
          style={{ 
            backgroundColor: colors.primary,
            opacity: isProcessingPayment ? 0.7 : 1,
          }}
          activeOpacity={0.85}
        >
          {isProcessingPayment ? (
            <ActivityIndicator color="#FFFFFF" size="small" />
          ) : (
            <>
              <Ionicons name="card" size={20} color="#FFFFFF" className="mr-2" />
              <ThemedText type="button" className="text-white font-bold">
                Pay {formatPrice(course.price, course.currency)} with eSewa
              </ThemedText>
            </>
          )}
        </TouchableOpacity>
        
        <ThemedText type="caption" className="text-center mt-3" style={{ color: colors.textSecondary }}>
          By paying, you agree to our Terms of Service and Privacy Policy
        </ThemedText>
      </View>

      {/* eSewa WebView Modal */}
      {showWebView && webViewData && (
        <View style={styles.webViewContainer}>
          <EsewaWebView
            courseId={courseId!}
            paymentId={webViewData.paymentId}
            payload={webViewData.payload}
            esewaUrl={webViewData.esewaUrl}
            onSuccess={handlePaymentSuccess}
            onFailure={handlePaymentFailure}
          />
        </View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: Spacing.four,
    paddingVertical: Spacing.three,
    paddingTop: Spacing.four,
    borderBottomWidth: 1,
  },
  scrollContent: {
    paddingBottom: 100,
  },
  badge: {
    position: 'absolute',
    top: 16,
    left: 16,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  webViewContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 1000,
    backgroundColor: '#fff',
  },
});