// components/home/Categories.tsx
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image, Dimensions, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { useTheme } from '@/context/themeContext';

const { width } = Dimensions.get('window');

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
  const { isDarkMode, colors } = useTheme();

  // Debug: Log categories received
  console.log('📦 Categories received in component:', categories?.length || 0);
  console.log('📦 Categories data:', JSON.stringify(categories, null, 2));

  // Process categories with proper data - only use real data, no fallbacks
  const processedCategories = categories?.map((cat, index) => ({
    ...cat,
    slug: cat.slug || getCategorySlug(cat.name),
    courseCount: cat._count?.courses || cat.courseCount || 0,
    color: cat.color || DEFAULT_COLORS[index % DEFAULT_COLORS.length],
    // Only use image if it exists, otherwise leave undefined
    image: cat.image,
  })) || [];

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
      <View style={{ width: '100%' }}>
        <View className="flex-row justify-between items-center mb-4">
          <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text }}>
            Categories
          </Text>
          <TouchableOpacity 
            onPress={handleSeeAll}
            className="flex-row items-center"
            activeOpacity={0.7}
          >
            <Text style={{ fontSize: 14, fontWeight: '600', color: colors.primary }}>
              See All
            </Text>
            <Ionicons name="chevron-forward" size={16} color={colors.primary} />
          </TouchableOpacity>
        </View>
        <View style={{
          alignItems: 'center',
          paddingVertical: 32,
          borderRadius: 16,
          borderWidth: 1,
          backgroundColor: colors.backgroundElement,
          borderColor: colors.backgroundSelected,
        }}>
          <Ionicons name="book-outline" size={40} color={colors.textSecondary} />
          <Text style={{ fontSize: 14, marginTop: 8, color: colors.textSecondary }}>
            No categories available
          </Text>
        </View>
      </View>
    );
  }

  return (
    <View style={{ width: '100%' }}>
      <View className="flex-row justify-between items-center mb-4">
        <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text }}>
          Categories
        </Text>
        <TouchableOpacity 
          onPress={handleSeeAll}
          className="flex-row items-center"
          activeOpacity={0.7}
        >
          <Text style={{ fontSize: 14, fontWeight: '600', color: colors.primary }}>
            See All
          </Text>
          <Ionicons name="chevron-forward" size={16} color={colors.primary} />
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
          const color = category.color || DEFAULT_COLORS[index % DEFAULT_COLORS.length];
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
                {/* Category Image - Only show if image exists */}
                {imageUrl ? (
                  <Image
                    source={{ uri: imageUrl }}
                    className="w-full h-28"
                    resizeMode="cover"
                  />
                ) : (
                  <View 
                    className="w-full h-28 items-center justify-center"
                    style={{ backgroundColor: `${color}30` }}
                  >
                    <Ionicons name="book-outline" size={32} color={color} />
                  </View>
                )}
                
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