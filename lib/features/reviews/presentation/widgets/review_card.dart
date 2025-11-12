import 'package:flutter/material.dart';
import '../../domain/entities/review.dart';

/// Widget to display a single review card
class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onHelpfulTap;
  final VoidCallback? onReportTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final bool isUserReview;

  const ReviewCard({
    super.key,
    required this.review,
    this.onHelpfulTap,
    this.onReportTap,
    this.onEditTap,
    this.onDeleteTap,
    this.isUserReview = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: User info and rating
            Row(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage: review.userPhoto != null
                      ? NetworkImage(review.userPhoto!)
                      : null,
                  child: review.userPhoto == null
                      ? Text(
                          review.userName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // User name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.userName ?? 'Anonymous',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (review.tripType != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getTripTypeLabel(review.tripType!),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        review.formattedDate,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Rating stars
                _buildRatingStars(context),
              ],
            ),

            const SizedBox(height: 12),

            // Review comment
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              Text(
                review.comment!,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
            ],

            // Pros and Cons
            if (review.pros.isNotEmpty || review.cons.isNotEmpty) ...[
              if (review.pros.isNotEmpty) ...[
                _buildProsOrCons(
                  context,
                  'Pros',
                  review.pros,
                  Colors.green,
                  Icons.add_circle_outline,
                ),
                const SizedBox(height: 8),
              ],
              if (review.cons.isNotEmpty) ...[
                _buildProsOrCons(
                  context,
                  'Cons',
                  review.cons,
                  Colors.orange,
                  Icons.remove_circle_outline,
                ),
                const SizedBox(height: 12),
              ],
            ],

            // Review images
            if (review.hasImages) ...[
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          review.images[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons
            Row(
              children: [
                // Helpful button
                TextButton.icon(
                  onPressed: onHelpfulTap,
                  icon: const Icon(Icons.thumb_up_outlined, size: 18),
                  label: Text('Helpful (${review.helpfulCount})'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ),
                const SizedBox(width: 8),

                // Edit/Delete for user's own review
                if (isUserReview) ...[
                  TextButton.icon(
                    onPressed: onEditTap,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onDeleteTap,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  ),
                ] else ...[
                  // Report button for other reviews
                  TextButton.icon(
                    onPressed: onReportTap,
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    label: const Text('Report'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < review.starRating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildProsOrCons(
    BuildContext context,
    String title,
    List<String> items,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  String _getTripTypeLabel(String tripType) {
    switch (tripType) {
      case 'solo':
        return '✈️ Solo';
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

