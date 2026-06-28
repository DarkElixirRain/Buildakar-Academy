// components/home/SearchBar.tsx
import React, { useState, useRef } from 'react';
import { 
  View, 
  TextInput, 
  TouchableOpacity, 
  FlatList, 
  Text,
  Animated,
} from 'react-native';
import { Feather, Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';

interface SearchBarProps {
  value: string;
  onChangeText: (text: string) => void;
  onSearch: (query: string) => void;
}

const RECENT_SEARCHES = [
  'React Native',
  'Machine Learning',
  'UI/UX Design',
  'Python Programming',
];

export const SearchBar: React.FC<SearchBarProps> = ({
  value,
  onChangeText,
  onSearch,
}) => {
  const [isFocused, setIsFocused] = useState(false);
  const [recentSearches, setRecentSearches] = useState(RECENT_SEARCHES);
  const scaleAnim = useRef(new Animated.Value(1)).current;
  const { isDarkMode, colors } = useTheme();

  const handleFocus = () => {
    setIsFocused(true);
    Animated.spring(scaleAnim, {
      toValue: 1.02,
      useNativeDriver: true,
    }).start();
  };

  const handleBlur = () => {
    setIsFocused(false);
    Animated.spring(scaleAnim, {
      toValue: 1,
      useNativeDriver: true,
    }).start();
  };

  const handleSubmit = () => {
    if (value.trim()) {
      // Add to recent searches
      setRecentSearches(prev => 
        [value.trim(), ...prev.filter(s => s !== value.trim())].slice(0, 5)
      );
      onSearch(value.trim());
    }
  };

  const clearSearch = () => {
    onChangeText('');
  };

  const handleRecentSearchPress = (search: string) => {
    onChangeText(search);
    onSearch(search);
  };

  const handleVoiceSearch = () => {
    // Implement voice search using expo-speech or similar
    console.log('Voice search activated');
  };

  return (
    <View style={{ width: '100%', marginTop: 8, marginBottom: 16 }}>
      <Animated.View 
        className="relative"
        style={{ transform: [{ scale: scaleAnim }] }}
      >
        {/* Search Icon */}
        <View className="absolute left-3 top-1/2 -translate-y-1/2 z-10">
          <Feather name="search" size={20} color={colors.textSecondary} />
        </View>

        {/* Input */}
        <TextInput
          style={{
            width: '100%',
            height: 48,
            borderRadius: 16,
            paddingLeft: 40,
            paddingRight: 80,
            fontSize: 16,
            borderWidth: 1,
            backgroundColor: colors.backgroundElement,
            color: colors.text,
            borderColor: colors.backgroundSelected,
            shadowColor: colors.text,
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: isDarkMode ? 0.3 : 0.05,
            shadowRadius: 4,
            elevation: 2,
          }}
          placeholder="Search courses, skills, instructors..."
          placeholderTextColor={colors.textSecondary}
          value={value}
          onChangeText={onChangeText}
          onFocus={handleFocus}
          onBlur={handleBlur}
          onSubmitEditing={handleSubmit}
          returnKeyType="search"
        />

        {/* Right Actions */}
        <View className="absolute right-2 top-1/2 -translate-y-1/2 flex-row items-center space-x-1">
          {value.length > 0 && (
            <TouchableOpacity 
              className="p-1.5"
              onPress={clearSearch}
            >
              <Feather name="x" size={18} color={colors.textSecondary} />
            </TouchableOpacity>
          )}

          <TouchableOpacity 
            style={{
              padding: 6,
              borderRadius: 20,
              backgroundColor: isDarkMode ? '#334155' : '#F1F5F9',
            }}
            onPress={handleVoiceSearch}
          >
            <Ionicons name="mic" size={18} color={colors.textSecondary} />
          </TouchableOpacity>
        </View>
      </Animated.View>

      {/* Recent Searches */}
      {isFocused && recentSearches.length > 0 && (
        <View style={{
          marginTop: 12,
          borderRadius: 16,
          borderWidth: 1,
          padding: 12,
          backgroundColor: colors.backgroundElement,
          borderColor: colors.backgroundSelected,
        }}>
          <Text style={{
            fontSize: 14,
            fontWeight: '500',
            marginBottom: 8,
            color: colors.textSecondary,
          }}>
            Recent Searches
          </Text>
          {recentSearches.map((search, index) => (
            <TouchableOpacity
              key={index}
              className="py-2 flex-row items-center"
              onPress={() => handleRecentSearchPress(search)}
            >
              <Feather name="clock" size={16} color={colors.textSecondary} />
              <Text style={{
                marginLeft: 12,
                fontSize: 16,
                flex: 1,
                color: colors.text,
              }}>
                {search}
              </Text>
              <TouchableOpacity 
                onPress={() => {
                  setRecentSearches(prev => prev.filter(s => s !== search));
                }}
              >
                <Feather name="x" size={16} color={colors.textSecondary} />
              </TouchableOpacity>
            </TouchableOpacity>
          ))}
          
          <TouchableOpacity 
            className="mt-2 py-1"
            onPress={() => setRecentSearches([])}
          >
            <Text style={{
              fontSize: 14,
              fontWeight: '500',
              textAlign: 'center',
              color: colors.primary,
            }}>
              Clear All
            </Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
};