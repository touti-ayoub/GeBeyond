import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/reviews_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/entities/review.dart';

class WriteReviewScreen extends StatefulWidget {
  final int listingId;
  final String listingTitle;
  final int? bookingId;
  final Review? existingReview; // For editing

  const WriteReviewScreen({
    super.key,
    required this.listingId,
    required this.listingTitle,
    this.bookingId,
    this.existingReview,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _reviewsService = ReviewsService();
  final _authService = AuthService.instance;

  double _rating = 5.0;
  String? _selectedTripType;
  final List<String> _pros = [];
  final List<String> _cons = [];
  final TextEditingController _proController = TextEditingController();
  final TextEditingController _conController = TextEditingController();

  bool _isSubmitting = false;

  final List<Map<String, String>> _tripTypes = [
    {'value': 'solo', 'label': '✈️ Solo Traveler'},
    {'value': 'couple', 'label': '💑 Couple'},
    {'value': 'family', 'label': '👨‍👩‍👧‍👦 Family'},
    {'value': 'business', 'label': '💼 Business'},
    {'value': 'friends', 'label': '👥 Friends'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _loadExistingReview();
    }
  }

  void _loadExistingReview() {
    final review = widget.existingReview!;
    _rating = review.rating;
    _commentController.text = review.comment ?? '';
    _selectedTripType = review.tripType;
    _pros.addAll(review.pros);
    _cons.addAll(review.cons);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _proController.dispose();
    _conController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user is logged in
    if (_authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to submit a review'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final review = Review(
        id: widget.existingReview?.id,
        userId: _authService.currentUser!.id!,
        listingId: widget.listingId,
        bookingId: widget.bookingId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        pros: _pros,
        cons: _cons,
        tripType: _selectedTripType,
        createdAt: widget.existingReview?.createdAt ?? DateTime.now(),
        updatedAt: widget.existingReview != null ? DateTime.now() : null,
      );

      if (widget.existingReview != null) {
        await _reviewsService.updateReview(review);
      } else {
        await _reviewsService.addReview(review);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingReview != null
                  ? 'Review updated successfully!'
                  : 'Review submitted successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _addPro() {
    final text = _proController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _pros.add(text);
        _proController.clear();
      });
    }
  }

  void _addCon() {
    final text = _conController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _cons.add(text);
        _conController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingReview != null ? 'Edit Review' : 'Write a Review'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Listing title
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviewing',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.listingTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Rating
            Text(
              'Overall Rating',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = (index + 1).toDouble();
                        return GestureDetector(
                          onTap: () => setState(() => _rating = starValue),
                          child: Icon(
                            starValue <= _rating ? Icons.star : Icons.star_border,
                            size: 48,
                            color: Colors.amber,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getRatingLabel(_rating),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Trip Type
            Text(
              'Trip Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tripTypes.map((type) {
                final isSelected = _selectedTripType == type['value'];
                return FilterChip(
                  label: Text(type['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTripType = selected ? type['value'] : null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Written Review
            Text(
              'Your Experience',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Share your experience with other travelers...',
                helperText: 'Optional but helpful for others',
              ),
            ),

            const SizedBox(height: 24),

            // Pros
            Text(
              'What did you like? (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Great location',
                    ),
                    onSubmitted: (_) => _addPro(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: _addPro,
                ),
              ],
            ),
            if (_pros.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _pros.map((pro) {
                  return Chip(
                    label: Text(pro),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => setState(() => _pros.remove(pro)),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            // Cons
            Text(
              'What could be improved? (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _conController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Wi-Fi was slow',
                    ),
                    onSubmitted: (_) => _addCon(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.orange),
                  onPressed: _addCon,
                ),
              ],
            ),
            if (_cons.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _cons.map((con) {
                  return Chip(
                    label: Text(con),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => setState(() => _cons.remove(con)),
                    backgroundColor: Colors.orange.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.existingReview != null ? 'Update Review' : 'Submit Review',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 3.5) return 'Very Good';
    if (rating >= 2.5) return 'Good';
    if (rating >= 1.5) return 'Fair';
    return 'Poor';
  }
}

