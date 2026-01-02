# EST - Enjoy Super Time

A calm, intentional self-care app that helps you spend quality time on activities you enjoy.

## 🌟 Concept

Instead of a productivity to-do list, **Enjoy Super Time** helps you create a list of things you genuinely enjoy doing - yoga, sketching, coding, music, walking, etc. Each activity represents "super time" you want to give yourself.

**No pressure. No guilt. No gamification. Just intentional time for yourself.**

---

## 📱 Features

### Onboarding
- Set your daily "super time" goal (15 min, 30 min, 1 hr, or custom)
- Simple, one-time setup
- Stored locally on your device

### Home Screen
- View all your "super time" activities
- Add new activities you enjoy
- Delete activities you no longer want
- Clean, minimal interface

### Timer
- Tap any activity to start your super time
- Simple play/pause timer
- Count-up timer (no countdown pressure)
- Gentle completion message when you're done
- No streaks, no guilt

---

## 🛠️ Tech Stack

- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **shared_preferences** - Local storage
- **Target Platform** - Android (offline-first)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Android device or emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/0xmetamonkey/est.git
cd est

# Install dependencies
flutter pub get

# Run on connected device
flutter run
```

### Build for Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

---

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point & theme
└── screens/
    ├── onboarding_screen.dart         # Daily time selection
    ├── home_screen.dart               # Activity list
    └── timer_screen.dart              # Timer interface
```

---

## 🎨 Design Philosophy

- **Calm** - Soft purple (#9C89B8) and beige (#F7F4F3) color palette
- **Minimal** - Clean interface, no clutter
- **No Gamification** - No streaks, points, or achievements
- **No Pressure** - Count-up timer, gentle messages
- **Intentional** - Focus on enjoyment, not productivity

---

## 💾 Data Storage

All data is stored **locally** on your device using `shared_preferences`:
- Daily super time goal
- List of activities
- No cloud sync
- No accounts
- No analytics

---

## 🔒 Privacy

- **100% offline** - No internet required
- **No tracking** - No analytics or telemetry
- **No accounts** - No login or authentication
- **Local only** - All data stays on your device

---

## 🚫 What's NOT Included (By Design)

- ❌ Accounts / Login
- ❌ Cloud sync
- ❌ Analytics
- ❌ Notifications
- ❌ Social features
- ❌ Payments
- ❌ Streaks or gamification
- ❌ Productivity metrics

---

## 📝 Customization

The app uses a calm purple theme by default. To customize:

1. Open `lib/main.dart`
2. Modify the `ColorScheme` in the `ThemeData`:

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF9C89B8), // Change this color
  brightness: Brightness.light,
),
scaffoldBackgroundColor: const Color(0xFFF7F4F3), // Change background
```

---

## 🧪 Testing

To test the app:

1. **Onboarding**: Select a daily time goal (or set custom)
2. **Add Activities**: Add 2-3 activities you enjoy
3. **Start Timer**: Tap an activity and press play
4. **End Session**: Let timer run for a minute, then end session
5. **Delete Activity**: Swipe or tap X to remove an activity

---

## 📄 License

Private project

---

## 👥 Author

**0xmetamonkey**

---

## 📦 Archive

Previous build (EST Audio Calling MVP) archived at:
`c:\Users\journ\archived-projects\est-audio-mvp-2026-01-02\`

---

**Status:** ✅ MVP Complete  
**Version:** 1.0.0  
**Last Updated:** January 2, 2026
