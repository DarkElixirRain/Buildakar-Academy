// lib/widgets/course/course_reviews.dart
import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../constants/colors.dart';

class CourseReviews extends StatelessWidget {
  final double rating;
  final List<Review> reviews;
  final Brightness brightness;

  const CourseReviews({
    super.key,
    required this.rating,
    required this.reviews,
    required this.brightness,
  });

  // Helper getters using AppColors
  Color get _textColor => AppColors.getTextColor(brightness);
  Color get _backgroundColor => AppColors.getBackgroundColor(brightness);
  Color get _backgroundElementColor =>
      AppColors.getBackgroundElementColor(brightness);
  Color get _textSecondaryColor =>
      AppColors.getTextSecondaryColor(brightness);
  Color get _primaryColor => AppColors.getPrimaryColor(brightness);
  Color get _primaryLightColor => AppColors.getPrimaryLightColor(brightness);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;
    final bodySize = isSmallScreen ? 12.0 : 14.0;
    final smallBodySize = isSmallScreen ? 10.0 : 12.0;
    final headingSize = isSmallScreen ? 14.0 : 16.0;

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Summary
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: _backgroundElementColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Big rating number
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 28 : 36,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: isSmallScreen ? 14 : 18,
                            color: AppColors.getWarningColor(brightness),
                          );
                        }),
                      ),
                      Text(
                        '${reviews.length} reviews',
                        style: TextStyle(
                          fontSize: smallBodySize,
                          color: _textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Rating distribution
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar(5, _getRatingCount(5), reviews.length),
                      _buildRatingBar(4, _getRatingCount(4), reviews.length),
                      _buildRatingBar(3, _getRatingCount(3), reviews.length),
                      _buildRatingBar(2, _getRatingCount(2), reviews.length),
                      _buildRatingBar(1, _getRatingCount(1), reviews.length),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Reviews List
          Text(
            'Reviews',
            style: TextStyle(
              fontSize: headingSize,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _backgroundElementColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No reviews yet',
                  style: TextStyle(
                    color: _textSecondaryColor,
                    fontSize: bodySize,
                  ),
                ),
              ),
            )
          else
            ...reviews.map((review) => _buildReviewCard(review, isSmallScreen)),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, int count, int total) {
    if (total == 0) return const SizedBox.shrink();
    final percentage = count / total;
    final barWidth = 100 * percentage;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$star',
            style: TextStyle(
              fontSize: 12,
              color: _textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
                          Icon(Icons.star, size: 12, color: AppColors.getWarningColor(brightness)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                widthFactor: barWidth / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              color: _textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  int _getRatingCount(int star) {
    return reviews.where((r) => r.rating.round() == star).length;
  }

  Widget _buildReviewCard(Review review, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: _backgroundElementColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _textSecondaryColor.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isSmallScreen ? 16 : 20,
                backgroundImage: NetworkImage(review.userAvatar),
                backgroundColor: _backgroundElementColor,
                child: review.userAvatar.isEmpty
                    ? Icon(Icons.person, color: _textSecondaryColor)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: AppColors.getWarningColor(brightness),
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: _textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // FIXED: Changed from review.date to review.createdAt
              Text(
                formatRelativeDate(review.createdAt),
                style: TextStyle(
                  color: _textSecondaryColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              color: _textSecondaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to format relative date
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return 'Today';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  }
}