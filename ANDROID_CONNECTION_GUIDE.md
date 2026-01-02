# Android Device Connection Guide

## Issue
Your Android phone is connected but not being detected by Flutter/ADB.

## Quick Fix Steps

### 1. Enable USB Debugging (if not already done)
On your Android phone:
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times to enable Developer Options
3. Go back to **Settings** → **System** → **Developer Options**
4. Enable **USB Debugging**

### 2. Check USB Connection Mode
1. When you connect your phone, check the notification
2. Make sure it's set to **File Transfer (MTP)** or **PTP** mode
3. NOT "Charging only"

### 3. Authorize Computer
1. When you connect, a popup should appear on your phone asking to "Allow USB debugging?"
2. Check "Always allow from this computer"
3. Tap **OK**

### 4. Restart ADB Server
Run these commands:
```bash
adb kill-server
adb start-server
adb devices
```

You should see your device listed like:
```
List of devices attached
ABC123XYZ    device
```

### 5. Run the App
Once the device appears:
```bash
flutter run
```

## Alternative: Build APK and Install Manually

If the above doesn't work, you can build an APK and install it:

```bash
# Build the APK
flutter build apk --release

# The APK will be at:
# build/app/outputs/flutter-apk/app-release.apk
```

Then:
1. Copy the APK to your phone
2. Install it manually
3. Open the app

## Troubleshooting

### Phone not showing in `adb devices`?
- Try a different USB cable
- Try a different USB port
- Restart your phone
- Restart your computer
- Check if USB drivers are installed (Windows may need Google USB Driver)

### "Unauthorized" showing in `adb devices`?
- Revoke USB debugging authorizations on phone
- Disconnect and reconnect
- Accept the authorization popup again

### Still not working?
Build the APK and install manually (see above).
