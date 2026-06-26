// components/home/LearningPaths.tsx
import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface LearningPath {
  id: string;
  title: string;
  description: string;
  courses: number;
  duration: string;
  image: string;
}

interface LearningPathsProps {
  paths: LearningPath[];
  onPathPress: (pathId: string) => void;
  onSeeAll: () => void;
}

export const LearningPaths: React.FC<LearningPathsProps> = ({
  paths,
  onPathPress,
  onSeeAll,
}) => {
  return (
    <View className="w-full">
      <View className="flex-row justify-between items-center mb-3">
        <Text className="text-[#0F172A] text-xl font-bold">
          Learning Paths
        </Text>
        <TouchableOpacity onPress={onSeeAll}>
          <Text className="text-[#2563EB] text-sm font-semibold">
            See All
          </Text>
        </TouchableOpacity>
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
      >
        {paths.map((path) => (
          <TouchableOpacity
            key={path.id}
            className="w-64 mr-4 bg-white rounded-2xl border border-[#E2E8F0] overflow-hidden"
            onPress={() => onPathPress(path.id)}
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
              source={{ uri: path.image }}
              className="w-full h-28"
              resizeMode="cover"
            />

            <View className="p-4">
              <Text className="text-[#0F172A] font-bold text-base mb-1">
                {path.title}
              </Text>
              <Text className="text-[#64748B] text-sm mb-3" numberOfLines={2}>
                {path.description}
              </Text>

              <View className="flex-row items-center justify-between mb-3">
                <View className="flex-row items-center">
                  <Ionicons name="book-outline" size={16} color="#64748B" />
                  <Text className="text-[#64748B] text-xs ml-1">
                    {path.courses} courses
                  </Text>
                </View>
                <View className="flex-row items-center">
                  <Ionicons name="time-outline" size={16} color="#64748B" />
                  <Text className="text-[#64748B] text-xs ml-1">
                    {path.duration}
                  </Text>
                </View>
              </View>

              <TouchableOpacity 
                className="bg-[#2563EB] py-2.5 rounded-xl"
                onPress={() => onPathPress(path.id)}
              >
                <Text className="text-white text-center text-sm font-bold">
                  Start Path →
                </Text>
              </TouchableOpacity>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
};