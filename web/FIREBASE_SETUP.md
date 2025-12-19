# Firebase Web Setup Guide

## ✅ Already Configured
- API Key: `AIzaSyBLzTpU-oUhfiCWadYHF25koMZOZ6fVuX0`
- Project ID: `estv01-8a473bce`
- Storage Bucket: `estv01-8a473bce.firebasestorage.app`
- Messaging Sender ID: `503909518866`

## 🔧 Steps to Complete Setup

### Step 1: Add Web App to Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **estv01-8a473bce**
3. Click the **gear icon** (⚙️) next to "Project Overview"
4. Click **Project settings**
5. Scroll down to "Your apps" section
6. Click the **Web icon** (`</>`) to add a web app
7. Enter app nickname: **ED Marketplace Web**
8. ✅ Check "Also set up Firebase Hosting" (optional)
9. Click **Register app**
10. Copy the **App ID** (looks like: `1:503909518866:web:xxxxxxxxxxxxx`)

### Step 2: Update Web App ID

After you get the App ID, update `web/js/config.js`:

```javascript
appId: "1:503909518866:web:YOUR_ACTUAL_WEB_APP_ID"
```

### Step 3: Enable Google Sign-In

1. In Firebase Console, go to **Authentication**
2. Click **Get started** (if first time)
3. Click **Sign-in method** tab
4. Click **Google** provider
5. Click **Enable** toggle
6. Select a support email
7. Click **Save**

### Step 4: Add Authorized Domains

1. Still in **Authentication** → **Settings** tab
2. Scroll to **Authorized domains**
3. Make sure these are listed:
   - `localhost` ✅ (should already be there)
   - Your production domain (when you deploy)

### Step 5: Test Authentication

1. Refresh your web app: http://localhost:8000
2. Click **ENTER**
3. Click **CONTINUE WITH GOOGLE**
4. Sign in with your Google account
5. You should be redirected to the dashboard!

## 🚀 Quick Test (Without Web App ID)

You can try testing now even without the Web App ID. Firebase might work with just the API key for localhost testing.

1. Open http://localhost:8000
2. Click ENTER → CONTINUE WITH GOOGLE
3. If you get an error, complete Step 1 & 2 above

## ⚠️ Common Issues

**"Firebase: Error (auth/invalid-api-key)"**
- Make sure you've enabled Authentication in Firebase Console

**"Firebase: Error (auth/unauthorized-domain)"**
- Add your domain to authorized domains in Firebase Console

**Google Sign-In popup doesn't appear**
- Check browser popup blocker
- Make sure Google provider is enabled in Firebase Console

**"Firebase: Error (auth/configuration-not-found)"**
- You need to add the web app in Firebase Console (Step 1)

## 📝 Next Steps After Setup

Once authentication works:
1. Test the full user flow (login → dashboard → profile → calling)
2. Add real creator data to Firestore
3. Build messaging system
4. Deploy to production
