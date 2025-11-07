# 📚 SQLite Explained - Your App's Database

## ✅ Yes, SQLite IS Normal SQL!

SQLite is a **real SQL database** with tables, rows, and columns - just like MySQL or PostgreSQL!

### The Key Difference:
- **MySQL/PostgreSQL**: Runs on a separate server (client-server model)
- **SQLite**: Runs inside your app (embedded database)

```
Traditional Database:          SQLite:
┌─────────────┐               ┌─────────────┐
│  Your App   │──────────────>│  Your App   │
└─────────────┘               │  ┌────────┐ │
      ↓                       │  │SQLite  │ │
      ↓                       │  │Database│ │
┌─────────────┐               │  └────────┘ │
│MySQL Server │               └─────────────┘
│ (Separate)  │               (All in one!)
└─────────────┘
```

---

## 🗄️ Your App's Database Structure

### Database File
**Name**: `travel_booking.db`
**Location**: Your device's app data folder
**Contains**: All your app data in 9 tables

---

## 📋 The 9 Tables in Your Database

### 1️⃣ **users** - User Accounts
Stores user information and login credentials.

```sql
CREATE TABLE users (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  name             TEXT NOT NULL,
  email            TEXT UNIQUE NOT NULL,
  password         TEXT NOT NULL,
  phone            TEXT,
  profile_photo    TEXT,
  role             TEXT DEFAULT 'user',
  created_at       INTEGER NOT NULL,
  is_deleted       INTEGER DEFAULT 0
)
```

**Example Data:**
| id | name | email | phone | role |
|----|------|-------|-------|------|
| 1 | Sarah Johnson | sarah@email.com | +1 555-123-4567 | user |
| 2 | John Doe | john@email.com | +1 555-987-6543 | user |

---

### 2️⃣ **listings** - Hotels, Flights, Activities
All the travel options users can browse and book.

```sql
CREATE TABLE listings (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  title         TEXT NOT NULL,
  type          TEXT NOT NULL,  -- 'hotel', 'flight', 'experience'
  location      TEXT NOT NULL,
  price         REAL NOT NULL,
  description   TEXT,
  rating        REAL DEFAULT 0.0,
  photos        TEXT,
  amenities     TEXT
)
```

**Example Data:**
| id | title | type | location | price | rating |
|----|-------|------|----------|-------|--------|
| 1 | Luxury Beach Resort | hotel | Maldives | 450.00 | 4.8 |
| 2 | Paris Flight | flight | Paris | 599.00 | 4.5 |
| 3 | Scuba Diving | experience | Hawaii | 250.00 | 4.9 |

---

### 3️⃣ **bookings** - User Reservations
**THIS IS WHERE YOUR BOOKINGS ARE STORED!**

```sql
CREATE TABLE bookings (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id           INTEGER NOT NULL,
  listing_id        INTEGER NOT NULL,
  check_in          INTEGER NOT NULL,  -- Date in milliseconds
  check_out         INTEGER NOT NULL,
  guests            INTEGER NOT NULL,
  total_price       REAL NOT NULL,
  status            TEXT DEFAULT 'booked',  -- 'booked', 'cancelled', 'completed'
  booking_reference TEXT UNIQUE,
  created_at        INTEGER NOT NULL
)
```

**Example Data:**
| id | user_id | listing_id | check_in | check_out | guests | total_price | status |
|----|---------|------------|----------|-----------|--------|-------------|--------|
| 1 | 1 | 1 | 1735689600000 | 1736121600000 | 2 | 2700.00 | booked |
| 2 | 1 | 3 | 1735603200000 | 1735603200000 | 1 | 250.00 | completed |

**When you make a booking:**
```dart
// This happens automatically:
await db.insert('bookings', {
  'user_id': 1,
  'listing_id': 5,
  'check_in': checkInDate.millisecondsSinceEpoch,
  'check_out': checkOutDate.millisecondsSinceEpoch,
  'guests': 2,
  'total_price': 1200.00,
  'status': 'booked',
  'created_at': DateTime.now().millisecondsSinceEpoch,
});
```

---

### 4️⃣ **wishlists** - Favorite Listings
When you tap the ❤️ icon on a listing.

```sql
CREATE TABLE wishlists (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id     INTEGER NOT NULL,
  listing_id  INTEGER NOT NULL,
  created_at  INTEGER NOT NULL
)
```

**Example Data:**
| id | user_id | listing_id | created_at |
|----|---------|------------|------------|
| 1 | 1 | 1 | 1699315200000 |
| 2 | 1 | 8 | 1699315200000 |

---

### 5️⃣ **itineraries** - Trip Plans
Your travel itineraries created in the Itinerary screen.

```sql
CREATE TABLE itineraries (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id      INTEGER NOT NULL,
  title        TEXT NOT NULL,
  start_date   INTEGER NOT NULL,
  end_date     INTEGER NOT NULL,
  destination  TEXT,
  notes        TEXT,
  created_at   INTEGER NOT NULL
)
```

**Example Data:**
| id | user_id | title | start_date | end_date | destination |
|----|---------|-------|------------|----------|-------------|
| 1 | 1 | Summer Vacation | 1720224000000 | 1720828800000 | Paris, France |
| 2 | 1 | Weekend Getaway | 1720396800000 | 1720569600000 | Miami Beach |

---

### 6️⃣ **itinerary_items** - Activities in Trips
Individual activities, notes, bookings within an itinerary.

```sql
CREATE TABLE itinerary_items (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  itinerary_id    INTEGER NOT NULL,
  booking_id      INTEGER,  -- Optional link to booking
  item_type       TEXT NOT NULL,  -- 'booking', 'activity', 'note'
  title           TEXT NOT NULL,
  description     TEXT,
  scheduled_time  INTEGER,
  location        TEXT
)
```

---

### 7️⃣ **rewards** - Loyalty Points & Promo Codes
**THIS IS WHERE YOUR POINTS ARE STORED!**

```sql
CREATE TABLE rewards (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id           INTEGER NOT NULL,
  points            INTEGER DEFAULT 0,
  promo_code        TEXT UNIQUE,
  discount_percent  REAL,
  description       TEXT,
  expiry_date       INTEGER,
  is_redeemed       INTEGER DEFAULT 0,
  redeemed_at       INTEGER,
  created_at        INTEGER NOT NULL
)
```

**Example Data:**
| id | user_id | points | promo_code | discount_percent | description | is_redeemed |
|----|---------|--------|------------|------------------|-------------|-------------|
| 1 | 1 | 50 | NULL | NULL | Welcome bonus | 0 |
| 2 | 1 | 125 | NULL | NULL | Booking reward | 0 |
| 3 | 1 | 0 | SUMMER2024 | 15 | 15% off promo | 0 |

**When you make a $500 booking:**
```dart
// This row gets added automatically:
await db.insert('rewards', {
  'user_id': 1,
  'points': 50,  // 1 point per $10
  'description': 'Earned from booking (\$500.00)',
  'created_at': DateTime.now().millisecondsSinceEpoch,
});
```

---

### 8️⃣ **feedbacks** - Reviews & Ratings
User reviews for listings.

```sql
CREATE TABLE feedbacks (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id     INTEGER NOT NULL,
  listing_id  INTEGER NOT NULL,
  booking_id  INTEGER,
  rating      INTEGER NOT NULL,  -- 1 to 5 stars
  comment     TEXT,
  created_at  INTEGER NOT NULL
)
```

---

### 9️⃣ **user_points** - Points Transaction History
Log of all point earning/spending activity.

```sql
CREATE TABLE user_points (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id           INTEGER NOT NULL,
  points            INTEGER NOT NULL,
  transaction_type  TEXT,  -- 'earned', 'redeemed', 'expired'
  description       TEXT,
  created_at        INTEGER NOT NULL
)
```

---

## 🔗 How Tables Connect (Relationships)

```
users (1)──────────(many) bookings
  │                         │
  │                         │
  │                    (many)│
  └──────────(many) rewards │
  │                         │
  │                    (many)│
  └──────────(many) wishlists
  │
  └──────────(many) itineraries
                        │
                        │
                   (many)│
               itinerary_items
```

**Foreign Keys** ensure data integrity:
- A booking **must have** a valid user_id (can't book without account)
- A wishlist **must have** a valid listing_id (can't favorite non-existent listing)
- If you delete a user, all their bookings/rewards/wishlists are deleted too

---

## 💾 Where is the Data Stored?

### On Android:
```
/data/data/com.yourapp.gobeyond/databases/travel_booking.db
```

### On iOS:
```
/var/mobile/Containers/Data/Application/[UUID]/Documents/travel_booking.db
```

### On Development (Flutter):
When you run `flutter run`, the database is created on your device/emulator.

---

## 🔍 How Your App Uses SQLite

### Example: Making a Booking

**1. User Action:** Tap "Book Now" on a hotel listing

**2. Code Execution:**
```dart
// In BookingService.createBooking()
await db.insert('bookings', {
  'user_id': 1,
  'listing_id': 5,
  'check_in': 1735689600000,
  'check_out': 1736121600000,
  'guests': 2,
  'total_price': 1200.00,
  'status': 'booked',
  'created_at': DateTime.now().millisecondsSinceEpoch,
});
```

**3. SQL Executed:**
```sql
INSERT INTO bookings (user_id, listing_id, check_in, check_out, guests, total_price, status, created_at)
VALUES (1, 5, 1735689600000, 1736121600000, 2, 1200.00, 'booked', 1699315200000);
```

**4. Automatic Points Award:**
```dart
// In RewardsService.awardPointsForBooking()
await db.insert('rewards', {
  'user_id': 1,
  'points': 120,  // $1200 / $10 = 120 points
  'description': 'Earned from booking ($1200.00)',
  'created_at': DateTime.now().millisecondsSinceEpoch,
});
```

**5. SQL Executed:**
```sql
INSERT INTO rewards (user_id, points, description, created_at)
VALUES (1, 120, 'Earned from booking ($1200.00)', 1699315200000);
```

---

## 📊 Viewing Your Database Data

### Example Queries Your App Uses:

**Get all bookings for user:**
```sql
SELECT * FROM bookings 
WHERE user_id = 1 AND is_deleted = 0 
ORDER BY created_at DESC;
```

**Get total points for user:**
```sql
SELECT SUM(points) as total 
FROM rewards 
WHERE user_id = 1 AND is_redeemed = 0 AND is_deleted = 0;
```

**Get upcoming bookings:**
```sql
SELECT * FROM bookings 
WHERE user_id = 1 
  AND check_in > strftime('%s', 'now') * 1000 
  AND status = 'booked';
```

**Get wishlist with listing details:**
```sql
SELECT listings.* 
FROM wishlists 
JOIN listings ON wishlists.listing_id = listings.id 
WHERE wishlists.user_id = 1 AND wishlists.is_deleted = 0;
```

---

## 🆚 SQLite vs SharedPreferences

Your app uses **BOTH**:

### SQLite (Database) - For Complex Data
✅ Used for: Bookings, Rewards, Itineraries, Wishlists
✅ Why: Needs relationships, queries, filtering
✅ Example: "Find all bookings in December with price > $500"

```dart
// Complex query:
final bookings = await db.query(
  'bookings',
  where: 'user_id = ? AND check_in >= ? AND total_price > ?',
  whereArgs: [userId, decemberStart, 500],
);
```

### SharedPreferences - For Simple Settings
✅ Used for: User name, email, simple flags
✅ Why: Quick access, no queries needed
✅ Example: Store user's name

```dart
// Simple storage:
await prefs.setString('user_name', 'Sarah Johnson');
final name = prefs.getString('user_name');
```

---

## 🎯 Summary

### What SQLite Is:
- ✅ A **real SQL database** (tables, queries, relationships)
- ✅ **Embedded** in your app (no separate server)
- ✅ **Perfect for mobile apps** (fast, reliable, no internet needed)

### Your Database Has:
- **9 tables** storing all app data
- **users** → Your account info
- **bookings** → Your reservations ⭐
- **rewards** → Your loyalty points ⭐
- **listings** → Hotels, flights, activities
- **wishlists** → Your favorites
- **itineraries** → Your trip plans
- **feedbacks** → Reviews
- And more...

### When You Make a Booking:
1. Row added to **bookings** table
2. Row added to **rewards** table (points)
3. Both screens read from these tables
4. Data synced across app

**It's just like any SQL database - but living inside your phone!** 📱💾

