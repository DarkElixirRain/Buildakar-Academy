// frontend/src/app/(auth)/signup.tsx
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
import { useTheme } from '@/context/themeContext';

const { width } = Dimensions.get('window');

// Simple custom input component
const CustomInput: React.FC<{
  label: string;
  value: string;
  onChangeText: (text: string) => void;
  placeholder: string;
  secureTextEntry?: boolean;
  error?: string | null;
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
  keyboardType?: 'default' | 'email-address' | 'numeric' | 'phone-pad';
  colors: any;
  isDarkMode: boolean;
}> = ({
  label,
  value,
  onChangeText,
  placeholder,
  secureTextEntry = false,
  error = null,
  autoCapitalize = 'none',
  keyboardType = 'default',
  colors,
  isDarkMode,
}) => {
  const [showPassword, setShowPassword] = useState(false);

  return (
    <View style={{ marginBottom: 16 }}>
      <Text style={{ fontSize: 14, fontWeight: '600', color: colors.text, marginBottom: 6 }}>
        {label}
      </Text>
      <View style={{
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: colors.backgroundElement,
        borderWidth: 1,
        borderColor: error ? '#ef4444' : colors.backgroundSelected,
        borderRadius: 12,
        paddingHorizontal: 12,
        paddingVertical: 2,
      }}>
        <TextInput
          style={{
            flex: 1,
            paddingVertical: 10,
            fontSize: 16,
            color: colors.text,
          }}
          placeholder={placeholder}
          placeholderTextColor={colors.textSecondary}
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
              color={colors.textSecondary} 
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
  colors: any;
}> = ({ title, onPress, loading = false, disabled = false, colors }) => {
  return (
    <TouchableOpacity
      style={{
        width: '100%',
        paddingVertical: 14,
        borderRadius: 12,
        backgroundColor: disabled || loading ? colors.textSecondary : colors.primary,
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
const validateFirstName = (firstName: string): string | null => {
  if (!firstName || !firstName.trim()) return 'First name is required';
  if (firstName.trim().length < 2) return 'First name must be at least 2 characters';
  return null;
};

const validateLastName = (lastName: string): string | null => {
  if (!lastName || !lastName.trim()) return 'Last name is required';
  if (lastName.trim().length < 2) return 'Last name must be at least 2 characters';
  return null;
};

const validateEmail = (email: string): string | null => {
  if (!email || !email.trim()) return 'Email is required';
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email.trim())) return 'Please enter a valid email address';
  return null;
};

const validatePassword = (password: string): string | null => {
  if (!password) return 'Password is required';
  if (password.length < 8) return 'Password must be at least 8 characters';
  if (!/(?=.*[a-z])/.test(password)) return 'Password must contain at least one lowercase letter';
  if (!/(?=.*[A-Z])/.test(password)) return 'Password must contain at least one uppercase letter';
  if (!/(?=.*\d)/.test(password)) return 'Password must contain at least one number';
  return null;
};

const validateConfirmPassword = (password: string, confirmPassword: string): string | null => {
  if (!confirmPassword) return 'Please confirm your password';
  if (password !== confirmPassword) return 'Passwords do not match';
  return null;
};

export default function SignupScreen() {
  const router = useRouter();
  const { signup, loading, isAuthenticated, initialized, requiresRoleSelection, user } = useAuthStore();
  const { colors, isDarkMode } = useTheme();
  const hasRedirected = useRef(false);

  // Form state
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  
  const [firstNameError, setFirstNameError] = useState<string | null>(null);
  const [lastNameError, setLastNameError] = useState<string | null>(null);
  const [emailError, setEmailError] = useState<string | null>(null);
  const [passwordError, setPasswordError] = useState<string | null>(null);
  const [confirmPasswordError, setConfirmPasswordError] = useState<string | null>(null);
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
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.background, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" color={colors.primary} />
        <Text style={{ marginTop: 16, color: colors.textSecondary, fontSize: 14, fontWeight: '500' }}>
          Loading...
        </Text>
      </SafeAreaView>
    );
  }

  const handleSignUp = async () => {
    // Clear all errors
    setFirstNameError(null);
    setLastNameError(null);
    setEmailError(null);
    setPasswordError(null);
    setConfirmPasswordError(null);
    setGeneralError(null);

    // Validate all fields
    const firstNameErr = validateFirstName(firstName);
    const lastNameErr = validateLastName(lastName);
    const emailErr = validateEmail(email);
    const passErr = validatePassword(password);
    const confirmPassErr = validateConfirmPassword(password, confirmPassword);

    if (firstNameErr || lastNameErr || emailErr || passErr || confirmPassErr) {
      setFirstNameError(firstNameErr);
      setLastNameError(lastNameErr);
      setEmailError(emailErr);
      setPasswordError(passErr);
      setConfirmPasswordError(confirmPassErr);
      return;
    }

    try {
      // Call signup from auth store
      const result = await signup(
        email.trim().toLowerCase(),
        firstName.trim(),
        lastName.trim(),
        password
      );
      
      // Navigation will be handled by the useEffect when isAuthenticated becomes true
      Alert.alert('Success', 'Your account has been created successfully!', [
        { text: 'Continue' }
      ]);
      
    } catch (err: any) {
      const errorMessage = err?.message || 'Registration failed. Please try again.';
      setGeneralError(errorMessage);
      
      Alert.alert('Registration Failed', errorMessage, [{ text: 'Try Again' }]);
    }
  };

  const handleSocialSignUp = async (provider: string) => {
    if (provider === 'Google') {
      try {
        setGeneralError(null);
        const { code, codeVerifier, redirectUri } = await googleAuth.signInWithGoogle();
        // Send code to backend
        const response = await api.post('/api/auth/google', { code, codeVerifier, redirectUri });

        if (response.data?.success) {
          const { user, token } = response.data.data;
          // Use existing auth store to set state and persist
          useAuthStore.setState({ user, token, isAuthenticated: true, initialized: true, requiresRoleSelection: true });
        } else {
          throw new Error(response.data?.message || 'Google sign-up failed');
        }
      } catch (err: any) {
        const message = err?.message || 'Google sign-up failed';
        Alert.alert('Google Sign-Up', message);
      }
    } else {
      Alert.alert('Coming Soon', `${provider} sign up will be available soon!`);
    }
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
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
              {/* Logo */}
              <View style={{ marginBottom: 24, alignItems: 'center', justifyContent: 'center' }}>
                <View style={{ 
                  width: 80, 
                  height: 80, 
                  borderRadius: 40, 
                  backgroundColor: isDarkMode ? 'rgba(37, 99, 235, 0.2)' : '#dbeafe', 
                  alignItems: 'center', 
                  justifyContent: 'center' 
                }}>
                  <Ionicons name="person-add-outline" size={32} color={colors.primary} />
                </View>
              </View>

              {/* Title & Subtitle */}
              <Text 
                style={{
                  fontWeight: 'bold',
                  color: colors.text,
                  textAlign: 'center',
                  marginBottom: 8,
                  fontSize: isSmallDevice ? 24 : 32,
                }}
              >
                Create Account
              </Text>
              <Text 
                style={{
                  color: colors.textSecondary,
                  textAlign: 'center',
                  marginBottom: 24,
                  paddingHorizontal: 16,
                  fontSize: isSmallDevice ? 13 : 15,
                }}
              >
                Join Buildakar and start your high-performance learning journey today.
              </Text>

              {/* Main Card Container */}
              <View 
                style={{
                  width: '100%',
                  backgroundColor: colors.backgroundElement,
                  borderRadius: 24,
                  borderWidth: 1,
                  borderColor: colors.backgroundSelected,
                  padding: cardPadding,
                  shadowColor: isDarkMode ? '#000000' : '#0f172a',
                  shadowOffset: { width: 0, height: 2 },
                  shadowOpacity: isDarkMode ? 0.2 : 0.05,
                  shadowRadius: 4,
                  elevation: 4,
                }}
              >
                {/* General Error Message */}
                {generalError && (
                  <View style={{ 
                    backgroundColor: isDarkMode ? 'rgba(239, 68, 68, 0.15)' : '#fef2f2', 
                    borderWidth: 1, 
                    borderColor: isDarkMode ? 'rgba(239, 68, 68, 0.3)' : '#fecaca', 
                    borderRadius: 12, 
                    padding: 12, 
                    marginBottom: 16 
                  }}>
                    <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                      <Ionicons name="alert-circle" size={20} color="#dc2626" style={{ marginRight: 8 }} />
                      <Text style={{ color: '#dc2626', fontSize: 14, flex: 1, fontWeight: '500' }}>
                        {generalError}
                      </Text>
                    </View>
                  </View>
                )}

                {/* First Name */}
                <CustomInput
                  label="First Name"
                  placeholder="Enter your first name"
                  value={firstName}
                  onChangeText={(text) => {
                    setFirstName(text);
                    if (firstNameError) setFirstNameError(null);
                  }}
                  error={firstNameError}
                  autoCapitalize="words"
                  colors={colors}
                  isDarkMode={isDarkMode}
                />

                {/* Last Name */}
                <CustomInput
                  label="Last Name"
                  placeholder="Enter your last name"
                  value={lastName}
                  onChangeText={(text) => {
                    setLastName(text);
                    if (lastNameError) setLastNameError(null);
                  }}
                  error={lastNameError}
                  autoCapitalize="words"
                  colors={colors}
                  isDarkMode={isDarkMode}
                />

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
                  colors={colors}
                  isDarkMode={isDarkMode}
                />

                {/* Password */}
                <CustomInput
                  label="Password"
                  placeholder="Create a strong password"
                  value={password}
                  onChangeText={(text) => {
                    setPassword(text);
                    if (passwordError) setPasswordError(null);
                  }}
                  error={passwordError}
                  secureTextEntry
                  colors={colors}
                  isDarkMode={isDarkMode}
                />

                {/* Confirm Password */}
                <CustomInput
                  label="Confirm Password"
                  placeholder="Confirm your password"
                  value={confirmPassword}
                  onChangeText={(text) => {
                    setConfirmPassword(text);
                    if (confirmPasswordError) setConfirmPasswordError(null);
                  }}
                  error={confirmPasswordError}
                  secureTextEntry
                  colors={colors}
                  isDarkMode={isDarkMode}
                />

                {/* Terms and Conditions */}
                <View style={{ marginTop: -8, marginBottom: 20 }}>
                  <Text style={{ color: colors.textSecondary, fontSize: 12, textAlign: 'center', lineHeight: 18 }}>
                    By creating an account, you agree to our{' '}
                    <Text style={{ color: colors.primary, fontWeight: '600' }}>Terms of Service</Text>
                    {' '}and{' '}
                    <Text style={{ color: colors.primary, fontWeight: '600' }}>Privacy Policy</Text>
                  </Text>
                </View>

                {/* Sign Up Button */}
                <View style={{ marginBottom: 24 }}>
                  <CustomButton
                    title="Create Account"
                    onPress={handleSignUp}
                    loading={loading}
                    colors={colors}
                  />
                </View>

                {/* Divider */}
                <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 16 }}>
                  <View style={{ flex: 1, height: 1, backgroundColor: colors.backgroundSelected }} />
                  <Text style={{ 
                    fontWeight: 'bold', 
                    color: colors.textSecondary, 
                    letterSpacing: 1, 
                    paddingHorizontal: 12, 
                    fontSize: isSmallDevice ? 9 : 11 
                  }}>
                    or sign up with
                  </Text>
                  <View style={{ flex: 1, height: 1, backgroundColor: colors.backgroundSelected }} />
                </View>

                {/* Social Sign Up Buttons */}
                <View style={{ flexDirection: 'row', gap: 8 }}>
                  <TouchableOpacity
                    activeOpacity={0.8}
                    style={{
                      flex: 1,
                      flexDirection: 'row',
                      alignItems: 'center',
                      justifyContent: 'center',
                      borderWidth: 1,
                      borderColor: colors.backgroundSelected,
                      borderRadius: 12,
                      backgroundColor: colors.backgroundElement,
                      paddingVertical: isSmallDevice ? 10 : 14,
                    }}
                    onPress={() => handleSocialSignUp('Google')}
                  >
                    <Ionicons name="logo-google" size={isSmallDevice ? 16 : 18} color="#ea4335" />
                    <Text style={{ 
                      fontWeight: 'bold', 
                      color: colors.text, 
                      marginLeft: 8, 
                      fontSize: isSmallDevice ? 12 : 14 
                    }}>
                      Google
                    </Text>
                  </TouchableOpacity>
                </View>
              </View>

              {/* Bottom Link to Login */}
              <View style={{ 
                marginTop: 24, 
                flexDirection: 'row', 
                alignItems: 'center', 
                justifyContent: 'center', 
                flexWrap: 'wrap' 
              }}>
                <Text style={{ color: colors.textSecondary, fontSize: isSmallDevice ? 13 : 15 }}>
                  Already have an account?{' '}
                </Text>
                <Link href="/(auth)/login" asChild>
                  <TouchableOpacity>
                    <Text style={{ 
                      fontWeight: 'bold', 
                      color: colors.primary, 
                      fontSize: isSmallDevice ? 13 : 15 
                    }}>
                      Sign In
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