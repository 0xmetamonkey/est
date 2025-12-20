# EST - Emergency MVP

A Flutter app with direct profile launch, payment confirmation, and audio calling.

## 🚀 Quick Start

### On Mac (for iOS):
See [MAC_SETUP_GUIDE.md](MAC_SETUP_GUIDE.md)

### On Windows (for Android):
App is already built! APK available at:
`build/app/outputs/flutter-apk/app-release.apk` (199.9MB)

## 📱 Features

- **Direct Profile Launch** - No login required
- **Payment Confirmation** - Manual dialog for MVP
- **Audio Calling** - Powered by Agora RTC
- **Retro Anime UI** - Custom pixel art design

## 🧪 Testing

### Requirements:
- Agora App ID (get from [console.agora.io](https://console.agora.io/))
- 2 devices (Android/iOS)

### Steps:
1. Install app on both devices
2. Both tap "CALL ME" → "YES, PAID"
3. Enter **same** Agora App ID
4. Enter **same** channel name (e.g., `test123`)
5. Tap "INITIATE AUDIO LINK"
6. Allow microphone permissions
7. Should connect and hear each other!

## 📚 Documentation

- [FINAL_STATUS.md](FINAL_STATUS.md) - Complete project summary
- [MAC_SETUP_GUIDE.md](MAC_SETUP_GUIDE.md) - iOS build instructions
- [TESTING_GUIDE.md](TESTING_GUIDE.md) - How to test
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues
- [WEB_LIMITATION.md](WEB_LIMITATION.md) - Why web doesn't work

## 🛠️ Tech Stack

- **Flutter** - Cross-platform framework
- **Agora RTC Engine** - Audio calling
- **Dart** - Programming language

## ⚠️ Known Limitations

- **Web not supported** - Agora SDK limitation
- **Manual payment** - UPI integration removed for MVP
- **Single profile** - Hardcoded in `lib/main.dart`

## 📦 Project Structure

```
lib/
├── main.dart                          # App entry point
├── screens/
│   ├── retro_profile_screen.dart     # Profile + payment
│   ├── audio_call_screen.dart        # Audio calling
│   └── dashboard_screen.dart         # Original (not used in MVP)
└── widgets/
    ├── retro_background.dart         # Background widget
    └── retro_button.dart             # Button widget
```

## 🔧 Setup

```bash
# Clone
git clone https://github.com/0xmetamonkey/est.git
cd est

# Install dependencies
flutter pub get

# Run on connected device
flutter run
```

## 📝 Customization

Edit `lib/main.dart` to customize:
- Profile name
- Bio
- Price per minute
- UPI ID

## 🚀 Build

### Android:
```bash
flutter build apk --release
```

### iOS (requires Mac):
```bash
flutter build ios --release
```

## 📄 License

Private project

## 👥 Contributors

- 0xmetamonkey

---

**Status:** ✅ Emergency MVP Complete  
**Last Updated:** 2025-12-20
