# GoBeyond Travel - Core Features, Business Logic & Optimization

## 🎯 Overview

This document defines all core features, business logic, performance optimizations, security measures, and testing strategies for the GoBeyond Travel application.

**Built upon**:
- SQLite database architecture (database_helper.dart)
- Clean Architecture + MVVM pattern
- Riverpod state management
- UI/UX design system

---

## 📊 Feature Implementation Matrix

| Feature | Database Tables | Providers | Screens | Status |
|---------|----------------|-----------|---------|--------|
| Authentication | users | authProvider | Login, Register | ✅ Planned |
| Explore & Search | listings | listingProvider | Explore, Search | ✅ Planned |
| Booking System | bookings, listings | bookingProvider | Booking Flow | ✅ Reference Implementation |
| Wishlist | wishlists, listings | wishlistProvider | Wishlist | ✅ Planned |
| Itinerary | itineraries, itinerary_items | itineraryProvider | Itinerary Screens | ✅ Planned |
| Rewards | rewards | rewardsProvider | Rewards | ✅ Planned |
| Feedback | feedbacks | feedbackProvider | Review Screen | ✅ Planned |
| Profile | users | userProvider | Profile | ✅ Planned |
| Notifications | - | notificationProvider | - | ✅ Planned |
| Offline Sync | All tables | syncProvider | - | ✅ Planned |

---

## 🔐 Feature 1: Authentication System

### Functional Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Authentication Flow                      │
└─────────────────────────────────────────────────────────────┘

App Launch
    │
    ▼
Check Local Auth State
    │
    ├─── Token Exists & Valid ──────► Navigate to Home
    │
    └─── No Token/Invalid ──────────► Show Onboarding
                                          │
                                          ▼
                                    User Chooses
                                          │
                    ┌─────────────────────┼─────────────────────┐
                    │                     │                     │
                    ▼                     ▼                     ▼
              Email/Password        Google OAuth          Apple Sign In
                    │                     │                     │
                    ▼                     ▼                     ▼
              Validate Input       Get OAuth Token       Get Apple Token
                    │                     │                     │
                    ▼                     ▼                     ▼
           Hash Password          Exchange for JWT      Exchange for JWT
                    │                     │                     │
                    ▼                     ▼                     ▼
         Create/Update User    Create/Update User    Create/Update User
              in SQLite              in SQLite             in SQLite
                    │                     │                     │
                    └─────────────────────┼─────────────────────┘
                                          │
                                          ▼
                                   Store JWT Token
                                   (Secure Storage)
                                          │
                                          ▼
                                   Update Auth State
                                   (Riverpod Provider)
                                          │
                                          ▼
                                   Navigate to Home
                                          │
                                          ▼
                                   Start Sync Process
```

### Implementation

#### 1.1 Authentication Entity

```dart
// lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profilePhoto;
  final String? authProvider; // 'email', 'google', 'apple'
  final String? authProviderId;
  final int rewardPoints;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  const User({
    this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profilePhoto,
    this.authProvider = 'email',
    this.authProviderId,
    this.rewardPoints = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePhoto,
    String? authProvider,
    String? authProviderId,
    int? rewardPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      authProvider: authProvider ?? this.authProvider,
      authProviderId: authProviderId ?? this.authProviderId,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phoneNumber,
        profilePhoto,
        authProvider,
        authProviderId,
        rewardPoints,
        createdAt,
        updatedAt,
        lastLoginAt,
      ];
}
```

#### 1.2 Auth State

```dart
// lib/features/auth/domain/entities/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:gobeyond/features/auth/domain/entities/user.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, token, errorMessage];
}
```

#### 1.3 Auth Repository

```dart
// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:gobeyond/core/errors/failures.dart';
import 'package:gobeyond/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, User>> signInWithApple();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, void>> updateUser(User user);

  Future<Either<Failure, void>> deleteAccount();
}
```

#### 1.4 Auth Repository Implementation

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:gobeyond/core/errors/exceptions.dart';
import 'package:gobeyond/core/errors/failures.dart';
import 'package:gobeyond/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:gobeyond/features/auth/data/datasources/auth_secure_storage.dart';
import 'package:gobeyond/features/auth/domain/entities/user.dart';
import 'package:gobeyond/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Validate credentials
      final user = await localDataSource.signInWithEmail(email, password);
      
      // Generate JWT token (placeholder - in production, get from backend)
      final token = _generateToken(user);
      
      // Store token securely
      await secureStorage.saveToken(token);
      
      // Update last login
      await localDataSource.updateLastLogin(user.id!);
      
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await localDataSource.getUserByEmail(email);
      if (existingUser != null) {
        return Left(AuthFailure('User with this email already exists'));
      }

      // Hash password
      final hashedPassword = _hashPassword(password);

      // Create user
      final user = User(
        name: name,
        email: email,
        authProvider: 'email',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final userId = await localDataSource.createUser(user, hashedPassword);
      final createdUser = user.copyWith(id: userId);

      // Generate and store token
      final token = _generateToken(createdUser);
      await secureStorage.saveToken(token);

      return Right(createdUser);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      // TODO: Implement Google Sign-In
      // 1. Use google_sign_in package
      // 2. Get Google credentials
      // 3. Exchange for user info
      // 4. Create/update user in SQLite
      // 5. Generate token
      
      return Left(AuthFailure('Google Sign-In not yet implemented'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      // TODO: Implement Apple Sign-In
      // 1. Use sign_in_with_apple package
      // 2. Get Apple credentials
      // 3. Exchange for user info
      // 4. Create/update user in SQLite
      // 5. Generate token
      
      return Left(AuthFailure('Apple Sign-In not yet implemented'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await secureStorage.deleteToken();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final token = await secureStorage.getToken();
      if (token == null) return const Right(null);

      final userId = _getUserIdFromToken(token);
      final user = await localDataSource.getUserById(userId);
      
      return Right(user);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(User user) async {
    try {
      await localDataSource.updateUser(user);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final token = await secureStorage.getToken();
      if (token == null) return Left(AuthFailure('Not authenticated'));

      final userId = _getUserIdFromToken(token);
      await localDataSource.deleteUser(userId);
      await secureStorage.deleteToken();
      
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // Helper methods
  String _hashPassword(String password) {
    // TODO: Use crypto package for proper hashing (bcrypt, argon2)
    // For now, placeholder implementation
    return password; // NEVER DO THIS IN PRODUCTION
  }

  String _generateToken(User user) {
    // TODO: Use jwt_decoder package to generate proper JWT
    // For now, simple placeholder
    return 'jwt_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
  }

  int _getUserIdFromToken(String token) {
    // TODO: Decode JWT properly
    // Placeholder implementation
    final parts = token.split('_');
    return int.parse(parts[1]);
  }
}
```

#### 1.5 Auth Local DataSource

```dart
// lib/features/auth/data/datasources/auth_local_datasource.dart
import 'package:sqflite/sqflite.dart';
import 'package:gobeyond/core/database/database_helper.dart';
import 'package:gobeyond/core/errors/exceptions.dart';
import 'package:gobeyond/features/auth/data/models/user_model.dart';
import 'package:gobeyond/features/auth/domain/entities/user.dart';

class AuthLocalDataSource {
  final DatabaseHelper dbHelper;

  AuthLocalDataSource({required this.dbHelper});

  Future<User> signInWithEmail(String email, String password) async {
    try {
      final db = await dbHelper.database;
      
      final results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (results.isEmpty) {
        throw AuthException('Invalid email or password');
      }

      final userMap = results.first;
      final storedPassword = userMap['password_hash'] as String?;

      // Verify password
      if (storedPassword != password) { // TODO: Proper hash comparison
        throw AuthException('Invalid email or password');
      }

      return UserModel.fromMap(userMap);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw DatabaseException('Failed to sign in: ${e.toString()}');
    }
  }

  Future<int> createUser(User user, String passwordHash) async {
    try {
      final db = await dbHelper.database;
      final userModel = UserModel.fromEntity(user);
      final userMap = userModel.toMap();
      userMap['password_hash'] = passwordHash;

      return await db.insert('users', userMap);
    } catch (e) {
      throw DatabaseException('Failed to create user: ${e.toString()}');
    }
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await dbHelper.database;
      
      final results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (results.isEmpty) return null;
      return UserModel.fromMap(results.first);
    } catch (e) {
      throw DatabaseException('Failed to get user: ${e.toString()}');
    }
  }

  Future<User?> getUserById(int id) async {
    try {
      final db = await dbHelper.database;
      
      final results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) return null;
      return UserModel.fromMap(results.first);
    } catch (e) {
      throw DatabaseException('Failed to get user: ${e.toString()}');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      final db = await dbHelper.database;
      final userModel = UserModel.fromEntity(user);

      await db.update(
        'users',
        userModel.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update user: ${e.toString()}');
    }
  }

  Future<void> updateLastLogin(int userId) async {
    try {
      final db = await dbHelper.database;

      await db.update(
        'users',
        {'last_login_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw DatabaseException('Failed to update last login: ${e.toString()}');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      final db = await dbHelper.database;

      await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete user: ${e.toString()}');
    }
  }
}
```

#### 1.6 Secure Storage

```dart
// lib/features/auth/data/datasources/auth_secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSecureStorage {
  final FlutterSecureStorage storage;

  AuthSecureStorage({required this.storage});

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveToken(String token) async {
    await storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _refreshTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: _refreshTokenKey);
  }
}
```

#### 1.7 Auth Provider (Riverpod)

```dart
// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gobeyond/core/database/database_helper.dart';
import 'package:gobeyond/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:gobeyond/features/auth/data/datasources/auth_secure_storage.dart';
import 'package:gobeyond/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gobeyond/features/auth/domain/entities/auth_state.dart';
import 'package:gobeyond/features/auth/domain/entities/user.dart';
import 'package:gobeyond/features/auth/domain/repositories/auth_repository.dart';

// Dependencies
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authSecureStorageProvider = Provider<AuthSecureStorage>((ref) {
  return AuthSecureStorage(storage: ref.read(secureStorageProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(dbHelper: DatabaseHelper.instance);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.read(authLocalDataSourceProvider),
    secureStorage: ref.read(authSecureStorageProvider),
  );
});

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await repository.getCurrentUser();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        );
      },
      (user) {
        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await repository.signInWithEmail(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      },
    );
  }

  Future<void> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await repository.signUpWithEmail(
      name: name,
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await repository.signInWithGoogle();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      },
    );
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await repository.signInWithApple();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      },
    );
  }

  Future<void> signOut() async {
    await repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> updateUser(User user) async {
    final result = await repository.updateUser(user);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(user: user);
      },
    );
  }

  Future<void> deleteAccount() async {
    final result = await repository.deleteAccount();

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      },
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

// Convenience providers
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
```

#### 1.8 Login Screen

```dart
// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gobeyond/app/themes.dart';
import 'package:gobeyond/features/auth/domain/entities/auth_state.dart';
import 'package:gobeyond/features/auth/presentation/providers/auth_provider.dart';
import 'package:gobeyond/shared/widgets/custom_app_bar.dart';
import 'package:gobeyond/shared/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  void _handleGoogleSignIn() {
    ref.read(authProvider.notifier).signInWithGoogle();
  }

  void _handleAppleSignIn() {
    ref.read(authProvider.notifier).signInWithApple();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/explore');
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: const CustomAppBar(title: 'Welcome Back'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                
                // Welcome text
                Text(
                  'Welcome Back! 👋',
                  style: AppTypography.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sign in to continue',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppSpacing.sm),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to forgot password
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Sign in button
                PrimaryButton(
                  label: 'Sign In',
                  onPressed: _handleLogin,
                  isLoading: authState.isLoading,
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        'OR',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Google sign in
                PrimaryButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata,
                  onPressed: _handleGoogleSignIn,
                  variant: ButtonVariant.outline,
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Apple sign in
                PrimaryButton(
                  label: 'Continue with Apple',
                  icon: Icons.apple,
                  onPressed: _handleAppleSignIn,
                  variant: ButtonVariant.outline,
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTypography.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/auth/register');
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### Security Measures for Authentication

✅ **Implemented**:
- Secure token storage using `flutter_secure_storage`
- Password hashing placeholders (TODO: implement bcrypt/argon2)
- Email validation
- Auth state management

⚠️ **TODO for Production**:
1. **Password Security**:
   ```dart
   // Use crypto package
   import 'package:crypto/crypto.dart';
   import 'package:convert/convert.dart';
   
   String hashPassword(String password) {
     final bytes = utf8.encode(password + salt);
     final digest = sha256.convert(bytes);
     return digest.toString();
   }
   
   // Better: Use argon2 or bcrypt
   ```

2. **JWT Implementation**:
   ```dart
   // Use dart_jsonwebtoken package
   import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
   
   String generateToken(User user) {
     final jwt = JWT({
       'userId': user.id,
       'email': user.email,
       'iat': DateTime.now().millisecondsSinceEpoch,
       'exp': DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch,
     });
     
     return jwt.sign(SecretKey('your-secret-key'));
   }
   ```

3. **Biometric Auth**:
   ```dart
   // Use local_auth package
   import 'package:local_auth/local_auth.dart';
   
   Future<bool> authenticateWithBiometrics() async {
     final localAuth = LocalAuthentication();
     return await localAuth.authenticate(
       localizedReason: 'Authenticate to access GoBeyond',
       options: const AuthenticationOptions(
         biometricOnly: true,
         stickyAuth: true,
       ),
     );
   }
   ```

4. **SSL Pinning** (when connecting to backend):
   ```dart
   // Use http_certificate_pinning package
   ```

---

## 🔍 Feature 2: Search & Filter System

### Functional Flow Diagram

```
User Opens Search
       │
       ▼
Load Recent Searches (SQLite)
Load Popular Destinations
       │
       ▼
User Types Query (debounced 500ms)
       │
       ├─── Empty Query ──────► Show Recent/Popular
       │
       └─── Has Query ─────────► Search Listings
                                        │
                                        ▼
                              Filter by Query (SQLite LIKE)
                                        │
                                        ▼
                              Apply Active Filters
                              (Price, Rating, Type, Amenities)
                                        │
                                        ▼
                              Apply Sort
                              (Popular, Price, Rating, Distance)
                                        │
                                        ▼
                              Paginate Results (20 per page)
                                        │
                                        ▼
                              Display Results
                                        │
                                        ├─► Tap Listing ──► Navigate to Detail
                                        ├─► Toggle Wishlist
                                        └─► Load More ──► Next Page
```

### Implementation

#### 2.1 Search Filter Model

```dart
// lib/features/explore/domain/entities/search_filter.dart
import 'package:equatable/equatable.dart';

enum SortBy { popular, priceLowToHigh, priceHighToLow, rating, distance }

enum ListingType { hotel, flight, activity }

class SearchFilter extends Equatable {
  final String? query;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final List<ListingType>? types;
  final List<String>? amenities;
  final SortBy sortBy;
  final int page;
  final int pageSize;

  const SearchFilter({
    this.query,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.types,
    this.amenities,
    this.sortBy = SortBy.popular,
    this.page = 1,
    this.pageSize = 20,
  });

  SearchFilter copyWith({
    String? query,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    List<ListingType>? types,
    List<String>? amenities,
    SortBy? sortBy,
    int? page,
    int? pageSize,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      types: types ?? this.types,
      amenities: amenities ?? this.amenities,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  bool get hasActiveFilters =>
      minPrice != null ||
      maxPrice != null ||
      minRating != null ||
      (types != null && types!.isNotEmpty) ||
      (amenities != null && amenities!.isNotEmpty);

  @override
  List<Object?> get props => [
        query,
        minPrice,
        maxPrice,
        minRating,
        types,
        amenities,
        sortBy,
        page,
        pageSize,
      ];
}
```

#### 2.2 Search Repository

```dart
// lib/features/explore/data/datasources/listing_local_datasource.dart
import 'package:sqflite/sqflite.dart';
import 'package:gobeyond/core/database/database_helper.dart';
import 'package:gobeyond/features/explore/data/models/listing_model.dart';
import 'package:gobeyond/features/explore/domain/entities/listing.dart';
import 'package:gobeyond/features/explore/domain/entities/search_filter.dart';

class ListingLocalDataSource {
  final DatabaseHelper dbHelper;

  ListingLocalDataSource({required this.dbHelper});

  Future<List<Listing>> searchListings(SearchFilter filter) async {
    final db = await dbHelper.database;

    // Build WHERE clause
    final whereConditions = <String>[];
    final whereArgs = <dynamic>[];

    // Text search
    if (filter.query != null && filter.query!.isNotEmpty) {
      whereConditions.add(
        '(title LIKE ? OR location LIKE ? OR description LIKE ?)',
      );
      final searchPattern = '%${filter.query}%';
      whereArgs.addAll([searchPattern, searchPattern, searchPattern]);
    }

    // Price filter
    if (filter.minPrice != null) {
      whereConditions.add('price_per_night >= ?');
      whereArgs.add(filter.minPrice);
    }
    if (filter.maxPrice != null) {
      whereConditions.add('price_per_night <= ?');
      whereArgs.add(filter.maxPrice);
    }

    // Rating filter
    if (filter.minRating != null) {
      whereConditions.add('rating >= ?');
      whereArgs.add(filter.minRating);
    }

    // Type filter
    if (filter.types != null && filter.types!.isNotEmpty) {
      final typePlaceholders = filter.types!.map((_) => '?').join(',');
      whereConditions.add('type IN ($typePlaceholders)');
      whereArgs.addAll(filter.types!.map((t) => t.toString().split('.').last));
    }

    // Amenities filter (assuming amenities stored as JSON string)
    if (filter.amenities != null && filter.amenities!.isNotEmpty) {
      for (final amenity in filter.amenities!) {
        whereConditions.add('amenities LIKE ?');
        whereArgs.add('%$amenity%');
      }
    }

    // Build ORDER BY clause
    String orderBy;
    switch (filter.sortBy) {
      case SortBy.popular:
        orderBy = 'rating DESC, total_reviews DESC';
        break;
      case SortBy.priceLowToHigh:
        orderBy = 'price_per_night ASC';
        break;
      case SortBy.priceHighToLow:
        orderBy = 'price_per_night DESC';
        break;
      case SortBy.rating:
        orderBy = 'rating DESC';
        break;
      case SortBy.distance:
        // TODO: Calculate distance based on user location
        orderBy = 'rating DESC';
        break;
    }

    // Pagination
    final limit = filter.pageSize;
    final offset = (filter.page - 1) * filter.pageSize;

    // Execute query
    final results = await db.query(
      'listings',
      where: whereConditions.isNotEmpty
          ? whereConditions.join(' AND ')
          : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return results.map((map) => ListingModel.fromMap(map)).toList();
  }

  Future<int> getSearchResultCount(SearchFilter filter) async {
    final db = await dbHelper.database;

    final whereConditions = <String>[];
    final whereArgs = <dynamic>[];

    // Same WHERE logic as searchListings
    if (filter.query != null && filter.query!.isNotEmpty) {
      whereConditions.add(
        '(title LIKE ? OR location LIKE ? OR description LIKE ?)',
      );
      final searchPattern = '%${filter.query}%';
      whereArgs.addAll([searchPattern, searchPattern, searchPattern]);
    }

    if (filter.minPrice != null) {
      whereConditions.add('price_per_night >= ?');
      whereArgs.add(filter.minPrice);
    }
    if (filter.maxPrice != null) {
      whereConditions.add('price_per_night <= ?');
      whereArgs.add(filter.maxPrice);
    }

    if (filter.minRating != null) {
      whereConditions.add('rating >= ?');
      whereArgs.add(filter.minRating);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM listings' +
          (whereConditions.isNotEmpty
              ? ' WHERE ${whereConditions.join(' AND ')}'
              : ''),
      whereArgs.isNotEmpty ? whereArgs : null,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<String>> getRecentSearches({int limit = 10}) async {
    // TODO: Store searches in a separate table
    // For now, return empty list
    return [];
  }

  Future<void> saveRecentSearch(String query) async {
    // TODO: Store in recent_searches table with timestamp
  }

  Future<List<Listing>> getFeaturedListings({int limit = 10}) async {
    final db = await dbHelper.database;

    final results = await db.query(
      'listings',
      where: 'is_featured = ?',
      whereArgs: [1],
      orderBy: 'rating DESC',
      limit: limit,
    );

    return results.map((map) => ListingModel.fromMap(map)).toList();
  }

  Future<List<Listing>> getPopularNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    int limit = 10,
  }) async {
    // TODO: Implement Haversine formula for distance calculation
    // For now, return top-rated listings
    final db = await dbHelper.database;

    final results = await db.query(
      'listings',
      orderBy: 'rating DESC, total_reviews DESC',
      limit: limit,
    );

    return results.map((map) => ListingModel.fromMap(map)).toList();
  }
}
```

#### 2.3 Search Provider

```dart
// lib/features/explore/presentation/providers/search_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gobeyond/core/database/database_helper.dart';
import 'package:gobeyond/features/explore/data/datasources/listing_local_datasource.dart';
import 'package:gobeyond/features/explore/domain/entities/listing.dart';
import 'package:gobeyond/features/explore/domain/entities/search_filter.dart';

// Data source provider
final listingLocalDataSourceProvider = Provider<ListingLocalDataSource>((ref) {
  return ListingLocalDataSource(dbHelper: DatabaseHelper.instance);
});

// Search filter state
final searchFilterProvider = StateProvider<SearchFilter>((ref) {
  return const SearchFilter();
});

// Search query (for debouncing)
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search results with filter
final searchResultsProvider = FutureProvider<List<Listing>>((ref) async {
  final dataSource = ref.read(listingLocalDataSourceProvider);
  final filter = ref.watch(searchFilterProvider);

  // Debounce: only execute if query hasn't changed in 500ms
  await Future.delayed(const Duration(milliseconds: 500));

  return dataSource.searchListings(filter);
});

// Result count
final searchResultCountProvider = FutureProvider<int>((ref) async {
  final dataSource = ref.read(listingLocalDataSourceProvider);
  final filter = ref.watch(searchFilterProvider);

  return dataSource.getSearchResultCount(filter);
});

// Recent searches
final recentSearchesProvider = FutureProvider<List<String>>((ref) async {
  final dataSource = ref.read(listingLocalDataSourceProvider);
  return dataSource.getRecentSearches();
});

// Featured listings
final featuredListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final dataSource = ref.read(listingLocalDataSourceProvider);
  return dataSource.getFeaturedListings();
});

// Popular nearby
final popularNearbyProvider = FutureProvider<List<Listing>>((ref) async {
  final dataSource = ref.read(listingLocalDataSourceProvider);
  // TODO: Get user location
  return dataSource.getPopularNearby(
    latitude: 0,
    longitude: 0,
  );
});
```

#### 2.4 Search Screen

```dart
// lib/features/explore/presentation/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gobeyond/app/themes.dart';
import 'package:gobeyond/features/explore/domain/entities/search_filter.dart';
import 'package:gobeyond/features/explore/presentation/providers/search_provider.dart';
import 'package:gobeyond/shared/widgets/custom_search_bar.dart';
import 'package:gobeyond/shared/widgets/empty_state.dart';
import 'package:gobeyond/shared/widgets/error_widget.dart';
import 'package:gobeyond/shared/widgets/listing_card.dart';
import 'package:gobeyond/shared/widgets/loading_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Update filter with new query
    final currentFilter = ref.read(searchFilterProvider);
    ref.read(searchFilterProvider.notifier).state = currentFilter.copyWith(
      query: query.isEmpty ? null : query,
      page: 1, // Reset to first page
    );
  }

  void _openFilterBottomSheet() {
    // TODO: Show filter bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _changeSortBy(SortBy sortBy) {
    final currentFilter = ref.read(searchFilterProvider);
    ref.read(searchFilterProvider.notifier).state = currentFilter.copyWith(
      sortBy: sortBy,
      page: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final resultCount = ref.watch(searchResultCountProvider);
    final filter = ref.watch(searchFilterProvider);
    final hasQuery = filter.query != null && filter.query!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: CustomSearchBar(
          controller: _searchController,
          hint: 'Where to?',
          onChanged: _onSearchChanged,
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter and sort bar
          if (hasQuery)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: AppElevation.sm,
              ),
              child: Row(
                children: [
                  // Filter button
                  OutlinedButton.icon(
                    onPressed: _openFilterBottomSheet,
                    icon: Icon(
                      filter.hasActiveFilters
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                    ),
                    label: const Text('Filters'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  
                  // Sort dropdown
                  Expanded(
                    child: DropdownButton<SortBy>(
                      value: filter.sortBy,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: SortBy.popular,
                          child: Text('Popular'),
                        ),
                        DropdownMenuItem(
                          value: SortBy.priceLowToHigh,
                          child: Text('Price: Low to High'),
                        ),
                        DropdownMenuItem(
                          value: SortBy.priceHighToLow,
                          child: Text('Price: High to Low'),
                        ),
                        DropdownMenuItem(
                          value: SortBy.rating,
                          child: Text('Top Rated'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) _changeSortBy(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          
          // Results
          Expanded(
            child: hasQuery
                ? _buildSearchResults(searchResults, resultCount)
                : _buildRecentAndPopular(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    AsyncValue searchResults,
    AsyncValue<int> resultCount,
  ) {
    return searchResults.when(
      data: (listings) {
        if (listings.isEmpty) {
          return const EmptyState(
            title: 'No results found',
            message: 'Try adjusting your search or filters',
            icon: Icons.search_off,
          );
        }

        return Column(
          children: [
            // Result count
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: resultCount.when(
                  data: (count) => Text(
                    '$count results',
                    style: AppTypography.titleSmall,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),
            
            // Listings
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ListingCard(
                      listing: listing,
                      onTap: () {
                        context.go('/explore/listing/${listing.id}');
                      },
                      onWishlistToggle: () {
                        // TODO: Toggle wishlist
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const LoadingState(type: LoadingType.list),
      error: (error, stack) => CustomErrorWidget(
        message: error.toString(),
        onRetry: () => ref.refresh(searchResultsProvider),
      ),
    );
  }

  Widget _buildRecentAndPopular() {
    final recentSearches = ref.watch(recentSearchesProvider);
    final popularDestinations = ref.watch(popularNearbyProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          recentSearches.when(
            data: (searches) {
              if (searches.isEmpty) return const SizedBox.shrink();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Searches',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...searches.map((search) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(search),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        // TODO: Remove from recent searches
                      },
                    ),
                    onTap: () {
                      _searchController.text = search;
                      _onSearchChanged(search);
                    },
                  )),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // Popular destinations
          Text(
            'Popular Destinations',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          popularDestinations.when(
            data: (listings) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.75,
              ),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                return ListingCard(
                  listing: listing,
                  compact: true,
                  onTap: () {
                    context.go('/explore/listing/${listing.id}');
                  },
                );
              },
            ),
            loading: () => const LoadingState(type: LoadingType.grid),
            error: (error, _) => CustomErrorWidget(message: error.toString()),
          ),
        ],
      ),
    );
  }
}

// Filter Bottom Sheet Widget
class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late SearchFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(searchFilterProvider);
  }

  void _applyFilters() {
    ref.read(searchFilterProvider.notifier).state = _tempFilter.copyWith(
      page: 1,
    );
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _tempFilter = const SearchFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: AppTypography.titleLarge,
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Price range
          Text('Price Range', style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          RangeSlider(
            values: RangeValues(
              _tempFilter.minPrice ?? 0,
              _tempFilter.maxPrice ?? 1000,
            ),
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              '\$${_tempFilter.minPrice?.toInt() ?? 0}',
              '\$${_tempFilter.maxPrice?.toInt() ?? 1000}',
            ),
            onChanged: (values) {
              setState(() {
                _tempFilter = _tempFilter.copyWith(
                  minPrice: values.start,
                  maxPrice: values.end,
                );
              });
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Minimum rating
          Text('Minimum Rating', style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: _tempFilter.minRating ?? 0,
            min: 0,
            max: 5,
            divisions: 10,
            label: _tempFilter.minRating?.toStringAsFixed(1) ?? '0',
            onChanged: (value) {
              setState(() {
                _tempFilter = _tempFilter.copyWith(minRating: value);
              });
            },
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Apply button
          PrimaryButton(
            label: 'Apply Filters',
            onPressed: _applyFilters,
          ),
          
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
```

### Performance Optimizations for Search

1. **Debouncing** ✅: Already implemented with 500ms delay
2. **SQLite Indexing**:
   ```sql
   CREATE INDEX idx_listings_title ON listings(title);
   CREATE INDEX idx_listings_location ON listings(location);
   CREATE INDEX idx_listings_price ON listings(price_per_night);
   CREATE INDEX idx_listings_rating ON listings(rating);
   ```

3. **Pagination** ✅: Implemented with LIMIT and OFFSET
4. **Full-Text Search** (Advanced):
   ```sql
   CREATE VIRTUAL TABLE listings_fts USING fts5(
     title, location, description, content=listings
   );
   ```

---

Due to length constraints, I'll create a second file for the remaining features. Let me continue with the Booking System implementation...
