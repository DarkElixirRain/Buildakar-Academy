// components/settings/SettingsRow.tsx
import React from "react";
import { View, Text, Pressable, Switch } from "react-native";
import { ChevronRight, type LucideIcon } from "lucide-react-native";

interface SettingsRowProps {
  icon?: LucideIcon;
  iconColor?: string;
  iconBg?: string;
  label: string;
  description?: string;
  /** "navigate" shows a chevron and calls onPress.
   *  "value" shows a value + chevron and calls onPress (e.g. opens a picker).
   *  "toggle" shows a Switch bound to `toggled` / `onToggle`.
   *  "danger" styles the label in red, for destructive actions like Log out. */
  type?: "navigate" | "value" | "toggle" | "danger";
  value?: string;
  toggled?: boolean;
  onToggle?: (next: boolean) => void;
  onPress?: () => void;
  isLast?: boolean;
}

export function SettingsRow({
  icon: Icon,
  iconColor = "#2563EB",
  iconBg = "#EFF6FF",
  label,
  description,
  type = "navigate",
  value,
  toggled = false,
  onToggle,
  onPress,
  isLast = false,
}: SettingsRowProps) {
  const isDanger = type === "danger";
  const content = (
    <View
      className={`flex-row items-center px-4 py-3.5 ${
        isLast ? "" : "border-b border-gray-100 dark:border-gray-800"
      }`}
    >
      {Icon && (
        <View
          className="w-9 h-9 rounded-full items-center justify-center mr-3"
          style={{ backgroundColor: isDanger ? "#FEF2F2" : iconBg }}
        >
          <Icon size={18} color={isDanger ? "#EF4444" : iconColor} />
        </View>
      )}

      <View className="flex-1">
        <Text
          className={`text-[15px] font-medium ${
            isDanger
              ? "text-red-500"
              : "text-gray-900 dark:text-gray-50"
          }`}
        >
          {label}
        </Text>
        {description && (
          <Text className="text-xs text-gray-400 dark:text-gray-500 mt-0.5">
            {description}
          </Text>
        )}
      </View>

      {type === "toggle" && (
        <Switch
          value={toggled}
          onValueChange={onToggle}
          trackColor={{ false: "#E2E8F0", true: "#93C5FD" }}
          thumbColor={toggled ? "#2563EB" : "#FFFFFF"}
        />
      )}

      {type === "value" && (
        <View className="flex-row items-center">
          <Text className="text-sm text-gray-400 dark:text-gray-500 mr-1">
            {value}
          </Text>
          <ChevronRight size={18} color="#94A3B8" />
        </View>
      )}

      {type === "navigate" && <ChevronRight size={18} color="#94A3B8" />}
    </View>
  );

  if (type === "toggle") {
    // Row itself isn't pressable when it's a toggle — only the Switch is —
    // so taps near the edge don't accidentally fire navigation.
    return content;
  }

  return (
    <Pressable onPress={onPress} android_ripple={{ color: "#F1F5F9" }}>
      {content}
    </Pressable>
  );
}