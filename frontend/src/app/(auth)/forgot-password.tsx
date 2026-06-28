// app/(auth)/forgot-password.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  KeyboardAvoidingView,
  ScrollView,
  Platform,
  SafeAreaView,
  Alert,
} from 'react-native';
import { Image } from 'expo-image';
import { Link, useRouter } from 'expo-router';
import { Feather } from '@expo/vector-icons';
import { AuthInput } from '@/components/auth/AuthInput';
import { AuthButton } from '@/components/auth/AuthButton';
import { validateEmail } from '@/lib/validation';
import { images } from '@/constants/images';
import { useTheme } from '@/context/themeContext';

export default function ForgotPasswordScreen() {
  const router = useRouter();
  const { colors, isDarkMode } = useTheme();
  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const handleResetPassword = async () => {
    setEmailError(null);
    const err = validateEmail(email);
    if (err) {
      setEmailError(err);
      return;
    }

    setLoading(true);
    try {
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 1500));
      setSubmitted(true);
    } catch (err: any) {
      Alert.alert('Error', 'Failed to send reset email. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Theme-based colors
  const bgColor = colors.background;
  const glowColor = isDarkMode ? 'rgba(37, 99, 235, 0.05)' : 'rgba(37, 99, 235, 0.1)';
  const cardBgColor = colors.backgroundElement;
  const cardBorderColor = colors.backgroundSelected;
  const titleColor = colors.text;
  const subtitleColor = colors.textSecondary;
  const linkColor = colors.primary;
  const successBgColor = isDarkMode ? 'rgba(34, 197, 94, 0.15)' : '#f0fdf4';
  const successBorderColor = isDarkMode ? 'rgba(34, 197, 94, 0.3)' : '#dcfce7';
  const successIconColor = '#22c55e';
  const resendBgColor = colors.backgroundSelected;
  const resendTextColor = colors.text;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: bgColor }}>
      {/* Background Glows */}
      <View
        style={{
          position: 'absolute',
          top: -100,
          left: -100,
          width: 350,
          height: 350,
          borderRadius: 175,
          backgroundColor: glowColor,
          ...(Platform.OS === 'web' ? { filter: 'blur(80px)' } : {}),
        }}
      />

      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={{ flex: 1 }}
      >
        <ScrollView
          showsVerticalScrollIndicator={false}
          contentContainerStyle={{ flexGrow: 1, justifyContent: 'center' }}
          className="px-6 py-8"
        >
          <View className="w-full max-w-[420px] mx-auto items-center">
            {/* Logo */}
            <View className="mb-6 items-center justify-center">
              <Image
                source={images.logo}
                className="w-24 h-24"
                contentFit="contain"
              />
            </View>

            {/* Main White Card Container */}
            <View
              style={{
                width: '100%',
                backgroundColor: cardBgColor,
                borderRadius: 24,
                padding: 24,
                borderWidth: 1,
                borderColor: cardBorderColor,
                shadowColor: isDarkMode ? '#000000' : '#0f172a',
                shadowOffset: { width: 0, height: 4 },
                shadowOpacity: isDarkMode ? 0.2 : 0.05,
                shadowRadius: 8,
                elevation: 4,
              }}
            >
              {!submitted ? (
                <>
                  <Text
                    style={{
                      fontSize: 26,
                      fontWeight: '700',
                      color: titleColor,
                      textAlign: 'center',
                      marginBottom: 8,
                      letterSpacing: -0.5,
                    }}
                  >
                    Reset Password
                  </Text>
                  <Text
                    style={{
                      fontSize: 14,
                      color: subtitleColor,
                      textAlign: 'center',
                      marginBottom: 24,
                      lineHeight: 20,
                      fontWeight: '400',
                    }}
                  >
                    Enter your email address and we'll send you a link to reset your password.
                  </Text>

                  {/* Email Input */}
                  <AuthInput
                    label="Email Address"
                    iconName="mail"
                    placeholder="name@company.com"
                    keyboardType="email-address"
                    autoCapitalize="none"
                    autoCorrect={false}
                    value={email}
                    onChangeText={(text) => {
                      setEmail(text);
                      if (emailError) setEmailError(null);
                    }}
                    error={emailError}
                  />

                  {/* Submit Button */}
                  <View className="mt-4 mb-2">
                    <AuthButton
                      title="Send Reset Link"
                      onPress={handleResetPassword}
                      loading={loading}
                    />
                  </View>
                </>
              ) : (
                <View className="items-center py-4">
                  <View
                    style={{
                      width: 64,
                      height: 64,
                      backgroundColor: successBgColor,
                      borderRadius: 32,
                      alignItems: 'center',
                      justifyContent: 'center',
                      marginBottom: 16,
                      borderWidth: 1,
                      borderColor: successBorderColor,
                    }}
                  >
                    <Feather name="check" size={30} color={successIconColor} />
                  </View>
                  <Text
                    style={{
                      fontSize: 22,
                      fontWeight: '700',
                      color: titleColor,
                      textAlign: 'center',
                      marginBottom: 8,
                    }}
                  >
                    Check Your Email
                  </Text>
                  <Text
                    style={{
                      fontSize: 14,
                      color: subtitleColor,
                      textAlign: 'center',
                      marginBottom: 24,
                      lineHeight: 20,
                      fontWeight: '400',
                      paddingHorizontal: 8,
                    }}
                  >
                    We have sent password reset instructions to{' '}
                    <Text style={{ fontWeight: '600', color: titleColor }}>
                      {email}
                    </Text>.
                  </Text>

                  <TouchableOpacity
                    activeOpacity={0.8}
                    onPress={() => setSubmitted(false)}
                    style={{
                      width: '100%',
                      height: 52,
                      borderRadius: 12,
                      justifyContent: 'center',
                      alignItems: 'center',
                      paddingHorizontal: 16,
                      backgroundColor: resendBgColor,
                    }}
                  >
                    <Text
                      style={{
                        color: resendTextColor,
                        fontSize: 16,
                        fontWeight: '700',
                      }}
                    >
                      Resend Link
                    </Text>
                  </TouchableOpacity>
                </View>
              )}
            </View>

            {/* Back to Sign In Link */}
            <View className="mt-8 flex-row items-center justify-center">
              <Link href="/(auth)/login" asChild>
                <TouchableOpacity className="flex-row items-center gap-1.5">
                  <Feather name="arrow-left" size={16} color={linkColor} />
                  <Text style={{ fontSize: 15, fontWeight: '700', color: linkColor }}>
                    Back to Sign In
                  </Text>
                </TouchableOpacity>
              </Link>
            </View>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}