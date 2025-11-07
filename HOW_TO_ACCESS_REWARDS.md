# ✅ Rewards Screen - Complete Access Guide

## 📍 File Location

**Rewards Screen File:**
```
lib/features/rewards/presentation/screens/rewards_screen.dart
```

## 🎯 How to Access the Rewards Screen in Your App

I've added **TWO ways** to navigate to the Rewards screen from the Profile page:

### ✨ Method 1: Menu Item (NEW!)
1. Open your app
2. Tap the **Profile** tab (bottom navigation)
3. Scroll down to the menu section
4. Tap **"Rewards & Points"** (first menu item with gift icon 🎁)
5. You'll be taken to the Rewards screen!

### ✨ Method 2: Redeem Button
1. Open your app
2. Tap the **Profile** tab
3. Look at the **Member Level Card** (golden gradient card)
4. Tap the **"Redeem"** button in the top-right of the card
5. You'll be taken to the Rewards screen!

## 🔗 Route Configuration

- **Path**: `/profile/rewards`
- **Name**: `rewards`
- **Parent**: Profile screen

## 🎨 What You'll See

When you open the Rewards screen, you'll find:

### 1. Member Level Card (Top)
- **Gradient design** (Bronze/Silver/Gold/Platinum colors)
- Shows your current **membership level**
- **Progress bar** to next level
- Points needed to level up

### 2. Points Summary Card
- **Total Points** you've earned
- **Active Rewards** count
- Clean dashboard layout

### 3. Three Tabs
- **Active**: Rewards you can use right now
- **Redeemed**: History of rewards you've already used
- **Expired**: Past rewards that expired

### 4. Reward Cards
Each reward shows:
- **Type icon** (points = green star, promo code = orange tag)
- **Title** (e.g., "SUMMER2024" or "125 Points")
- **Description** (how you earned it)
- **Status badge** (Active/Redeemed/Expired)
- **Dates** (earned date, expiry date)
- **"Redeem Now" button** for promo codes

## 🎁 Sample Data

On first launch, the app automatically creates:
- ✅ **Welcome Bonus**: 50 points
- ✅ **Booking Reward**: 125 points (from Paris booking)
- ✅ **Booking Reward**: 75 points (from Tokyo booking)
- ✅ **Promo Code**: SUMMER2024 (15% discount, expires in 30 days)

**Total**: 250 points = **Silver Member** status! 🥈

## 🏆 Member Levels

| Level | Points Required | Color |
|-------|----------------|-------|
| Bronze | 0 - 199 | Copper/Brown |
| Silver | 200 - 499 | Silver/Gray |
| Gold | 500 - 999 | Gold/Yellow |
| Platinum | 1000+ | Purple/Violet |

## 📱 Testing the Feature

### Quick Test Steps:
1. **Run the app**: `flutter run`
2. **Navigate to Profile** (tap Profile icon in bottom nav)
3. **Tap "Rewards & Points"** menu item
4. **See the rewards screen** with sample data
5. **Try switching tabs** (Active/Redeemed/Expired)
6. **Tap "Redeem Now"** on the SUMMER2024 promo code
7. **Confirm redemption** in the dialog

### What to Expect:
- ✅ Smooth navigation from Profile → Rewards
- ✅ Beautiful gradient member level card
- ✅ 4 sample rewards visible in Active tab
- ✅ Points total showing: 250
- ✅ Member level showing: Silver
- ✅ Progress bar showing path to Gold (need 250 more points)

## 🔧 Code Changes Made

I updated `profile_screen.dart` to add:

1. **New menu item** (line ~70):
```dart
{
  'icon': Icons.card_giftcard,
  'title': 'Rewards & Points',
  'subtitle': 'View your loyalty rewards',
  'route': '/profile/rewards',
}
```

2. **Navigation handler** (line ~500):
```dart
if (title == 'Rewards & Points') {
  context.push('/profile/rewards');
}
```

3. **Redeem button** (line ~420):
```dart
onPressed: () {
  context.push('/profile/rewards');
}
```

## 🚀 Next Steps

### Award Points for Bookings
When a user completes a booking, add this code:
```dart
import 'package:gobeyond/core/services/rewards_service.dart';

// After successful booking
await RewardsService().awardPointsForBooking(
  userId: 1,
  bookingAmount: totalPrice, // e.g., 1250.00
);
// This will automatically award 125 points (1 point per $10)
```

### Apply Promo Codes
In your booking flow:
```dart
final rewardsService = RewardsService();
await rewardsService.initialize();

// Get active promo codes
final activeRewards = rewardsService.activeRewards
    .where((r) => r.promoCode != null);

// Apply discount
if (selectedPromo != null) {
  final discount = totalPrice * (selectedPromo.discountPercent! / 100);
  final finalPrice = totalPrice - discount;
}
```

## 📖 Full Documentation

For complete technical details, see:
- `ITINERARY_REWARDS_IMPLEMENTATION.md` - Full feature documentation
- `lib/core/services/rewards_service.dart` - Service API
- `lib/features/rewards/domain/entities/reward.dart` - Data models

## ✅ Summary

**The Rewards Screen is now fully accessible!**

Just open your app, go to Profile, and tap either:
- The **"Rewards & Points"** menu item, or
- The **"Redeem"** button on the member card

You'll see a beautiful, fully-functional loyalty rewards dashboard with sample data ready to explore! 🎉

