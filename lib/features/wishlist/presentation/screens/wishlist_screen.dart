import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../explore/presentation/screens/listing_detail_screen.dart';
import '../../../../core/services/wishlist_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _wishlistService = WishlistService();

  @override
  void initState() {
    super.initState();
    _wishlistService.addListener(_onWishlistChanged);
  }

  @override
  void dispose() {
    _wishlistService.removeListener(_onWishlistChanged);
    super.dispose();
  }

  void _onWishlistChanged() {
    setState(() {});
  }

  void _removeFromWishlist(int index) {
    final items = _wishlistService.wishlistItems;
    final item = items[index];
    _wishlistService.removeAtIndex(index);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['title']} removed from wishlist'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            _wishlistService.restoreAtIndex(index, item);
          },
        ),
      ),
    );
  }

  void _clearAllWishlist() {
    final items = _wishlistService.wishlistItems;
    if (items.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text(
          'Are you sure you want to remove all items from your wishlist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _wishlistService.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wishlist cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wishlistItems = _wishlistService.wishlistItems;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Wishlist',
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
            actions: wishlistItems.isNotEmpty
                ? [
                    IconButton(
                      icon: const Icon(Icons.delete_sweep),
                      tooltip: 'Clear all',
                      onPressed: _clearAllWishlist,
                    ),
                  ]
                : null,
          ),

          // Content
          wishlistItems.isEmpty
              ? _buildEmptyState()
              : SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Summary Bar
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${wishlistItems.length} ${wishlistItems.length == 1 ? 'item' : 'items'} saved',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    'Your dream destinations await',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '\$${_wishlistService.getTotalPrice().toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Filter Chips
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildFilterChip('All', wishlistItems.length),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Hotels',
                              wishlistItems
                                  .where((item) => item['type'] == 'hotel')
                                  .length,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Experiences',
                              wishlistItems
                                  .where((item) => item['type'] == 'experience')
                                  .length,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Flights',
                              wishlistItems
                                  .where((item) => item['type'] == 'flight')
                                  .length,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

          // Wishlist Grid
          if (wishlistItems.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = wishlistItems[index];
                    return _buildWishlistCard(item, index);
                  },
                  childCount: wishlistItems.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Wishlist is Empty',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Start adding your favorite destinations, hotels, and experiences to your wishlist',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  // Navigate to explore tab using GoRouter
                  context.go('/explore');
                },
                icon: const Icon(Icons.explore),
                label: const Text('Explore Now'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final theme = Theme.of(context);
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
    );
  }

  Widget _buildWishlistCard(Map<String, dynamic> item, int index) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListingDetailScreen(listing: item),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Remove Button
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item['image'] as String? ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
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
                  // Gradient overlay
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
                  // Type Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(item['type'] as String? ?? 'hotel'),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (item['type'] as String? ?? 'hotel').toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Remove Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 4,
                      child: InkWell(
                        onTap: () => _removeFromWishlist(index),
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Saved Date
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['savedDate'].toString().replaceAll('Added ', ''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
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
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      item['title'] as String? ?? 'Unknown',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Location & Rating
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['location'] as String? ?? 'Unknown',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Rating & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (item['rating'] ?? 0.0).toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\$${((item['price'] as num?) ?? 0).toStringAsFixed(0)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
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
