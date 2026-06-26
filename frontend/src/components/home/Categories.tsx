// components/home/Categories.tsx
import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image, Dimensions } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';

const { width } = Dimensions.get('window');

interface Category {
  id: string;
  name: string;
  icon: string;
  color: string;
  image?: string;
  courseCount?: number;
}

interface CategoriesProps {
  categories: Category[];
  onCategoryPress: (categoryId: string) => void;
  onSeeAll?: () => void;
}

const CATEGORY_IMAGES: Record<string, any> = {
  'Development': 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400&h=300&fit=crop',
  'AI': 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&h=300&fit=crop',
  'Data Science': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=300&fit=crop',
  'Design': 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400&h=300&fit=crop',
  'Marketing': 'https://images.unsplash.com/photo-1432889821006-4ba4fa9c2a00?w=400&h=300&fit=crop',
  'Business': 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&h=300&fit=crop',
  'Finance': 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=400&h=300&fit=crop',
  'Languages': 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&h=300&fit=crop',
};

const FALLBACK_IMAGES = [
  'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&h=300&fit=crop',
  'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=400&h=300&fit=crop',
  'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=400&h=300&fit=crop',
  'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&h=300&fit=crop',
];

export const Categories: React.FC<CategoriesProps> = ({
  categories,
  onCategoryPress,
  onSeeAll,
}) => {
  // Add course counts to categories
  const categoriesWithCount = categories.map((cat, index) => ({
    ...cat,
    courseCount: Math.floor(Math.random() * 50) + 10, // Mock course count
  }));

  // Handle See All press - navigate to categories page
  const handleSeeAll = () => {
    if (onSeeAll) {
      onSeeAll();
    } else {
      // Navigate to the categories page
      router.push('/(categories)');
    }
  };

  // Handle category press
  const handleCategoryPress = (categoryId: string) => {
    if (onCategoryPress) {
      onCategoryPress(categoryId);
    } else {
      // Navigate to category detail page
      router.push(`/categories/${categoryId}`);
    }
  };

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
        {categoriesWithCount.map((category, index) => {
          const imageUrl = CATEGORY_IMAGES[category.name] || FALLBACK_IMAGES[index % FALLBACK_IMAGES.length];
          const color = category.color || '#2563EB';

          return (
            <TouchableOpacity
              key={category.id}
              className="mr-4"
              onPress={() => handleCategoryPress(category.id)}
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
                      <Text className="text-white text-lg font-bold">
                        {category.name.charAt(0)}
                      </Text>
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