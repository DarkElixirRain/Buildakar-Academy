import React from 'react';
import {
  TouchableOpacity,
  Text,
  ActivityIndicator,
  TouchableOpacityProps,
} from 'react-native';

interface AuthButtonProps extends TouchableOpacityProps {
  title: string;
  loading?: boolean;
}

export const AuthButton: React.FC<AuthButtonProps> = ({
  title,
  loading = false,
  ...props
}) => {
  return (
    <TouchableOpacity
      activeOpacity={0.8}
      className="w-full bg-[#0a53d6] rounded-[12px] py-3.5 items-center justify-center"
      disabled={loading}
      {...props}
    >
      {loading ? (
        <ActivityIndicator color="#ffffff" />
      ) : (
        <Text className="text-white text-[15px] font-bold">{title}</Text>
      )}
    </TouchableOpacity>
  );
};