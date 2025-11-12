import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/reviews_service.dart';
import '../../domain/entities/review.dart';
import '../widgets/review_card.dart';
import '../widgets/review_stats_widget.dart';
import 'write_review_screen.dart';

class ReviewsListScreen extends StatefulWidget {
  final int listingId;
  final String listingTitle;

  const ReviewsListScreen({
    super.key,
    required this.listingId,
    required this.listingTitle,
  });

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  final _reviewsService = ReviewsService();
  List<Review> _reviews = [];
  ReviewStats? _stats;
  bool _isLoading = true;
  String _sortBy = 'newest'; // newest, highest, lowest, helpful

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);

    try {
      final reviews = await _reviewsService.getReviewsByListing(widget.listingId);
      final stats = await _reviewsService.getReviewStats(widget.listingId);

      setState(() {
        _reviews = reviews;
        _stats = stats;
        _isLoading = false;
      });

      _sortReviews();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reviews: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sortReviews() {
    setState(() {
      switch (_sortBy) {
        case 'newest':
          _reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'oldest':
          _reviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case 'highest':
          _reviews.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'lowest':
          _reviews.sort((a, b) => a.rating.compareTo(b.rating));
          break;
        case 'helpful':
          _reviews.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
          break;
      }
    });
  }

  Future<void> _markHelpful(Review review) async {
    try {
      await _reviewsService.markHelpful(review.id!, true);
      _loadReviews();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteReview(Review review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && review.id != null) {
      try {
        await _reviewsService.deleteReview(review.id!, widget.listingId);
        _loadReviews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting review: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editReview(Review review) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => WriteReviewScreen(
          listingId: widget.listingId,
          listingTitle: widget.listingTitle,
          existingReview: review,
        ),
      ),
    );

    if (result == true) {
      _loadReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _sortBy,
            onSelected: (value) {
              setState(() => _sortBy = value);
              _sortReviews();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Text('Oldest First'),
              ),
              const PopupMenuItem(
                value: 'highest',
                child: Text('Highest Rating'),
              ),
              const PopupMenuItem(
                value: 'lowest',
                child: Text('Lowest Rating'),
              ),
              const PopupMenuItem(
                value: 'helpful',
                child: Text('Most Helpful'),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReviews,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats widget
                  if (_stats != null)
                    ReviewStatsWidget(
                      stats: _stats!,
                    ),

                  const SizedBox(height: 24),

                  // Reviews header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Reviews (${_reviews.length})',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Reviews list
                  if (_reviews.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No reviews yet',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to share your experience!',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._reviews.map((review) {
                      // TODO: Check if this is the current user's review
                      final isUserReview = review.userId == 1;

                      return ReviewCard(
                        review: review,
                        isUserReview: isUserReview,
                        onHelpfulTap: () => _markHelpful(review),
                        onEditTap: isUserReview ? () => _editReview(review) : null,
                        onDeleteTap: isUserReview ? () => _deleteReview(review) : null,
                        onReportTap: !isUserReview
                            ? () {
                                // TODO: Implement report functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Report functionality coming soon'),
                                  ),
                                );
                              }
                            : null,
                      );
                    }).toList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => WriteReviewScreen(
                listingId: widget.listingId,
                listingTitle: widget.listingTitle,
              ),
            ),
          );

          if (result == true) {
            _loadReviews();
          }
        },
        icon: const Icon(Icons.rate_review),
        label: const Text('Write Review'),
      ),
    );
  }
}

