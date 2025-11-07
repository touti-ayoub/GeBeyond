# GoBeyond Travel - Quick Start Guide

## 🚀 Project Setup

### Step 1: Install Dependencies

```bash
cd c:\Users\Ayoub\Desktop\gobeyond
flutter pub get
```

### Step 2: Verify Installation

```bash
flutter doctor
```

Make sure all required components are installed.

### Step 3: Run the Application

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For a specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

---

## 📱 Testing Database Operations

### Example: Create and Retrieve a Booking

```dart
import 'package:gobeyond/core/database/database_helper.dart';
import 'package:gobeyond/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:gobeyond/features/booking/data/models/booking_model.dart';
import 'package:gobeyond/features/booking/domain/entities/booking.dart';

void main() async {
  // Initialize database
  final dbHelper = DatabaseHelper.instance;
  final dataSource = BookingLocalDataSource(dbHelper);

  // Create a booking
  final booking = BookingModel(
    userId: 1,
    listingId: 1,
    checkIn: DateTime.now().add(Duration(days: 7)),
    checkOut: DateTime.now().add(Duration(days: 10)),
    guests: 2,
    totalPrice: 450.00,
    bookingReference: 'BK-2025-001',
    createdAt: DateTime.now(),
  );

  final savedBooking = await dataSource.createBooking(booking);
  print('Booking created with ID: ${savedBooking.id}');

  // Retrieve bookings
  final userBookings = await dataSource.getUserBookings(1);
  print('User has ${userBookings.length} bookings');
}
```

---

## 🧪 Running Tests

### Unit Tests

```bash
flutter test test/unit/
```

### Widget Tests

```bash
flutter test test/widget/
```

### Integration Tests

```bash
flutter test integration_test/
```

### Test Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 🏗️ Building for Production

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

---

## 🔧 Development Tips

### Hot Reload
Press `r` in terminal while app is running for hot reload.

### Hot Restart
Press `R` in terminal for hot restart.

### Debug Mode
Use VS Code or Android Studio debugger:
```bash
flutter run --debug
```

### Performance Profiling
```bash
flutter run --profile
```

---

## 📂 Adding New Features

### 1. Create Feature Module

```bash
mkdir -p lib/features/your_feature/data/models
mkdir -p lib/features/your_feature/data/datasources
mkdir -p lib/features/your_feature/data/repositories
mkdir -p lib/features/your_feature/domain/entities
mkdir -p lib/features/your_feature/domain/repositories
mkdir -p lib/features/your_feature/domain/usecases
mkdir -p lib/features/your_feature/presentation/screens
mkdir -p lib/features/your_feature/presentation/widgets
mkdir -p lib/features/your_feature/presentation/providers
```

### 2. Create Database Table

Edit `lib/core/database/database_helper.dart` and add your table creation in `_onCreate`:

```dart
await db.execute('''
  CREATE TABLE your_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    created_at INTEGER NOT NULL
  )
''');
```

### 3. Create Entity

```dart
// lib/features/your_feature/domain/entities/your_entity.dart
class YourEntity extends Equatable {
  final int? id;
  final String name;
  final DateTime createdAt;

  const YourEntity({this.id, required this.name, required this.createdAt});

  @override
  List<Object?> get props => [id, name, createdAt];
}
```

### 4. Create Model

```dart
// lib/features/your_feature/data/models/your_model.dart
class YourModel extends YourEntity {
  const YourModel({super.id, required super.name, required super.createdAt});

  factory YourModel.fromMap(Map<String, dynamic> map) {
    return YourModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
```

### 5. Create Data Source (DAO)

```dart
// lib/features/your_feature/data/datasources/your_local_datasource.dart
class YourLocalDataSource {
  final DatabaseHelper _dbHelper;
  YourLocalDataSource(this._dbHelper);

  Future<YourModel> create(YourModel model) async {
    final db = await _dbHelper.database;
    final id = await db.insert('your_table', model.toMap());
    return model.copyWith(id: id);
  }

  Future<List<YourModel>> getAll() async {
    final db = await _dbHelper.database;
    final results = await db.query('your_table');
    return results.map((map) => YourModel.fromMap(map)).toList();
  }
}
```

### 6. Create Repository

```dart
// lib/features/your_feature/domain/repositories/your_repository.dart
abstract class YourRepository {
  Future<Either<Failure, YourEntity>> create(YourEntity entity);
  Future<Either<Failure, List<YourEntity>>> getAll();
}

// lib/features/your_feature/data/repositories/your_repository_impl.dart
class YourRepositoryImpl implements YourRepository {
  final YourLocalDataSource localDataSource;

  YourRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, YourEntity>> create(YourEntity entity) async {
    try {
      final model = YourModel.fromEntity(entity);
      final result = await localDataSource.create(model);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
```

### 7. Create Providers

```dart
// lib/features/your_feature/presentation/providers/your_provider.dart
final yourDataSourceProvider = Provider<YourLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return YourLocalDataSource(dbHelper);
});

final yourRepositoryProvider = Provider<YourRepository>((ref) {
  final dataSource = ref.watch(yourDataSourceProvider);
  return YourRepositoryImpl(localDataSource: dataSource);
});

final yourListProvider = FutureProvider<List<YourEntity>>((ref) async {
  final repository = ref.watch(yourRepositoryProvider);
  final result = await repository.getAll();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (entities) => entities,
  );
});
```

### 8. Create UI Screen

```dart
// lib/features/your_feature/presentation/screens/your_screen.dart
class YourScreen extends ConsumerWidget {
  const YourScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(yourListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Feature')),
      body: itemsAsync.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(title: Text(item.name));
          },
        ),
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }
}
```

---

## 🐛 Common Issues & Solutions

### Issue: Database locked error

**Solution**: Make sure you're not opening multiple database connections. Use the singleton pattern provided in `DatabaseHelper`.

### Issue: Missing dependencies

**Solution**: Run `flutter pub get` and restart the app.

### Issue: Hot reload not working

**Solution**: Try hot restart (`R` in terminal) or full app restart.

### Issue: Build errors after adding dependencies

**Solution**: 
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📊 Database Management

### View Database Contents

Use a SQLite viewer tool:
- **DB Browser for SQLite** (Desktop)
- **Android Studio Database Inspector** (Android)
- **VS Code SQLite extension**

### Database Location

**Android**: 
```
/data/data/com.example.gobeyond/databases/travel_booking.db
```

**iOS**: 
```
~/Library/Developer/CoreSimulator/Devices/<device-id>/data/Containers/Data/Application/<app-id>/Documents/travel_booking.db
```

### Reset Database

```dart
// For development/testing only
await DatabaseHelper.instance.deleteDatabase();
```

---

## 🎨 Customizing Theme

Edit `lib/app/themes.dart`:

```dart
static const Color primaryColor = Color(0xFF2196F3); // Change this
static const Color secondaryColor = Color(0xFFFF9800); // Change this
```

---

## 📱 Device Testing

### Test on Physical Device

1. Enable developer mode on your device
2. Connect via USB
3. Run: `flutter devices`
4. Run: `flutter run -d <device-id>`

### Test on Emulator

```bash
# List emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator-id>

# Run on emulator
flutter run
```

---

## 📖 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## 🤝 Need Help?

If you encounter any issues:
1. Check the error message carefully
2. Review the architecture documentation
3. Ensure all dependencies are installed
4. Try `flutter clean && flutter pub get`

---

**Happy Coding! 🚀**
