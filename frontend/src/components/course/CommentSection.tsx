// components/course/CommentsSection.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  TextInput,
  Image,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Comment } from '../../types/course';

interface CommentsSectionProps {
  comments: Comment[];
  onAddComment: (text: string) => void;
  onToggleLike: (commentId: string) => void;
}

export const CommentsSection: React.FC<CommentsSectionProps> = ({
  comments,
  onAddComment,
  onToggleLike,
}) => {
  const [text, setText] = useState('');

  const handleSend = () => {
    const trimmed = text.trim();
    if (!trimmed) return;
    onAddComment(trimmed);
    setText('');
  };

  return (
    <KeyboardAvoidingView
      style={{ flex: 1 }}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 90 : 0}
    >
      <ScrollView
        className="flex-1"
        contentContainerStyle={{ paddingTop: 12, paddingBottom: 16 }}
        keyboardShouldPersistTaps="handled"
      >
        <View className="px-4">
          {comments.length === 0 ? (
            <View className="items-center py-10">
              <Ionicons
                name="chatbubble-ellipses-outline"
                size={32}
                color="#94A3B8"
              />
              <Text className="text-[#64748B] text-sm mt-2">
                No comments yet. Be the first to comment.
              </Text>
            </View>
          ) : (
            comments.map((comment) => (
              <View key={comment.id} className="flex-row mb-4">
                <Image
                  source={{ uri: comment.userAvatar }}
                  className="w-9 h-9 rounded-full mr-3"
                />
                <View className="flex-1">
                  <View className="flex-row items-center justify-between">
                    <Text className="text-[#0F172A] font-semibold text-sm">
                      {comment.userName}
                    </Text>
                    <Text className="text-[#94A3B8] text-xs">
                      {comment.timestamp}
                    </Text>
                  </View>
                  <Text className="text-[#334155] text-sm mt-1 leading-5">
                    {comment.text}
                  </Text>
                  <TouchableOpacity
                    className="flex-row items-center mt-1.5"
                    onPress={() => onToggleLike(comment.id)}
                    activeOpacity={0.7}
                  >
                    <Ionicons
                      name={comment.likedByMe ? 'heart' : 'heart-outline'}
                      size={14}
                      color={comment.likedByMe ? '#EF4444' : '#94A3B8'}
                    />
                    <Text className="text-[#94A3B8] text-xs ml-1">
                      {comment.likes}
                    </Text>
                  </TouchableOpacity>
                </View>
              </View>
            ))
          )}
        </View>
      </ScrollView>

      <View className="flex-row items-center px-4 py-3 border-t border-[#E2E8F0] bg-white">
        <TextInput
          value={text}
          onChangeText={setText}
          placeholder="Add a comment..."
          placeholderTextColor="#94A3B8"
          className="flex-1 bg-[#F1F5F9] rounded-full px-4 py-2.5 text-sm text-[#0F172A] mr-2"
          multiline
        />
        <TouchableOpacity
          onPress={handleSend}
          disabled={!text.trim()}
          className={`w-10 h-10 rounded-full items-center justify-center ${
            text.trim() ? 'bg-[#2563EB]' : 'bg-[#CBD5E1]'
          }`}
          activeOpacity={0.7}
        >
          <Ionicons name="send" size={16} color="#FFFFFF" />
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
};