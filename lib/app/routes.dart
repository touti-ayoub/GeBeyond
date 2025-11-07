import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gobeyond/features/auth/presentation/screens/login_screen.dart';
import 'package:gobeyond/features/auth/presentation/screens/register_screen.dart';
import 'package:gobeyond/features/auth/presentation/screens/splash_screen.dart';
import 'package:gobeyond/features/explore/presentation/screens/explore_screen.dart';
import 'package:gobeyond/features/booking/presentation/screens/booking_screen.dart';
import 'package:gobeyond/features/booking/presentation/screens/booking_detail_screen.dart';
import 'package:gobeyond/features/itinerary/presentation/screens/itinerary_list_screen.dart';
import 'package:gobeyond/features/itinerary/presentation/screens/itinerary_detail_screen.dart';
import 'package:gobeyond/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:gobeyond/features/rewards/presentation/screens/rewards_screen.dart';
import 'package:gobeyond/features/profile/presentation/screens/profile_screen.dart';
import 'package:gobeyond/features/profile/presentation/screens/settings_screen.dart';
import 'package:gobeyond/shared/presentation/screens/main_screen.dart';

/// App routing configuration using GoRouter
final goRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    // ============================================
    // SPLASH & AUTH ROUTES
    // ============================================
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // ============================================
    // MAIN APP ROUTES (with bottom navigation)
    // ============================================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        // Explore Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              name: 'explore',
              builder: (context, state) => const ExploreScreen(),
              // Note: Listing detail navigation is handled by Navigator.push in ExploreScreen
            ),
          ],
        ),

        // Wishlist Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/wishlist',
              name: 'wishlist',
              builder: (context, state) => const WishlistScreen(),
            ),
          ],
        ),

        // Bookings Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bookings',
              name: 'bookings',
              builder: (context, state) {
                // Using BookingScreen which works with BookingService (SharedPreferences)
                return const BookingScreen();
              },
              routes: [
                GoRoute(
                  path: ':id',
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

        // Itinerary Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/itinerary',
              name: 'itinerary',
              builder: (context, state) => const ItineraryListScreen(),
              routes: [
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

        // Profile Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
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

    // ============================================
    // BOOKING FLOW
    // ============================================
    GoRoute(
      path: '/book/:listingId',
      name: 'book',
      builder: (context, state) {
        return const BookingScreen();
      },
    ),
  ],

  // ============================================
  // ERROR HANDLING
  // ============================================
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: ${state.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),

  // ============================================
  // REDIRECT LOGIC (for auth guards)
  // ============================================
  redirect: (context, state) {
    // TODO: Implement actual auth state checking
    // final isAuthenticated = ref.read(authStateProvider).isAuthenticated;
    // final isOnAuthPage = state.matchedLocation.startsWith('/login') || 
    //                      state.matchedLocation.startsWith('/register');
    
    // if (!isAuthenticated && !isOnAuthPage && state.matchedLocation != '/') {
    //   return '/login';
    // }
    
    // if (isAuthenticated && isOnAuthPage) {
    //   return '/explore';
    // }
    
    return null; // No redirect
  },
);
