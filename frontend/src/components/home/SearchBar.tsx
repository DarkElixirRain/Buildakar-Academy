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
    <View className="w-full">
      <Animated.View 
        className="relative"
        style={{ transform: [{ scale: scaleAnim }] }}
      >
        {/* Search Icon */}
        <View className="absolute left-3 top-1/2 -translate-y-1/2 z-10">
          <Feather name="search" size={20} color="#94A3B8" />
        </View>

        {/* Input */}
        <TextInput
          className="w-full h-12 bg-white rounded-2xl pl-10 pr-20 text-[#0F172A] text-base border border-[#E2E8F0]"
          style={{ 
            shadowColor: '#0F172A',
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: 0.05,
            shadowRadius: 4,
            elevation: 2,
          }}
          placeholder="Search courses, skills, instructors..."
          placeholderTextColor="#94A3B8"
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
              <Feather name="x" size={18} color="#94A3B8" />
            </TouchableOpacity>
          )}

          <TouchableOpacity 
            className="p-1.5 bg-[#F1F5F9] rounded-full"
            onPress={handleVoiceSearch}
          >
            <Ionicons name="mic" size={18} color="#475569" />
          </TouchableOpacity>
        </View>
      </Animated.View>

      {/* Recent Searches */}
      {isFocused && recentSearches.length > 0 && (
        <View className="mt-3 bg-white rounded-2xl border border-[#E2E8F0] p-3">
          <Text className="text-[#64748B] text-sm font-medium mb-2">
            Recent Searches
          </Text>
          {recentSearches.map((search, index) => (
            <TouchableOpacity
              key={index}
              className="py-2 flex-row items-center"
              onPress={() => handleRecentSearchPress(search)}
            >
              <Feather name="clock" size={16} color="#94A3B8" />
              <Text className="ml-3 text-[#0F172A] text-base flex-1">
                {search}
              </Text>
              <TouchableOpacity 
                onPress={() => {
                  setRecentSearches(prev => prev.filter(s => s !== search));
                }}
              >
                <Feather name="x" size={16} color="#94A3B8" />
              </TouchableOpacity>
            </TouchableOpacity>
          ))}
          
          <TouchableOpacity 
            className="mt-2 py-1"
            onPress={() => setRecentSearches([])}
          >
            <Text className="text-[#2563EB] text-sm font-medium text-center">
              Clear All
            </Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
};