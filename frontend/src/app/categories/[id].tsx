// app/categories/[id].tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  Image,
  SafeAreaView,
  FlatList,
  ActivityIndicator,
} from 'react-native';
import { router, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

interface CategoryDetail {
  id: string;
  name: string;
  description: string;
  image: string;
  color: string;
  courseCount: number;
  courses: {
    id: string;
    title: string;
    instructor: string;
    thumbnail: string;
    rating: number;
    students: number;
  }[];
}

export default function CategoryDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const insets = useSafeAreaInsets();
  const [loading, setLoading] = useState(true);
  const [category, setCategory] = useState<CategoryDetail | null>(null);

  useEffect(() => {
    if (id) {
      fetchCategoryDetail();
    }
  }, [id]);

  const fetchCategoryDetail = async () => {
    try {
      await new Promise(resolve => setTimeout(resolve, 800));
      
      const mockCategory: CategoryDetail = {
        id: id || '1',
        name: 'Development',
        description: 'Learn programming and software development',
        image: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&h=400&fit=crop',
        color: '#2563EB',
        courseCount: 45,
        courses: [
          {
            id: '1',
            title: 'The Complete React Native Course',
            instructor: 'John Doe',
            thumbnail: 'https://picsum.photos/seed/react/400/300',
            rating: 4.8,
            students: 15400,
          },
          {
            id: '2',
            title: 'JavaScript: The Advanced Concepts',
            instructor: 'Sarah Chen',
            thumbnail: 'https://picsum.photos/seed/js/400/300',
            rating: 4.9,
            students: 21300,
          },
          {
            id: '3',
            title: 'Python for Data Science',
            instructor: 'Bob Wilson',
            thumbnail: 'https://picsum.photos/seed/python/400/300',
            rating: 4.7,
            students: 8900,
          },
        ],
      };
      
      setCategory(mockCategory);
      setLoading(false);
    } catch (error) {
      console.error('Failed to fetch category:', error);
      setLoading(false);
    }
  };

  const handleCoursePress = (courseId: string) => {
    router.push(`/course/${courseId}`);
  };

  if (loading) {
    return (
      <SafeAreaView className="flex-1 bg-[#F8FAFC] items-center justify-center">
        <ActivityIndicator size="large" color="#2563EB" />
        <Text className="mt-4 text-[#64748B] text-sm font-medium">
          Loading category...
        </Text>
      </SafeAreaView>
    );
  }

  if (!category) {
    return (
      <SafeAreaView className="flex-1 bg-[#F8FAFC] items-center justify-center p-4">
        <Ionicons name="alert-circle-outline" size={60} color="#EF4444" />
        <Text className="text-[#0F172A] text-xl font-bold mt-4">
          Category Not Found
        </Text>
        <TouchableOpacity
          className="mt-6 bg-[#2563EB] px-8 py-3 rounded-xl"
          onPress={() => router.back()}
        >
          <Text className="text-white font-bold">Go Back</Text>
        </TouchableOpacity>
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
          {category.name}
        </Text>
        <Text className="text-[#64748B] text-sm">
          {category.courseCount} courses
        </Text>
      </View>

      <FlatList
        data={category.courses}
        renderItem={({ item }) => (
          <TouchableOpacity
            className="mx-4 mb-4 bg-white rounded-2xl border border-[#E2E8F0] overflow-hidden"
            onPress={() => handleCoursePress(item.id)}
            activeOpacity={0.8}
            style={{
              shadowColor: '#0F172A',
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: 0.05,
              shadowRadius: 4,
              elevation: 2,
            }}
          >
            <Image
              source={{ uri: item.thumbnail }}
              className="w-full h-40"
              resizeMode="cover"
            />
            <View className="p-3">
              <Text className="text-[#0F172A] font-semibold text-base" numberOfLines={1}>
                {item.title}
              </Text>
              <Text className="text-[#64748B] text-sm">
                {item.instructor}
              </Text>
              <View className="flex-row items-center mt-1">
                <Ionicons name="star" size={16} color="#FBBF24" />
                <Text className="text-[#0F172A] font-medium ml-1">
                  {item.rating.toFixed(1)}
                </Text>
                <Text className="text-[#94A3B8] text-sm ml-1">
                  ({item.students.toLocaleString()} students)
                </Text>
              </View>
            </View>
          </TouchableOpacity>
        )}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ 
          paddingTop: 16,
          paddingBottom: insets.bottom + 80,
        }}
        showsVerticalScrollIndicator={false}
        ListHeaderComponent={
          <View className="px-4 mb-4">
            <Image
              source={{ uri: category.image }}
              className="w-full h-48 rounded-2xl"
              resizeMode="cover"
            />
            <Text className="text-[#64748B] text-sm mt-2">
              {category.description}
            </Text>
          </View>
        }
        ListEmptyComponent={
          <View className="items-center py-12">
            <Ionicons name="book-outline" size={60} color="#94A3B8" />
            <Text className="text-[#64748B] text-center mt-4">
              No courses available in this category yet
            </Text>
          </View>
        }
      />
    </SafeAreaView>
  );
}