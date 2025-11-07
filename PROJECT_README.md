# 🌍 GoBeyond Travel App

A full-featured Flutter travel booking and management application with offline-first SQLite backend.

## ✨ Features

### Implemented Features
- ✅ **Authentication System**
  - Local email/password authentication
  - Splash screen with auto-login
  - Register and login screens
  - Secure password hashing
  
- ✅ **Explore & Search**
  - Browse travel listings (hotels, tours, activities)
  - Category filtering
  - Search functionality
  - Listing details with images and reviews

- ✅ **Booking System**
  - Book listings with date selection
  - Manage bookings
  - Booking history
  - Booking details and status

- ✅ **Wishlist**
  - Save favorite listings
  - Remove from wishlist
  - View all wishlisted items

- ✅ **Itinerary Planning**
  - Create trip itineraries
  - Add listings to itineraries
  - Manage itinerary items

- ✅ **Rewards System**
  - Earn points on bookings
  - View rewards balance
  - Loyalty tiers

- ✅ **Profile Management**
  - View and edit profile
  - Settings
  - Account management

- ✅ **Offline-First Database**
  - SQLite local database
  - 8 tables with relationships
  - Sample data included
  - Optimized with indexes

## 🏗️ Architecture

The app follows **Clean Architecture** principles with three main layers:

```
lib/
├── app/                    # App-level configuration
│   ├── routes.dart        # GoRouter navigation
│   └── themes.dart        # Material Design theme
├── core/                  # Core utilities & infrastructure
│   ├── database/          # SQLite database helper
│   ├── theme/             # Theme data
│   ├── widgets/           # Reusable widgets
│   ├── utils/             # Utilities & helpers
│   └── constants/         # App constants
├── features/              # Feature modules
│   ├── auth/             # Authentication
│   ├── explore/          # Browse & search
│   ├── booking/          # Bookings management
│   ├── wishlist/         # Wishlist feature
│   ├── itinerary/        # Trip planning
│   ├── rewards/          # Loyalty rewards
│   └── profile/          # User profile
└── shared/               # Shared components
    └── presentation/
        └── screens/
            └── main_screen.dart  # Bottom navigation shell
```

### Each feature follows this structure:
```
feature/
├── data/
│   ├── datasources/      # Local/Remote data sources
│   ├── models/           # Data models
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business logic
└── presentation/
    ├── providers/        # Riverpod state management
    ├── screens/          # UI screens
    └── widgets/          # Feature-specific widgets
```

## 🗄️ Database Schema

The app uses SQLite with 8 tables:

1. **users** - User accounts
2. **listings** - Travel listings (hotels, tours, activities)
3. **bookings** - User bookings
4. **wishlists** - Saved favorite listings
5. **itineraries** - Trip plans
6. **itinerary_items** - Items in each itinerary
7. **feedbacks** - Reviews and ratings
8. **rewards** - Loyalty points

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Clone the repository**
   ```bash
   cd gobeyond
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Create assets folders** (if not exists)
   ```bash
   mkdir -p assets/images assets/icons assets/animations assets/fonts
   ```

4. **Run the app**

   - **Web (Chrome)**
     ```bash
     flutter run -d chrome
     ```

   - **Windows** (requires Developer Mode enabled)
     ```bash
     flutter run -d windows
     ```

   - **Android**
     ```bash
     flutter run -d <device-id>
     ```

   - **iOS** (macOS only)
     ```bash
     flutter run -d <device-id>
     ```

### Default Login Credentials

The app comes with sample data. Use these credentials to login:

- **Email:** `john@example.com`
- **Password:** Any password (for demo purposes, password validation is basic)

## 📦 Dependencies

### Core Dependencies
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `sqflite` - SQLite database
- `path_provider` - File system access

### UI Dependencies
- `cached_network_image` - Image caching
- `shimmer` - Loading placeholders
- `lottie` - Animations
- `table_calendar` - Date picker
- `flutter_slidable` - Swipe actions

### Utilities
- `dartz` - Functional programming
- `equatable` - Value equality
- `intl` - Internationalization
- `uuid` - Unique IDs

See `pubspec.yaml` for complete list.

## 🎨 Design System

### Colors
- **Primary:** Blue (#2196F3) - Trust & reliability
- **Secondary:** Orange (#FF9800) - Adventure & excitement
- **Accent:** Cyan (#00BCD4) - Sky & travel
- **Success:** Green (#4CAF50)
- **Error:** Red (#F44336)

### Typography
- Default system font (Poppins commented out - add font files to enable)
- Material Design 3 type scale

### Components
- Cards with 12px border radius
- Buttons with 8px border radius
- Input fields with outlined style
- Bottom navigation with 5 tabs

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📱 Screens

### Authentication Flow
1. **Splash Screen** - Initial loading
2. **Login Screen** - Email/password login
3. **Register Screen** - New user registration

### Main App (Bottom Navigation)
1. **Explore** - Browse listings with categories
2. **Wishlist** - Saved favorites
3. **Bookings** - Trip history
4. **Itinerary** - Trip planning
5. **Profile** - User account

### Detail Screens
- **Listing Detail** - Full listing information
- **Booking Detail** - Booking information
- **Itinerary Detail** - Trip plan details
- **Rewards** - Loyalty points
- **Settings** - App preferences

## 🔧 Configuration

### Environment Setup
Currently using local SQLite only. For backend integration:

1. Create environment files:
   ```
   .env.development
   .env.staging
   .env.production
   ```

2. Add API endpoints and keys

### Build Flavors
```bash
# Development
flutter run --flavor dev

# Staging
flutter run --flavor staging

# Production
flutter run --flavor prod
```

## 🐛 Known Issues & Limitations

- Custom fonts (Poppins) commented out - add font files to `assets/fonts/` to enable
- Social login (Google, Facebook) is placeholder only
- Payment integration is UI-only (no actual payment processing)
- Maps integration pending API key configuration
- Image cropper disabled for web compatibility

## 🛣️ Roadmap

### Phase 1 (Current)
- ✅ Core features implemented
- ✅ SQLite database
- ✅ Navigation structure
- ✅ Basic UI screens

### Phase 2 (Next)
- [ ] Complete all screen implementations
- [ ] Add data providers (Riverpod)
- [ ] Implement repository pattern
- [ ] Add error handling
- [ ] Loading states

### Phase 3
- [ ] Backend API integration
- [ ] Real authentication
- [ ] Push notifications
- [ ] Offline sync
- [ ] Payment gateway

### Phase 4
- [ ] Advanced search filters
- [ ] Maps integration
- [ ] Chat support
- [ ] Multi-language
- [ ] Dark mode enhancements

## 📄 License

This project is for educational/demonstration purposes.

## 👥 Contributing

This is a demonstration project. Feel free to fork and modify for your own use.

## 📞 Support

For questions or issues, please check the documentation files:
- `COMPLETE_SUMMARY.md` - Project overview
- `CORE_FEATURES_LOGIC.md` - Feature implementations
- `ADVANCED_FEATURES.md` - Advanced features
- `QUICK_REFERENCE.md` - Quick navigation guide

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All open-source package contributors
- Material Design for UI guidelines

---

**Built with ❤️ using Flutter**

*Last Updated: November 2025*
