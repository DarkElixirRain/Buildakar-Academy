// components/home/TopInstructors.tsx
import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';

export interface Instructor {
  id: string;
  name: string;
  expertise: string;
  photo: string;
  rating: number;
  studentsCount?: number;
  coursesCount?: number;
  bio?: string;
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
  const { isDarkMode, colors } = useTheme();

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
    <View style={{ width: '100%' }}>
      <View className="flex-row justify-between items-center mb-3">
        <Text style={{
          fontSize: 20,
          fontWeight: 'bold',
          color: colors.text,
        }}>
          Top Instructors
        </Text>
        <TouchableOpacity onPress={onSeeAll} activeOpacity={0.7}>
          <Text style={{
            fontSize: 14,
            fontWeight: '600',
            color: colors.primary,
          }}>
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
              style={{
                width: 192,
                marginRight: 16,
                borderRadius: 16,
                borderWidth: 1,
                padding: 16,
                alignItems: 'center',
                backgroundColor: colors.backgroundElement,
                borderColor: colors.backgroundSelected,
                shadowColor: isDarkMode ? '#000000' : '#0F172A',
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: isDarkMode ? 0.3 : 0.05,
                shadowRadius: 4,
                elevation: 2,
              }}
              onPress={() => onInstructorPress(instructor.id)}
              activeOpacity={0.8}
            >
              <Image 
                source={{ uri: instructor.photo }}
                className="w-16 h-16 rounded-full mb-2"
              />
              
              <Text style={{
                fontWeight: 'bold',
                fontSize: 14,
                textAlign: 'center',
                color: colors.text,
              }}>
                {instructor.name}
              </Text>
              <Text style={{
                fontSize: 12,
                textAlign: 'center',
                marginBottom: 4,
                color: colors.textSecondary,
              }}>
                {instructor.expertise}
              </Text>

              <View className="flex-row items-center mb-3">
                <Ionicons name="star" size={14} color="#FBBF24" />
                <Text style={{
                  fontSize: 12,
                  fontWeight: '500',
                  marginLeft: 2,
                  color: colors.text,
                }}>
                  {instructor.rating.toFixed(1)}
                </Text>
                {instructor.studentsCount && (
                  <Text style={{
                    fontSize: 12,
                    marginLeft: 4,
                    color: colors.textSecondary,
                  }}>
                    • {instructor.studentsCount.toLocaleString()} students
                  </Text>
                )}
              </View>

              <TouchableOpacity 
                style={{
                  paddingVertical: 6,
                  paddingHorizontal: 16,
                  borderRadius: 20,
                  borderWidth: 1,
                  backgroundColor: isFollowing ? 'transparent' : colors.primary,
                  borderColor: isFollowing ? colors.primary : colors.primary,
                }}
                onPress={() => handleFollow(instructor.id)}
              >
                <Text style={{
                  fontSize: 12,
                  fontWeight: 'bold',
                  color: isFollowing ? colors.primary : '#FFFFFF',
                }}>
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