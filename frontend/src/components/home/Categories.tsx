// components/home/Categories.tsx
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image, Dimensions, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';

const { width } = Dimensions.get('window');

// API Configuration
const API_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000/api';

interface Category {
  id: string;
  name: string;
  icon: string;
  color: string;
  image?: string;
  courseCount?: number;
  slug?: string;
  description?: string;
  isActive?: boolean;
  _count?: {
    courses: number;
  };
}

interface CategoriesProps {
  categories: Category[];
  onCategoryPress: (categoryId: string) => void;
  onSeeAll?: () => void;
}

// Fallback images for categories
const FALLBACK_IMAGES = [
  'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400&h=300&fit=crop',
  'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&h=300&fit=crop',
  'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=300&fit=crop',
  'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400&h=300&fit=crop',
  'https://images.unsplash.com/photo-1432889821006-4ba4fa9c2a00?w=400&h=300&fit=crop',
  'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&h=300&fit=crop',
  'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=400&h=300&fit=crop',
  'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&h=300&fit=crop',
];

// Map category names to slugs
const getCategorySlug = (name: string): string => {
  return name.toLowerCase().replace(/\s+/g, '-');
};

// Default colors for categories if not provided
const DEFAULT_COLORS = [
  '#2563EB', '#7C3AED', '#22C55E', '#F59E0B', 
  '#EF4444', '#3B82F6', '#10B981', '#EC4899',
  '#8B5CF6', '#F472B6'
];

export const Categories: React.FC<CategoriesProps> = ({
  categories,
  onCategoryPress,
  onSeeAll,
}) => {
  const [loading, setLoading] = useState(false);

  // Process categories with proper data
  const processedCategories = categories.map((cat, index) => ({
    ...cat,
    slug: cat.slug || getCategorySlug(cat.name),
    courseCount: cat._count?.courses || cat.courseCount || 0,
    color: cat.color || DEFAULT_COLORS[index % DEFAULT_COLORS.length],
    image: cat.image || FALLBACK_IMAGES[index % FALLBACK_IMAGES.length],
  }));

  // Handle See All press
  const handleSeeAll = () => {
    if (onSeeAll) {
      onSeeAll();
    } else {
      router.push('/categories' as any);
    }
  };

  // Handle category press
  const handleCategoryPress = (category: Category) => {
    const slug = category.slug || getCategorySlug(category.name);
    
    if (onCategoryPress) {
      onCategoryPress(category.id);
    } else {
      // Navigate to category detail page using slug
      router.push(`/categories/${slug}` as any);
    }
  };

  // If no categories, show empty state
  if (!categories || categories.length === 0) {
    return (
      <View className="w-full">
        <View className="flex-row justify-between items-center mb-4">
          <Text className="text-[#0F172A] text-xl font-bold">
            Categories
          </Text>
          <TouchableOpacity 
            onPress={handleSeeAll}
            className="flex-row items-center"
            activeOpacity={0.7}
          >
            <Text className="text-[#2563EB] text-sm font-semibold">
              See All
            </Text>
            <Ionicons name="chevron-forward" size={16} color="#2563EB" />
          </TouchableOpacity>
        </View>
        <View className="items-center py-8 bg-[#F8FAFC] rounded-2xl border border-[#E2E8F0]">
          <Ionicons name="book-outline" size={40} color="#94A3B8" />
          <Text className="text-[#64748B] text-sm mt-2">
            No categories available
          </Text>
        </View>
      </View>
    );
  }

  return (
    <View className="w-full">
      <View className="flex-row justify-between items-center mb-4">
        <Text className="text-[#0F172A] text-xl font-bold">
          Categories
        </Text>
        <TouchableOpacity 
          onPress={handleSeeAll}
          className="flex-row items-center"
          activeOpacity={0.7}
        >
          <Text className="text-[#2563EB] text-sm font-semibold">
            See All
          </Text>
          <Ionicons name="chevron-forward" size={16} color="#2563EB" />
        </TouchableOpacity>
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
        decelerationRate="fast"
        snapToInterval={180}
        snapToAlignment="start"
      >
        {processedCategories.map((category, index) => {
          const color = category.color;
          const imageUrl = category.image;

          return (
            <TouchableOpacity
              key={category.id}
              className="mr-4"
              onPress={() => handleCategoryPress(category)}
              activeOpacity={0.8}
            >
              <View 
                className="w-40 rounded-2xl overflow-hidden"
                style={{
                  shadowColor: color,
                  shadowOffset: { width: 0, height: 6 },
                  shadowOpacity: 0.25,
                  shadowRadius: 12,
                  elevation: 6,
                }}
              >
                {/* Category Image */}
                <Image
                  source={{ uri: imageUrl }}
                  className="w-full h-28"
                  resizeMode="cover"
                />
                
                {/* Gradient Overlay */}
                <View 
                  className="absolute inset-0"
                  style={{ 
                    backgroundColor: `${color}60`,
                  }}
                />
                
                {/* Content Overlay */}
                <View className="absolute inset-0 p-3 justify-between">
                  {/* Category Icon/Name */}
                  <View className="flex-row items-center">
                    <View 
                      className="w-8 h-8 rounded-full items-center justify-center"
                      style={{ backgroundColor: `${color}CC` }}
                    >
                      {category.icon ? (
                        <Ionicons name={category.icon as any} size={16} color="#FFFFFF" />
                      ) : (
                        <Text className="text-white text-lg font-bold">
                          {category.name.charAt(0)}
                        </Text>
                      )}
                    </View>
                    <Text className="text-white font-bold text-sm ml-2" numberOfLines={1}>
                      {category.name}
                    </Text>
                  </View>
                  
                  {/* Course Count */}
                  <View className="flex-row items-center">
                    <Ionicons name="book-outline" size={14} color="white" />
                    <Text className="text-white text-xs ml-1">
                      {category.courseCount} Courses
                    </Text>
                  </View>
                </View>
              </View>
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </View>
  );
};