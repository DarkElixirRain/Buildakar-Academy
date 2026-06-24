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

export default function ForgotPasswordScreen() {
  const router = useRouter();
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

  return (
    <SafeAreaView className="flex-1 bg-[#f8fafc]">
      {/* Background Glows */}
      <View
        className="absolute top-[-100px] left-[-100px] w-[350px] h-[350px] rounded-full bg-blue-100/40"
        style={{ filter: Platform.OS === 'web' ? 'blur(80px)' : undefined } as any}
      />

      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        className="flex-1"
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
            <View className="w-full bg-white rounded-[24px] p-6 border border-[#f1f5f9] shadow-lg shadow-slate-200/50">
              {!submitted ? (
                <>
                  <Text className="text-[26px] font-bold text-[#0f172a] text-center mb-2 tracking-tight">
                    Reset Password
                  </Text>
                  <Text className="text-[14px] text-[#64748b] text-center mb-6 leading-5 font-normal">
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
                  <View className="w-16 h-16 bg-green-50 rounded-full items-center justify-center mb-4 border border-green-100">
                    <Feather name="check" size={30} color="#22c55e" />
                  </View>
                  <Text className="text-[22px] font-bold text-[#0f172a] text-center mb-2">
                    Check Your Email
                  </Text>
                  <Text className="text-[14px] text-[#64748b] text-center mb-6 leading-5 font-normal px-2">
                    We have sent password reset instructions to <Text className="font-semibold text-slate-700">{email}</Text>.
                  </Text>

                  <TouchableOpacity
                    activeOpacity={0.8}
                    onPress={() => setSubmitted(false)}
                    className="w-full bg-[#f1f5f9] h-[52px] rounded-[12px] justify-center items-center px-4"
                  >
                    <Text className="text-[#475569] text-[16px] font-bold">
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
                  <Feather name="arrow-left" size={16} color="#0a53d6" />
                  <Text className="text-[15px] font-bold text-[#0a53d6]">
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
