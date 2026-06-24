import React, { useState } from 'react';
import { View, Text, TextInput, TextInputProps, TouchableOpacity } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { cn } from '@/lib/cn';

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

    const isSecure = isPassword && !showPassword;

    return (
      <View className="w-full mb-4">
        {/* Label Row */}
        <View className="flex-row justify-between items-center mb-1.5">
          <Text className="text-[14px] font-semibold text-[#1e293b]">{label}</Text>
          {rightElement}
        </View>

        {/* Input Wrapper */}
        <View
          className={cn(
            'flex-row items-center bg-[#f1f5f9] border border-transparent rounded-[12px] px-3.5 py-3 h-[52px]',
            isFocused && 'border-[#0a53d6] bg-white shadow-sm',
            error && 'border-red-500 bg-red-50/10'
          )}
        >
          {/* Left Icon */}
          <View className="mr-3">
            <Feather
              name={iconName as any}
              size={20}
              color={error ? '#ef4444' : isFocused ? '#0a53d6' : '#64748b'}
            />
          </View>

          {/* TextInput */}
          <TextInput
            ref={ref}
            secureTextEntry={isSecure}
            placeholderTextColor="#94a3b8"
            onFocus={() => setIsFocused(true)}
            onBlur={() => setIsFocused(false)}
            className="flex-1 text-[#0f172a] text-[15px] p-0 m-0 h-full"
            style={{
              outlineStyle: 'none', // Remove web outline
            } as any}
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
                color="#64748b"
              />
            </TouchableOpacity>
          )}
        </View>

        {/* Inline Error Message */}
        {error && (
          <Text className="text-red-500 text-[12px] mt-1.5 ml-1 font-medium">{error}</Text>
        )}
      </View>
    );
  }
);

AuthInput.displayName = 'AuthInput';
