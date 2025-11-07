import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gobeyond/app/routes.dart';
import 'package:gobeyond/app/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Note: Database initialization removed - using SharedPreferences instead
  // SharedPreferences works on all platforms including web

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
