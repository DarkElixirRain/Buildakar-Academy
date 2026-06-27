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

const { width } = Dimensions.get('window');

// ✅ Get the correct API URL based on platform
const getApiUrl = () => {
  // For web
  if (Platform.OS === 'web') {
    // If running on web, use localhost or the actual backend URL
    return process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000/api';
  }
  // For native (iOS/Android)
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
const Skeleton = ({ className = '' }: { className?: string }) => (
  <View className={`bg-[#E2E8F0] rounded-lg animate-pulse ${className}`} />
);

const SkeletonText = ({ className = '' }: { className?: string }) => (
  <View className={`bg-[#E2E8F0] rounded h-4 ${className}`} />
);

const SkeletonCircle = ({ size = 28 }: { size?: number }) => (
  <View className="bg-[#E2E8F0] rounded-full" style={{ width: size, height: size }} />
);

export default function CategoriesPage() {
  const insets = useSafeAreaInsets();
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
          // Add authorization if needed
          // 'Authorization': `Bearer ${token}`,
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
        console.log('⚠️ No categories found in response');
        categoriesData = getMockCategories();
      }
      
      setCategories(categoriesData);
    } catch (error: any) {
      console.error('❌ Failed to fetch categories:', error.message);
      Alert.alert(
        'Error',
        `Failed to load categories: ${error.message}`
      );
      // Fallback mock data
      setCategories(getMockCategories());
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchCategories();
    setRefreshing(false);
  };

  const getMockCategories = (): Category[] => {
    return [
      {
        id: 'dev',
        name: 'Development',
        icon: 'code-slash',
        color: '#2563EB',
        image: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400&h=300&fit=crop',
        courseCount: 45,
        description: 'Learn programming and software development',
        popular: true,
      },
      {
        id: 'ai',
        name: 'AI & Machine Learning',
        icon: 'bulb-outline',
        color: '#7C3AED',
        image: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&h=300&fit=crop',
        courseCount: 32,
        description: 'Artificial Intelligence and Machine Learning',
        trending: true,
      },
      {
        id: 'data',
        name: 'Data Science',
        icon: 'bar-chart-outline',
        color: '#22C55E',
        image: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=300&fit=crop',
        courseCount: 28,
        description: 'Data analysis, visualization, and statistics',
        popular: true,
      },
      {
        id: 'design',
        name: 'Design',
        icon: 'color-palette-outline',
        color: '#F59E0B',
        image: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400&h=300&fit=crop',
        courseCount: 38,
        description: 'UI/UX, graphic design, and creative skills',
      },
      {
        id: 'marketing',
        name: 'Marketing',
        icon: 'megaphone-outline',
        color: '#EF4444',
        image: 'https://images.unsplash.com/photo-1432889821006-4ba4fa9c2a00?w=400&h=300&fit=crop',
        courseCount: 25,
        description: 'Digital marketing, SEO, and social media',
      },
      {
        id: 'business',
        name: 'Business',
        icon: 'briefcase-outline',
        color: '#3B82F6',
        image: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&h=300&fit=crop',
        courseCount: 30,
        description: 'Entrepreneurship and business management',
        popular: true,
      },
      {
        id: 'finance',
        name: 'Finance',
        icon: 'cash-outline',
        color: '#10B981',
        image: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=400&h=300&fit=crop',
        courseCount: 20,
        description: 'Financial planning and investment strategies',
      },
      {
        id: 'languages',
        name: 'Languages',
        icon: 'language-outline',
        color: '#EC4899',
        image: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&h=300&fit=crop',
        courseCount: 15,
        description: 'Learn new languages and communication skills',
      },
    ];
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
        <View className="flex-row items-center bg-white rounded-2xl overflow-hidden border border-[#E2E8F0]"
          style={{
            shadowColor: '#0F172A',
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: 0.05,
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
              <Text className="text-[#0F172A] font-bold text-base">
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
              <Text className="text-[#64748B] text-sm mt-0.5" numberOfLines={1}>
                {item.description}
              </Text>
            )}
            
            <View className="flex-row items-center mt-1.5">
              <View 
                className="w-2 h-2 rounded-full"
                style={{ backgroundColor: item.color }}
              />
              <Text className="text-[#94A3B8] text-xs ml-1.5">
                {item.courseCount} courses
              </Text>
              <Text className="text-[#94A3B8] text-xs ml-2">•</Text>
              <View className="flex-row items-center ml-2">
                <Ionicons name="arrow-forward" size={12} color="#2563EB" />
                <Text className="text-[#2563EB] text-xs font-medium ml-1">
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
    return (
      <SafeAreaView className="flex-1 bg-[#F8FAFC]">
        <StatusBar style="dark" />
        <View className="flex-row items-center px-4 py-3 bg-white border-b border-[#E2E8F0]">
          <SkeletonCircle size={40} />
          <SkeletonText className="w-32 h-6 ml-3" />
          <SkeletonText className="w-20 h-5 ml-auto" />
        </View>
        <View className="px-4 py-3 bg-white border-b border-[#E2E8F0]">
          <Skeleton className="h-11 rounded-xl" />
        </View>
        <ScrollView className="flex-1 px-4 pt-4" showsVerticalScrollIndicator={false}>
          {[1, 2, 3, 4, 5].map((i) => (
            <View key={i} className="flex-row items-center bg-white rounded-2xl mb-4 overflow-hidden border border-[#E2E8F0]">
              <Skeleton className="w-24 h-24" />
              <View className="flex-1 p-3">
                <View className="flex-row items-center justify-between">
                  <SkeletonText className="w-28 h-5" />
                  <SkeletonText className="w-16 h-4" />
                </View>
                <SkeletonText className="w-48 h-4 mt-1" />
                <View className="flex-row items-center mt-2">
                  <Skeleton className="w-2 h-2 rounded-full" />
                  <SkeletonText className="w-20 h-3 ml-1.5" />
                </View>
              </View>
            </View>
          ))}
        </ScrollView>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView className="flex-1 bg-[#F8FAFC]">
      <StatusBar style="dark" />

      <View className="flex-row items-center px-4 py-3 bg-white border-b border-[#E2E8F0]">
        <TouchableOpacity
          onPress={handleBack}
          className="w-10 h-10 rounded-full bg-[#F1F5F9] items-center justify-center"
          activeOpacity={0.7}
        >
          <Ionicons name="chevron-back" size={24} color="#0F172A" />
        </TouchableOpacity>
        <View className="flex-1 ml-2">
          <Text className="text-[#0F172A] text-lg font-bold">Categories</Text>
          <Text className="text-[#64748B] text-xs">
            {filteredCategories.length} categories available
          </Text>
        </View>
        <TouchableOpacity className="w-10 h-10 rounded-full bg-[#F1F5F9] items-center justify-center">
          <Ionicons name="grid-outline" size={20} color="#0F172A" />
        </TouchableOpacity>
      </View>

      <View className="px-4 py-3 bg-white border-b border-[#E2E8F0]">
        <View className="flex-row items-center bg-[#F1F5F9] rounded-xl px-3">
          <Ionicons name="search-outline" size={20} color="#94A3B8" />
          <TextInput
            className="flex-1 py-2.5 px-2 text-[#0F172A] text-sm"
            placeholder="Search categories..."
            value={searchQuery}
            onChangeText={setSearchQuery}
            placeholderTextColor="#94A3B8"
          />
          {searchQuery.length > 0 && (
            <TouchableOpacity onPress={() => setSearchQuery('')}>
              <Ionicons name="close-circle" size={20} color="#94A3B8" />
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
            tintColor="#2563EB"
            colors={["#2563EB"]}
          />
        }
        ListEmptyComponent={
          <View className="items-center py-16">
            <View className="w-24 h-24 rounded-full bg-[#F1F5F9] items-center justify-center mb-4">
              <Ionicons name="search-outline" size={48} color="#94A3B8" />
            </View>
            <Text className="text-[#0F172A] text-xl font-bold">
              No Categories Found
            </Text>
            <Text className="text-[#64748B] text-center mt-1 px-8">
              {searchQuery 
                ? `We couldn't find any categories matching "${searchQuery}"`
                : "No categories available"}
            </Text>
            <TouchableOpacity
              className="mt-6 px-6 py-3 bg-[#2563EB] rounded-xl"
              onPress={() => setSearchQuery('')}
            >
              <Text className="text-white font-semibold">Clear Search</Text>
            </TouchableOpacity>
          </View>
        }
      />
    </SafeAreaView>
  );
}