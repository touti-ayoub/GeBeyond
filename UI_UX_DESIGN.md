# GoBeyond Travel - UI/UX Design & Navigation System

## 🎨 Design Philosophy

### Core Principles
- **Simplicity First**: Clean, uncluttered interfaces
- **Offline Indication**: Clear visual feedback for sync status
- **Travel-Focused**: Inspiring imagery and smooth animations
- **Accessible**: WCAG 2.1 AA compliance
- **Consistent**: Design system applied throughout

### Visual Identity
**Theme**: Modern, airy, travel-inspired  
**Mood**: Exciting yet trustworthy  
**Target**: Millennial & Gen-Z travelers

---

## 🎨 Design System

### Color Palette

```dart
class AppColors {
  // Primary Colors
  static const primary = Color(0xFF2196F3);      // Trust Blue
  static const primaryLight = Color(0xFF64B5F6);
  static const primaryDark = Color(0xFF1976D2);
  
  // Secondary Colors
  static const secondary = Color(0xFFFF9800);    // Adventure Orange
  static const secondaryLight = Color(0xFFFFB74D);
  static const secondaryDark = Color(0xFFF57C00);
  
  // Accent
  static const accent = Color(0xFF00BCD4);       // Sky Cyan
  static const accentLight = Color(0xFF4DD0E1);
  
  // Semantic Colors
  static const success = Color(0xFF4CAF50);      // Green
  static const warning = Color(0xFFFFC107);      // Amber
  static const error = Color(0xFFF44336);        // Red
  static const info = Color(0xFF2196F3);         // Blue
  
  // Neutrals
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F5F5);
  
  // Text Colors
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textDisabled = Color(0xFFBDBDBD);
  static const textHint = Color(0xFF9E9E9E);
  
  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const heroGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

### Typography

```dart
class AppTypography {
  // Font Family
  static const String fontFamily = 'Poppins';
  
  // Display Styles (Large headings)
  static const displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
  );
  
  static const displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
  );
  
  static const displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.22,
  );
  
  // Headline Styles
  static const headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );
  
  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );
  
  static const headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );
  
  // Title Styles
  static const titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );
  
  static const titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  // Body Styles
  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  // Label Styles (Buttons, chips)
  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  static const labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );
  
  static const labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
  );
}
```

### Spacing System

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  // Padding presets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  
  // Horizontal padding
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  
  // Vertical padding
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
}
```

### Border Radius

```dart
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
  
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));
  
  // Card specific
  static const BorderRadius cardRadius = radiusMD;
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}
```

### Elevation & Shadows

```dart
class AppElevation {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];
  
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];
  
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];
  
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x29000000), // 16% black
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];
}
```

---

## 🗺️ Navigation Architecture

### Navigation Strategy: **GoRouter with Shell Routes**

**Why GoRouter?**
- ✅ Declarative routing (type-safe)
- ✅ Deep linking support
- ✅ Nested navigation with shell routes
- ✅ Auth guards built-in
- ✅ Browser history support (web)
- ✅ Excellent developer experience

### Navigation Flow Diagram

```
                    App Start
                        │
                        ▼
                  ┌─────────────┐
                  │   Splash    │
                  │   Screen    │
                  └──────┬──────┘
                         │
                    Check Auth
                         │
          ┌──────────────┴──────────────┐
          │ Authenticated               │ Not Authenticated
          ▼                             ▼
    ┌──────────┐                  ┌──────────┐
    │  Main    │                  │Onboarding│
    │  Shell   │◄─────────────────│  Flow    │
    └──────────┘   After Login    └──────────┘
          │                             │
          │                             ├─► Welcome
          │                             ├─► Features
          │                             └─► Login/Register
          │
    ┌─────┴──────┬─────────┬──────────┬─────────┐
    │            │         │          │         │
    ▼            ▼         ▼          ▼         ▼
┌────────┐  ┌────────┐ ┌─────┐  ┌────────┐ ┌────────┐
│Explore │  │Wishlist│ │Trips│  │Itinerary│ │Profile│
│        │  │        │ │     │  │        │ │       │
└────┬───┘  └───┬────┘ └──┬──┘  └───┬────┘ └───┬───┘
     │          │         │         │          │
     │          │         │         │          │
     ├─Search   │         │         │          ├─Settings
     ├─Filter   │         │         │          ├─Edit Profile
     │          │         │         │          ├─Rewards
     │          │         │         │          └─Logout
     ▼          ▼         ▼         ▼
┌─────────┐ ┌──────┐ ┌──────┐ ┌──────────┐
│Listing  │ │Remove│ │Booking│ │Itinerary │
│ Detail  │ │      │ │Detail │ │  Detail  │
└────┬────┘ └──────┘ └───┬───┘ └──────────┘
     │                   │
     │                   ├─Cancel
     │                   ├─Modify
     ▼                   └─Review
┌─────────┐
│ Booking │
│  Flow   │
└────┬────┘
     │
     ├─Date Selection
     ├─Guest Count
     ├─Payment (Placeholder)
     │
     ▼
┌──────────┐
│Confirmation│
│   Screen  │
└──────────┘
```

### Route Structure

```dart
// lib/app/router.dart
final router = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  
  // Redirect logic for auth
  redirect: (context, state) {
    final authState = ref.read(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final isOnAuthRoute = state.matchedLocation.startsWith('/auth');
    
    // Redirect to login if not authenticated
    if (!isAuthenticated && !isOnAuthRoute && state.matchedLocation != '/splash') {
      return '/auth/onboarding';
    }
    
    // Redirect to home if authenticated and on auth route
    if (isAuthenticated && isOnAuthRoute) {
      return '/explore';
    }
    
    return null;
  },
  
  routes: [
    // Splash Route
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    
    // Auth Routes
    GoRoute(
      path: '/auth',
      name: 'auth',
      redirect: (context, state) => '/auth/onboarding',
      routes: [
        GoRoute(
          path: 'onboarding',
          name: 'onboarding',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const OnboardingScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: 'login',
          name: 'login',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const LoginScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: 'register',
          name: 'register',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const RegisterScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),
      ],
    ),
    
    // Main App Shell with Bottom Navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch 1: Explore
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              name: 'explore',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ExploreScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'search',
                  name: 'search',
                  builder: (context, state) => const SearchScreen(),
                ),
                GoRoute(
                  path: 'listing/:id',
                  name: 'listing-detail',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return ListingDetailScreen(listingId: id);
                  },
                  routes: [
                    GoRoute(
                      path: 'book',
                      name: 'book-listing',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        return BookingFlowScreen(listingId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        
        // Branch 2: Wishlist
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/wishlist',
              name: 'wishlist',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: WishlistScreen(),
              ),
            ),
          ],
        ),
        
        // Branch 3: Trips/Bookings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/trips',
              name: 'trips',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TripsScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'booking/:id',
                  name: 'booking-detail',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return BookingDetailScreen(bookingId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        
        // Branch 4: Itinerary
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/itinerary',
              name: 'itinerary',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ItineraryListScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'create-itinerary',
                  builder: (context, state) => const CreateItineraryScreen(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'itinerary-detail',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return ItineraryDetailScreen(itineraryId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        
        // Branch 5: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'edit-profile',
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  name: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'rewards',
                  name: 'rewards',
                  builder: (context, state) => const RewardsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
  
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
);

// Custom transition builders
Widget _fadeTransition(context, animation, secondaryAnimation, child) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(context, animation, secondaryAnimation, child) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  const curve = Curves.easeInOut;
  
  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  final offsetAnimation = animation.drive(tween);
  
  return SlideTransition(position: offsetAnimation, child: child);
}
```

---

## 📱 Screen Wireframes & Component Breakdown

### 1. Splash Screen

**Purpose**: App initialization, check auth, load initial data

```
┌────────────────────────────────┐
│                                │
│                                │
│         [App Logo]             │
│                                │
│      GoBeyond Travel           │
│                                │
│    [Loading Animation]         │
│                                │
│                                │
│                                │
│    Your adventure awaits...    │
│                                │
└────────────────────────────────┘
```

**Components**:
- Animated logo (scale + fade in)
- Tagline with fade-in
- Loading indicator
- Background gradient animation

**State Integration**:
```dart
- DatabaseHelper initialization
- Auth state check (authProvider)
- Initial data sync check
```

---

### 2. Onboarding Flow (3 Screens)

**Screen 1: Welcome**
```
┌────────────────────────────────┐
│                                │
│    [Hero Illustration]         │
│     Explore the World          │
│                                │
│  Discover amazing destinations │
│  and experiences worldwide     │
│                                │
│                                │
│          ● ○ ○                 │
│                                │
│         [Next Button]          │
│         [Skip]                 │
└────────────────────────────────┘
```

**Screen 2: Features**
```
┌────────────────────────────────┐
│                                │
│    [Feature Illustration]      │
│     Book with Ease             │
│                                │
│  Save favorites, plan trips,   │
│  and earn rewards              │
│                                │
│                                │
│          ○ ● ○                 │
│                                │
│         [Next Button]          │
│         [Skip]                 │
└────────────────────────────────┘
```

**Screen 3: Offline**
```
┌────────────────────────────────┐
│                                │
│    [Offline Illustration]      │
│    Works Offline               │
│                                │
│  Access your bookings and      │
│  itineraries anytime           │
│                                │
│                                │
│          ○ ○ ●                 │
│                                │
│      [Get Started Button]      │
│                                │
└────────────────────────────────┘
```

**Components**:
- Lottie animations for illustrations
- Page indicator dots
- Swipeable PageView
- Skip button (top-right)
- Primary action button

---

### 3. Login Screen

```
┌────────────────────────────────┐
│     [<] Back                   │
│                                │
│    Welcome Back! 👋            │
│    Sign in to continue         │
│                                │
│  ┌──────────────────────────┐ │
│  │ 📧 Email                  │ │
│  └──────────────────────────┘ │
│                                │
│  ┌──────────────────────────┐ │
│  │ 🔒 Password              │ │
│  └──────────────────────────┘ │
│                                │
│         [Forgot Password?]     │
│                                │
│  ┌──────────────────────────┐ │
│  │      Sign In             │ │
│  └──────────────────────────┘ │
│                                │
│         ─── OR ───             │
│                                │
│  [🔵 Continue with Google]    │
│  [📱 Continue with Apple]     │
│                                │
│  Don't have an account?        │
│        [Sign Up]               │
└────────────────────────────────┘
```

**Components**:
- App bar with back button
- Email text field (with validation)
- Password text field (with visibility toggle)
- Forgot password link
- Primary button (Sign In)
- Social auth buttons
- Sign up navigation link

**State Integration**:
```dart
- Form validation (email, password)
- Loading state during auth
- Error handling (authProvider)
- Navigation on success
```

---

### 4. Home/Explore Screen

```
┌────────────────────────────────┐
│  GoBeyond   [🔔] [👤]          │
├────────────────────────────────┤
│                                │
│  ┌──────────────────────────┐ │
│  │ 🔍 Search destinations... │ │
│  └──────────────────────────┘ │
│                                │
│  [Hotels] [Flights] [Things]  │
│                                │
│  ┌────────────────────────┐   │
│  │  Featured Destinations │   │
│  │  ──────────────────── │   │
│  │  [Carousel of cards]   │   │
│  └────────────────────────┘   │
│                                │
│  Popular Near You              │
│  ┌──────┐ ┌──────┐ ┌──────┐  │
│  │ Card │ │ Card │ │ Card │  │
│  │      │ │      │ │      │  │
│  └──────┘ └──────┘ └──────┘  │
│                                │
│  Best Deals                    │
│  ┌──────────────────────────┐ │
│  │  Card with Image         │ │
│  │  Title                   │ │
│  │  ⭐ 4.8 · From $99       │ │
│  └──────────────────────────┘ │
│                                │
├────────────────────────────────┤
│ [🏠] [❤️] [🎫] [📅] [👤]     │
└────────────────────────────────┘
```

**Components**:
- Custom app bar with logo, notifications, profile avatar
- Search bar (navigates to search screen)
- Category chips (horizontal scroll)
- Featured carousel (auto-scroll)
- Section headers
- Listing cards (grid/list)
- Bottom navigation bar

**State Integration**:
```dart
- Featured listings (listingProvider)
- Popular listings (filtered by location)
- Best deals (sorted by price/rating)
- User location (geolocator)
- Wishlist status for each card
```

---

### 5. Search Screen

```
┌────────────────────────────────┐
│  [<] ┌────────────────────┐ [×]│
│      │ Where to?          │    │
│      └────────────────────┘    │
├────────────────────────────────┤
│                                │
│  Recent Searches               │
│  · Paris, France          [×]  │
│  · Tokyo, Japan           [×]  │
│  · New York, USA          [×]  │
│                                │
│  ──────────────────────────    │
│                                │
│  Popular Destinations          │
│  ┌────┐  ┌────┐  ┌────┐       │
│  │ 🗼 │  │ 🗽 │  │ 🗻 │       │
│  │Paris│  │NYC │  │Tokyo│      │
│  └────┘  └────┘  └────┘       │
│                                │
│  ┌────┐  ┌────┐  ┌────┐       │
│  │ 🏖️ │  │ 🏰 │  │ 🌉 │       │
│  │Bali │  │Rome│  │SF  │       │
│  └────┘  └────┘  └────┘       │
│                                │
└────────────────────────────────┘
```

**With Search Results**:
```
┌────────────────────────────────┐
│  [<] ┌────────────────────┐ [×]│
│      │ Paris              │    │
│      └────────────────────┘    │
│  [Filters]  [Sort: Popular]    │
├────────────────────────────────┤
│  124 results                   │
│                                │
│  ┌──────────────────────────┐ │
│  │ [Image]        ❤️         │ │
│  │ Luxury Hotel Paris       │ │
│  │ ⭐ 4.9 (312 reviews)     │ │
│  │ From $180/night          │ │
│  └──────────────────────────┘ │
│                                │
│  ┌──────────────────────────┐ │
│  │ [Image]        ❤️         │ │
│  │ Boutique Stay            │ │
│  │ ⭐ 4.7 (189 reviews)     │ │
│  │ From $120/night          │ │
│  └──────────────────────────┘ │
│                                │
│  [Load More...]                │
└────────────────────────────────┘
```

**Components**:
- Search text field (auto-focus on open)
- Clear button
- Recent searches (stored locally)
- Popular destination chips
- Filter button (opens bottom sheet)
- Sort dropdown
- Result count
- Listing cards with wishlist toggle
- Infinite scroll/pagination

**State Integration**:
```dart
- Search query debouncing (500ms)
- Filter state (price, rating, type)
- Sort state (popular, price, rating)
- Listing results (searchListingsProvider)
- Wishlist toggle (wishlistProvider)
```

---

### 6. Listing Detail Screen

```
┌────────────────────────────────┐
│ [<]              [🔗] [❤️]    │
│                                │
│ [Image Gallery - Swipeable]   │
│ ●○○○○                          │
│                                │
├────────────────────────────────┤
│  Luxury Hotel Paris            │
│  ⭐ 4.9 (312 reviews)          │
│  📍 Champs-Élysées, Paris      │
│                                │
│  ──────────────────────────    │
│                                │
│  💰 From $180 / night          │
│                                │
│  ──────────────────────────    │
│                                │
│  About                         │
│  Experience luxury in the      │
│  heart of Paris with stunning  │
│  views of the Eiffel Tower...  │
│  [Read more]                   │
│                                │
│  ──────────────────────────    │
│                                │
│  ✨ Amenities                  │
│  [🏊 Pool] [🍽️ Restaurant]    │
│  [🅿️ Parking] [📶 WiFi]       │
│  [+ 12 more]                   │
│                                │
│  ──────────────────────────    │
│                                │
│  📊 Reviews (312)              │
│  ⭐⭐⭐⭐⭐ 5.0               │
│  ⭐⭐⭐⭐   4.0               │
│  [See all reviews]             │
│                                │
│  ──────────────────────────    │
│                                │
│  📍 Location                   │
│  [Map preview]                 │
│  [View on map]                 │
│                                │
│                                │
├────────────────────────────────┤
│ From $180    [Book Now] ❯      │
└────────────────────────────────┘
```

**Components**:
- Custom app bar (transparent over image)
- Image carousel with indicators
- Share button
- Wishlist toggle button
- Title, rating, location
- Price display
- Expandable description
- Amenities chips (horizontal scroll)
- Review summary with bars
- Map preview (static or interactive)
- Sticky bottom bar with booking CTA

**State Integration**:
```dart
- Listing details (listingByIdProvider)
- Wishlist status (wishlistProvider)
- Reviews (feedbackProvider)
- Image gallery state
- Booking availability (dates)
```

---

### 7. Booking Flow Screen

**Step 1: Dates & Guests**
```
┌────────────────────────────────┐
│ [<] Book Stay          Step 1/3│
├────────────────────────────────┤
│                                │
│  Select Dates                  │
│  ┌──────────────────────────┐ │
│  │  [Calendar Widget]       │ │
│  │  Mar 2025                │ │
│  │  S M T W T F S           │ │
│  │    1 2 3 4 5 6 7        │ │
│  │  8 9 10 11 12 13 14     │ │
│  │  15 16 17 18 19 20 21   │ │
│  │  22 23 24 25 26 27 28   │ │
│  │  29 30 31               │ │
│  └──────────────────────────┘ │
│                                │
│  Check-in:  Mar 15, 2025       │
│  Check-out: Mar 18, 2025       │
│  Duration:  3 nights           │
│                                │
│  ──────────────────────────    │
│                                │
│  Guests                        │
│  ┌──────────────────────────┐ │
│  │ Adults    [-] 2 [+]      │ │
│  │ Children  [-] 0 [+]      │ │
│  └──────────────────────────┘ │
│                                │
│                                │
├────────────────────────────────┤
│  Total: $540     [Next] ❯      │
└────────────────────────────────┘
```

**Step 2: Review Details**
```
┌────────────────────────────────┐
│ [<] Review Booking     Step 2/3│
├────────────────────────────────┤
│                                │
│  [Listing Image]               │
│  Luxury Hotel Paris            │
│  ⭐ 4.9 · 📍 Paris            │
│                                │
│  ──────────────────────────    │
│                                │
│  📅 Mar 15 - Mar 18, 2025      │
│      3 nights                  │
│                                │
│  👥 2 Adults                   │
│                                │
│  ──────────────────────────    │
│                                │
│  Price Breakdown               │
│  $180 x 3 nights      $540     │
│  Service fee           $27     │
│  Taxes                 $54     │
│  ─────────────────────────     │
│  Total                $621     │
│                                │
│  ──────────────────────────    │
│                                │
│  Special Requests (Optional)   │
│  ┌──────────────────────────┐ │
│  │ Late check-in...         │ │
│  └──────────────────────────┘ │
│                                │
├────────────────────────────────┤
│         [Confirm Booking] ❯    │
└────────────────────────────────┘
```

**Step 3: Payment (Placeholder)**
```
┌────────────────────────────────┐
│ [<] Payment            Step 3/3│
├────────────────────────────────┤
│                                │
│  Payment Method                │
│                                │
│  [○] Credit/Debit Card         │
│  [○] PayPal                    │
│  [○] Apple Pay                 │
│                                │
│  ──────────────────────────    │
│                                │
│  Card Information              │
│  ┌──────────────────────────┐ │
│  │ Card Number              │ │
│  └──────────────────────────┘ │
│  ┌────────────┐ ┌───────────┐ │
│  │ MM/YY      │ │ CVV       │ │
│  └────────────┘ └───────────┘ │
│                                │
│  ──────────────────────────    │
│                                │
│  [✓] Save for future bookings  │
│                                │
│  By booking, you agree to our  │
│  Terms of Service and Privacy  │
│  Policy                        │
│                                │
├────────────────────────────────┤
│  Total: $621  [Pay Now] ❯      │
└────────────────────────────────┘
```

**Confirmation Screen**
```
┌────────────────────────────────┐
│                                │
│        [✓ Animation]           │
│                                │
│      Booking Confirmed!        │
│                                │
│   Booking Ref: #BK-2025-001    │
│                                │
│  ──────────────────────────    │
│                                │
│  [Listing Image]               │
│  Luxury Hotel Paris            │
│                                │
│  📅 Mar 15 - 18, 2025          │
│  👥 2 Adults                   │
│  💰 $621                       │
│                                │
│  ──────────────────────────    │
│                                │
│  [📧 Email Confirmation Sent]  │
│                                │
│  ┌──────────────────────────┐ │
│  │   View Booking Details   │ │
│  └──────────────────────────┘ │
│                                │
│  ┌──────────────────────────┐ │
│  │   Add to Itinerary       │ │
│  └──────────────────────────┘ │
│                                │
│         [Done]                 │
│                                │
└────────────────────────────────┘
```

**Components**:
- Step indicator (1/3, 2/3, 3/3)
- Calendar widget (table_calendar or syncfusion)
- Date range selector
- Guest counter (increment/decrement)
- Price calculator
- Review summary card
- Special requests text field
- Payment form (placeholder)
- Success animation (Lottie)
- Booking reference display
- Action buttons (email, view, add to itinerary)

**State Integration**:
```dart
- Date selection state
- Guest count state
- Price calculation (bookingProvider)
- Create booking (bookingNotifierProvider)
- Loading states during submission
- Error handling
- Navigation on success
```

---

### 8. Trips/Bookings Screen

```
┌────────────────────────────────┐
│  My Trips                      │
├────────────────────────────────┤
│  [Upcoming] [Past] [Cancelled] │
│                                │
│  Upcoming Trips (2)            │
│                                │
│  ┌──────────────────────────┐ │
│  │ [Image]                  │ │
│  │ Luxury Hotel Paris       │ │
│  │ 📅 Mar 15-18, 2025       │ │
│  │ #BK-2025-001             │ │
│  │ [View Details] ❯          │ │
│  └──────────────────────────┘ │
│                                │
│  ┌──────────────────────────┐ │
│  │ [Image]                  │ │
│  │ Beach Resort Bali        │ │
│  │ 📅 Apr 10-17, 2025       │ │
│  │ #BK-2025-002             │ │
│  │ [View Details] ❯          │ │
│  └──────────────────────────┘ │
│                                │
│                                │
│  [Empty state if no bookings]  │
│  No upcoming trips             │
│  [Explore Destinations]        │
│                                │
├────────────────────────────────┤
│ [🏠] [❤️] [🎫] [📅] [👤]     │
└────────────────────────────────┘
```

**Components**:
- Tab bar (Upcoming, Past, Cancelled)
- Booking cards with image, title, dates, reference
- Status badges
- Empty state illustration
- CTA button when empty
- Pull-to-refresh
- Swipe actions (cancel, modify)

**State Integration**:
```dart
- Upcoming bookings (upcomingBookingsProvider)
- Past bookings (pastBookingsProvider)
- Tab state (selectedTab)
- Pull-to-refresh action
- Swipe actions (cancel booking)
```

---

### 9. Wishlist Screen

```
┌────────────────────────────────┐
│  Wishlist                      │
├────────────────────────────────┤
│  24 saved places               │
│                                │
│  ┌──────┐  ┌──────┐  ┌──────┐ │
│  │[Img] │  │[Img] │  │[Img] │ │
│  │ ❤️   │  │ ❤️   │  │ ❤️   │ │
│  │Title │  │Title │  │Title │ │
│  │⭐4.8 │  │⭐4.9 │  │⭐4.7 │ │
│  │ $150 │  │ $180 │  │ $120 │ │
│  └──────┘  └──────┘  └──────┘ │
│                                │
│  ┌──────┐  ┌──────┐  ┌──────┐ │
│  │[Img] │  │[Img] │  │[Img] │ │
│  │ ❤️   │  │ ❤️   │  │ ❤️   │ │
│  │Title │  │Title │  │Title │ │
│  │⭐4.6 │  │⭐4.8 │  │⭐4.9 │ │
│  │ $200 │  │ $95  │  │ $175 │ │
│  └──────┘  └──────┘  └──────┘ │
│                                │
│  [Empty state if empty]        │
│  No saved places yet           │
│  Tap ❤️ to save your favorites│
│                                │
├────────────────────────────────┤
│ [🏠] [❤️] [🎫] [📅] [👤]     │
└────────────────────────────────┘
```

**Components**:
- Grid layout (2 columns)
- Listing cards with heart icon
- Item count
- Empty state with illustration
- Pull-to-refresh
- Long-press to remove

**State Integration**:
```dart
- Wishlist items (wishlistProvider)
- Remove from wishlist action
- Navigation to listing detail
```

---

### 10. Itinerary Screen

```
┌────────────────────────────────┐
│  My Itineraries        [+ New] │
├────────────────────────────────┤
│                                │
│  ┌──────────────────────────┐ │
│  │ 🗼 Paris Adventure       │ │
│  │ Mar 15-18, 2025          │ │
│  │ 3 days · 2 activities    │ │
│  │ [View Details] ❯          │ │
│  └──────────────────────────┘ │
│                                │
│  ┌──────────────────────────┐ │
│  │ 🏖️ Bali Retreat          │ │
│  │ Apr 10-17, 2025          │ │
│  │ 7 days · 5 activities    │ │
│  │ [View Details] ❯          │ │
│  └──────────────────────────┘ │
│                                │
│                                │
│  [Empty state]                 │
│  No itineraries yet            │
│  Plan your perfect trip        │
│  [Create Itinerary]            │
│                                │
├────────────────────────────────┤
│ [🏠] [❤️] [🎫] [📅] [👤]     │
└────────────────────────────────┘
```

**Itinerary Detail**:
```
┌────────────────────────────────┐
│ [<] Paris Adventure    [✎] [⋮] │
├────────────────────────────────┤
│  Mar 15-18, 2025               │
│  3 days in Paris, France       │
│                                │
│  ──────────────────────────    │
│                                │
│  Day 1 - Mar 15                │
│  ┌──────────────────────────┐ │
│  │ 📍 10:00 AM              │ │
│  │ Check-in at Luxury Hotel │ │
│  │ [Booking #BK-2025-001]   │ │
│  └──────────────────────────┘ │
│  ┌──────────────────────────┐ │
│  │ 🗼 2:00 PM               │ │
│  │ Visit Eiffel Tower       │ │
│  │ [Note: Book tickets]     │ │
│  └──────────────────────────┘ │
│                                │
│  Day 2 - Mar 16                │
│  ┌──────────────────────────┐ │
│  │ 🏛️ 10:00 AM              │ │
│  │ Louvre Museum            │ │
│  └──────────────────────────┘ │
│                                │
│  [+ Add Activity]              │
│                                │
├────────────────────────────────┤
│         [Share Itinerary]      │
└────────────────────────────────┘
```

**Components**:
- Itinerary list cards
- Create button (FAB or header)
- Day-by-day timeline
- Activity cards (bookings + custom)
- Time indicators
- Edit/delete actions
- Add activity button
- Share functionality
- Empty state

**State Integration**:
```dart
- Itineraries list (itinerariesProvider)
- Itinerary detail (itineraryByIdProvider)
- Itinerary items (linked bookings + activities)
- Create/edit/delete actions
- Drag-to-reorder items
```

---

### 11. Rewards Screen

```
┌────────────────────────────────┐
│ [<] Rewards                    │
├────────────────────────────────┤
│                                │
│  ┌──────────────────────────┐ │
│  │   Your Points Balance    │ │
│  │                          │ │
│  │        2,450             │ │
│  │        points            │ │
│  │                          │ │
│  │  ≈ $24.50 in rewards     │ │
│  └──────────────────────────┘ │
│                                │
│  ──────────────────────────    │
│                                │
│  Available Rewards             │
│                                │
│  ┌──────────────────────────┐ │
│  │ 🎁 10% Off Next Booking  │ │
│  │ 1,000 points             │ │
│  │ Expires: Mar 31, 2025    │ │
│  │         [Redeem]         │ │
│  └──────────────────────────┘ │
│                                │
│  ┌──────────────────────────┐ │
│  │ 🎁 Free Room Upgrade     │ │
│  │ 2,500 points             │ │
│  │ Expires: Apr 15, 2025    │ │
│  │       [Redeem]           │ │
│  └──────────────────────────┘ │
│                                │
│  ──────────────────────────    │
│                                │
│  Points History                │
│  · +500 pts · Booking #001     │
│  · +250 pts · Referral bonus   │
│  · -1000 pts · Redeemed reward │
│                                │
│  [View All History]            │
│                                │
└────────────────────────────────┘
```

**Components**:
- Points balance card (with gradient)
- Value conversion display
- Available rewards cards
- Redeem buttons
- Expiry dates
- Points history list
- Empty state (no rewards)

**State Integration**:
```dart
- Points balance (userPointsProvider)
- Available rewards (rewardsProvider)
- Points history (pointsHistoryProvider)
- Redeem action (redeemRewardNotifier)
```

---

### 12. Profile Screen

```
┌────────────────────────────────┐
│  Profile                       │
├────────────────────────────────┤
│                                │
│       [Profile Photo]          │
│                                │
│       John Doe                 │
│       john.doe@email.com       │
│                                │
│  ┌──────────────────────────┐ │
│  │    [Edit Profile]        │ │
│  └──────────────────────────┘ │
│                                │
│  ──────────────────────────    │
│                                │
│  Account                       │
│  📊 Rewards & Points      ❯    │
│  🎫 My Bookings          ❯    │
│  ❤️  Wishlist             ❯    │
│  📅 Itineraries          ❯    │
│                                │
│  ──────────────────────────    │
│                                │
│  Preferences                   │
│  ⚙️  Settings              ❯   │
│  🔔 Notifications        ❯    │
│  🌐 Language            ❯     │
│  🎨 Appearance          ❯     │
│                                │
│  ──────────────────────────    │
│                                │
│  Support                       │
│  ❓ Help Center          ❯    │
│  📧 Contact Us           ❯    │
│  📄 Terms & Privacy      ❯    │
│                                │
│  ──────────────────────────    │
│                                │
│  [🚪 Logout]                   │
│                                │
│  Version 1.0.0                 │
│                                │
├────────────────────────────────┤
│ [🏠] [❤️] [🎫] [📅] [👤]     │
└────────────────────────────────┘
```

**Components**:
- Profile header with photo
- Edit profile button
- Settings list items
- Section dividers
- Navigation arrows
- Logout button
- App version display

**State Integration**:
```dart
- User profile (userProvider)
- Settings state (settingsProvider)
- Logout action (authNotifier)
```

---

## 🎨 Reusable UI Components Library

I'll create the key reusable components in the next file.
