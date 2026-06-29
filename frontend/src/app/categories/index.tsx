// app/categories/index.tsx
import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  Image,
  SafeAreaView,
  TextInput,
  FlatList,
  RefreshControl,
  Dimensions,
  Alert,
  Platform,
} from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '@/context/themeContext';

const { width } = Dimensions.get('window');

// ✅ Get the correct API URL based on platform
const getApiUrl = () => {
  if (Platform.OS === 'web') {
    return process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000/api';
  }
  return process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000/api';
};

const API_URL = getApiUrl();

console.log('📡 API URL:', API_URL);

interface Category {
  id: string;
  name: string;
  icon: string;
  color: string;
  image?: string;
  courseCount?: number;
  description?: string;
  popular?: boolean;
  trending?: boolean;
  slug?: string;
  isActive?: boolean;
  _count?: {
    courses: number;
  };
}

// Skeleton Components
const Skeleton = ({ className = '', bgColor = '#E2E8F0' }: { className?: string; bgColor?: string }) => (
  <View className={`rounded-lg animate-pulse ${className}`} style={{ backgroundColor: bgColor }} />
);

const SkeletonText = ({ className = '', bgColor = '#E2E8F0' }: { className?: string; bgColor?: string }) => (
  <View className={`rounded h-4 ${className}`} style={{ backgroundColor: bgColor }} />
);

const SkeletonCircle = ({ size = 28, bgColor = '#E2E8F0' }: { size?: number; bgColor?: string }) => (
  <View className="rounded-full" style={{ width: size, height: size, backgroundColor: bgColor }} />
);

export default function CategoriesPage() {
  const insets = useSafeAreaInsets();
  const { isDarkMode, colors } = useTheme();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [categories, setCategories] = useState<Category[]>([]);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    fetchCategories();
  }, []);

  const fetchCategories = async () => {
    try {
      setLoading(true);
      
      console.log('🌐 Fetching categories from:', `${API_URL}/categories?includeCourses=true`);
      
      const response = await fetch(`${API_URL}/api/categories`, {
        headers: {
          'Content-Type': 'application/json',
        },
      });
      
      console.log('📥 Response status:', response.status);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const result = await response.json();
      console.log('📥 Response data:', JSON.stringify(result, null, 2));
      
      let categoriesData: Category[] = [];
      
      if (result.success && result.data) {
        categoriesData = result.data.map((cat: any) => ({
          id: cat.id,
          name: cat.name,
          slug: cat.slug,
          icon: cat.icon || 'book-outline',
          color: cat.color || '#2563EB',
          image: cat.image,
          description: cat.description || '',
          courseCount: cat._count?.courses || cat.courseCount || 0,
          isActive: cat.isActive !== undefined ? cat.isActive : true,
          popular: cat.popular || false,
          trending: cat.trending || false,
        }));
        
        console.log(`✅ Fetched ${categoriesData.length} categories`);
      } else {
        console.log('⚠️ No categories found in response - showing empty state');
        categoriesData = [];
      }
      
      setCategories(categoriesData);
    } catch (error: any) {
      console.error('❌ Failed to fetch categories:', error.message);
      Alert.alert(
        'Error',
        `Failed to load categories: ${error.message}`
      );
      setCategories([]);
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchCategories();
    setRefreshing(false);
  };

  const filteredCategories = categories.filter(category =>
    category.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    category.description?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleCategoryPress = (categoryId: string) => {
    const category = categories?.find((cat) => cat.id === categoryId);
    if (category) {
      const slug = category.slug || category.name.toLowerCase().replace(/\s+/g, "-");
      router.push(`/categories/${slug}` as any);
    } else {
      router.push('/categories' as any);
    }
  };

  const handleBack = () => {
    router.back();
  };

  const renderCategoryItem = ({ item, index }: { item: Category; index: number }) => {
    return (
      <TouchableOpacity
        className="mb-4"
        onPress={() => handleCategoryPress(item.id)}
        activeOpacity={0.8}
      >
        <View className="flex-row items-center rounded-2xl overflow-hidden border"
          style={{
            backgroundColor: colors.backgroundElement,
            borderColor: colors.backgroundSelected,
            shadowColor: isDarkMode ? '#000000' : '#0F172A',
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: isDarkMode ? 0.3 : 0.05,
            shadowRadius: 4,
            elevation: 2,
          }}
        >
          <View className="relative w-24 h-24 overflow-hidden">
            <Image
              source={{ uri: item.image || `https://picsum.photos/seed/${item.id}/200/200` }}
              className="w-full h-full"
              resizeMode="cover"
            />
            <LinearGradient
              colors={['transparent', 'rgba(0,0,0,0.3)']}
              className="absolute inset-0"
            />
          </View>
          
          <View className="flex-1 p-3">
            <View className="flex-row items-center justify-between">
              <Text className="font-bold text-base" style={{ color: colors.text }}>
                {item.name}
              </Text>
              {item.popular && (
                <View className="bg-[#FEF3C7] px-2 py-0.5 rounded-full">
                  <Text className="text-[#F59E0B] text-[10px] font-semibold">POPULAR</Text>
                </View>
              )}
              {item.trending && !item.popular && (
                <View className="bg-[#D1FAE5] px-2 py-0.5 rounded-full">
                  <Text className="text-[#10B981] text-[10px] font-semibold">TRENDING</Text>
                </View>
              )}
            </View>
            
            {item.description && (
              <Text className="text-sm mt-0.5" style={{ color: colors.textSecondary }} numberOfLines={1}>
                {item.description}
              </Text>
            )}
            
            <View className="flex-row items-center mt-1.5">
              <View 
                className="w-2 h-2 rounded-full"
                style={{ backgroundColor: item.color }}
              />
              <Text className="text-xs ml-1.5" style={{ color: colors.textSecondary }}>
                {item.courseCount} courses
              </Text>
              <Text className="text-xs mx-2" style={{ color: colors.textSecondary }}>•</Text>
              <View className="flex-row items-center">
                <Ionicons name="arrow-forward" size={12} color={colors.primary} />
                <Text className="text-xs font-medium ml-1" style={{ color: colors.primary }}>
                  Explore
                </Text>
              </View>
            </View>
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  if (loading) {
    const skeletonBg = isDarkMode ? '#1E293B' : '#E2E8F0';
    return (
      <SafeAreaView className="flex-1" style={{ backgroundColor: colors.background }}>
        <StatusBar style={isDarkMode ? 'light' : 'dark'} />
        <View className="flex-row items-center px-4 py-3 border-b"
          style={{
            backgroundColor: colors.backgroundElement,
            borderBottomColor: colors.backgroundSelected,
          }}
        >
          <SkeletonCircle size={40} bgColor={skeletonBg} />
          <SkeletonText className="w-32 h-6 ml-3" bgColor={skeletonBg} />
          <SkeletonText className="w-20 h-5 ml-auto" bgColor={skeletonBg} />
        </View>
        <View className="px-4 py-3 border-b"
          style={{
            backgroundColor: colors.backgroundElement,
            borderBottomColor: colors.backgroundSelected,
          }}
        >
          <Skeleton className="h-11 rounded-xl" bgColor={skeletonBg} />
        </View>
        <ScrollView className="flex-1 px-4 pt-4" showsVerticalScrollIndicator={false}>
          {[1, 2, 3, 4, 5].map((i) => (
            <View key={i} className="flex-row items-center rounded-2xl mb-4 overflow-hidden border"
              style={{
                backgroundColor: colors.backgroundElement,
                borderColor: colors.backgroundSelected,
              }}
            >
              <Skeleton className="w-24 h-24" bgColor={skeletonBg} />
              <View className="flex-1 p-3">
                <View className="flex-row items-center justify-between">
                  <SkeletonText className="w-28 h-5" bgColor={skeletonBg} />
                  <SkeletonText className="w-16 h-4" bgColor={skeletonBg} />
                </View>
                <SkeletonText className="w-48 h-4 mt-1" bgColor={skeletonBg} />
                <View className="flex-row items-center mt-2">
                  <Skeleton className="w-2 h-2 rounded-full" bgColor={skeletonBg} />
                  <SkeletonText className="w-20 h-3 ml-1.5" bgColor={skeletonBg} />
                </View>
              </View>
            </View>
          ))}
        </ScrollView>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView className="flex-1" style={{ backgroundColor: colors.background }}>
      <StatusBar style={isDarkMode ? 'light' : 'dark'} />

      <View className="flex-row items-center px-4 py-3 border-b"
        style={{
          backgroundColor: colors.backgroundElement,
          borderBottomColor: colors.backgroundSelected,
        }}
      >
        <TouchableOpacity
          onPress={handleBack}
          className="w-10 h-10 rounded-full items-center justify-center"
          style={{ backgroundColor: colors.backgroundSelected }}
          activeOpacity={0.7}
        >
          <Ionicons name="chevron-back" size={24} color={colors.text} />
        </TouchableOpacity>
        <View className="flex-1 ml-2">
          <Text className="text-lg font-bold" style={{ color: colors.text }}>Categories</Text>
          <Text className="text-xs" style={{ color: colors.textSecondary }}>
            {filteredCategories.length} categories available
          </Text>
        </View>
        <TouchableOpacity className="w-10 h-10 rounded-full items-center justify-center"
          style={{ backgroundColor: colors.backgroundSelected }}
        >
          <Ionicons name="grid-outline" size={20} color={colors.text} />
        </TouchableOpacity>
      </View>

      <View className="px-4 py-3 border-b"
        style={{
          backgroundColor: colors.backgroundElement,
          borderBottomColor: colors.backgroundSelected,
        }}
      >
        <View className="flex-row items-center rounded-xl px-3"
          style={{ backgroundColor: colors.backgroundSelected }}
        >
          <Ionicons name="search-outline" size={20} color={colors.textSecondary} />
          <TextInput
            className="flex-1 py-2.5 px-2 text-sm"
            style={{ color: colors.text }}
            placeholder="Search categories..."
            value={searchQuery}
            onChangeText={setSearchQuery}
            placeholderTextColor={colors.textSecondary}
          />
          {searchQuery.length > 0 && (
            <TouchableOpacity onPress={() => setSearchQuery('')}>
              <Ionicons name="close-circle" size={20} color={colors.textSecondary} />
            </TouchableOpacity>
          )}
        </View>
      </View>

      <FlatList
        data={filteredCategories}
        renderItem={renderCategoryItem}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ 
          paddingHorizontal: 16,
          paddingTop: 16,
          paddingBottom: insets.bottom + 80,
        }}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.primary}
            colors={[colors.primary]}
          />
        }
        ListEmptyComponent={
          <View className="items-center py-16">
            <View className="w-24 h-24 rounded-full items-center justify-center mb-4"
              style={{ backgroundColor: colors.backgroundSelected }}
            >
              <Ionicons name="search-outline" size={48} color={colors.textSecondary} />
            </View>
            <Text className="text-xl font-bold" style={{ color: colors.text }}>
              No Categories Found
            </Text>
            <Text className="text-center mt-1 px-8" style={{ color: colors.textSecondary }}>
              {searchQuery 
                ? `We couldn't find any categories matching "${searchQuery}"`
                : "No categories available"}
            </Text>
            {searchQuery && (
              <TouchableOpacity
                className="mt-6 px-6 py-3 rounded-xl"
                style={{ backgroundColor: colors.primary }}
                onPress={() => setSearchQuery('')}
              >
                <Text className="text-white font-semibold">Clear Search</Text>
              </TouchableOpacity>
            )}
          </View>
        }
      />
    </SafeAreaView>
  );
}