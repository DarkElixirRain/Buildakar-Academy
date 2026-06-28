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
import { useTheme } from '@/context/themeContext';

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
  const { isDarkMode, colors } = useTheme();

  const handleSend = () => {
    const trimmed = text.trim();
    if (!trimmed) return;
    onAddComment(trimmed);
    setText('');
  };

  return (
    <KeyboardAvoidingView
      style={{ flex: 1, backgroundColor: colors.background }}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 90 : 0}
    >
      <ScrollView
        style={{ flex: 1, backgroundColor: colors.background }}
        contentContainerStyle={{ paddingTop: 12, paddingBottom: 16 }}
        keyboardShouldPersistTaps="handled"
      >
        <View className="px-4">
          {comments.length === 0 ? (
            <View className="items-center py-10">
              <Ionicons
                name="chatbubble-ellipses-outline"
                size={32}
                color={colors.textSecondary}
              />
              <Text style={{
                color: colors.textSecondary,
                fontSize: 14,
                marginTop: 8,
              }}>
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
                    <Text style={{
                      color: colors.text,
                      fontWeight: '600',
                      fontSize: 14,
                    }}>
                      {comment.userName}
                    </Text>
                    <Text style={{
                      color: colors.textSecondary,
                      fontSize: 12,
                    }}>
                      {comment.timestamp}
                    </Text>
                  </View>
                  <Text style={{
                    color: isDarkMode ? '#E2E8F0' : '#334155',
                    fontSize: 14,
                    marginTop: 4,
                    lineHeight: 20,
                  }}>
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
                      color={comment.likedByMe ? '#EF4444' : colors.textSecondary}
                    />
                    <Text style={{
                      color: colors.textSecondary,
                      fontSize: 12,
                      marginLeft: 4,
                    }}>
                      {comment.likes}
                    </Text>
                  </TouchableOpacity>
                </View>
              </View>
            ))
          )}
        </View>
      </ScrollView>

      <View style={{
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 16,
        paddingVertical: 12,
        borderTopWidth: 1,
        borderTopColor: colors.backgroundSelected,
        backgroundColor: colors.backgroundElement,
      }}>
        <TextInput
          value={text}
          onChangeText={setText}
          placeholder="Add a comment..."
          placeholderTextColor={colors.textSecondary}
          style={{
            flex: 1,
            borderRadius: 20,
            paddingHorizontal: 16,
            paddingVertical: 10,
            fontSize: 14,
            marginRight: 8,
            backgroundColor: colors.backgroundSelected,
            color: colors.text,
          }}
          multiline
        />
        <TouchableOpacity
          onPress={handleSend}
          disabled={!text.trim()}
          style={{
            width: 40,
            height: 40,
            borderRadius: 20,
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: text.trim() ? colors.primary : colors.backgroundSelected,
          }}
          activeOpacity={0.7}
        >
          <Ionicons 
            name="send" 
            size={16} 
            color={text.trim() ? '#FFFFFF' : colors.textSecondary} 
          />
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
};