// app/categories/index.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  Image,
  SafeAreaView,
  TextInput,
  FlatList,
  ActivityIndicator,
} from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

interface Category {
  id: string;
  name: string;
  icon: string;
  color: string;
  image?: string;
  courseCount?: number;
  description?: string;
}

export default function CategoriesPage() {
  const insets = useSafeAreaInsets();
  const [loading, setLoading] = useState(true);
  const [categories, setCategories] = useState<Category[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);

  useEffect(() => {
    fetchCategories();
  }, []);

  const fetchCategories = async () => {
    try {
      await new Promise(resolve => setTimeout(resolve, 800));
      
      const mockCategories: Category[] = [
        {
          id: 'dev',
          name: 'Development',
          icon: 'code-slash',
          color: '#2563EB',
          image: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400&h=300&fit=crop',
          courseCount: 45,
          description: 'Learn programming and software development',
        },
        {
          id: 'ai',
          name: 'AI',
          icon: 'bulb-outline',
          color: '#7C3AED',
          image: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&h=300&fit=crop',
          courseCount: 32,
          description: 'Artificial Intelligence and Machine Learning',
        },
        {
          id: 'data',
          name: 'Data Science',
          icon: 'bar-chart-outline',
          color: '#22C55E',
          image: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=300&fit=crop',
          courseCount: 28,
          description: 'Data analysis, visualization, and statistics',
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
      
      setCategories(mockCategories);
      setLoading(false);
    } catch (error) {
      console.error('Failed to fetch categories:', error);
      setLoading(false);
    }
  };

  const filteredCategories = categories.filter(category =>
    category.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    category.description?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleCategoryPress = (categoryId: string) => {
    router.push(`/categories/${categoryId}`);
  };

  const renderCategoryItem = ({ item }: { item: Category }) => {
    const isSelected = selectedCategory === item.id;
    
    return (
      <TouchableOpacity
        className="mb-4"
        onPress={() => handleCategoryPress(item.id)}
        activeOpacity={0.8}
      >
        <View 
          className="flex-row items-center bg-white rounded-2xl border border-[#E2E8F0] overflow-hidden"
          style={{
            shadowColor: '#0F172A',
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: 0.05,
            shadowRadius: 4,
            elevation: 2,
          }}
        >
          {/* Category Image */}
          <Image
            source={{ uri: item.image || `https://picsum.photos/seed/${item.id}/200/200` }}
            className="w-24 h-24"
            resizeMode="cover"
          />
          
          {/* Content */}
          <View className="flex-1 p-3">
            <View className="flex-row items-center justify-between">
              <Text className="text-[#0F172A] font-bold text-base">
                {item.name}
              </Text>
              <View 
                className="px-2 py-0.5 rounded-full"
                style={{ backgroundColor: `${item.color}15` }}
              >
                <Text 
                  className="text-xs font-medium"
                  style={{ color: item.color }}
                >
                  {item.courseCount} Courses
                </Text>
              </View>
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
                Explore {item.name} courses →
              </Text>
            </View>
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  if (loading) {
    return (
      <SafeAreaView className="flex-1 bg-[#F8FAFC] items-center justify-center">
        <ActivityIndicator size="large" color="#2563EB" />
        <Text className="mt-4 text-[#64748B] text-sm font-medium">
          Loading categories...
        </Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView className="flex-1 bg-[#F8FAFC]">
      {/* Header */}
      <View className="flex-row items-center px-4 py-3 bg-white border-b border-[#E2E8F0]">
        <TouchableOpacity
          onPress={() => router.back()}
          className="w-10 h-10 rounded-full bg-[#F1F5F9] items-center justify-center"
        >
          <Ionicons name="chevron-back" size={24} color="#0F172A" />
        </TouchableOpacity>
        <Text className="text-[#0F172A] text-lg font-bold ml-2 flex-1">
          All Categories
        </Text>
        <Text className="text-[#64748B] text-sm">
          {filteredCategories.length} found
        </Text>
      </View>

      {/* Search Bar */}
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

      {/* Categories Grid */}
      <FlatList
        data={filteredCategories}
        renderItem={renderCategoryItem}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ 
          padding: 16,
          paddingBottom: insets.bottom + 80,
        }}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={
          <View className="items-center py-12">
            <Ionicons name="search-outline" size={60} color="#94A3B8" />
            <Text className="text-[#0F172A] text-lg font-bold mt-4">
              No Categories Found
            </Text>
            <Text className="text-[#64748B] text-center mt-1">
              Try adjusting your search terms
            </Text>
          </View>
        }
      />
    </SafeAreaView>
  );
}