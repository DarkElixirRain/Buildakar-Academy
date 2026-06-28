// components/common/AuthInput.tsx
import React, { useState } from 'react';
import { View, Text, TextInput, TextInputProps, TouchableOpacity } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { cn } from '@/lib/cn';
import { useTheme } from '@/context/themeContext';

interface AuthInputProps extends TextInputProps {
  label: string;
  iconName: keyof typeof Feather.glyphMap;
  error?: string | null;
  isPassword?: boolean;
  rightElement?: React.ReactNode;
}

export const AuthInput = React.forwardRef<TextInput, AuthInputProps>(
  ({ label, iconName, error, isPassword = false, rightElement, ...props }, ref) => {
    const [isFocused, setIsFocused] = useState(false);
    const [showPassword, setShowPassword] = useState(false);
    const { colors, isDarkMode } = useTheme();

    const isSecure = isPassword && !showPassword;

    // Theme-based colors
    const labelColor = colors.text;
    const inputBgColor = isDarkMode ? colors.backgroundElement : '#f1f5f9';
    const inputTextColor = colors.text;
    const placeholderColor = colors.textSecondary;
    const iconColor = error ? '#ef4444' : isFocused ? colors.primary : colors.textSecondary;
    const borderColor = error ? '#ef4444' : isFocused ? colors.primary : 'transparent';
    const errorColor = '#ef4444';

    return (
      <View className="w-full mb-4">
        {/* Label Row */}
        <View className="flex-row justify-between items-center mb-1.5">
          <Text style={{ fontSize: 14, fontWeight: '600', color: labelColor }}>
            {label}
          </Text>
          {rightElement}
        </View>

        {/* Input Wrapper */}
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            backgroundColor: inputBgColor,
            borderWidth: 1,
            borderColor: borderColor,
            borderRadius: 12,
            paddingHorizontal: 14,
            paddingVertical: 12,
            height: 52,
            shadowColor: isFocused ? colors.primary : 'transparent',
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: isFocused ? 0.1 : 0,
            shadowRadius: 4,
            elevation: isFocused ? 2 : 0,
          }}
        >
          {/* Left Icon */}
          <View className="mr-3">
            <Feather
              name={iconName as any}
              size={20}
              color={iconColor}
            />
          </View>

          {/* TextInput */}
          <TextInput
            ref={ref}
            secureTextEntry={isSecure}
            placeholderTextColor={placeholderColor}
            onFocus={() => setIsFocused(true)}
            onBlur={() => setIsFocused(false)}
            style={{
              flex: 1,
              color: inputTextColor,
              fontSize: 15,
              padding: 0,
              margin: 0,
              height: '100%',
            }}
            {...props}
          />

          {/* Password Eye Toggle / Right Icon */}
          {isPassword && (
            <TouchableOpacity
              activeOpacity={0.7}
              onPress={() => setShowPassword(!showPassword)}
              className="pl-3"
            >
              <Feather
                name={showPassword ? 'eye-off' : 'eye'}
                size={20}
                color={colors.textSecondary}
              />
            </TouchableOpacity>
          )}
        </View>

        {/* Inline Error Message */}
        {error && (
          <Text style={{ color: errorColor, fontSize: 12, marginTop: 6, marginLeft: 4, fontWeight: '500' }}>
            {error}
          </Text>
        )}
      </View>
    );
  }
);

AuthInput.displayName = 'AuthInput';