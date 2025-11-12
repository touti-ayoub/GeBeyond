import 'package:flutter/material.dart';
import '../../domain/entities/review.dart';

/// Widget to display review statistics
class ReviewStatsWidget extends StatelessWidget {
  final ReviewStats stats;
  final VoidCallback? onViewAllTap;

  const ReviewStatsWidget({
    super.key,
    required this.stats,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Guest Reviews',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onViewAllTap != null)
                  TextButton(
                    onPressed: onViewAllTap,
                    child: const Text('View All'),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Overall Rating
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      stats.averageRating.toStringAsFixed(1),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    _buildRatingStars(stats.averageRating),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.totalReviews} reviews',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                // Rating distribution
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final rating = 5 - index;
                      final percentage = stats.getRatingPercentage(rating);
                      final count = stats.ratingDistribution[rating] ?? 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              '$rating',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 30,
                              child: Text(
                                '$count',
                                style: theme.textTheme.bodySmall,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),

            // Trip type distribution (if available)
            if (stats.tripTypeDistribution.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Trip Types',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stats.tripTypeDistribution.entries.map((entry) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        '${entry.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    label: Text(_getTripTypeLabel(entry.key)),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return Icon(
          starValue <= rating
              ? Icons.star
              : starValue - 0.5 <= rating
                  ? Icons.star_half
                  : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  String _getTripTypeLabel(String tripType) {
    switch (tripType) {
      case 'solo':
        return '✈️ Solo Traveler';
      case 'family':
        return '👨‍👩‍👧‍👦 Family';
      case 'couple':
        return '💑 Couple';
      case 'business':
        return '💼 Business';
      case 'friends':
        return '👥 Friends';
      default:
        return tripType;
    }
  }
}

