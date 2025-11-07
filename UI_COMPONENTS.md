# GoBeyond Travel - Reusable UI Components

## 🧩 Component Library Implementation

### 1. Custom App Bar

```dart
// lib/shared/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:gobeyond/app/themes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.showBackButton = true,
    this.onBackPressed,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.surface,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
```

### 2. Listing Card

```dart
// lib/shared/widgets/listing_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image.dart';
import 'package:gobeyond/features/explore/domain/entities/listing.dart';
import 'package:gobeyond/app/themes.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback? onWishlistToggle;
  final bool isWishlisted;
  final bool compact;
  
  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.onWishlistToggle,
    this.isWishlisted = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppElevation.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with wishlist button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.md),
                  ),
                  child: AspectRatio(
                    aspectRatio: compact ? 16 / 9 : 4 / 3,
                    child: CachedNetworkImage(
                      imageUrl: listing.photos.isNotEmpty
                          ? listing.photos.first
                          : 'https://via.placeholder.com/400x300',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
                
                // Wishlist button
                if (onWishlistToggle != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onWishlistToggle,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: AppElevation.sm,
                          ),
                          child: Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isWishlisted
                                ? AppColors.error
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Type badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      listing.type.value.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    listing.title,
                    style: AppTypography.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.location,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Rating and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            listing.rating.toStringAsFixed(1),
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      
                      // Price
                      Text(
                        listing.priceDisplay,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
}
```

### 3. Primary Button

```dart
// lib/shared/widgets/primary_button.dart
import 'package:flutter/material.dart';
import 'package:gobeyond/app/themes.dart';

enum ButtonSize { small, medium, large }
enum ButtonVariant { primary, secondary, outline, text }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;
  final ButtonVariant variant;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.large,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: _buildButton(context, isDisabled),
    );
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: textColor ?? Colors.white,
            disabledBackgroundColor: AppColors.textDisabled,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            elevation: 0,
          ),
          child: _buildContent(),
        );
      
      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.secondary,
            foregroundColor: textColor ?? Colors.white,
            disabledBackgroundColor: AppColors.textDisabled,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            elevation: 0,
          ),
          child: _buildContent(),
        );
      
      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primary,
            padding: _getPadding(),
            side: BorderSide(
              color: isDisabled
                  ? AppColors.textDisabled
                  : (backgroundColor ?? AppColors.primary),
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          child: _buildContent(),
        );
      
      case ButtonVariant.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primary,
            padding: _getPadding(),
          ),
          child: _buildContent(),
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return AppTypography.labelSmall;
      case ButtonSize.medium:
        return AppTypography.labelMedium;
      case ButtonSize.large:
        return AppTypography.labelLarge;
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: _getTextStyle().fontSize,
        width: _getTextStyle().fontSize,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getTextStyle().fontSize! * 1.2),
          const SizedBox(width: 8),
          Text(label, style: _getTextStyle()),
        ],
      );
    }

    return Text(label, style: _getTextStyle());
  }
}
```

### 4. Search Bar

```dart
// lib/shared/widgets/search_bar.dart
import 'package:flutter/material.dart';
import 'package:gobeyond/app/themes.dart';

class CustomSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final bool readOnly;
  final bool autofocus;
  final Widget? leading;
  final Widget? trailing;
  
  const CustomSearchBar({
    super.key,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.controller,
    this.readOnly = false,
    this.autofocus = false,
    this.leading,
    this.trailing,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppElevation.sm,
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          prefixIcon: widget.leading ??
              const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                )
              : widget.trailing,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}
```

### 5. Empty State Widget

```dart
// lib/shared/widgets/empty_state.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:gobeyond/app/themes.dart';
import 'package:gobeyond/shared/widgets/primary_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? animationAsset;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.animationAsset,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation or Icon
            if (animationAsset != null)
              Lottie.asset(
                animationAsset!,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              )
            else if (icon != null)
              Icon(
                icon,
                size: 80,
                color: AppColors.textDisabled,
              )
            else
              const Icon(
                Icons.inbox_outlined,
                size: 80,
                color: AppColors.textDisabled,
              ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Title
            Text(
              title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Message
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
                size: ButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 6. Loading State Widget

```dart
// lib/shared/widgets/loading_state.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gobeyond/app/themes.dart';

class LoadingState extends StatelessWidget {
  final LoadingType type;
  final int itemCount;
  
  const LoadingState({
    super.key,
    this.type = LoadingType.list,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LoadingType.list:
        return ListView.builder(
          itemCount: itemCount,
          padding: const EdgeInsets.all(AppSpacing.md),
          itemBuilder: (context, index) => const LoadingListItem(),
        );
      
      case LoadingType.grid:
        return GridView.builder(
          itemCount: itemCount,
          padding: const EdgeInsets.all(AppSpacing.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) => const LoadingGridItem(),
        );
      
      case LoadingType.detail:
        return const LoadingDetailView();
      
      case LoadingType.spinner:
        return const Center(
          child: CircularProgressIndicator(),
        );
    }
  }
}

enum LoadingType { list, grid, detail, spinner }

class LoadingListItem extends StatelessWidget {
  const LoadingListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardRadius,
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: AppColors.surfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 14,
                    color: AppColors.surfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 14,
                    color: AppColors.surfaceVariant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingGridItem extends StatelessWidget {
  const LoadingGridItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: AppColors.surfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    color: AppColors.surfaceVariant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingDetailView extends StatelessWidget {
  const LoadingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              color: AppColors.surfaceVariant,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 24,
                    color: AppColors.surfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 16,
                    color: AppColors.surfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        width: double.infinity,
                        height: 14,
                        color: AppColors.surfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 7. Error Widget

```dart
// lib/shared/widgets/error_widget.dart
import 'package:flutter/material.dart';
import 'package:gobeyond/app/themes.dart';
import 'package:gobeyond/shared/widgets/primary_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  
  const CustomErrorWidget({
    super.key,
    this.title = 'Oops!',
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Try Again',
                onPressed: onRetry,
                isFullWidth: false,
                size: ButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 8. Bottom Sheet

```dart
// lib/shared/widgets/custom_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:gobeyond/app/themes.dart';

class CustomBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.sheetRadius,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              if (enableDrag)
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.sm),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textDisabled,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              
              // Title
              if (title != null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    title,
                    style: AppTypography.titleLarge,
                  ),
                ),
              
              // Content
              child,
            ],
          ),
        ),
      ),
    );
  }
}
```

### 9. Rating Stars

```dart
// lib/shared/widgets/rating_stars.dart
import 'package:flutter/material.dart';
import 'package:gobeyond/app/themes.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? color;
  final bool showValue;
  
  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.color,
    this.showValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          if (index < rating.floor()) {
            return Icon(
              Icons.star,
              size: size,
              color: color ?? AppColors.warning,
            );
          } else if (index < rating) {
            return Icon(
              Icons.star_half,
              size: size,
              color: color ?? AppColors.warning,
            );
          } else {
            return Icon(
              Icons.star_border,
              size: size,
              color: color ?? AppColors.textDisabled,
            );
          }
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
```

### 10. Status Badge

```dart
// lib/shared/widgets/status_badge.dart
import 'package:flutter/material.dart';
import 'package:gobeyond/app/themes.dart';

enum BadgeType { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  
  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.icon,
  });

  Color get _backgroundColor {
    switch (type) {
      case BadgeType.success:
        return AppColors.success.withOpacity(0.1);
      case BadgeType.warning:
        return AppColors.warning.withOpacity(0.1);
      case BadgeType.error:
        return AppColors.error.withOpacity(0.1);
      case BadgeType.info:
        return AppColors.info.withOpacity(0.1);
      case BadgeType.neutral:
        return AppColors.surfaceVariant;
    }
  }

  Color get _textColor {
    switch (type) {
      case BadgeType.success:
        return AppColors.success;
      case BadgeType.warning:
        return AppColors.warning;
      case BadgeType.error:
        return AppColors.error;
      case BadgeType.info:
        return AppColors.info;
      case BadgeType.neutral:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: _textColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: _textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📚 Usage Examples

### Listing Card Usage

```dart
ListingCard(
  listing: listing,
  isWishlisted: isWishlisted,
  onTap: () => context.go('/explore/listing/${listing.id}'),
  onWishlistToggle: () async {
    await ref.read(wishlistNotifierProvider.notifier)
        .toggleWishlist(listing.id!);
    ref.invalidate(wishlistProvider);
  },
)
```

### Primary Button Usage

```dart
PrimaryButton(
  label: 'Book Now',
  icon: Icons.arrow_forward,
  onPressed: () => _handleBooking(),
  isLoading: isBooking,
  variant: ButtonVariant.primary,
  size: ButtonSize.large,
)
```

### Empty State Usage

```dart
EmptyState(
  title: 'No bookings yet',
  message: 'Start exploring and book your first adventure!',
  animationAsset: 'assets/animations/empty_bookings.json',
  actionLabel: 'Explore Destinations',
  onAction: () => context.go('/explore'),
)
```

### Bottom Sheet Usage

```dart
CustomBottomSheet.show(
  context: context,
  title: 'Filter Results',
  child: FilterOptionsWidget(),
)
```

---

These reusable components provide a consistent UI/UX throughout the app and can be easily customized with the design system parameters.
