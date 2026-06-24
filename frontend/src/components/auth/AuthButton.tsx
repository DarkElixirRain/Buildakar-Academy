import React from 'react';
import { TouchableOpacity, Text, ActivityIndicator, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { cn } from '@/lib/cn';

interface AuthButtonProps {
  title: string;
  onPress: () => void;
  loading?: boolean;
  disabled?: boolean;
  className?: string;
  showArrow?: boolean;
}

export const AuthButton: React.FC<AuthButtonProps> = ({
  title,
  onPress,
  loading = false,
  disabled = false,
  className = '',
  showArrow = true,
}) => {
  const isDisabled = disabled || loading;

  return (
    <TouchableOpacity
      activeOpacity={0.8}
      onPress={onPress}
      disabled={isDisabled}
      className={cn(
        'w-full bg-[#0a53d6] h-[52px] rounded-[12px] flex-row justify-center items-center px-4 shadow-sm shadow-blue-500/10',
        isDisabled && 'opacity-60 bg-[#0a53d6]',
        className
      )}
    >
      {loading ? (
        <ActivityIndicator size="small" color="#ffffff" />
      ) : (
        <View className="flex-row items-center justify-center">
          <Text className="text-white text-[16px] font-bold tracking-wide mr-2">
            {title}
          </Text>
          {showArrow && (
            <Feather name="arrow-right" size={18} color="#ffffff" className="mt-0.5" />
          )}
        </View>
      )}
    </TouchableOpacity>
  );
};
