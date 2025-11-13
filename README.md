# GoBeyond — Travel Booking App

<p align="center">
  <img width="364" height="228" alt="image" src="https://github.com/user-attachments/assets/3a08142b-9458-4ecd-8498-fc6c85793402" />
</p>

GoBeyond is a Flutter app for discovering listings (hotels, flights, activities), booking trips with secure Stripe payments, leaving reviews, managing wishlists, and tracking rewards — all backed by an offline-first SQLite storage layer.

## Highlights
- Offline-first data persistence with SQLite (users, sessions, bookings, favorites, itineraries, reviews, rewards)
- Email notifications via SMTP after successful payments
- Secure payments with Stripe (confirm booking on payment success)
- Explore listings with images, details, reviews, and a location tab using MapTiler tiles
- Modern app architecture using Riverpod, Freezed, and clean data layering

## Tech Stack
- Flutter 3 (Dart >= 3.0.0)
- State: flutter_riverpod, riverpod_annotation
- Data: sqflite, shared_preferences, path_provider
- Payments: flutter_stripe
- Email: mailer (SMTP)
- Maps: flutter_map + MapTiler tiles (latlong2)
- UI: Material 3, cached_network_image, lottie, flutter_slidable, animations

## Project Structure
```
lib/
  core/
    config/                 # App config (MapTilerConfig, etc.)
    services/               # Auth, Reviews, Wishlist, Payments, Email
    utils/                  # Helpers (LocationHelper, formatters, etc.)
  features/
    auth/                   # Login, Register, Session
    booking/                # Booking flow and persistence
    common/                 # Shared widgets (MapTilerWidget, etc.)
    explore/                # Listing browse + detail (with Location tab)
    itinerary/              # Itinerary management
    profile/                # Profile, favorites, rewards
    reviews/                # Reviews (write, list, stats)
  main.dart                 # App entry point
```

## Prerequisites
- Flutter SDK installed
- Android Studio/Xcode (Android Emulator/iOS Simulator)
- A Stripe account (test keys)
- SMTP credentials for email (e.g., Gmail/SendGrid/your SMTP)
- MapTiler API key

## Configuration

### MapTiler
- File: `lib/core/config/google_maps_config.dart`
- Uses `MapTilerConfig`
- The API key is currently set for development; replace for production.

### Stripe
- Where to put keys: set publishable key in your Stripe initialization service (look for Stripe setup in core/services). Keep secret keys on your backend or a secure service; for test flows we create PaymentIntents via a simple endpoint or a mocked layer.
- Make sure to run in TEST mode during development.

### Email (SMTP)
- File(s): email service under `lib/core/services/`
- Configure SMTP host, port, username, and password.
- After a successful payment, the app sends a confirmation email with booking details.

### SQLite
- Migrations and schema are defined in the local persistence layer (services/repositories under `lib/core/services` and `lib/features/**/data`).
- Tables: users, sessions, listings, bookings, favorites (wishlist), itineraries, reviews, rewards, etc.

## Install Dependencies
```cmd
flutter pub get
```

## Run
- Android emulator:
```cmd
flutter run -d emulator-5554
```
- Windows desktop:
```cmd
flutter run -d windows
```
- Chrome (web):
```cmd
flutter run -d chrome
```

## Key Flows

### Authentication
- Register -> user record stored in SQLite
- Login -> session saved; app navigates to home
- Logout -> session cleared (optionally keep user profile depending on settings)

### Bookings + Payments
- Start booking from listing detail
- Confirm price and proceed to payment (Stripe)
- On success: booking saved to DB, rewards updated, email sent to user
- Bookings visible under "My Bookings"

### Reviews
- Users can write/edit/delete their own reviews
- Review stats shown on listing detail page

### Maps
- Location tab on listing detail shows a map via MapTiler tiles
- No Google Maps SDK required

## Troubleshooting
- If you see missing imports for flutter_map/latlong2:
```cmd
flutter pub get
flutter clean
flutter run -d emulator-5554
```
- Stripe init errors on Android: ensure the app theme extends AppCompat/MaterialComponents and MainActivity extends FlutterFragmentActivity per flutter_stripe docs.
- SQLite schema errors: uninstall the app (to clear the old DB) or bump the DB version/migration logic.
- RenderFlex overflow warnings: typically cosmetic; wrap content in Expanded/Flexible/ListView as needed.

## Scripts
- Quick run on Android:
```cmd
run_app.bat
```
- Rebuild helper:
```cmd
rebuild_and_run.bat
```

## Notes
- API keys in source are for development only. Replace them with secure storage or environment variables for production.
- Many guides are included in the repo (STRIPE_*.md, QUICK_START_*.md, etc.).


## License
This project is provided as-is for demonstration purposes. Add your preferred license here.

