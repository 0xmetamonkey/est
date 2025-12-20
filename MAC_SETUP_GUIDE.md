# 🍎 Mac Setup Guide - iOS Build

## ✅ Code Pushed to GitHub!

**Repository:** https://github.com/0xmetamonkey/est
**Branch:** main
**Commit:** Emergency MVP with audio calling

---

## 📋 Mac Setup Steps

### 1. Clone the Repository

```bash
cd ~/Desktop
git clone https://github.com/0xmetamonkey/est.git
cd est
```

### 2. Install Dependencies

```bash
# Install Flutter packages
flutter pub get

# Install iOS pods
cd ios
pod install
cd ..
```

### 3. Open in Xcode

```bash
open ios/Runner.xcworkspace
```

### 4. Configure Signing

In Xcode:
1. Select **Runner** in the project navigator
2. Go to **Signing & Capabilities** tab
3. Select your **Team** (Apple Developer account)
4. Xcode will automatically create a provisioning profile

### 5. Connect iPhone

1. Connect your iPhone via USB
2. Trust the computer on iPhone
3. In Xcode, select your iPhone from the device dropdown

### 6. Build and Run

**Option A: Via Xcode**
- Click the ▶️ Play button in Xcode
- App will build and install on iPhone

**Option B: Via Terminal**
```bash
flutter run -d <device-id>
```

To find device ID:
```bash
flutter devices
```

---

## 🧪 Testing: iPhone + Samsung

### On iPhone (After Build):

1. App opens to Luna's profile
2. Tap **"CALL ME (₹50/min)"**
3. Tap **"YES, PAID"**
4. Enter Agora App ID: `4077f6fd...` (full ID)
5. Channel: `test123`
6. Tap **"INITIATE AUDIO LINK"**
7. **Allow microphone** when iOS asks

### On Samsung Phone:

1. Open the app (already installed)
2. Tap **"CALL ME"** → **"YES, PAID"**
3. Enter **SAME** Agora App ID
4. Channel: `test123`
5. Tap **"INITIATE AUDIO LINK"**

### Expected Result:

- Both show "CONNECTED"
- You can hear each other
- Mic/speaker controls work
- Disconnect works

---

## ⚠️ Important Notes

### Agora App ID

Make sure you're using the correct App ID:
- Get from: https://console.agora.io/
- Project must be in **"Testing Mode: APP ID"** (not Secure mode)
- Same ID on both devices

### iOS Permissions

The app will automatically request:
- Microphone permission
- Make sure to **Allow** when prompted

### Network

- Both devices need internet
- WiFi or mobile data works
- Firewall shouldn't block Agora

---

## 🐛 Troubleshooting

### "No provisioning profile found"
- Sign in to Xcode with Apple ID
- Select your team in Signing & Capabilities
- Xcode will create profile automatically

### "Untrusted Developer"
On iPhone:
- Settings → General → VPN & Device Management
- Trust your developer certificate

### "Build failed"
```bash
# Clean and rebuild
flutter clean
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

### "Cannot connect to channel"
- Check App ID is correct
- Check channel name matches exactly
- Check internet connection
- Check Agora project is in Testing Mode

---

## 📱 After Testing

### If Everything Works:

You're ready for Play Store (Android) and App Store (iOS)!

### Next Steps:

1. **Update Profile Info:**
   - Edit `lib/main.dart`
   - Change name, bio, price, UPI ID

2. **Add App Icon:**
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - Android: `android/app/src/main/res/`

3. **Update App Name:**
   - iOS: Xcode → Runner → General → Display Name
   - Android: `android/app/src/main/AndroidManifest.xml`

4. **Build Release:**
   ```bash
   # iOS
   flutter build ios --release
   
   # Android
   flutter build apk --release
   ```

---

## 📊 What's in the Code

### Main Features:
- Direct launch to profile screen (no login)
- Manual payment confirmation dialog
- Audio calling via Agora
- Mic/Speaker controls
- Retro anime UI

### Key Files:
- `lib/main.dart` - App entry point
- `lib/screens/retro_profile_screen.dart` - Profile with payment
- `lib/screens/audio_call_screen.dart` - Audio calling
- `lib/screens/dashboard_screen.dart` - Original dashboard (not used in MVP)

### Documentation:
- `FINAL_STATUS.md` - Complete summary
- `TESTING_GUIDE.md` - How to test
- `TROUBLESHOOTING.md` - Common issues
- `WEB_LIMITATION.md` - Why web doesn't work

---

## ✅ Quick Checklist

- [ ] Clone repo on Mac
- [ ] Run `flutter pub get`
- [ ] Run `cd ios && pod install`
- [ ] Open in Xcode
- [ ] Configure signing
- [ ] Connect iPhone
- [ ] Build and run
- [ ] Get Agora App ID
- [ ] Test call: iPhone ↔ Samsung
- [ ] Verify audio works both ways
- [ ] Test mic/speaker controls

---

**Repository:** https://github.com/0xmetamonkey/est
**Ready to build!** 🚀
