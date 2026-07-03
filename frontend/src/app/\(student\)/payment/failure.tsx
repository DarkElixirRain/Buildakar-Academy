import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Alert,
  Linking,
} from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '@/hooks/use-theme';
import { useAuthStore } from '@/store/authStore';
import { Colors, Spacing } from '@/constants/Color';
import { ThemedView, ThemedText } from '@/components/themed-view';

interface RouteParams {
  reason?: string;
  courseId?: string;
}

export default function PaymentFailureScreen() {
  const params = useLocalSearchParams<RouteParams>();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { isDarkMode, colors } = useTheme();
  const { user } = useAuthStore();

  const [animationScale, setAnimationScale] = useState(0);
  const [showContent, setShowContent] = useState(false);

  const { reason = 'payment_cancelled', courseId } = params;

  useEffect(() => {
    // Trigger entrance animation
    setTimeout(() => {
      setAnimationScale(1);
      setTimeout(() => {
        setShowContent(true);
      }, 300);
    }, 100);
  }, []);

  const getFailureMessage = (reason: string): { title: string; message: string; icon: string; color: string } => {
    switch (reason) {
      case 'payment_cancelled':
        return {
          title: 'Payment Cancelled',
          message: 'You cancelled the payment process. No charges were made.',
          icon: 'close-circle',
          color: colors.warning,
        };
      case 'verification_failed':
        return {
          title: 'Verification Failed',
          message: 'We couldn\'t verify your payment. Please try again or contact support.',
          icon: 'alert-circle',
          color: colors.error,
        };
      case 'missing_data':
        return {
          title: 'Invalid Payment Data',
          message: 'The payment response was incomplete. Please try again.',
          icon: 'warning',
          color: colors.error,
        };
      case 'webview_error':
        return {
          title: 'Connection Error',
          message: 'Unable to load the payment page. Please check your connection and try again.',
          icon: 'wifi-off',
          color: colors.error,
        };
      case 'payment_failed':
      default:
        return {
          title: 'Payment Failed',
          message: 'The payment could not be processed. Please try again or use a different payment method.',
          icon: 'close-circle',
          color: colors.error,
        };
    }
  };

  const failureInfo = getFailureMessage(reason);

  const handleTryAgain = () => {
    if (courseId) {
      router.back(); // Goes back to checkout screen
    } else {
      router.replace('/(tabs)/explore');
    }
  };

  const handleContactSupport = async () => {
    const supportUrl = 'https://buildakar.com/support';
    try {
      await Linking.openURL(supportUrl);
    } catch (error) {
      Alert.alert(
        'Contact Support',
        'Email us at support@buildakar.com\nor visit buildakar.com/support',
        [{ text: 'OK' }]
      );
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
            : ['#F8FAFC', '#FEF2F2', '#F8FAFC']
          }
          style={StyleSheet.absoluteFill}
        />
      </View>

      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', paddingHorizontal: Spacing.five }}>
        {/* Failure Animation */}
        <View className="items-center mb-6">
          {/* Outer pulse rings */}
          <View style={styles.pulseRing}>
            <View style={[styles.pulseCircle, { 
              transform: [{ scale: animationScale }],
              opacity: animationScale > 0 ? 0.3 : 0,
              backgroundColor: failureInfo.color,
            }]} />
          </View>
          
          {/* Main icon circle */}
          <View style={[styles.checkCircle, {
            transform: [{ scale: animationScale }],
            backgroundColor: failureInfo.color,
          }]}>
            <Ionicons 
              name={failureInfo.icon} 
              size={50} 
              color="#FFFFFF" 
              style={{ 
                marginTop: 2,
                opacity: showContent ? 1 : 0,
              }}
            />
          </View>
        </View>

        {/* Failure Message */}
        {showContent && (
          <View className="items-center px-4" style={{ maxWidth: 400 }}>
            <ThemedText type="h4" className="font-bold text-center mb-2" style={{ color: failureInfo.color }}>
              {failureInfo.title}
            </ThemedText>
            
            <ThemedText type="body" className="text-center mb-8" style={{ color: colors.textSecondary, lineHeight: 24 }}>
              {failureInfo.message}
            </ThemedText>

            {/* Action Buttons */}
            <View className="w-full space-y-3" style={{ maxWidth: 300 }}>
              {courseId && (
                <TouchableOpacity
                  onPress={handleTryAgain}
                  className="w-full py-4 rounded-full items-center justify-center flex-row"
                  style={{ backgroundColor: colors.primary }}
                  activeOpacity={0.85}
                >
                  <Ionicons name="refresh" size={22} color="#FFFFFF" className="mr-2" />
                  <ThemedText type="button" className="text-white font-bold">
                    Try Again
                  </ThemedText>
                </TouchableOpacity>
              )}

              <TouchableOpacity
                onPress={handleContactSupport}
                className="w-full py-4 rounded-full items-center justify-center flex-row border-2"
                style={{ 
                  borderColor: colors.primary,
                  backgroundColor: isDarkMode ? 'rgba(96,165,250,0.1)' : 'rgba(37,99,235,0.1)',
                }}
                activeOpacity={0.85}
              >
                <Ionicons name="headset" size={22} style={{ color: colors.primary, marginRight: 8 }} />
                <ThemedText type="button" className="font-bold" style={{ color: colors.primary }}>
                  Contact Support
                </ThemedText>
              </TouchableOpacity>

              <TouchableOpacity
                onPress={handleGoHome}
                className="w-full py-3 rounded-full items-center justify-center"
                activeOpacity={0.7}
              >
                <ThemedText type="button" className="font-medium" style={{ color: colors.textSecondary }}>
                  Back to Home
                </ThemedText>
              </TouchableOpacity>
            </View>

            {/* Helpful Info */}
            <ThemedView type="backgroundElement" className="w-full mt-8 rounded-xl p-4" style={{ maxWidth: 400 }}>
              <View className="flex-row items-start">
                <Ionicons name="information-circle" size={20} color={colors.info} className="mr-3 mt-0.5" />
                <View className="flex-1">
                  <ThemedText type="caption" className="font-semibold mb-1" style={{ color: colors.text }}>
                    Need help?
                  </ThemedText>
                  <ThemedText type="caption" style={{ color: colors.textSecondary, lineHeight: 20 }}>
                    Common issues: insufficient balance, network timeout, or expired session. 
                    Your account was not charged for failed payments.
                  </ThemedText>
                </View>
              </View>
            </ThemedView>
          </View>
        )}

        {/* Loading fallback */}
        {!showContent && animationScale === 0 && (
          <View className="items-center">
            <Ionicons name="close-circle" size={80} color={colors.error} />
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
    backgroundColor: '#EF4444',
  },
  checkCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: '#EF4444',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#EF4444',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.4,
    shadowRadius: 20,
    elevation: 8,
  },
});