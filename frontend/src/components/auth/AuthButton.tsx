// components/common/AuthButton.tsx
import React from 'react';
import {
  TouchableOpacity,
  Text,
  ActivityIndicator,
  TouchableOpacityProps,
  View,
} from 'react-native';
import { useTheme } from '@/context/themeContext';

interface AuthButtonProps extends TouchableOpacityProps {
  title: string;
  loading?: boolean;
  variant?: 'primary' | 'secondary' | 'outline';
  fullWidth?: boolean;
}

export const AuthButton: React.FC<AuthButtonProps> = ({
  title,
  loading = false,
  variant = 'primary',
  fullWidth = true,
  style,
  disabled,
  ...props
}) => {
  const { colors, isDarkMode } = useTheme();

  const getButtonStyles = () => {
    switch (variant) {
      case 'secondary':
        return {
          backgroundColor: colors.backgroundElement,
          borderColor: colors.backgroundSelected,
          borderWidth: 1,
        };
      case 'outline':
        return {
          backgroundColor: 'transparent',
          borderColor: colors.primary,
          borderWidth: 2,
        };
      default: // primary
        return {
          backgroundColor: colors.primary,
        };
    }
  };

  const getTextStyles = () => {
    switch (variant) {
      case 'secondary':
        return {
          color: colors.text,
        };
      case 'outline':
        return {
          color: colors.primary,
        };
      default: // primary
        return {
          color: '#FFFFFF',
        };
    }
  };

  const getLoadingColor = () => {
    switch (variant) {
      case 'secondary':
        return colors.text;
      case 'outline':
        return colors.primary;
      default: // primary
        return '#FFFFFF';
    }
  };

  const isDisabled = disabled || loading;

  return (
    <TouchableOpacity
      activeOpacity={0.8}
      style={[
        {
          width: fullWidth ? '100%' : 'auto',
          borderRadius: 12,
          paddingVertical: 14,
          alignItems: 'center',
          justifyContent: 'center',
          opacity: isDisabled ? 0.6 : 1,
        },
        getButtonStyles(),
        style,
      ]}
      disabled={isDisabled}
      {...props}
    >
      {loading ? (
        <ActivityIndicator color={getLoadingColor()} />
      ) : (
        <Text
          style={[
            {
              fontSize: 15,
              fontWeight: '700',
            },
            getTextStyles(),
          ]}
        >
          {title}
        </Text>
      )}
    </TouchableOpacity>
  );
};