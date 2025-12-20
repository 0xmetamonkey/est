# 🔧 Connection Troubleshooting

## Issue: Stuck on "CONNECTING..."

I've just updated the code with better Agora initialization. Here's what to check:

### ✅ Checklist:

1. **App ID is Correct**
   - Must be from console.agora.io
   - No spaces before/after
   - Same on BOTH devices

2. **Channel Name Matches EXACTLY**
   - Case-sensitive: `test123` ≠ `Test123`
   - Same on BOTH devices
   - Try simple names: `test` or `test123`

3. **Agora Project Settings**
   - Go to console.agora.io
   - Click your project
   - **Authentication:** Must be "Testing Mode: APP ID" (NOT Secure mode)
   - If it's in Secure mode, create a new project

4. **Internet Connection**
   - Both devices need internet
   - Try switching WiFi/mobile data

5. **Browser Permissions (Chrome)**
   - Click 🔒 lock icon in address bar
   - Check microphone is "Allow"
   - If blocked, change to "Allow" and refresh

6. **Phone Permissions**
   - Go to Settings → Apps → est
   - Check Microphone permission is enabled

### 🔄 Fresh Start Steps:

**On Browser:**
1. Refresh the page (F5)
2. Click "CALL ME" → "YES, PAID"
3. Enter App ID
4. Enter channel: `test123`
5. Click "INITIATE AUDIO LINK"
6. **Allow microphone** when asked

**On Phone:**
1. Close and reopen the app
2. Tap "CALL ME" → "YES, PAID"
3. Enter **SAME** App ID
4. Enter **SAME** channel: `test123`
5. Tap "INITIATE AUDIO LINK"

### 📊 Debug Info:

The app now prints debug messages. Check the terminal/console for:

✅ **Good signs:**
```
✅ Local user 123 joined channel test123
✅ Remote user 456 joined
```

❌ **Bad signs:**
```
❌ Agora Error: ...
🔄 Connection state: Failed
```

### 🎯 Most Common Issues:

1. **Different App IDs** → Both must use EXACT same ID
2. **Different channel names** → Must match exactly
3. **Secure mode project** → Must be "Testing Mode"
4. **No microphone permission** → Allow in browser/phone settings
5. **Firewall blocking** → Try different network

### 🆘 Quick Test:

Try this simple test:
- App ID: Get from console.agora.io
- Channel: `test`
- Both devices: Enter EXACTLY the same values

If still stuck, check the browser console (F12) for error messages.

---

**Updated:** Just improved the Agora initialization code. Restart both devices and try again!
