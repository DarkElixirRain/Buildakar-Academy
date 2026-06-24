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
import { Link } from 'expo-router';
import { FontAwesome, Feather, Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '@/store/authStore';
import { AuthInput } from '@/components/auth/AuthInput';
import { AuthButton } from '@/components/auth/AuthButton';
import { validateEmail, validatePassword, validateName, getPasswordStrength } from '@/lib/validation';

export default function SignupScreen() {
  const { signup, loading } = useAuthStore();

  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [agreed, setAgreed] = useState(false);

  const [nameError, setNameError] = useState<string | null>(null);
  const [emailError, setEmailError] = useState<string | null>(null);
  const [passwordError, setPasswordError] = useState<string | null>(null);
  const [agreementError, setAgreementError] = useState<string | null>(null);
  const [generalError, setGeneralError] = useState<string | null>(null);

  const passwordStrength = getPasswordStrength(password);

  const handleSignUp = async () => {
    setNameError(null);
    setEmailError(null);
    setPasswordError(null);
    setAgreementError(null);
    setGeneralError(null);

    const nameErr = validateName(name);
    const emailErr = validateEmail(email);
    const passErr = validatePassword(password);
    
    let hasError = false;
    if (nameErr) {
      setNameError(nameErr);
      hasError = true;
    }
    if (emailErr) {
      setEmailError(emailErr);
      hasError = true;
    }
    if (passErr) {
      setPasswordError(passErr);
      hasError = true;
    }

    if (!agreed) {
      setAgreementError('You must agree to the Terms of Service and Privacy Policy');
      hasError = true;
    }

    if (hasError) return;

    try {
      await signup(email, name);
    } catch (err: any) {
      setGeneralError(err?.message || 'Failed to create account. Please try again.');
    }
  };

  return (
    <SafeAreaView className="flex-1 bg-[#f8fafc]">
      {/* Background Glows */}
      <View
        className="absolute top-[-100px] right-[-100px] w-[350px] h-[350px] rounded-full bg-blue-100/30"
        style={{ filter: Platform.OS === 'web' ? 'blur(80px)' : undefined } as any}
      />
      <View
        className="absolute bottom-[-100px] left-[-100px] w-[350px] h-[350px] rounded-full bg-indigo-100/30"
        style={{ filter: Platform.OS === 'web' ? 'blur(80px)' : undefined } as any}
      />

      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        className="flex-1"
      >
        <ScrollView
          showsVerticalScrollIndicator={false}
          contentContainerStyle={{ flexGrow: 1 }}
          className="px-6 py-6"
        >
          {/* Header Area */}
          <View className="flex-row items-center justify-center mt-3 mb-6 w-full max-w-[420px] mx-auto">
            <Ionicons name="sparkles" size={24} color="#0a53d6" />
            <Text className="text-[26px] font-bold text-[#0a53d6] ml-2 tracking-tight">
              Buildakar
            </Text>
          </View>

          {/* Form and Card Container */}
          <View className="w-full max-w-[420px] mx-auto items-center mb-8">
            <View className="w-full bg-white rounded-[24px] p-6 border border-[#f1f5f9] shadow-lg shadow-slate-200/50 relative overflow-hidden">
              {/* Card top border blue highlight */}
              <View className="absolute top-0 left-0 w-1/4 h-[3.5px] bg-[#0a53d6]" />

              {/* Title & Subtitle */}
              <Text className="text-[28px] font-bold text-[#0f172a] text-center mt-2 mb-1 tracking-tight">
                Start Your Journey
              </Text>
              <Text className="text-[14px] text-[#64748b] text-center mb-6 leading-5 font-normal">
                Create your account to unlock premium courses.
              </Text>

              {generalError && (
                <View className="bg-red-50 border border-red-100 rounded-xl p-3 mb-4">
                  <Text className="text-red-600 text-sm text-center font-medium">
                    {generalError}
                  </Text>
                </View>
              )}

              {/* Full Name */}
              <AuthInput
                label="Full Name"
                iconName="user"
                placeholder="John Doe"
                autoCapitalize="words"
                autoCorrect={false}
                value={name}
                onChangeText={(text) => {
                  setName(text);
                  if (nameError) setNameError(null);
                }}
                error={nameError}
              />

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
              />

              {/* Password Strength Meter */}
              {password.length > 0 && (
                <View className="w-full -mt-2 mb-4">
                  <View className="flex-row gap-1 h-1.5 w-full">
                    <View
                      className={`flex-1 h-full rounded-full ${
                        passwordStrength >= 1 ? 'bg-[#0a53d6]' : 'bg-[#e2e8f0]'
                      }`}
                    />
                    <View
                      className={`flex-1 h-full rounded-full ${
                        passwordStrength >= 2 ? 'bg-[#0a53d6]' : 'bg-[#e2e8f0]'
                      }`}
                    />
                    <View
                      className={`flex-1 h-full rounded-full ${
                        passwordStrength >= 3 ? 'bg-[#0a53d6]' : 'bg-[#e2e8f0]'
                      }`}
                    />
                    <View
                      className={`flex-1 h-full rounded-full ${
                        passwordStrength >= 4 ? 'bg-[#0a53d6]' : 'bg-[#e2e8f0]'
                      }`}
                    />
                  </View>
                  <Text className="text-[11px] text-[#64748b] mt-1.5 font-medium">
                    {passwordStrength === 1 && 'Weak password'}
                    {passwordStrength === 2 && 'Fair password'}
                    {passwordStrength === 3 && 'Good password'}
                    {passwordStrength >= 4 && 'Strong password'}
                  </Text>
                </View>
              )}

              {/* Checkbox Agreement */}
              <TouchableOpacity
                activeOpacity={0.8}
                onPress={() => {
                  setAgreed(!agreed);
                  if (agreementError) setAgreementError(null);
                }}
                className="flex-row items-start mt-1 mb-6 px-1"
              >
                <View
                  className={`w-4.5 h-4.5 border rounded-[4px] items-center justify-center mr-2.5 mt-0.5 ${
                    agreed
                      ? 'border-[#0a53d6] bg-[#0a53d6]'
                      : 'border-[#cbd5e1] bg-white'
                  }`}
                  style={{ width: 18, height: 18 }}
                >
                  {agreed && <Feather name="check" size={12} color="#ffffff" />}
                </View>
                <View className="flex-1">
                  <Text className="text-[13px] text-[#475569] leading-4">
                    I agree to the{' '}
                    <Text className="text-[#0a53d6] font-semibold">Terms of Service</Text>{' '}
                    and{' '}
                    <Text className="text-[#0a53d6] font-semibold">Privacy Policy</Text>.
                  </Text>
                </View>
              </TouchableOpacity>
              {agreementError && (
                <Text className="text-red-500 text-[12px] -mt-4 mb-4 ml-1.5 font-medium">
                  {agreementError}
                </Text>
              )}

              {/* Create Account Button */}
              <View className="mb-6">
                <AuthButton
                  title="Create Account"
                  onPress={handleSignUp}
                  loading={loading}
                />
              </View>

              {/* Divider: OR SIGN UP WITH */}
              <View className="flex-row items-center mb-6">
                <View className="flex-1 h-[1px] bg-[#e2e8f0]" />
                <Text className="text-[11px] font-bold text-[#94a3b8] tracking-wider px-3 uppercase">
                  or sign up with
                </Text>
                <View className="flex-1 h-[1px] bg-[#e2e8f0]" />
              </View>

              {/* Social Login Buttons */}
              <View className="flex-row gap-3 mb-6">
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
                  <FontAwesome name="github" size={18} color="#000000" />
                  <Text className="text-[14px] font-bold text-[#0f172a] ml-2">
                    GitHub
                  </Text>
                </TouchableOpacity>
              </View>

              {/* Already have an account link inside the card */}
              <View className="flex-row items-center justify-center mt-2 pt-4 border-t border-[#f1f5f9]">
                <Text className="text-[14px] text-[#475569] font-normal">
                  Already have an account?{' '}
                </Text>
                <Link href="/(auth)/login" asChild>
                  <TouchableOpacity>
                    <Text className="text-[14px] font-bold text-[#0a53d6]">
                      Login
                    </Text>
                  </TouchableOpacity>
                </Link>
              </View>
            </View>
          </View>

          {/* Footer Area */}
          <View className="mt-auto items-center pb-4">
            <View className="flex-row justify-center space-x-4 mb-4">
              <Text className="text-[12px] text-[#94a3b8] font-normal">
                © 2024 Buildakar Academy
              </Text>
              <Text className="text-[12px] text-[#94a3b8] font-normal px-2">|</Text>
              <TouchableOpacity>
                <Text className="text-[12px] text-[#64748b] font-medium">Support</Text>
              </TouchableOpacity>
              <Text className="text-[12px] text-[#94a3b8] font-normal px-2">|</Text>
              <TouchableOpacity>
                <Text className="text-[12px] text-[#64748b] font-medium">Security</Text>
              </TouchableOpacity>
            </View>

            <View className="flex-row gap-3">
              {/* System Online Pill */}
              <View className="flex-row items-center bg-[#f0fdf4] border border-[#dcfce7] rounded-full px-3 py-1">
                <View className="w-1.5 h-1.5 rounded-full bg-[#22c55e] mr-1.5" />
                <Text className="text-[#15803d] text-[11px] font-bold">
                  System Online
                </Text>
              </View>

              {/* Language Pill */}
              <View className="flex-row items-center bg-[#f8fafc] border border-[#e2e8f0] rounded-full px-3 py-1">
                <Feather name="globe" size={10} color="#64748b" className="mr-1.5" />
                <Text className="text-[#475569] text-[11px] font-bold ml-1">
                  English (US)
                </Text>
              </View>
            </View>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
