import 'package:flutter/material.dart';
import 'listing_detail_screen.dart';
import '../../../../core/services/wishlist_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final _wishlistService = WishlistService();

  final List<Map<String, dynamic>> _allListings = [
    {
      'id': 1,
      'title': 'Luxury Beach Resort',
      'type': 'hotel',
      'location': 'Maldives',
      'price': 450.0,
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
      'description': 'Stunning beachfront resort with private villas',
    },
    {
      'id': 2,
      'title': 'Mountain Retreat Lodge',
      'type': 'hotel',
      'location': 'Swiss Alps',
      'price': 320.0,
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      'description': 'Cozy mountain lodge with breathtaking views',
    },
    {
      'id': 3,
      'title': 'Paris Round Trip',
      'type': 'flight',
      'location': 'Paris, France',
      'price': 680.0,
      'rating': 4.6,
      'image': 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
      'description': 'Direct flight to the city of lights',
    },
    {
      'id': 4,
      'title': 'City Center Boutique Hotel',
      'type': 'hotel',
      'location': 'Barcelona, Spain',
      'price': 180.0,
      'rating': 4.7,
      'image': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
      'description': 'Modern hotel in the heart of Barcelona',
    },
    {
      'id': 5,
      'title': 'Tokyo to Kyoto Bullet Train',
      'type': 'flight',
      'location': 'Japan',
      'price': 120.0,
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=800',
      'description': 'High-speed rail experience through Japan',
    },
    {
      'id': 6,
      'title': 'Scuba Diving Adventure',
      'type': 'experience',
      'location': 'Great Barrier Reef',
      'price': 250.0,
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
      'description': 'Explore the underwater wonders',
    },
    {
      'id': 7,
      'title': 'Desert Safari Experience',
      'type': 'experience',
      'location': 'Dubai, UAE',
      'price': 150.0,
      'rating': 4.7,
      'image': 'https://images.unsplash.com/photo-1451337516015-6b6e9a44a8a3?w=800',
      'description': 'Thrilling desert adventure with dinner',
    },
    {
      'id': 8,
      'title': 'Northern Lights Tour',
      'type': 'experience',
      'location': 'Iceland',
      'price': 380.0,
      'rating': 5.0,
      'image': 'https://images.unsplash.com/photo-1483347756197-71ef80e95f73?w=800',
      'description': 'Witness the magical aurora borealis',
    },
    {
      'id': 9,
      'title': 'New York to London',
      'type': 'flight',
      'location': 'London, UK',
      'price': 890.0,
      'rating': 4.5,
      'image': 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
      'description': 'Transatlantic flight with premium service',
    },
    {
      'id': 10,
      'title': 'Tropical Island Villa',
      'type': 'hotel',
      'location': 'Bali, Indonesia',
      'price': 280.0,
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
      'description': 'Private villa with infinity pool',
    },
    {
      'id': 11,
      'title': 'Wine Tasting Experience',
      'type': 'experience',
      'location': 'Tuscany, Italy',
      'price': 95.0,
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=800',
      'description': 'Tour vineyards and taste premium wines',
    },
    {
      'id': 12,
      'title': 'Safari Lodge',
      'type': 'hotel',
      'location': 'Serengeti, Tanzania',
      'price': 520.0,
      'rating': 5.0,
      'image': 'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=800',
      'description': 'Luxury safari experience with wildlife',
    },
  ];

  List<Map<String, dynamic>> get _filteredListings {
    return _allListings.where((listing) {
      final matchesCategory = _selectedCategory == 'All' || 
          listing['type'] == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          listing['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          listing['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredListings = _filteredListings;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Search
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Explore',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search destinations, hotels, experiences...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
            ),
          ),

          // Category Filters
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('All', Icons.explore),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Hotel', Icons.hotel),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Flight', Icons.flight),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Experience', Icons.local_activity),
                ],
              ),
            ),
          ),

          // Results Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${filteredListings.length} ${filteredListings.length == 1 ? 'result' : 'results'} found',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),

          // Listings Grid
          filteredListings.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final listing = filteredListings[index];
                        return _buildListingCard(listing);
                      },
                      childCount: filteredListings.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _selectedCategory == label;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = label;
        });
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to listing detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListingDetailScreen(listing: listing),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    listing['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                  // Type Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(listing['type']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(listing['type']),
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            listing['type'].toString().toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Wishlist Button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _wishlistService.isInWishlist(listing['id'])
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        color: _wishlistService.isInWishlist(listing['id'])
                            ? Colors.red
                            : null,
                        iconSize: 20,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            if (_wishlistService.isInWishlist(listing['id'])) {
                              _wishlistService.removeFromWishlist(listing['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Removed from wishlist'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            } else {
                              _wishlistService.addToWishlist(listing);
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
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      listing['title'],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Location & Rating
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            listing['location'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          listing['rating'].toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Price
                    Row(
                      children: [
                        Text(
                          '\$${listing['price'].toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          listing['type'] == 'hotel' ? '/night' : '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'hotel':
        return Icons.hotel;
      case 'flight':
        return Icons.flight;
      case 'experience':
        return Icons.local_activity;
      default:
        return Icons.explore;
    }
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
