import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/wishlist_service.dart';
import '../../../../core/services/reviews_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/location_helper.dart';
import '../../../../core/config/google_maps_config.dart';
import '../../../booking/presentation/screens/booking_flow_screen.dart';
import '../../../reviews/domain/entities/review.dart';
import '../../../reviews/presentation/screens/reviews_list_screen.dart';
import '../../../reviews/presentation/screens/write_review_screen.dart';
import '../../../reviews/presentation/widgets/review_card.dart';
import '../../../common/presentation/widgets/map_tiler_widget.dart';

class ListingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> listing;

  const ListingDetailScreen({
    super.key,
    required this.listing,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _wishlistService = WishlistService();
  final _reviewsService = ReviewsService();
  final _authService = AuthService.instance;
  int _selectedImageIndex = 0;

  List<Review> _reviews = [];
  ReviewStats? _reviewStats;
  bool _isLoadingReviews = true;

  // Old hardcoded reviews removed - now using real data from database

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final listingId = widget.listing['id'] as int;
      final reviews = await _reviewsService.getReviewsByListing(listingId);
      final stats = await _reviewsService.getReviewStats(listingId);

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _reviewStats = stats;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
      print('Error loading reviews: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> get _images {
    final baseImage = widget.listing['image'] as String;
    // Generate multiple related images for gallery
    return [
      baseImage,
      baseImage.replaceAll('?w=800', '?w=800&auto=format&fit=crop&q=80'),
      baseImage.replaceAll('photo-', 'photo-1506905925346-21bda4d32df4?w=800&auto='),
      baseImage.replaceAll('photo-', 'photo-1571896349842-33c89424de2d?w=800&auto='),
    ];
  }

  List<Map<String, dynamic>> get _amenities {
    final type = widget.listing['type'];
    if (type == 'hotel') {
      return [
        {'icon': Icons.wifi, 'name': 'Free WiFi'},
        {'icon': Icons.pool, 'name': 'Swimming Pool'},
        {'icon': Icons.restaurant, 'name': 'Restaurant'},
        {'icon': Icons.fitness_center, 'name': 'Gym'},
        {'icon': Icons.local_parking, 'name': 'Free Parking'},
        {'icon': Icons.spa, 'name': 'Spa'},
        {'icon': Icons.room_service, 'name': 'Room Service'},
        {'icon': Icons.ac_unit, 'name': 'Air Conditioning'},
      ];
    } else if (type == 'flight') {
      return [
        {'icon': Icons.airline_seat_recline_extra, 'name': 'Extra Legroom'},
        {'icon': Icons.wifi, 'name': 'In-Flight WiFi'},
        {'icon': Icons.restaurant_menu, 'name': 'Meals Included'},
        {'icon': Icons.tv, 'name': 'Entertainment'},
        {'icon': Icons.luggage, 'name': '2 Bags Allowed'},
        {'icon': Icons.power, 'name': 'Power Outlets'},
      ];
    } else {
      return [
        {'icon': Icons.groups, 'name': 'Group Friendly'},
        {'icon': Icons.camera_alt, 'name': 'Photo Ops'},
        {'icon': Icons.emoji_food_beverage, 'name': 'Food Included'},
        {'icon': Icons.verified_user, 'name': 'Safety Gear'},
        {'icon': Icons.translate, 'name': 'Multi-language'},
        {'icon': Icons.accessible, 'name': 'Accessible'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = _images;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Gallery App Bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _wishlistService.isInWishlist(widget.listing['id'])
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                color: _wishlistService.isInWishlist(widget.listing['id'])
                    ? Colors.red
                    : Colors.white,
                onPressed: () {
                  setState(() {
                    if (_wishlistService.isInWishlist(widget.listing['id'])) {
                      _wishlistService.removeFromWishlist(widget.listing['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Removed from wishlist'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } else {
                      _wishlistService.addToWishlist(widget.listing);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to wishlist!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Main Image
                  Image.network(
                    images[_selectedImageIndex],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported, size: 64),
                      );
                    },
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  // Image Counter
                  Positioned(
                    bottom: 70,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selectedImageIndex + 1}/${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image Thumbnails
          SliverToBoxAdapter(
            child: Container(
              height: 80,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedImageIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedImageIndex = index),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Title and Rating
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(widget.listing['type']),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.listing['type'].toString().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.listing['rating'].toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' (${_reviews.length} reviews)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.listing['title'],
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.listing['location'],
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.listing['description'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor:
                    theme.colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(text: 'Amenities'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Location'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAmenitiesTab(),
                _buildReviewsTab(),
                _buildLocationTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAmenitiesTab() {
    final theme = Theme.of(context);
    final amenities = _amenities;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'What this place offers',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          itemCount: amenities.length,
          itemBuilder: (context, index) {
            final amenity = amenities[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    amenity['icon'],
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      amenity['name'],
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'House Rules',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          icon: Icons.schedule,
          title: 'Check-in',
          subtitle: 'After 3:00 PM',
        ),
        _buildInfoTile(
          icon: Icons.schedule,
          title: 'Check-out',
          subtitle: 'Before 11:00 AM',
        ),
        _buildInfoTile(
          icon: Icons.no_photography,
          title: 'Cancellation',
          subtitle: 'Free cancellation before 48 hours',
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    final theme = Theme.of(context);

    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rating Overview
        if (_reviewStats != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      _reviewStats!.averageRating.toStringAsFixed(1),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < _reviewStats!.averageRating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                    Text(
                      '${_reviewStats!.totalReviews} reviews',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar('5 stars', _reviewStats!.getRatingPercentage(5) / 100),
                      _buildRatingBar('4 stars', _reviewStats!.getRatingPercentage(4) / 100),
                      _buildRatingBar('3 stars', _reviewStats!.getRatingPercentage(3) / 100),
                      _buildRatingBar('2 stars', _reviewStats!.getRatingPercentage(2) / 100),
                      _buildRatingBar('1 star', _reviewStats!.getRatingPercentage(1) / 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WriteReviewScreen(
                        listingId: widget.listing['id'],
                        listingTitle: widget.listing['title'],
                      ),
                    ),
                  );
                  if (result == true) {
                    _loadReviews(); // Reload reviews after writing
                  }
                },
                icon: const Icon(Icons.rate_review),
                label: const Text('Write Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewsListScreen(
                        listingId: widget.listing['id'],
                        listingTitle: widget.listing['title'],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('View All'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Reviews List
        if (_reviews.isEmpty) ...[
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
          ),
        ] else ...[
          Text(
            'Recent Reviews',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Show first 3 reviews
          ...(_reviews.take(3).map((review) {
            final currentUserId = _authService.currentUser?.id;
            final isUserReview = currentUserId != null && review.userId == currentUserId;

            return ReviewCard(
                review: review,
                isUserReview: isUserReview,
                onHelpfulTap: () async {
                  await _reviewsService.markHelpful(review.id!, true);
                  _loadReviews();
                },
                onEditTap: isUserReview
                    ? () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WriteReviewScreen(
                              listingId: widget.listing['id'],
                              listingTitle: widget.listing['title'],
                              existingReview: review,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadReviews();
                        }
                      }
                    : null,
                onDeleteTap: isUserReview
                    ? () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Review'),
                            content: const Text(
                                'Are you sure you want to delete this review?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && review.id != null) {
                          await _reviewsService.deleteReview(
                              review.id!, widget.listing['id']);
                          _loadReviews();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Review deleted')),
                            );
                          }
                        }
                      }
                    : null,
              );
          })),
        ],
      ],
    );
  }

  Widget _buildLocationTab() {
    final theme = Theme.of(context);
    final location = widget.listing['location'] as String;
    final coordinates = LocationHelper.getCoordinates(location);
    final nearbyPlaces = LocationHelper.getNearbyPlaces(location);

    if (!MapTilerConfig.enableMaps || coordinates == null) {
      // Fallback UI if maps disabled or no coordinates
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Location',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure MapTiler API Key',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Map Container using MapTiler
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: MapTilerWidget(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude,
            zoom: MapTilerConfig.detailZoom,
            showMarker: true,
          ),
        ),

        const SizedBox(height: 24),

        // Location Address
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Nearby Places
        Text(
          'Nearby Places',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ...nearbyPlaces.map((place) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    place['icon'],
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    place['name'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  place['distance'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        )).toList(),

        const SizedBox(height: 16),

        // Get Directions Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Open in Google Maps app
              // In a real app, you would use url_launcher to open maps
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening in Google Maps...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, double value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNearbyPlace(String name, String distance, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: theme.textTheme.bodyMedium),
          ),
          Text(
            distance,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '\$${widget.listing['price'].toStringAsFixed(0)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (widget.listing['type'] == 'hotel')
                      Text(
                        '/night',
                        style: theme.textTheme.bodyMedium,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookingFlowScreen(
                        listing: widget.listing,
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'hotel':
        return Colors.blue;
      case 'flight':
        return Colors.orange;
      case 'experience':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
