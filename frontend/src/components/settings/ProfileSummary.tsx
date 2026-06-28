// components/settings/ProfileSummary.tsx
import React from "react";
import { View, Text, Image, Pressable } from "react-native";
import { ChevronRight } from "lucide-react-native";

interface ProfileSummaryProps {
  name: string;
  email: string;
  avatarUrl?: string;
  /** Pass authStore.getInitials() here if available — falls back to deriving from `name`. */
  initials?: string;
  onPress: () => void;
}

function getInitials(name: string) {
  return name
    .trim()
    .split(/\s+/)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join("");
}

export function ProfileSummary({
  name,
  email,
  avatarUrl,
  initials,
  onPress,
}: ProfileSummaryProps) {
  return (
    <Pressable
      onPress={onPress}
      className="flex-row items-center bg-white dark:bg-gray-900 rounded-2xl border border-gray-100 dark:border-gray-800 p-4 mb-6"
    >
      {avatarUrl ? (
        <Image
          source={{ uri: avatarUrl }}
          className="w-14 h-14 rounded-full"
        />
      ) : (
        <View className="w-14 h-14 rounded-full bg-blue-600 items-center justify-center">
          <Text className="text-white text-base font-semibold">
            {initials ?? getInitials(name)}
          </Text>
        </View>
      )}

      <View className="flex-1 ml-3.5">
        <Text className="text-base font-semibold text-gray-900 dark:text-gray-50">
          {name}
        </Text>
        <Text className="text-sm text-gray-400 dark:text-gray-500 mt-0.5">
          {email}
        </Text>
      </View>

      <View className="px-3 py-1.5 rounded-full bg-blue-50 dark:bg-blue-950 flex-row items-center">
        <Text className="text-xs font-medium text-blue-600 dark:text-blue-400 mr-0.5">
          Edit
        </Text>
        <ChevronRight size={14} color="#2563EB" />
      </View>
    </Pressable>
  );
}