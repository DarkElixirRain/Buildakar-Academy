// app/(auth)/login.tsx
import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  KeyboardAvoidingView,
  ScrollView,
  Platform,
  SafeAreaView,
  Dimensions,
  Alert,
  ActivityIndicator,
  TextInput,
} from 'react-native';
import { useRouter, Link } from 'expo-router';
import { useAuthStore } from '@/store/authStore';
import googleAuth from '@/lib/googleAuth';
import api from '@/lib/api';
import { Ionicons } from '@expo/vector-icons';

const { width } = Dimensions.get('window');

// Simple custom input component to avoid dependency issues
const CustomInput: React.FC<{
  label: string;
  value: string;
  onChangeText: (text: string) => void;
  placeholder: string;
  secureTextEntry?: boolean;
  error?: string | null;
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
  keyboardType?: 'default' | 'email-address' | 'numeric' | 'phone-pad';
}> = ({
  label,
  value,
  onChangeText,
  placeholder,
  secureTextEntry = false,
  error = null,
  autoCapitalize = 'none',
  keyboardType = 'default',
}) => {
  const [showPassword, setShowPassword] = React.useState(false);

  return (
    <View style={{ marginBottom: 16 }}>
      <Text style={{ fontSize: 14, fontWeight: '600', color: '#0f172a', marginBottom: 6 }}>
        {label}
      </Text>
      <View style={{
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: '#f8fafc',
        borderWidth: 1,
        borderColor: error ? '#ef4444' : '#e2e8f0',
        borderRadius: 12,
        paddingHorizontal: 12,
        paddingVertical: 2,
      }}>
        <TextInput
          style={{
            flex: 1,
            paddingVertical: 10,
            fontSize: 16,
            color: '#0f172a',
          }}
          placeholder={placeholder}
          placeholderTextColor="#94a3b8"
          value={value}
          onChangeText={onChangeText}
          secureTextEntry={secureTextEntry && !showPassword}
          autoCapitalize={autoCapitalize}
          keyboardType={keyboardType}
        />
        {secureTextEntry && (
          <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
            <Ionicons 
              name={showPassword ? 'eye-off-outline' : 'eye-outline'} 
              size={20} 
              color="#64748b" 
            />
          </TouchableOpacity>
        )}
      </View>
      {error && (
        <Text style={{ color: '#ef4444', fontSize: 12, marginTop: 4 }}>{error}</Text>
      )}
    </View>
  );
};

// Simple button component
const CustomButton: React.FC<{
  title: string;
  onPress: () => void;
  loading?: boolean;
  disabled?: boolean;
}> = ({ title, onPress, loading = false, disabled = false }) => {
  return (
    <TouchableOpacity
      style={{
        width: '100%',
        paddingVertical: 14,
        borderRadius: 12,
        backgroundColor: disabled || loading ? '#94a3b8' : '#0a53d6',
        alignItems: 'center',
        justifyContent: 'center',
      }}
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.7}
    >
      {loading ? (
        <ActivityIndicator size="small" color="#ffffff" />
      ) : (
        <Text style={{ color: '#ffffff', fontWeight: 'bold', fontSize: 16 }}>
          {title}
        </Text>
      )}
    </TouchableOpacity>
  );
};

// Validation helpers
const validateEmail = (email: string): string | null => {
  if (!email) return 'Email is required';
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) return 'Please enter a valid email address';
  return null;
};

const validatePassword = (password: string): string | null => {
  if (!password) return 'Password is required';
  if (password.length < 8) return 'Password must be at least 8 characters';
  return null;
};

export default function LoginScreen() {
  const router = useRouter();
  const { login, loading, isAuthenticated, initialized, requiresRoleSelection, user } = useAuthStore();
  const hasRedirected = useRef(false);

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [emailError, setEmailError] = useState<string | null>(null);
  const [passwordError, setPasswordError] = useState<string | null>(null);
  const [generalError, setGeneralError] = useState<string | null>(null);

  const isSmallDevice = width < 375;
  const isTablet = width >= 768;
  const cardPadding = isSmallDevice ? 16 : isTablet ? 32 : 24;

  // Check if already authenticated and redirect
  useEffect(() => {
    if (initialized && isAuthenticated && !hasRedirected.current) {
      hasRedirected.current = true;

      if (requiresRoleSelection && !user?.hasCompletedOnboarding) {
        router.replace('/(auth)/role-selection');
      } else {
        router.replace('/(tabs)' as any);
      }
    }
  }, [isAuthenticated, initialized, requiresRoleSelection, user?.hasCompletedOnboarding, router]);

  // Reset redirect ref when not authenticated
  useEffect(() => {
    if (!isAuthenticated) {
      hasRedirected.current = false;
    }
  }, [isAuthenticated]);

  // Show loading while checking auth state
  if (!initialized) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: '#f8fafc', justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" color="#0a53d6" />
        <Text style={{ marginTop: 16, color: '#64748b', fontSize: 14, fontWeight: '500' }}>
          Loading...
        </Text>
      </SafeAreaView>
    );
  }

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
      await login(email, password);
      // Navigation will be handled by the useEffect
    } catch (err: any) {
      const errorMessage = err?.message || 'Authentication failed. Please try again.';
      setGeneralError(errorMessage);
      
      Alert.alert('Login Failed', errorMessage, [{ text: 'Try Again' }]);
    }
  };

  const handleForgotPassword = () => {
    router.push('/(auth)/forgot-password');
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#f8fafc' }}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={{ flex: 1 }}
      >
        <ScrollView
          showsVerticalScrollIndicator={false}
          contentContainerStyle={{
            flexGrow: 1,
            justifyContent: 'center',
            paddingVertical: isSmallDevice ? 16 : 32,
          }}
        >
          <View style={{ width: '100%', paddingHorizontal: 16 }}>
            <View style={{ width: '100%', maxWidth: 480, marginHorizontal: 'auto', alignItems: 'center' }}>
              {/* Simple Logo */}
              <View style={{ marginBottom: 24, alignItems: 'center', justifyContent: 'center' }}>
                <View style={{ width: 80, height: 80, borderRadius: 40, backgroundColor: '#dbeafe', alignItems: 'center', justifyContent: 'center' }}>
                  <Text style={{ fontSize: 32, color: '#0a53d6', fontWeight: 'bold' }}>B</Text>
                </View>
              </View>

              {/* Title & Subtitle */}
              <Text 
                style={{
                  fontWeight: 'bold',
                  color: '#0f172a',
                  textAlign: 'center',
                  marginBottom: 8,
                  fontSize: isSmallDevice ? 24 : 32,
                }}
              >
                Welcome Back
              </Text>
              <Text 
                style={{
                  color: '#64748b',
                  textAlign: 'center',
                  marginBottom: 24,
                  paddingHorizontal: 16,
                  fontSize: isSmallDevice ? 13 : 15,
                }}
              >
                Continue your high-performance learning journey with Buildakar.
              </Text>

              {/* Main White Card Container */}
              <View 
                style={{
                  width: '100%',
                  backgroundColor: '#ffffff',
                  borderRadius: 24,
                  borderWidth: 1,
                  borderColor: '#f1f5f9',
                  padding: cardPadding,
                  shadowColor: '#0f172a',
                  shadowOffset: { width: 0, height: 2 },
                  shadowOpacity: 0.05,
                  shadowRadius: 4,
                  elevation: 4,
                }}
              >
                {generalError && (
                  <View style={{ backgroundColor: '#fef2f2', borderWidth: 1, borderColor: '#fecaca', borderRadius: 12, padding: 12, marginBottom: 16 }}>
                    <Text style={{ color: '#dc2626', fontSize: 14, textAlign: 'center', fontWeight: '500' }}>
                      {generalError}
                    </Text>
                  </View>
                )}

                {/* Email Address */}
                <CustomInput
                  label="Email Address"
                  placeholder="Enter your email"
                  value={email}
                  onChangeText={(text) => {
                    setEmail(text);
                    if (emailError) setEmailError(null);
                  }}
                  error={emailError}
                  autoCapitalize="none"
                  keyboardType="email-address"
                />

                {/* Password */}
                <CustomInput
                  label="Password"
                  placeholder="Enter your password"
                  value={password}
                  onChangeText={(text) => {
                    setPassword(text);
                    if (passwordError) setPasswordError(null);
                  }}
                  error={passwordError}
                  secureTextEntry
                />

                {/* Forgot Password Button */}
                <View style={{ flexDirection: 'row', justifyContent: 'flex-end', marginTop: -8, marginBottom: 16 }}>
                  <TouchableOpacity onPress={handleForgotPassword} activeOpacity={0.7}>
                    <Text style={{ fontWeight: '600', color: '#0a53d6', fontSize: isSmallDevice ? 12 : 14 }}>
                      Forgot Password?
                    </Text>
                  </TouchableOpacity>
                </View>

                {/* Sign In Button */}
                <View style={{ marginTop: 8, marginBottom: 24 }}>
                  <CustomButton
                    title="Sign In"
                    onPress={handleSignIn}
                    loading={loading}
                  />
                </View>

                {/* Divider */}
                <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 16 }}>
                  <View style={{ flex: 1, height: 1, backgroundColor: '#e2e8f0' }} />
                  <Text style={{ fontWeight: 'bold', color: '#94a3b8', letterSpacing: 1, paddingHorizontal: 12, fontSize: isSmallDevice ? 9 : 11 }}>
                    or continue with
                  </Text>
                  <View style={{ flex: 1, height: 1, backgroundColor: '#e2e8f0' }} />
                </View>

                {/* Social Login Buttons */}
                <View style={{ flexDirection: 'row', gap: 8 }}>
                  <TouchableOpacity
                    activeOpacity={0.8}
                    style={{
                      flex: 1,
                      flexDirection: 'row',
                      alignItems: 'center',
                      justifyContent: 'center',
                      borderWidth: 1,
                      borderColor: '#e2e8f0',
                      borderRadius: 12,
                      backgroundColor: '#ffffff',
                      paddingVertical: isSmallDevice ? 10 : 14,
                    }}
                    onPress={async () => {
                      try {
                        setGeneralError(null);
                        const { code, codeVerifier, redirectUri } = await googleAuth.signInWithGoogle();
                        // Send code to backend
                        const response = await api.post('/api/auth/google', { code, codeVerifier, redirectUri });

                        if (response.data?.success) {
                          const { user, token } = response.data.data;
                          // Use existing auth store to set state and persist
                          useAuthStore.setState({ user, token, isAuthenticated: true, initialized: true });
                        } else {
                          throw new Error(response.data?.message || 'Google login failed');
                        }
                      } catch (err: any) {
                        const message = err?.message || 'Google sign-in failed';
                        Alert.alert('Google Sign-In', message);
                      }
                    }}
                  >
                    <Ionicons name="logo-google" size={isSmallDevice ? 16 : 18} color="#ea4335" />
                    <Text style={{ fontWeight: 'bold', color: '#0f172a', marginLeft: 8, fontSize: isSmallDevice ? 12 : 14 }}>
                      Google
                    </Text>
                  </TouchableOpacity>
                </View>
              </View>

              {/* Bottom Link */}
              <View style={{ marginTop: 24, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', flexWrap: 'wrap' }}>
                <Text style={{ color: '#475569', fontSize: isSmallDevice ? 13 : 15 }}>
                  Don't have an account?{' '}
                </Text>
                <Link href="/(auth)/signup" asChild>
                  <TouchableOpacity>
                    <Text style={{ fontWeight: 'bold', color: '#0a53d6', fontSize: isSmallDevice ? 13 : 15 }}>
                      Create Account
                    </Text>
                  </TouchableOpacity>
                </Link>
              </View>
            </View>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}