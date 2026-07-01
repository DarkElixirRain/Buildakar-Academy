// app/(search)/index.tsx
import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Image,
  TextInput,
  RefreshControl,
  ActivityIndicator,
  FlatList,
  ScrollView,
} from 'react-native';
import { useLocalSearchParams, useRouter, Stack } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';
import { searchService } from '@/services/search.service';
import { SearchResult, CourseSearchResult, InstructorSearchResult, CategorySearchResult } from '@/types/search';

type FilterType = 'all' | 'courses' | 'instructors' | 'categories';

export default function SearchScreen() {
  const { q } = useLocalSearchParams<{ q: string }>();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { isDarkMode, colors } = useTheme();

  // State
  const [searchQuery, setSearchQuery] = useState(q || '');
  const [results, setResults] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [activeFilter, setActiveFilter] = useState<FilterType>('all');
  const [suggestions, setSuggestions] = useState<any[]>([]);
  const [showSuggestions, setShowSuggestions] = useState(false);

  // Search function
  const performSearch = useCallback(async (query: string, filter: FilterType = 'all') => {
    if (!query.trim()) {
      setResults(null);
      return;
    }

    try {
      setLoading(true);
      console.log(`🔍 Searching for: ${query} (filter: ${filter})`);
      
      const data = await searchService.search(query, filter);
      console.log('📊 Full search response:', JSON.stringify(data, null, 2));
      
      // ✅ The data is already the parsed response from the service
      // The service returns response.data.data, so results should be the data object
      setResults(data);
      setShowSuggestions(false);
    } catch (error: any) {
      console.error('❌ Search failed:', error);
      setResults(null);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  // Get suggestions for autocomplete
  const fetchSuggestions = useCallback(async (query: string) => {
    if (query.length < 2) {
      setSuggestions([]);
      return;
    }

    try {
      const data = await searchService.getSuggestions(query);
      setSuggestions(data);
      setShowSuggestions(true);
    } catch (error) {
      console.error('❌ Suggestions failed:', error);
    }
  }, []);

  // Debounced search for suggestions
  useEffect(() => {
    const timer = setTimeout(() => {
      if (searchQuery.length >= 2) {
        fetchSuggestions(searchQuery);
      } else {
        setSuggestions([]);
        setShowSuggestions(false);
      }
    }, 300);

    return () => clearTimeout(timer);
  }, [searchQuery]);

  // Initial search when component mounts with query
  useEffect(() => {
    if (q) {
      setSearchQuery(q);
      performSearch(q);
    }
  }, [q]);

  // Handle search submit
  const handleSearch = () => {
    if (searchQuery.trim()) {
      router.setParams({ q: searchQuery.trim() });
      performSearch(searchQuery.trim(), activeFilter);
    }
  };

  // Handle filter change
  const handleFilterChange = (filter: FilterType) => {
    setActiveFilter(filter);
    if (searchQuery.trim()) {
      performSearch(searchQuery.trim(), filter);
    }
  };

  // Handle suggestion press
  const handleSuggestionPress = (suggestion: any) => {
    setSearchQuery(suggestion.title);
    setShowSuggestions(false);
    router.setParams({ q: suggestion.title });
    performSearch(suggestion.title, activeFilter);
  };

  // Handle course press
  const handleCoursePress = (courseId: string) => {
    router.push(`/course-details/${courseId}`);
  };

  // Handle instructor press
  const handleInstructorPress = (instructorId: string) => {
    router.push(`/instructor/${instructorId}`);
  };

  // Handle category press
  const handleCategoryPress = (categorySlug: string) => {
    router.push(`/categories/${categorySlug}`);
  };

  // Handle back
  const handleBack = () => {
    if (router.canGoBack()) {
      router.back();
    } else {
      router.push('/(tabs)' as any);
    }
  };

  // Clear search
  const clearSearch = () => {
    setSearchQuery('');
    setResults(null);
    setSuggestions([]);
    setShowSuggestions(false);
    router.setParams({ q: '' });
  };

  // ✅ Get the data to display
  const getDisplayData = () => {
    if (!results) return null;

    // The results structure is:
    // {
    //   courses: [...],
    //   instructors: [...],
    //   categories: [...],
    //   meta: { query, totalResults, type }
    // }
    
    let courses = results.courses || [];
    let instructors = results.instructors || [];
    let categories = results.categories || [];
    let meta = results.meta || { query: searchQuery, totalResults: 0 };

    // Apply filter
    if (activeFilter === 'courses') {
      instructors = [];
      categories = [];
    } else if (activeFilter === 'instructors') {
      courses = [];
      categories = [];
    } else if (activeFilter === 'categories') {
      courses = [];
      instructors = [];
    }

    return { courses, instructors, categories, meta };
  };

  const displayData = getDisplayData();

  // ✅ Render course card
  const renderCourseCard = ({ item }: { item: CourseSearchResult }) => {
    if (!item) return null;
    
    return (
      <TouchableOpacity
        style={{
          flexDirection: 'row',
          padding: 12,
          marginBottom: 12,
          borderRadius: 12,
          backgroundColor: colors.backgroundElement,
          borderWidth: 1,
          borderColor: colors.backgroundSelected,
        }}
        onPress={() => handleCoursePress(item.id)}
        activeOpacity={0.7}
      >
        <Image
          source={{ uri: item.thumbnail || 'https://via.placeholder.com/100x100' }}
          style={{
            width: 100,
            height: 80,
            borderRadius: 8,
            backgroundColor: colors.backgroundSelected,
          }}
          resizeMode="cover"
        />
        
        <View style={{ flex: 1, marginLeft: 12, justifyContent: 'space-between' }}>
          <View>
            <Text
              style={{
                fontSize: 14,
                fontWeight: '600',
                color: colors.text,
                marginBottom: 2,
              }}
              numberOfLines={2}
            >
              {item.title || 'Untitled Course'}
            </Text>
            <Text
              style={{
                fontSize: 12,
                color: colors.textSecondary,
              }}
              numberOfLines={1}
            >
              {item.instructor?.firstName || ''} {item.instructor?.lastName || ''}
            </Text>
          </View>
          
          <View className="flex-row items-center justify-between">
            <View className="flex-row items-center">
              <Ionicons name="star" size={14} color="#F59E0B" />
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 4 }}>
                {item.rating?.toFixed(1) || '0.0'}
              </Text>
              <Text style={{ color: colors.textSecondary, fontSize: 12, marginLeft: 8 }}>
                {item.studentsCount || 0} students
              </Text>
            </View>
            
            <Text style={{ color: colors.primary, fontSize: 14, fontWeight: 'bold' }}>
              {item.price === 0 ? 'Free' : `$${item.price?.toFixed(2) || '0.00'}`}
            </Text>
          </View>
          
          {item.level && (
            <View
              style={{
                position: 'absolute',
                top: 0,
                right: 0,
                paddingHorizontal: 8,
                paddingVertical: 2,
                borderRadius: 12,
                backgroundColor: colors.primary + '20',
              }}
            >
              <Text style={{ fontSize: 10, color: colors.primary }}>
                {item.level}
              </Text>
            </View>
          )}
        </View>
      </TouchableOpacity>
    );
  };

  // ✅ Render instructor card
  const renderInstructorCard = ({ item }: { item: InstructorSearchResult }) => {
    if (!item) return null;
    
    return (
      <TouchableOpacity
        style={{
          flexDirection: 'row',
          padding: 12,
          marginBottom: 12,
          borderRadius: 12,
          backgroundColor: colors.backgroundElement,
          borderWidth: 1,
          borderColor: colors.backgroundSelected,
          alignItems: 'center',
        }}
        onPress={() => handleInstructorPress(item.id)}
        activeOpacity={0.7}
      >
        <Image
          source={{ uri: item.photo || `https://ui-avatars.com/api/?name=${item.name || 'Instructor'}&size=150&background=4F46E5&color=fff` }}
          style={{
            width: 50,
            height: 50,
            borderRadius: 25,
            backgroundColor: colors.backgroundSelected,
          }}
        />
        
        <View style={{ flex: 1, marginLeft: 12 }}>
          <Text
            style={{
              fontSize: 16,
              fontWeight: '600',
              color: colors.text,
            }}
          >
            {item.name || 'Instructor'}
          </Text>
          <Text
            style={{
              fontSize: 14,
              color: colors.textSecondary,
            }}
          >
            {item.expertise || 'Instructor'}
          </Text>
          <View className="flex-row items-center mt-1">
            <Ionicons name="people" size={14} color={colors.textSecondary} />
            <Text style={{ fontSize: 12, color: colors.textSecondary, marginLeft: 4 }}>
              {item.studentsCount || 0} students
            </Text>
            <Text style={{ fontSize: 12, color: colors.textSecondary, marginLeft: 12 }}>
              {item.coursesCount || 0} courses
            </Text>
            {item.isVerified && (
              <View className="ml-2 bg-green-500 px-1.5 py-0.5 rounded-full">
                <Text style={{ color: 'white', fontSize: 8, fontWeight: '600' }}>
                  Verified
                </Text>
              </View>
            )}
          </View>
        </View>
        
        <Ionicons name="chevron-forward" size={20} color={colors.textSecondary} />
      </TouchableOpacity>
    );
  };

  // ✅ Render category card
  const renderCategoryCard = ({ item }: { item: CategorySearchResult }) => {
    if (!item) return null;
    
    return (
      <TouchableOpacity
        style={{
          padding: 16,
          marginBottom: 12,
          borderRadius: 12,
          backgroundColor: colors.backgroundElement,
          borderWidth: 1,
          borderColor: colors.backgroundSelected,
          flexDirection: 'row',
          alignItems: 'center',
        }}
        onPress={() => handleCategoryPress(item.slug || item.id)}
        activeOpacity={0.7}
      >
        <View
          style={{
            width: 48,
            height: 48,
            borderRadius: 24,
            backgroundColor: (item.color || '#7C3AED') + '20',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <Ionicons name={(item.icon || 'folder') as any} size={24} color={item.color || '#7C3AED'} />
        </View>
        
        <View style={{ flex: 1, marginLeft: 12 }}>
          <Text
            style={{
              fontSize: 16,
              fontWeight: '600',
              color: colors.text,
            }}
          >
            {item.name || 'Category'}
          </Text>
          {item.description && (
            <Text
              style={{
                fontSize: 13,
                color: colors.textSecondary,
                marginTop: 2,
              }}
              numberOfLines={2}
            >
              {item.description}
            </Text>
          )}
          <Text
            style={{
              fontSize: 12,
              color: colors.textSecondary,
              marginTop: 4,
            }}
          >
            {item.courseCount || 0} courses
          </Text>
        </View>
        
        <Ionicons name="chevron-forward" size={20} color={colors.textSecondary} />
      </TouchableOpacity>
    );
  };

  // ✅ Render section
  const renderSection = (title: string, data: any[], renderItem: any, key: string) => {
    if (!data || data.length === 0) return null;

    return (
      <View key={key} style={{ marginBottom: 16 }}>
        <Text
          style={{
            fontSize: 16,
            fontWeight: 'bold',
            color: colors.text,
            marginBottom: 12,
          }}
        >
          {title} ({data.length})
        </Text>
        <FlatList
          data={data}
          keyExtractor={(item) => item?.id || Math.random().toString()}
          renderItem={renderItem}
          scrollEnabled={false}
        />
      </View>
    );
  };

  // ✅ Render all results
  const renderResults = () => {
    if (!displayData) {
      return (
        <View className="flex-1 items-center justify-center px-8">
          <Ionicons name="search-outline" size={64} color={colors.textSecondary} />
          <Text
            style={{
              fontSize: 18,
              fontWeight: '600',
              color: colors.text,
              marginTop: 16,
            }}
          >
            No results found
          </Text>
          <Text
            style={{
              fontSize: 14,
              color: colors.textSecondary,
              textAlign: 'center',
              marginTop: 4,
            }}
          >
            Try a different search term
          </Text>
        </View>
      );
    }

    const { courses, instructors, categories, meta } = displayData;

    return (
      <ScrollView
        style={{ flex: 1 }}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={() => {
              setRefreshing(true);
              performSearch(searchQuery, activeFilter);
            }}
            tintColor={colors.primary}
          />
        }
      >
        {/* Results header */}
        <Text
          style={{
            fontSize: 14,
            color: colors.textSecondary,
            marginBottom: 16,
            marginTop: 8,
            paddingHorizontal: 16,
          }}
        >
          Found {meta?.totalResults || 0} results for "{meta?.query || searchQuery}"
        </Text>

        {/* Courses */}
        {renderSection('Courses', courses, renderCourseCard, 'courses')}

        {/* Instructors */}
        {renderSection('Instructors', instructors, renderInstructorCard, 'instructors')}

        {/* Categories */}
        {renderSection('Categories', categories, renderCategoryCard, 'categories')}

        {/* No results message */}
        {(!courses || courses.length === 0) && 
         (!instructors || instructors.length === 0) && 
         (!categories || categories.length === 0) && (
          <View className="items-center py-12">
            <Ionicons name="search-outline" size={64} color={colors.textSecondary} />
            <Text
              style={{
                fontSize: 18,
                fontWeight: '600',
                color: colors.text,
                marginTop: 16,
              }}
            >
              No results found
            </Text>
            <Text
              style={{
                fontSize: 14,
                color: colors.textSecondary,
                textAlign: 'center',
                marginTop: 4,
              }}
            >
              Try a different search term
            </Text>
          </View>
        )}
      </ScrollView>
    );
  };

  return (
    <View style={{ flex: 1, backgroundColor: colors.background }}>
      <Stack.Screen options={{ headerShown: false }} />
      
      {/* Header */}
      <View
        style={{
          paddingHorizontal: 16,
          paddingTop: insets.top + 12,
          paddingBottom: 12,
          backgroundColor: colors.backgroundElement,
          borderBottomWidth: 1,
          borderBottomColor: colors.backgroundSelected,
        }}
      >
        <View className="flex-row items-center">
          <TouchableOpacity
            onPress={handleBack}
            style={{
              padding: 8,
              marginRight: 8,
            }}
          >
            <Ionicons name="chevron-back" size={24} color={colors.text} />
          </TouchableOpacity>
          
          <View className="flex-1 flex-row items-center">
            <View
              style={{
                flex: 1,
                flexDirection: 'row',
                alignItems: 'center',
                borderRadius: 12,
                paddingHorizontal: 12,
                backgroundColor: colors.backgroundSelected,
              }}
            >
              <Ionicons name="search" size={20} color={colors.textSecondary} />
              <TextInput
                style={{
                  flex: 1,
                  paddingVertical: 8,
                  paddingHorizontal: 8,
                  fontSize: 16,
                  color: colors.text,
                }}
                placeholder="Search courses, skills, instructors..."
                placeholderTextColor={colors.textSecondary}
                value={searchQuery}
                onChangeText={setSearchQuery}
                onSubmitEditing={handleSearch}
                returnKeyType="search"
                autoFocus
              />
              {searchQuery.length > 0 && (
                <TouchableOpacity onPress={clearSearch}>
                  <Ionicons name="close-circle" size={20} color={colors.textSecondary} />
                </TouchableOpacity>
              )}
            </View>
          </View>
        </View>
      </View>

      {/* Filter Tabs */}
      <View
        style={{
          paddingHorizontal: 16,
          paddingVertical: 12,
          borderBottomWidth: 1,
          borderBottomColor: colors.backgroundSelected,
        }}
      >
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          <View className="flex-row items-center space-x-2">
            {(['all', 'courses', 'instructors', 'categories'] as FilterType[]).map((filter) => (
              <TouchableOpacity
                key={filter}
                style={{
                  paddingHorizontal: 16,
                  paddingVertical: 6,
                  borderRadius: 20,
                  backgroundColor: activeFilter === filter ? colors.primary : colors.backgroundSelected,
                  marginRight: 8,
                }}
                onPress={() => handleFilterChange(filter)}
              >
                <Text
                  style={{
                    fontSize: 12,
                    fontWeight: '500',
                    color: activeFilter === filter ? 'white' : colors.textSecondary,
                    textTransform: 'capitalize',
                  }}
                >
                  {filter === 'all' ? 'All' : filter}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </ScrollView>
      </View>

      {/* Suggestions */}
      {showSuggestions && suggestions.length > 0 && (
        <View
          style={{
            position: 'absolute',
            top: 120,
            left: 16,
            right: 16,
            borderRadius: 12,
            backgroundColor: colors.backgroundElement,
            borderWidth: 1,
            borderColor: colors.backgroundSelected,
            maxHeight: 200,
            zIndex: 1000,
            shadowColor: '#000',
            shadowOffset: { width: 0, height: 4 },
            shadowOpacity: 0.1,
            shadowRadius: 8,
            elevation: 5,
          }}
        >
          <FlatList
            data={suggestions}
            keyExtractor={(item) => item?.id || Math.random().toString()}
            renderItem={({ item }) => (
              <TouchableOpacity
                style={{
                  paddingHorizontal: 16,
                  paddingVertical: 12,
                  borderBottomWidth: 1,
                  borderBottomColor: colors.backgroundSelected,
                  flexDirection: 'row',
                  alignItems: 'center',
                }}
                onPress={() => handleSuggestionPress(item)}
              >
                {item.type === 'course' && (
                  <Ionicons name="book-outline" size={20} color={colors.textSecondary} />
                )}
                {item.type === 'instructor' && (
                  <Ionicons name="person-outline" size={20} color={colors.textSecondary} />
                )}
                {item.type === 'category' && (
                  <Ionicons name="folder-outline" size={20} color={colors.textSecondary} />
                )}
                <View style={{ marginLeft: 12 }}>
                  <Text style={{ color: colors.text, fontSize: 14, fontWeight: '500' }}>
                    {item.title || 'Untitled'}
                  </Text>
                  {item.subtitle && (
                    <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
                      {item.subtitle}
                    </Text>
                  )}
                </View>
              </TouchableOpacity>
            )}
          />
        </View>
      )}

      {/* Results or Loading */}
      {loading ? (
        <View className="flex-1 items-center justify-center">
          <ActivityIndicator size="large" color={colors.primary} />
          <Text style={{ color: colors.textSecondary, marginTop: 12 }}>
            Searching...
          </Text>
        </View>
      ) : (
        renderResults()
      )}
    </View>
  );
}