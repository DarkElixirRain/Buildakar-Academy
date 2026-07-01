// components/instructor/CourseCard.tsx
import React from 'react';
import { View, Text, TouchableOpacity, Image, Dimensions } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Course } from '@/types/instructor';
import { StatusBadge } from './StatusBadge';
import { LevelBadge } from './StatusBadge';

const { width } = Dimensions.get('window');
const CARD_WIDTH = width * 0.9;
const CARD_HEIGHT = 180;

interface CourseCardProps {
  course: Course;
  onPress?: () => void;
  onEdit?: () => void;
  onDelete?: () => void;
  onDuplicate?: () => void;
  showActions?: boolean;
}

export const CourseCard: React.FC<CourseCardProps> = ({
  course,
  onPress,
  onEdit,
  onDelete,
  onDuplicate,
  showActions = true,
}) => {
  const formatNumber = (num: number) => {
    if (num >= 1000) {
      return (num / 1000).toFixed(1) + 'k';
    }
    return num.toString();
  };

  return (
    <TouchableOpacity
      onPress={onPress}
      activeOpacity={0.8}
      style={{
        width: CARD_WIDTH,
        height: CARD_HEIGHT,
        backgroundColor: '#FFFFFF',
        borderRadius: 16,
        marginRight: 16,
        shadowColor: '#0F172A',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 8,
        elevation: 4,
        overflow: 'hidden',
      }}
    >
      <View style={{ flex: 1, flexDirection: 'row' }}>
        {/* Thumbnail */}
        <View style={{ width: 140, height: '100%', position: 'relative' }}>
          {course.thumbnail ? (
            <Image
              source={{ uri: course.thumbnail }}
              style={{ width: '100%', height: '100%', borderTopLeftRadius: 16, borderBottomLeftRadius: 16 }}
              resizeMode="cover"
            />
          ) : (
            <View style={{ width: '100%', height: '100%', backgroundColor: '#F1F5F9', borderTopLeftRadius: 16, borderBottomLeftRadius: 16, justifyContent: 'center', alignItems: 'center' }}>
              <Ionicons name="book-outline" size={40} color="#94A3B8" />
            </View>
          )}
          
          {/* Status badge overlay */}
          <View style={{ position: 'absolute', top: 12, left: 12, zIndex: 10 }}>
            <StatusBadge status={course.status} size="sm" />
          </View>
          
          {/* Level badge */}
          <View style={{ position: 'absolute', bottom: 12, left: 12, zIndex: 10 }}>
            <LevelBadge level={course.level as any} size="sm" />
          </View>
        </View>

        {/* Content */}
        <View style={{ flex: 1, padding: 12, justifyContent: 'space-between' }}>
          <View>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
              <Text style={{ fontSize: 16, fontWeight: '700', color: '#0F172A', flex: 1, marginRight: 8 }}>
                {course.title}
              </Text>
              {showActions && (
                <TouchableOpacity
                  onPress={(event) => {
                    event.stopPropagation?.();
                    onEdit?.();
                  }}
                  style={{ padding: 4 }}
                  activeOpacity={0.7}
                >
                  <Ionicons name="ellipsis-horizontal" size={24} color="#64748B" />
                </TouchableOpacity>
              )}
            </View>

            {course.description && (
              <Text
                numberOfLines={2}
                style={{ fontSize: 13, color: '#64748B', lineHeight: 18, marginBottom: 8 }}
              >
                {course.description}
              </Text>
            )}

            <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginBottom: 8 }}>
              {course.category && (
                <View style={{ backgroundColor: '#EFF6FF', borderRadius: 12, paddingHorizontal: 8, paddingVertical: 2 }}>
                  <Text style={{ fontSize: 11, fontWeight: '600', color: '#2563EB' }}>
                    {course.category.name}
                  </Text>
                </View>
              )}
              <View style={{ backgroundColor: '#F1F5F9', borderRadius: 12, paddingHorizontal: 8, paddingVertical: 2 }}>
                <Text style={{ fontSize: 11, fontWeight: '600', color: '#475569' }}>
                  {course._count?.lessons || 0} lessons
                </Text>
              </View>
            </View>
          </View>

          {/* Stats and price */}
          <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', borderTopWidth: 1, borderTopColor: '#F1F5F9', paddingTop: 12 }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 16 }}>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
                <Ionicons name="people-outline" size={14} color="#94A3B8" />
                <Text style={{ fontSize: 12, color: '#64748B', fontWeight: '500' }}>
                  {formatNumber(course.studentsCount)}
                </Text>
              </View>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
                <Ionicons name="star-outline" size={14} color="#F59E0B" />
                <Text style={{ fontSize: 12, color: '#64748B', fontWeight: '500' }}>
                  {course.rating.toFixed(1)}
                </Text>
              </View>
            </View>

            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
              {course.originalPrice && course.originalPrice > course.price && (
                <Text style={{ fontSize: 12, color: '#94A3B8', textDecorationLine: 'line-through' }}>
                  ${course.originalPrice.toFixed(2)}
                </Text>
              )}
              <Text style={{ 
                fontSize: 16, 
                fontWeight: '700', 
                color: course.price === 0 ? '#10B981' : '#0F172A' 
              }}>
                {course.price === 0 ? 'Free' : `$${course.price.toFixed(2)}`}
              </Text>
            </View>
          </View>
        </View>
      </View>

      {/* Action menu (if needed) */}
      {showActions && (
        <View style={{ position: 'absolute', top: 12, right: 12, zIndex: 20 }}>
          <TouchableOpacity
            onPress={(event) => {
              event.stopPropagation?.();
              onEdit?.();
            }}
            style={{ backgroundColor: 'rgba(255,255,255,0.9)', borderRadius: 20, padding: 8 }}
            activeOpacity={0.7}
          >
            <Ionicons name="create-outline" size={20} color="#0F172A" />
          </TouchableOpacity>
        </View>
      )}
    </TouchableOpacity>
  );
};

export default CourseCard;