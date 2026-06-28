// components/settings/ConfirmModal.tsx
import React from "react";
import { Modal, View, Text, Pressable, ActivityIndicator } from "react-native";

interface ConfirmModalProps {
  visible: boolean;
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  destructive?: boolean;
  loading?: boolean;
  onConfirm: () => void;
  onClose: () => void;
}

export function ConfirmModal({
  visible,
  title,
  message,
  confirmText = "Confirm",
  cancelText = "Cancel",
  destructive = false,
  loading = false,
  onConfirm,
  onClose,
}: ConfirmModalProps) {
  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onClose}>
      <View className="flex-1 items-center justify-center bg-black/40 px-6">
        <View className="w-full bg-white dark:bg-gray-900 rounded-2xl p-5">
          <Text className="text-lg font-semibold text-gray-900 dark:text-gray-50 text-center">
            {title}
          </Text>
          <Text className="text-sm text-gray-500 dark:text-gray-400 text-center mt-2 leading-5">
            {message}
          </Text>

          <View className="flex-row mt-5 gap-3">
            <Pressable
              onPress={onClose}
              disabled={loading}
              className="flex-1 py-3 rounded-xl bg-gray-100 dark:bg-gray-800 items-center"
            >
              <Text className="text-sm font-semibold text-gray-700 dark:text-gray-200">
                {cancelText}
              </Text>
            </Pressable>

            <Pressable
              onPress={onConfirm}
              disabled={loading}
              className={`flex-1 py-3 rounded-xl items-center ${
                destructive ? "bg-red-500" : "bg-blue-600"
              }`}
            >
              {loading ? (
                <ActivityIndicator color="#FFFFFF" size="small" />
              ) : (
                <Text className="text-sm font-semibold text-white">
                  {confirmText}
                </Text>
              )}
            </Pressable>
          </View>
        </View>
      </View>
    </Modal>
  );
}