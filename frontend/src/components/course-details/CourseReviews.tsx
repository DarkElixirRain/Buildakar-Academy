// components/course-details/CourseReviews.tsx
import React from 'react';
import { View, Text, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import type { RatingBreakdown, Review } from '../../data/courseData';

interface StarRowProps {
  rating: number;
  size?: number;
}

const StarRow: React.FC<StarRowProps> = ({ rating, size = 14 }) => (
  <View className="flex-row">
    {[1, 2, 3, 4, 5].map((star) => (
      <Ionicons
        key={star}
        name={star <= Math.round(rating) ? 'star' : 'star-outline'}
        size={size}
        color="#F59E0B"
      />
    ))}
  </View>
);

interface CourseReviewsProps {
  rating: number;
  reviewsCount: number;
  breakdown: RatingBreakdown;
  reviews: Review[];
}

export const CourseReviews: React.FC<CourseReviewsProps> = ({
  rating,
  reviewsCount,
  breakdown,
  reviews,
}) => {
  const breakdownRows: Array<keyof RatingBreakdown> = [5, 4, 3, 2, 1];

  return (
    <View className="px-4 py-4">
      <View className="flex-row items-center mb-5">
        <View className="items-center mr-6">
          <Text className="text-[#0F172A] text-3xl font-bold">{rating.toFixed(1)}</Text>
          <StarRow rating={rating} />
          <Text className="text-[#64748B] text-xs mt-1">
            {reviewsCount.toLocaleString()} reviews
          </Text>
        </View>

        <View className="flex-1">
          {breakdownRows.map((star) => (
            <View key={star} className="flex-row items-center mb-1.5">
              <Text className="text-[#64748B] text-xs w-7">{star}★</Text>
              <View className="flex-1 h-1.5 bg-[#F1F5F9] rounded-full overflow-hidden mx-2">
                <View
                  className="h-full bg-[#F59E0B] rounded-full"
                  style={{ width: `${breakdown[star]}%` }}
                />
              </View>
              <Text className="text-[#64748B] text-xs w-9 text-right">{breakdown[star]}%</Text>
            </View>
          ))}
        </View>
      </View>

      {reviews.map((review) => (
        <View key={review.id} className="mb-4 pb-4 border-b border-[#E2E8F0]">
          <View className="flex-row items-center mb-2">
            <Image source={{ uri: review.avatar }} className="w-9 h-9 rounded-full mr-2.5" />
            <View className="flex-1">
              <Text className="text-[#0F172A] text-sm font-semibold">{review.name}</Text>
              <View className="flex-row items-center mt-0.5">
                <StarRow rating={review.rating} size={11} />
                <Text className="text-[#94A3B8] text-xs ml-2">{review.date}</Text>
              </View>
            </View>
          </View>
          <Text className="text-[#475569] text-sm leading-5">{review.comment}</Text>
        </View>
      ))}
    </View>
  );
};