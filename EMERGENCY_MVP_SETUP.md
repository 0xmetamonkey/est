# Emergency MVP - Quick Setup Guide

## ✅ What's Changed

The app now launches **directly into a public profile screen** with UPI payment integration!

### Flow:
```
App Launch → Profile Screen → [CALL ME Button] → GPay Payment → Audio Call Screen
```

## 🚀 Quick Setup (2 Minutes)

### Step 1: Add Your UPI ID

Open `lib/main.dart` and replace `"yourupiid@paytm"` with your actual UPI ID:

```dart
home: const RetroProfileScreen(
  name: "Luna",
  bio: "Available for voice calls 💖",
  pricePerMinute: 50.0,
  upiId: "YOUR_ACTUAL_UPI_ID@paytm", // ← CHANGE THIS
),
```

### Step 2: Customize Profile (Optional)

You can change:
- **name**: Display name on profile
- **bio**: Short description
- **pricePerMinute**: Price per minute in ₹

### Step 3: Build APK

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 How It Works

1. **User opens app** → Sees your profile immediately
2. **User taps "CALL ME (₹50/min)"** → GPay opens
3. **User completes payment** → Automatically navigates to audio call screen
4. **User enters Agora details** → Starts call

## ⚠️ Important Notes

### UPI Payment
- Only works on **Android devices** with GPay installed
- Won't work on emulators or web
- Test with a real phone

### Audio Call
- Requires **Agora App ID** (get from console.agora.io)
- User needs to enter App ID and channel name
- Both caller and receiver need same channel name

## 🧪 Testing Checklist

- [ ] Replace UPI ID in main.dart
- [ ] Build APK
- [ ] Install on Android phone
- [ ] Tap "CALL ME" button
- [ ] Verify GPay opens
- [ ] Complete test payment (₹1 for testing)
- [ ] Verify navigation to call screen
- [ ] Enter Agora App ID
- [ ] Test call with another device

## 🎯 What's Removed (For MVP)

- ❌ Login/Authentication
- ❌ Marketplace/Browse
- ❌ Chat
- ❌ Firebase
- ❌ Multiple profiles

## 📦 What's Included

- ✅ Single public profile
- ✅ UPI payment (GPay)
- ✅ Audio calling (Agora)
- ✅ Retro anime design
- ✅ Simple navigation

## 🔧 Troubleshooting

### "Payment failed"
- Check UPI ID is correct
- Ensure GPay is installed
- Try with different amount

### "App crashes on launch"
- Run `flutter clean && flutter pub get`
- Rebuild APK

### "Call doesn't connect"
- Get Agora App ID from console.agora.io
- Ensure both devices use same channel name
- Check internet connection

## 🚀 Ready for Play Store?

### Before Publishing:

1. **Update UPI ID** in main.dart
2. **Test payment flow** thoroughly
3. **Update app name** in AndroidManifest.xml
4. **Add app icon** (replace default)
5. **Update version** in pubspec.yaml
6. **Build release APK**
7. **Test on multiple devices**

### Play Store Requirements:

- Privacy policy URL
- App screenshots
- Feature graphic
- Short & full description
- Content rating

---

**Current Status:** ✅ Emergency MVP Ready!
**Next Step:** Add your UPI ID and build APK
