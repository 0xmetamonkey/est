# 🧪 Testing Guide: Phone + Browser Call

## Setup Complete! ✅

- **Samsung Phone:** App installed and ready
- **Chrome Browser:** App running now

## 📋 Step-by-Step Testing

### Step 1: Get Agora App ID (2 minutes)

1. Open https://console.agora.io/ in a new tab
2. Sign up or log in
3. Click "Create Project"
4. Name: "EST Test"
5. Authentication: **"Testing Mode: APP ID"**
6. **Copy the App ID** (looks like: `abc123def456...`)

### Step 2: Start Call on Phone

**On Your Samsung Phone:**

1. Open the "est" app (should already be open)
2. You'll see Luna's profile
3. Tap **"CALL ME (₹50/min)"**
4. Dialog appears → Tap **"YES, PAID"** (skip payment for testing)
5. You're now on the **Audio Call Screen**
6. **Enter:**
   - **APP ID:** Paste your Agora App ID
   - **CHANNEL NAME:** `test123`
7. Tap **"INITIATE AUDIO LINK"**
8. Wait for "CONNECTED" status

### Step 3: Join Call on Browser

**In Your Chrome Browser:**

1. You should see Luna's profile
2. Click **"CALL ME (₹50/min)"**
3. Click **"YES, PAID"**
4. You're now on the **Audio Call Screen**
5. **Enter:**
   - **APP ID:** Same Agora App ID (paste it)
   - **CHANNEL NAME:** `test123` (MUST MATCH!)
6. Click **"INITIATE AUDIO LINK"**
7. **Allow microphone** when browser asks
8. Wait for "CONNECTED" status

### Step 4: Test the Call! 🎉

Once both show "CONNECTED":

- **Speak into your phone** → Should hear in browser
- **Speak into your computer mic** → Should hear on phone
- **Test controls:**
  - Tap mic button to mute/unmute
  - Tap speaker button (phone only)
  - Tap disconnect to end call

---

## 🐛 Troubleshooting

### "Waiting for remote..."
- Make sure **both devices** use the **SAME App ID**
- Make sure **both devices** use the **SAME channel name** (`test123`)
- Check internet connection

### No audio on browser
- Click the 🔒 lock icon in address bar
- Check microphone permissions
- Try refreshing and allowing permissions

### No audio on phone
- Check phone volume
- Try toggling speaker mode
- Check microphone permissions in phone settings

### "Please enter an App ID"
- Make sure you pasted the App ID correctly
- No spaces before/after
- Get it from console.agora.io

---

## ✅ Success Checklist

- [ ] Agora App ID obtained
- [ ] Phone shows profile screen
- [ ] Browser shows profile screen
- [ ] Both can navigate to call screen
- [ ] Both entered same App ID
- [ ] Both entered same channel name
- [ ] Both show "CONNECTED"
- [ ] Can hear audio both ways
- [ ] Mic mute works
- [ ] Disconnect works

---

## 🎯 What You're Testing

1. **Profile Screen** → Payment flow → Call screen navigation ✅
2. **Audio calling** between phone and browser ✅
3. **Controls** (mic, speaker, disconnect) ✅
4. **Cross-platform** compatibility ✅

---

## 📝 Notes

- **Channel name must match exactly** (case-sensitive)
- **App ID must be the same** on both devices
- **Internet required** for both devices
- **Microphone permissions** needed on both
- First connection might take 5-10 seconds

---

**Current Status:**
- ✅ Phone: App installed
- ✅ Browser: App running in Chrome
- 🎯 Next: Get Agora App ID and test!

**Agora Console:** https://console.agora.io/
