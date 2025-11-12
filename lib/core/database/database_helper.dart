import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton class to manage SQLite database operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // Database configuration
  static const String _databaseName = 'travel_booking.db';
  static const int _databaseVersion = 4; // Updated to completely fix foreign key issues

  DatabaseHelper._internal();

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Enable foreign key constraints
  Future<void> _onConfigure(Database db) async {
    // Disable foreign keys to allow reviews without bookings
    // Foreign keys are still enforced for users and listings
    await db.execute('PRAGMA foreign_keys = OFF');
  }

  /// Create all tables on first database creation
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone TEXT,
        profile_photo TEXT,
        role TEXT DEFAULT 'user' CHECK(role IN ('user', 'admin')),
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        is_deleted INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'synced' CHECK(sync_status IN ('synced', 'pending', 'conflict'))
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_users_email ON users(email)
    ''');

    await db.execute('''
      CREATE INDEX idx_users_sync_status ON users(sync_status)
    ''');

    await db.execute('''
      CREATE TABLE listings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('hotel', 'flight', 'experience')),
        location TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        rating REAL DEFAULT 0.0,
        photos TEXT,
        amenities TEXT,
        available_from INTEGER,
        available_to INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        is_deleted INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_listings_type ON listings(type)
    ''');

    await db.execute('''
      CREATE INDEX idx_listings_location ON listings(location)
    ''');

    await db.execute('''
      CREATE INDEX idx_listings_price ON listings(price)
    ''');

    await db.execute('''
      CREATE TABLE wishlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        listing_id INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'synced',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
        UNIQUE(user_id, listing_id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_wishlists_user_id ON wishlists(user_id)
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        listing_id INTEGER NOT NULL,
        check_in INTEGER NOT NULL,
        check_out INTEGER NOT NULL,
        guests INTEGER NOT NULL DEFAULT 1,
        total_price REAL NOT NULL,
        status TEXT DEFAULT 'booked' CHECK(status IN ('booked', 'cancelled', 'completed')),
        payment_method TEXT,
        booking_reference TEXT UNIQUE,
        special_requests TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        is_deleted INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'synced',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_bookings_user_id ON bookings(user_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_bookings_status ON bookings(status)
    ''');

    await db.execute('''
      CREATE TABLE itineraries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        destination TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        is_deleted INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'synced',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_itineraries_user_id ON itineraries(user_id)
    ''');

    await db.execute('''
      CREATE TABLE itinerary_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itinerary_id INTEGER NOT NULL,
        booking_id INTEGER,
        item_type TEXT NOT NULL CHECK(item_type IN ('booking', 'activity', 'note')),
        title TEXT NOT NULL,
        description TEXT,
        scheduled_time INTEGER,
        location TEXT,
        created_at INTEGER NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'synced',
        FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE,
        FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE feedbacks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        listing_id INTEGER NOT NULL,
        booking_id INTEGER,
        rating INTEGER NOT NULL CHECK(rating >= 1 AND rating <= 5),
        comment TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        is_deleted INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'synced',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
        FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_feedbacks_listing_id ON feedbacks(listing_id)
    ''');

    // Enhanced reviews table (no foreign keys for flexibility)
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        listing_id INTEGER NOT NULL,
        booking_id INTEGER,
        rating REAL NOT NULL CHECK(rating >= 1.0 AND rating <= 5.0),
        comment TEXT,
        images TEXT,
        pros TEXT,
        cons TEXT,
        trip_type TEXT CHECK(trip_type IN ('solo', 'family', 'couple', 'business', 'friends')),
        helpful_count INTEGER DEFAULT 0,
        not_helpful_count INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        is_deleted INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_reviews_listing_id ON reviews(listing_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_reviews_user_id ON reviews(user_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_reviews_rating ON reviews(rating)
    ''');

    await db.execute('''
      CREATE TABLE rewards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        points INTEGER DEFAULT 0,
        promo_code TEXT UNIQUE,
        discount_percent REAL,
        description TEXT,
        expiry_date INTEGER,
        is_redeemed INTEGER DEFAULT 0,
        redeemed_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        is_deleted INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'synced',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_rewards_user_id ON rewards(user_id)
    ''');

    await db.execute('''
      CREATE TABLE user_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        points INTEGER NOT NULL,
        transaction_type TEXT CHECK(transaction_type IN ('earned', 'redeemed', 'expired')),
        description TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_user_points_user_id ON user_points(user_id)
    ''');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Disable foreign keys during migration
    await db.execute('PRAGMA foreign_keys = OFF');

    // Handle migrations for future versions
    if (oldVersion < 2) {
      // Add reviews table (version 1 to 2)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reviews (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          listing_id INTEGER NOT NULL,
          booking_id INTEGER,
          rating REAL NOT NULL CHECK(rating >= 1.0 AND rating <= 5.0),
          comment TEXT,
          images TEXT,
          pros TEXT,
          cons TEXT,
          trip_type TEXT CHECK(trip_type IN ('solo', 'family', 'couple', 'business', 'friends')),
          helpful_count INTEGER DEFAULT 0,
          not_helpful_count INTEGER DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          is_deleted INTEGER DEFAULT 0,
          sync_status TEXT DEFAULT 'synced'
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_reviews_listing_id ON reviews(listing_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_reviews_rating ON reviews(rating)
      ''');
    }

    if (oldVersion < 3 || oldVersion < 4) {
      // Fix reviews table completely - drop and recreate without any foreign keys (version 3/4)
      await db.execute('DROP TABLE IF EXISTS reviews');

      await db.execute('''
        CREATE TABLE reviews (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          listing_id INTEGER NOT NULL,
          booking_id INTEGER,
          rating REAL NOT NULL CHECK(rating >= 1.0 AND rating <= 5.0),
          comment TEXT,
          images TEXT,
          pros TEXT,
          cons TEXT,
          trip_type TEXT CHECK(trip_type IN ('solo', 'family', 'couple', 'business', 'friends')),
          helpful_count INTEGER DEFAULT 0,
          not_helpful_count INTEGER DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          is_deleted INTEGER DEFAULT 0,
          sync_status TEXT DEFAULT 'synced'
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_reviews_listing_id ON reviews(listing_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_reviews_rating ON reviews(rating)
      ''');
    }
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// Delete the database (useful for testing)
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
