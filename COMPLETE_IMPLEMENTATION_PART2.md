# 🚀 GoBeyond Travel - Complete Implementation (Part 2)

> **Listing Details, Booking Flow, Wishlist & Itinerary Screens**

---

## 4. Listing Details & Booking Flow

### 4.1 Listing Detail Screen

```dart
// lib/features/explore/presentation/screens/listing_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/providers/listing_providers.dart';
import '../../../wishlist/domain/providers/wishlist_providers.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../../core/widgets/rating_stars.dart';

class ListingDetailScreen extends ConsumerWidget {
  final int listingId;

  const ListingDetailScreen({
    Key? key,
    required this.listingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));

    return Scaffold(
      body: listingAsync.when(
        data: (listing) => _buildContent(context, ref, listing),
        loading: () => const LoadingState(type: LoadingType.detail),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(listingDetailProvider(listingId)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Listing listing) {
    final isInWishlist = ref.watch(isInWishlistProvider(listingId));

    return CustomScrollView(
      slivers: [
        // Image Gallery App Bar
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageGallery(listing.images),
          ),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isInWishlist.value ?? false
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                ref.read(wishlistNotifierProvider.notifier).toggle(listingId);
              },
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share, color: Colors.white),
              ),
              onPressed: () {
                // Share functionality
              },
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Category
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        listing.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Chip(
                      label: Text(listing.category),
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        listing.location,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Rating & Reviews
                Row(
                  children: [
                    RatingStars(rating: listing.rating, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      listing.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${listing.reviewCount} reviews)',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  listing.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Amenities
                if (listing.amenities.isNotEmpty) ...[
                  Text(
                    'Amenities',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: listing.amenities.map((amenity) {
                      return Chip(
                        avatar: Icon(
                          _getAmenityIcon(amenity),
                          size: 18,
                        ),
                        label: Text(amenity),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Availability
                Text(
                  'Availability',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: listing.isAvailable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        listing.isAvailable
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: listing.isAvailable ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        listing.isAvailable
                            ? 'Available'
                            : 'Currently Unavailable',
                        style: TextStyle(
                          color: listing.isAvailable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Reviews Section
                _buildReviewsSection(context, listing),
                
                const SizedBox(height: 80), // Space for bottom bar
              ],
            ),
          ),
        ),
      ],
      // Bottom booking bar
      bottomNavigationBar: _buildBookingBar(context, listing),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    if (images.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image, size: 64, color: Colors.grey),
        ),
      );
    }

    return PageView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: images[index],
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          ),
        );
      },
    );
  }

  Widget _buildReviewsSection(BuildContext context, Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all reviews
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Show top 3 reviews
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3, // Show first 3 reviews
          separatorBuilder: (_, __) => const Divider(height: 32),
          itemBuilder: (context, index) {
            return _buildReviewItem(context);
          },
        ),
      ],
    );
  }

  Widget _buildReviewItem(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'John Doe',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '2 days ago',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const RatingStars(rating: 4.5, size: 16),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Great place! Had an amazing experience. Highly recommended for anyone visiting the area.',
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildBookingBar(BuildContext context, Listing listing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${listing.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    'per night',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: listing.isAvailable
                    ? () => context.push('/explore/listing/$listingId/book')
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    final amenityLower = amenity.toLowerCase();
    if (amenityLower.contains('wifi')) return Icons.wifi;
    if (amenityLower.contains('pool')) return Icons.pool;
    if (amenityLower.contains('parking')) return Icons.local_parking;
    if (amenityLower.contains('restaurant')) return Icons.restaurant;
    if (amenityLower.contains('gym')) return Icons.fitness_center;
    if (amenityLower.contains('spa')) return Icons.spa;
    return Icons.check_circle;
  }
}
```

### 4.2 Booking Flow Screen (Multi-Step)

```dart
// lib/features/booking/presentation/screens/booking_flow_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/providers/booking_providers.dart';
import '../../../explore/domain/providers/listing_providers.dart';
import '../../../../core/widgets/loading_state.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  final int listingId;

  const BookingFlowScreen({
    Key? key,
    required this.listingId,
  }) : super(key: key);

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  int _currentStep = 0;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestCount = 1;
  String _paymentMethod = 'credit_card';

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Booking'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: listingAsync.when(
        data: (listing) => Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(),

            // Step Content
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildStep1DateSelection(),
                  _buildStep2ReviewDetails(listing),
                  _buildStep3Payment(),
                ],
              ),
            ),

            // Navigation Buttons
            _buildNavigationButtons(listing),
          ],
        ),
        loading: () => const LoadingState(type: LoadingType.detail),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Dates'),
          Expanded(child: _buildStepLine(0)),
          _buildStepIndicator(1, 'Review'),
          Expanded(child: _buildStepLine(1)),
          _buildStepIndicator(2, 'Payment'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = step <= _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = step < _currentStep;
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isActive
          ? Theme.of(context).colorScheme.primary
          : Colors.grey[300],
    );
  }

  // STEP 1: Date Selection
  Widget _buildStep1DateSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Dates',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // Calendar
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _checkInDate ?? DateTime.now(),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(_checkInDate, day) || isSameDay(_checkOutDate, day);
            },
            rangeStartDay: _checkInDate,
            rangeEndDay: _checkOutDate,
            rangeSelectionMode: RangeSelectionMode.enforced,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                if (_checkInDate == null || (_checkInDate != null && _checkOutDate != null)) {
                  _checkInDate = selectedDay;
                  _checkOutDate = null;
                } else if (_checkInDate != null && _checkOutDate == null) {
                  if (selectedDay.isAfter(_checkInDate!)) {
                    _checkOutDate = selectedDay;
                  } else {
                    _checkInDate = selectedDay;
                  }
                }
              });
            },
          ),
          const SizedBox(height: 24),

          // Date Summary
          if (_checkInDate != null || _checkOutDate != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Check-in', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          _checkInDate != null
                              ? _formatDate(_checkInDate!)
                              : 'Select date',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Check-out', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          _checkOutDate != null
                              ? _formatDate(_checkOutDate!)
                              : 'Select date',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Guest Count
          Text(
            'Number of Guests',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: _guestCount > 1
                    ? () => setState(() => _guestCount--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Expanded(
                child: Text(
                  '$_guestCount ${_guestCount == 1 ? 'Guest' : 'Guests'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _guestCount++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 2: Review Details
  Widget _buildStep2ReviewDetails(Listing listing) {
    final nights = _checkOutDate != null && _checkInDate != null
        ? _checkOutDate!.difference(_checkInDate!).inDays
        : 0;
    final subtotal = listing.price * nights;
    final serviceFee = subtotal * 0.10;
    final total = subtotal + serviceFee;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Booking',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // Listing Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 40),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          listing.location,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          listing.category,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Booking Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Check-in', _formatDate(_checkInDate!)),
                  const Divider(),
                  _buildDetailRow('Check-out', _formatDate(_checkOutDate!)),
                  const Divider(),
                  _buildDetailRow('Guests', '$_guestCount'),
                  const Divider(),
                  _buildDetailRow('Nights', '$nights'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Price Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildPriceRow(
                    '\$${listing.price.toStringAsFixed(2)} × $nights nights',
                    '\$${subtotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    'Service fee (10%)',
                    '\$${serviceFee.toStringAsFixed(2)}',
                  ),
                  const Divider(height: 24),
                  _buildPriceRow(
                    'Total',
                    '\$${total.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: Payment
  Widget _buildStep3Payment() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // Payment Methods
          RadioListTile<String>(
            title: const Row(
              children: [
                Icon(Icons.credit_card),
                SizedBox(width: 8),
                Text('Credit/Debit Card'),
              ],
            ),
            value: 'credit_card',
            groupValue: _paymentMethod,
            onChanged: (value) => setState(() => _paymentMethod = value!),
          ),
          RadioListTile<String>(
            title: const Row(
              children: [
                Icon(Icons.account_balance),
                SizedBox(width: 8),
                Text('Bank Transfer'),
              ],
            ),
            value: 'bank_transfer',
            groupValue: _paymentMethod,
            onChanged: (value) => setState(() => _paymentMethod = value!),
          ),
          RadioListTile<String>(
            title: const Row(
              children: [
                Icon(Icons.payments),
                SizedBox(width: 8),
                Text('Digital Wallet'),
              ],
            ),
            value: 'wallet',
            groupValue: _paymentMethod,
            onChanged: (value) => setState(() => _paymentMethod = value!),
          ),
          const SizedBox(height: 24),

          // Payment Form (Placeholder)
          if (_paymentMethod == 'credit_card') ...[
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Card Number',
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Cardholder Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Terms
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'By completing this booking, you agree to our Terms & Conditions and Privacy Policy.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(Listing listing) {
    final isLastStep = _currentStep == 2;
    final canProceed = _canProceedToNextStep();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
            if (_currentStep > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: canProceed ? () => _handleNext(listing) : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(isLastStep ? 'Confirm Booking' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _checkInDate != null && _checkOutDate != null && _guestCount > 0;
      case 1:
        return true;
      case 2:
        return _paymentMethod.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _handleNext(Listing listing) async {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Create booking
      await _createBooking(listing);
    }
  }

  Future<void> _createBooking(Listing listing) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final bookingNotifier = ref.read(bookingNotifierProvider.notifier);
    final result = await bookingNotifier.createBooking(
      listingId: widget.listingId,
      checkInDate: _checkInDate!,
      checkOutDate: _checkOutDate!,
      guestCount: _guestCount,
      paymentMethod: _paymentMethod,
    );

    if (!mounted) return;

    Navigator.pop(context); // Close loading

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
          ),
        );
      },
      (booking) {
        context.go('/booking-confirmation/${booking.id}');
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 20 : 14,
            color: isTotal ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
```

### 4.3 Booking Confirmation Screen

```dart
// lib/features/booking/presentation/screens/booking_confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../domain/providers/booking_providers.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final int bookingId;

  const BookingConfirmationScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      body: SafeArea(
        child: bookingAsync.when(
          data: (booking) => _buildSuccessContent(context, booking),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, Booking booking) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          // Success Animation
          Lottie.asset(
            'assets/animations/success.json',
            width: 200,
            height: 200,
            repeat: false,
          ),
          const SizedBox(height: 32),

          // Success Message
          Text(
            'Booking Confirmed!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your booking has been confirmed. A confirmation email has been sent to your email address.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // Booking ID
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Booking Reference',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'BK${booking.id.toString().padLeft(6, '0')}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Action Buttons
          ElevatedButton(
            onPressed: () => context.go('/trips'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('View My Trips'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/explore'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Back to Home'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
```

---

## 5. Wishlist & Itinerary Screens

### 5.1 Wishlist Screen

```dart
// lib/features/wishlist/presentation/screens/wishlist_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/providers/wishlist_providers.dart';
import '../../../../core/widgets/listing_card.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/empty_state.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        actions: [
          if (wishlistState.hasValue && wishlistState.value!.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Wishlist'),
                    content: const Text('Are you sure you want to clear your entire wishlist?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(wishlistNotifierProvider.notifier).clearAll();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: wishlistState.when(
        data: (wishlistItems) {
          if (wishlistItems.isEmpty) {
            return const EmptyState(
              message: 'Your wishlist is empty',
              subtitle: 'Add places you love to save them for later',
              icon: Icons.favorite_border,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(wishlistNotifierProvider.future);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final wishlistItem = wishlistItems[index];
                return ListingCard(
                  listing: wishlistItem.listing,
                  onTap: () => context.push('/explore/listing/${wishlistItem.listingId}'),
                  showFavoriteButton: true,
                  onFavoriteToggle: () {
                    ref.read(wishlistNotifierProvider.notifier).remove(wishlistItem.listingId);
                  },
                );
              },
            ),
          );
        },
        loading: () => const LoadingState(type: LoadingType.grid),
        error: (error, stack) => EmptyState(
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
```

### 5.2 My Trips Screen

```dart
// lib/features/booking/presentation/screens/my_trips_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/providers/booking_providers.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';

class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsState = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
      ),
      body: bookingsState.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const EmptyState(
              message: 'No trips yet',
              subtitle: 'Start exploring and book your first adventure',
              icon: Icons.luggage_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(myBookingsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _TripCard(
                  booking: booking,
                  onTap: () => context.push('/trips/${booking.id}'),
                );
              },
            ),
          );
        },
        loading: () => const LoadingState(type: LoadingType.list),
        error: (error, stack) => EmptyState(
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _TripCard({
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 150,
              color: Colors.grey[300],
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.image, size: 64, color: Colors.grey),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: StatusBadge(status: booking.status),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.listingName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDate(booking.checkInDate)} - ${_formatDate(booking.checkOutDate)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${booking.guestCount} ${booking.guestCount == 1 ? 'Guest' : 'Guests'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: \$${booking.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
```

---

**[This is Part 2 of 4 - Continuing...]**

This part covers:
- ✅ Complete Listing Detail Screen with reviews
- ✅ Multi-step Booking Flow (Dates, Review, Payment)
- ✅ Booking Confirmation with success animation
- ✅ Wishlist management screen
- ✅ My Trips screen with booking cards

Next parts:
- Part 3: Itinerary, Rewards, Profile screens + Business Logic Integration
- Part 4: Optimization, Testing, Deployment

