// components/settings/OptionPickerModal.tsx
import React from "react";
import { Modal, View, Text, Pressable } from "react-native";
import { Check, X } from "lucide-react-native";

export interface PickerOption {
  label: string;
  value: string;
  description?: string;
}

interface OptionPickerModalProps {
  visible: boolean;
  title: string;
  options: PickerOption[];
  selectedValue: string;
  onSelect: (value: string) => void;
  onClose: () => void;
}

export function OptionPickerModal({
  visible,
  title,
  options,
  selectedValue,
  onSelect,
  onClose,
}: OptionPickerModalProps) {
  return (
    <Modal
      visible={visible}
      transparent
      animationType="slide"
      onRequestClose={onClose}
    >
      <View className="flex-1 justify-end bg-black/40">
        <Pressable className="flex-1" onPress={onClose} />

        <View className="bg-white dark:bg-gray-900 rounded-t-3xl pb-8">
          <View className="flex-row items-center justify-between px-5 pt-5 pb-3">
            <Text className="text-lg font-semibold text-gray-900 dark:text-gray-50">
              {title}
            </Text>
            <Pressable
              onPress={onClose}
              className="w-8 h-8 rounded-full bg-gray-100 dark:bg-gray-800 items-center justify-center"
            >
              <X size={16} color="#64748B" />
            </Pressable>
          </View>

          {options.map((option) => {
            const selected = option.value === selectedValue;
            return (
              <Pressable
                key={option.value}
                onPress={() => {
                  onSelect(option.value);
                  onClose();
                }}
                className="flex-row items-center justify-between px-5 py-3.5 border-t border-gray-100 dark:border-gray-800"
              >
                <View className="flex-1">
                  <Text
                    className={`text-[15px] ${
                      selected
                        ? "font-semibold text-blue-600"
                        : "font-medium text-gray-900 dark:text-gray-50"
                    }`}
                  >
                    {option.label}
                  </Text>
                  {option.description && (
                    <Text className="text-xs text-gray-400 dark:text-gray-500 mt-0.5">
                      {option.description}
                    </Text>
                  )}
                </View>
                {selected && <Check size={18} color="#2563EB" />}
              </Pressable>
            );
          })}
        </View>
      </View>
    </Modal>
  );
}