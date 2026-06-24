import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  KeyboardAvoidingView,
  ScrollView,
  Platform,
  SafeAreaView,
} from 'react-native';
import { Image } from 'expo-image';
import { Link, useRouter } from 'expo-router';
import { FontAwesome } from '@expo/vector-icons';
import { useAuthStore } from '@/store/authStore';
import { AuthInput } from '@/components/auth/AuthInput';
import { AuthButton } from '@/components/auth/AuthButton';
import { validateEmail, validatePassword } from '@/lib/validation';
import { images } from '@/constants/images';

export default function LoginScreen() {
  const router = useRouter();
  const { login, loading } = useAuthStore();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const [emailError, setEmailError] = useState<string | null>(null);
  const [passwordError, setPasswordError] = useState<string | null>(null);
  const [generalError, setGeneralError] = useState<string | null>(null);

  const handleSignIn = async () => {
    setEmailError(null);
    setPasswordError(null);
    setGeneralError(null);

    const emailErr = validateEmail(email);
    const passErr = validatePassword(password);

    if (emailErr || passErr) {
      setEmailError(emailErr);
      setPasswordError(passErr);
      return;
    }

    try {
      await login(email);
      // Auth status update in Zustand will trigger auto-redirect to tabs in root layout
    } catch (err: any) {
      setGeneralError(err?.message || 'Authentication failed. Please try again.');
    }
  };

  return (
    <SafeAreaView className="flex-1 bg-[#f8fafc]">
      {/* Background Glows for Premium Aesthetic */}
      <View
        className="absolute top-[-100px] left-[-100px] w-[350px] h-[350px] rounded-full bg-blue-100/40"
        style={{ filter: Platform.OS === 'web' ? 'blur(80px)' : undefined } as any}
      />
      <View
        className="absolute top-[20%] right-[-150px] w-[400px] h-[400px] rounded-full bg-indigo-50/55"
        style={{ filter: Platform.OS === 'web' ? 'blur(100px)' : undefined } as any}
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

            {/* Title & Subtitle */}
            <Text className="text-[32px] font-bold text-[#0f172a] text-center mb-2 tracking-tight">
              Welcome Back
            </Text>
            <Text className="text-[15px] text-[#64748b] text-center mb-8 px-4 leading-5 font-normal">
              Continue your high-performance learning journey with Buildakar.
            </Text>

            {/* Main White Card Container */}
            <View className="w-full bg-white rounded-[24px] p-6 border border-[#f1f5f9] shadow-lg shadow-slate-200/50">
              {generalError && (
                <View className="bg-red-50 border border-red-100 rounded-xl p-3 mb-4">
                  <Text className="text-red-600 text-sm text-center font-medium">
                    {generalError}
                  </Text>
                </View>
              )}

              {/* Email Address */}
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

              {/* Password */}
              <AuthInput
                label="Password"
                iconName="lock"
                placeholder="••••••••"
                isPassword
                value={password}
                onChangeText={(text) => {
                  setPassword(text);
                  if (passwordError) setPasswordError(null);
                }}
                error={passwordError}
                rightElement={
                  <Link href="/(auth)/forgot-password" asChild>
                    <TouchableOpacity>
                      <Text className="text-[13px] font-semibold text-[#0a53d6]">
                        Forgot Password?
                      </Text>
                    </TouchableOpacity>
                  </Link>
                }
              />

              {/* Sign In Button */}
              <View className="mt-2 mb-6">
                <AuthButton
                  title="Sign In"
                  onPress={handleSignIn}
                  loading={loading}
                />
              </View>

              {/* Divider: OR CONTINUE WITH */}
              <View className="flex-row items-center mb-6">
                <View className="flex-1 h-[1px] bg-[#e2e8f0]" />
                <Text className="text-[11px] font-bold text-[#94a3b8] tracking-wider px-3 uppercase">
                  or continue with
                </Text>
                <View className="flex-1 h-[1px] bg-[#e2e8f0]" />
              </View>

              {/* Social Login Buttons */}
              <View className="flex-row gap-3">
                <TouchableOpacity
                  activeOpacity={0.8}
                  className="flex-1 flex-row items-center justify-center border border-[#e2e8f0] rounded-[12px] py-3.5 bg-white"
                >
                  <FontAwesome name="google" size={18} color="#ea4335" />
                  <Text className="text-[14px] font-bold text-[#0f172a] ml-2">
                    Google
                  </Text>
                </TouchableOpacity>

                <TouchableOpacity
                  activeOpacity={0.8}
                  className="flex-1 flex-row items-center justify-center border border-[#e2e8f0] rounded-[12px] py-3.5 bg-white"
                >
                  <FontAwesome name="apple" size={18} color="#000000" />
                  <Text className="text-[14px] font-bold text-[#0f172a] ml-2">
                    Apple
                  </Text>
                </TouchableOpacity>
              </View>
            </View>

            {/* Bottom Link */}
            <View className="mt-8 flex-row items-center justify-center">
              <Text className="text-[15px] text-[#475569] font-normal">
                Don't have an account?{' '}
              </Text>
              <Link href="/(auth)/signup" asChild>
                <TouchableOpacity>
                  <Text className="text-[15px] font-bold text-[#0a53d6]">
                    Create Account
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
