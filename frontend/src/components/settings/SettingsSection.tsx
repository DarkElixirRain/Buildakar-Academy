// components/settings/SettingsSection.tsx
import React from "react";
import { View, Text } from "react-native";

interface SettingsSectionProps {
  title?: string;
  children: React.ReactNode;
}

export function SettingsSection({ title, children }: SettingsSectionProps) {
  return (
    <View className="mb-6">
      {title && (
        <Text className="px-1 mb-2 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500">
          {title}
        </Text>
      )}
      <View className="bg-white dark:bg-gray-900 rounded-2xl overflow-hidden border border-gray-100 dark:border-gray-800">
        {children}
      </View>
    </View>
  );
}