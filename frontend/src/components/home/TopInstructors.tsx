// components/home/TopInstructors.tsx
import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface Instructor {
  id: string;
  name: string;
  expertise: string;
  photo: string;
  rating: number;
  isFollowing?: boolean;
}

interface TopInstructorsProps {
  instructors: Instructor[];
  onFollowPress: (instructorId: string) => void;
  onInstructorPress: (instructorId: string) => void;
  onSeeAll: () => void;
}

export const TopInstructors: React.FC<TopInstructorsProps> = ({
  instructors,
  onFollowPress,
  onInstructorPress,
  onSeeAll,
}) => {
  const [following, setFollowing] = React.useState<Set<string>>(new Set());

  const handleFollow = (id: string) => {
    setFollowing(prev => {
      const newSet = new Set(prev);
      if (newSet.has(id)) {
        newSet.delete(id);
      } else {
        newSet.add(id);
      }
      return newSet;
    });
    onFollowPress(id);
  };

  return (
    <View className="w-full">
      <View className="flex-row justify-between items-center mb-3">
        <Text className="text-[#0F172A] text-xl font-bold">
          Top Instructors
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
        {instructors.map((instructor) => {
          const isFollowing = following.has(instructor.id);

          return (
            <TouchableOpacity
              key={instructor.id}
              className="w-48 mr-4 bg-white rounded-2xl border border-[#E2E8F0] p-4 items-center"
              onPress={() => onInstructorPress(instructor.id)}
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
                source={{ uri: instructor.photo }}
                className="w-16 h-16 rounded-full mb-2"
              />
              
              <Text className="text-[#0F172A] font-bold text-sm text-center">
                {instructor.name}
              </Text>
              <Text className="text-[#64748B] text-xs text-center mb-1">
                {instructor.expertise}
              </Text>

              <View className="flex-row items-center mb-3">
                <Ionicons name="star" size={14} color="#FBBF24" />
                <Text className="text-[#0F172A] text-xs font-medium ml-0.5">
                  {instructor.rating.toFixed(1)}
                </Text>
              </View>

              <TouchableOpacity 
                className={`py-1.5 px-4 rounded-full border ${
                  isFollowing 
                    ? 'bg-transparent border-[#2563EB]' 
                    : 'bg-[#2563EB] border-[#2563EB]'
                }`}
                onPress={() => handleFollow(instructor.id)}
              >
                <Text className={`text-xs font-bold ${
                  isFollowing ? 'text-[#2563EB]' : 'text-white'
                }`}>
                  {isFollowing ? 'Following' : 'Follow'}
                </Text>
              </TouchableOpacity>
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </View>
  );
};