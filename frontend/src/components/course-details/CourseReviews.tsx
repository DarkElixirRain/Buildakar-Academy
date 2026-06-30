// components/course-details/CourseReviews.tsx
import React from 'react';
import { View, Text, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';

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

interface Review {
  id: string;
  name: string;
  avatar: string;
  rating: number;
  comment: string;
  date: string;
  likes?: number;
}

interface RatingBreakdown {
  1: number;
  2: number;
  3: number;
  4: number;
  5: number;
}

interface CourseReviewsProps {
  rating: number;
  reviewsCount: number;
  breakdown?: RatingBreakdown; // ✅ Made optional
  reviews?: Review[]; // ✅ Made optional
  onLoadMore?: () => void;
}

export const CourseReviews: React.FC<CourseReviewsProps> = ({
  rating,
  reviewsCount,
  breakdown,
  reviews = [],
  onLoadMore,
}) => {
  const { isDarkMode, colors } = useTheme();

  // If no reviews, show empty state
  if (reviewsCount === 0 || reviews.length === 0) {
    return (
      <View className="px-4 py-8 items-center justify-center">
        <Ionicons name="chatbubbles-outline" size={48} color={colors.textSecondary} />
        <Text style={{ color: colors.textSecondary, fontSize: 16, marginTop: 12 }}>
          No reviews yet
        </Text>
        <Text style={{ color: colors.textSecondary, fontSize: 14, marginTop: 4, textAlign: 'center' }}>
          Be the first to review this course!
        </Text>
      </View>
    );
  }

  const breakdownRows: Array<keyof RatingBreakdown> = [5, 4, 3, 2, 1];

  return (
    <View className="px-4 py-4">
      {/* Rating Summary */}
      <View className="flex-row items-center mb-5">
        <View className="items-center mr-6">
          <Text style={{ color: colors.text, fontSize: 32, fontWeight: 'bold' }}>
            {rating.toFixed(1)}
          </Text>
          <StarRow rating={rating} />
          <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 2 }}>
            {reviewsCount.toLocaleString()} reviews
          </Text>
        </View>

        {/* Rating Breakdown - Only show if breakdown exists */}
        {breakdown && (
          <View className="flex-1">
            {breakdownRows.map((star) => (
              <View key={star} className="flex-row items-center mb-1.5">
                <Text style={{ color: colors.textSecondary, fontSize: 11, width: 24 }}>
                  {star}★
                </Text>
                <View
                  className="flex-1 h-1.5 rounded-full overflow-hidden mx-2"
                  style={{ backgroundColor: colors.backgroundSelected }}
                >
                  <View
                    className="h-full rounded-full"
                    style={{
                      width: `${breakdown[star] || 0}%`,
                      backgroundColor: '#F59E0B',
                    }}
                  />
                </View>
                <Text style={{ color: colors.textSecondary, fontSize: 11, width: 32, textAlign: 'right' }}>
                  {breakdown[star] || 0}%
                </Text>
              </View>
            ))}
          </View>
        )}
      </View>

      {/* Reviews List */}
      {reviews.map((review) => (
        <View
          key={review.id}
          className="mb-4 pb-4"
          style={{ borderBottomWidth: 1, borderBottomColor: colors.backgroundSelected }}
        >
          <View className="flex-row items-center mb-2">
            <Image
              source={{ uri: review.avatar || 'https://ui-avatars.com/api/?name=User&size=150&background=4F46E5&color=fff' }}
              className="w-9 h-9 rounded-full mr-2.5"
            />
            <View className="flex-1">
              <Text style={{ color: colors.text, fontSize: 14, fontWeight: '600' }}>
                {review.name || 'Anonymous'}
              </Text>
              <View className="flex-row items-center mt-0.5">
                <StarRow rating={review.rating || 0} size={11} />
                <Text style={{ color: colors.textSecondary, fontSize: 11, marginLeft: 8 }}>
                  {review.date || 'Recently'}
                </Text>
              </View>
            </View>
          </View>
          <Text style={{ color: colors.textSecondary, fontSize: 14, lineHeight: 20 }}>
            {review.comment || 'No comment provided.'}
          </Text>
        </View>
      ))}

      {/* Load More */}
      {onLoadMore && (
        <View className="items-center mt-2">
          <Text
            onPress={onLoadMore}
            style={{ color: colors.primary, fontSize: 14, fontWeight: '600' }}
          >
            Load More Reviews
          </Text>
        </View>
      )}
    </View>
  );
};