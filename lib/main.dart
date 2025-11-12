import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gobeyond/app/routes.dart';
import 'package:gobeyond/app/themes.dart';
import 'package:gobeyond/core/services/auth_service.dart';
import 'package:gobeyond/core/services/listings_seed_service.dart';
import 'package:gobeyond/core/services/stripe_payment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize authentication service and restore user session
  try {
    await AuthService.instance.initialize();
    print('✅ Auth service initialized - User logged in: ${AuthService.instance.isLoggedIn}');
  } catch (e) {
    print('❌ Error initializing auth service: $e');
  }

  // Seed listings into database if needed
  try {
    await ListingsSeedService().seedListingsIfNeeded();
  } catch (e) {
    print('❌ Error seeding listings: $e');
  }

  // Initialize Stripe payment service
  try {
    await StripePaymentService().initialize();
    print('✅ Stripe payment service initialized');
  } catch (e) {
    print('❌ Error initializing Stripe: $e');
    print('⚠️  Payment functionality will not work. Please check your Stripe configuration.');
  }

  runApp(
    const ProviderScope(
      child: GoBeyondApp(),
    ),
  );
}

class GoBeyondApp extends ConsumerWidget {
  const GoBeyondApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'GoBeyond Travel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
    );
  }
}
