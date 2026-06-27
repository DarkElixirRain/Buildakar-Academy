// app/(auth)/role-selection.tsx
import React, { useState, useRef } from 'react';
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
} from 'react-native';
import { useRouter } from 'expo-router';
import { useAuthStore } from '@/store/authStore';
import { Ionicons } from '@expo/vector-icons';

const { width } = Dimensions.get('window');

type SignupRole = 'STUDENT' | 'INSTRUCTOR';

const roleOptions: Array<{
  value: SignupRole;
  title: string;
  description: string;
  icon: keyof typeof Ionicons.glyphMap;
}> = [
  {
    value: 'STUDENT',
    title: 'Student',
    description: 'Learn, practice, and track progress',
    icon: 'school-outline',
  },
  {
    value: 'INSTRUCTOR',
    title: 'Instructor',
    description: 'Create and share learning content',
    icon: 'people-outline',
  },
];

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

export default function RoleSelectionScreen() {
  const router = useRouter();
  const { updateRole, user, loading, isAuthenticated, initialized } = useAuthStore();
  const hasRedirected = useRef(false);

  const [selectedRole, setSelectedRole] = useState<SignupRole>('STUDENT');
  const [generalError, setGeneralError] = useState<string | null>(null);

  const isSmallDevice = width < 375;
  const isTablet = width >= 768;
  const cardPadding = isSmallDevice ? 16 : isTablet ? 32 : 24;

  // Check if already authenticated and redirect
  // Note: We only redirect if the user has already completed onboarding
  // If they're authenticated but haven't completed onboarding, they stay here
  // useEffect(() => {
  //   if (initialized && isAuthenticated && user?.hasCompletedOnboarding && !hasRedirected.current) {
  //     hasRedirected.current = true;
  //     router.replace('/(tabs)');
  //   }
  // }, [isAuthenticated, initialized, user?.hasCompletedOnboarding, router]);

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

  const handleContinue = async () => {
    setGeneralError(null);

    try {
      const result = await updateRole(selectedRole);
      
      Alert.alert('Welcome!', `You're now set up as a ${selectedRole.toLowerCase()}.`, [
        { text: 'Continue', onPress: () => router.replace('/(tabs)') }
      ]);
    } catch (err: any) {
      const errorMessage = err?.message || 'Failed to set role. Please try again.';
      setGeneralError(errorMessage);
      
      Alert.alert('Error', errorMessage, [{ text: 'Try Again' }]);
    }
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
              {/* Logo */}
              <View style={{ marginBottom: 24, alignItems: 'center', justifyContent: 'center' }}>
                <View style={{ 
                  width: 80, 
                  height: 80, 
                  borderRadius: 40, 
                  backgroundColor: '#dbeafe', 
                  alignItems: 'center', 
                  justifyContent: 'center' 
                }}>
                  <Ionicons name="person-outline" size={32} color="#0a53d6" />
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
                Choose Your Role
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
                {user?.firstName ? `Welcome, ${user.firstName}! ` : ''}Select how you'd like to use Buildakar.
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
                {/* General Error Message */}
                {generalError && (
                  <View style={{ 
                    backgroundColor: '#fef2f2', 
                    borderWidth: 1, 
                    borderColor: '#fecaca', 
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

                {/* Role Selection */}
                <View style={{ marginBottom: 16 }}>
                  <Text style={{ fontSize: 14, fontWeight: '600', color: '#0f172a', marginBottom: 6 }}>
                    How will you use Buildakar?
                  </Text>
                  <View style={{ flexDirection: 'row', gap: 10 }}>
                    {roleOptions.map((option) => {
                      const isSelected = selectedRole === option.value;

                      return (
                        <TouchableOpacity
                          key={option.value}
                          activeOpacity={0.85}
                          onPress={() => setSelectedRole(option.value)}
                          style={{
                            flex: 1,
                            borderWidth: 1.5,
                            borderColor: isSelected ? '#0a53d6' : '#e2e8f0',
                            backgroundColor: isSelected ? '#eff6ff' : '#ffffff',
                            borderRadius: 16,
                            paddingVertical: 14,
                            paddingHorizontal: 12,
                          }}
                        >
                          <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 8 }}>
                            <View
                              style={{
                                width: 34,
                                height: 34,
                                borderRadius: 17,
                                backgroundColor: isSelected ? '#dbeafe' : '#f8fafc',
                                alignItems: 'center',
                                justifyContent: 'center',
                                marginRight: 10,
                              }}
                            >
                              <Ionicons
                                name={option.icon}
                                size={18}
                                color={isSelected ? '#0a53d6' : '#64748b'}
                              />
                            </View>
                            <View style={{ flex: 1 }}>
                              <Text style={{ fontSize: 15, fontWeight: '700', color: '#0f172a' }}>
                                {option.title}
                              </Text>
                            </View>
                          </View>
                          <Text style={{ fontSize: 12, color: '#64748b', lineHeight: 17 }}>
                            {option.description}
                          </Text>
                        </TouchableOpacity>
                      );
                    })}
                  </View>
                </View>

                {/* Continue Button */}
                <View style={{ marginTop: 8, marginBottom: 24 }}>
                  <CustomButton
                    title="Continue"
                    onPress={handleContinue}
                    loading={loading}
                  />
                </View>
              </View>

              {/* Bottom Note */}
              <View style={{ 
                marginTop: 24, 
                flexDirection: 'row', 
                alignItems: 'center', 
                justifyContent: 'center', 
                flexWrap: 'wrap' 
              }}>
                <Text style={{ color: '#64748b', fontSize: isSmallDevice ? 11 : 13, textAlign: 'center' }}>
                  You can change your role later in settings.
                </Text>
              </View>
            </View>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}