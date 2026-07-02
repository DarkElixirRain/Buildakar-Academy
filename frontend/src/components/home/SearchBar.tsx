// components/home/SearchBar.tsx
import React, { useState, useRef, useEffect } from "react";
import {
  View,
  TextInput,
  TouchableOpacity,
  Text,
  Animated,
  Platform,
  Keyboard,
} from "react-native";
import { Feather, Ionicons } from "@expo/vector-icons";
import { useRouter } from "expo-router";
import { useTheme } from "@/context/themeContext";
import { searchService } from "@/services/search.service";
import { useAuthStore } from "@/store/authStore";

interface SearchBarProps {
  value: string;
  onChangeText: (text: string) => void;
  onSearch: (query: string) => void;
}

export const SearchBar: React.FC<SearchBarProps> = ({
  value,
  onChangeText,
  onSearch,
}) => {
  const router = useRouter();
  const { isDarkMode, colors } = useTheme();
  const { isAuthenticated } = useAuthStore();

  const [isFocused, setIsFocused] = useState(false);
  const [recentSearches, setRecentSearches] = useState<string[]>([]);
  const [loadingRecent, setLoadingRecent] = useState(false);
  const scaleAnim = useRef(new Animated.Value(1)).current;
  const inputRef = useRef<TextInput>(null);

  // Load recent searches from backend
  const loadRecentSearches = async () => {
    if (!isAuthenticated) {
      loadLocalRecentSearches();
      return;
    }

    try {
      setLoadingRecent(true);
      const data = await searchService.getRecentSearches();
      if (data && data.length > 0) {
        setRecentSearches(data);
      } else {
        loadLocalRecentSearches();
      }
    } catch (error) {
      console.error("❌ Failed to load recent searches:", error);
      loadLocalRecentSearches();
    } finally {
      setLoadingRecent(false);
    }
  };

  // Load recent searches from local storage
  const loadLocalRecentSearches = () => {
    try {
      if (Platform.OS === "web") {
        const stored = localStorage.getItem("recent_searches");
        if (stored) {
          setRecentSearches(JSON.parse(stored));
        }
      } else {
        const defaultSearches = [
          "React Native",
          "Machine Learning",
          "UI/UX Design",
          "Python Programming",
        ];
        setRecentSearches(defaultSearches);
      }
    } catch (error) {
      console.error("Failed to load local recent searches:", error);
    }
  };

  // Save recent search to backend
  const saveRecentSearch = async (query: string) => {
    try {
      if (isAuthenticated) {
        await searchService.saveRecentSearch(query);
      }
    } catch (error) {
      console.error("❌ Failed to save recent search:", error);
    }
  };

  // Save to local storage
  const saveLocalRecentSearch = (query: string) => {
    try {
      const updated = [
        query,
        ...recentSearches.filter((s) => s !== query),
      ].slice(0, 5);
      setRecentSearches(updated);

      if (Platform.OS === "web") {
        localStorage.setItem("recent_searches", JSON.stringify(updated));
      }
    } catch (error) {
      console.error("Failed to save local recent search:", error);
    }
  };

  // Load recent searches on mount
  useEffect(() => {
    loadRecentSearches();
  }, [isAuthenticated]);

  const handleFocus = () => {
    setIsFocused(true);
    Animated.spring(scaleAnim, {
      toValue: 1.02,
      useNativeDriver: true,
    }).start();
    // Load recent searches when focusing
    loadRecentSearches();
  };

  const handleBlur = () => {
    // Delay hiding recent searches to allow clicks to register
    setTimeout(() => {
      setIsFocused(false);
    }, 200);
    Animated.spring(scaleAnim, {
      toValue: 1,
      useNativeDriver: true,
    }).start();
  };

  const handleSubmit = () => {
    if (value.trim()) {
      const query = value.trim();

      // Add to recent searches
      saveRecentSearch(query);
      saveLocalRecentSearch(query);
      
      // Close keyboard and blur
      Keyboard.dismiss();
      setIsFocused(false);

      // Navigate to search results page
      router.push({
        pathname: "/result",
        params: { q: query },
      });

      onSearch(query);
    }
  };

  const handleRecentSearchPress = (search: string) => {
    // Update input value
    onChangeText(search);
    
    // Close keyboard and blur
    Keyboard.dismiss();
    setIsFocused(false);

    // Navigate to search results page
    router.push({
      pathname: "/result",
      params: { q: search },
    });

    onSearch(search);
  };

  const clearSearch = () => {
    onChangeText("");
    // Keep focus on input
    inputRef.current?.focus();
  };

  const handleVoiceSearch = () => {
    console.log("Voice search activated");
  };

  const handleClearAll = async () => {
    try {
      // Clear from backend
      if (isAuthenticated) {
        await searchService.clearRecentSearches();
      }
      // Clear from local state
      setRecentSearches([]);
      // Clear from local storage
      if (Platform.OS === "web") {
        localStorage.removeItem("recent_searches");
      }
      // Keep focus on input
      inputRef.current?.focus();
    } catch (error) {
      console.error("Failed to clear recent searches:", error);
    }
  };

  const handleRemoveSingleSearch = (searchToRemove: string) => {
    const updated = recentSearches.filter((s) => s !== searchToRemove);
    setRecentSearches(updated);
    if (Platform.OS === "web") {
      localStorage.setItem("recent_searches", JSON.stringify(updated));
    }
    // Keep focus on input
    inputRef.current?.focus();
  };

  const handleCloseSearchBar = () => {
    Keyboard.dismiss();
    setIsFocused(false);
    inputRef.current?.blur();
  };

  return (
    <View style={{ width: "100%", marginTop: 8, marginBottom: 16 }}>
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
          ref={inputRef}
          style={{
            width: "100%",
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
              activeOpacity={0.7}
            >
              <Feather name="x" size={18} color={colors.textSecondary} />
            </TouchableOpacity>
          )}

          <TouchableOpacity
            style={{
              padding: 6,
              borderRadius: 20,
              backgroundColor: isDarkMode ? "#334155" : "#F1F5F9",
            }}
            onPress={handleVoiceSearch}
            activeOpacity={0.7}
          >
            <Ionicons name="mic" size={18} color={colors.textSecondary} />
          </TouchableOpacity>
        </View>
      </Animated.View>

      {/* Recent Searches */}
      {isFocused && recentSearches.length > 0 && (
        <View
          style={{
            marginTop: 12,
            borderRadius: 16,
            borderWidth: 1,
            padding: 12,
            backgroundColor: colors.backgroundElement,
            borderColor: colors.backgroundSelected,
          }}
        >
          <View className="flex-row justify-between items-center mb-2">
            <Text
              style={{
                fontSize: 14,
                fontWeight: "500",
                color: colors.textSecondary,
              }}
            >
              Recent Searches
            </Text>
            <TouchableOpacity 
              onPress={handleCloseSearchBar}
              activeOpacity={0.7}
            >
              <Feather name="chevron-down" size={20} color={colors.textSecondary} />
            </TouchableOpacity>
          </View>
          
          {recentSearches.map((search, index) => (
            <TouchableOpacity
              key={index}
              className="py-2 flex-row items-center"
              onPress={() => handleRecentSearchPress(search)}
              activeOpacity={0.7}
            >
              <Feather name="clock" size={16} color={colors.textSecondary} />
              <Text
                style={{
                  marginLeft: 12,
                  fontSize: 16,
                  flex: 1,
                  color: colors.text,
                }}
                numberOfLines={1}
              >
                {search}
              </Text>
              <TouchableOpacity
                onPress={() => handleRemoveSingleSearch(search)}
                activeOpacity={0.7}
                style={{ padding: 4 }}
              >
                <Feather name="x" size={16} color={colors.textSecondary} />
              </TouchableOpacity>
            </TouchableOpacity>
          ))}

          <TouchableOpacity 
            className="mt-2 py-2" 
            onPress={handleClearAll}
            activeOpacity={0.7}
          >
            <Text
              style={{
                fontSize: 14,
                fontWeight: "500",
                textAlign: "center",
                color: colors.primary,
              }}
            >
              Clear All
            </Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
};