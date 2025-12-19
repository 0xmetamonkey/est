# ED Marketplace - Web Version

A premium native web application with a stunning retro anime aesthetic, connecting creators and admirers through an immersive platform.

## 🎨 Features

- **Retro Anime Aesthetic**: VHS effects, CRT glow, scanlines, and vibrant neon colors
- **Firebase Authentication**: Secure Google Sign-In integration
- **Responsive Design**: Optimized for desktop, tablet, and mobile devices
- **Smooth Animations**: Glitch effects, pulse animations, and smooth transitions
- **Creator Profiles**: Browse and interact with creators
- **Calling Interface**: Retro-styled calling experience

## 🚀 Quick Start

### Prerequisites

- A modern web browser (Chrome, Firefox, Safari, or Edge)
- Firebase project with Authentication enabled

### Setup Instructions

1. **Firebase Configuration**
   
   Open `js/config.js` and replace the placeholder values with your Firebase credentials:
   
   ```javascript
   const firebaseConfig = {
       apiKey: "YOUR_API_KEY_HERE",
       authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
       projectId: "YOUR_PROJECT_ID",
       storageBucket: "YOUR_PROJECT_ID.appspot.com",
       messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
       appId: "YOUR_APP_ID"
   };
   ```
   
   Get these credentials from:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project (or create a new one)
   - Go to Project Settings > Your apps > Web app
   - Copy the configuration values

2. **Enable Google Sign-In**
   
   In Firebase Console:
   - Go to Authentication > Sign-in method
   - Enable "Google" as a sign-in provider
   - Add your domain to authorized domains

3. **Run the Application**
   
   **Option A: Using Python (Recommended)**
   ```bash
   cd web-app
   python -m http.server 8000
   ```
   Then open: http://localhost:8000
   
   **Option B: Using Node.js**
   ```bash
   cd web-app
   npx http-server -p 8000
   ```
   Then open: http://localhost:8000
   
   **Option C: Using VS Code Live Server**
   - Install "Live Server" extension
   - Right-click on `index.html`
   - Select "Open with Live Server"

## 📁 Project Structure

```
web-app/
├── index.html              # Main HTML entry point
├── css/
│   └── styles.css          # Complete retro anime design system
├── js/
│   ├── config.js           # Firebase configuration
│   ├── auth.js             # Authentication service
│   ├── router.js           # Client-side routing
│   ├── app.js              # Main application controller
│   └── screens/
│       ├── landing.js      # Landing screen with ASCII art
│       ├── welcome.js      # Google Sign-In screen
│       ├── dashboard.js    # User dashboard
│       ├── profile.js      # Creator profile view
│       └── calling.js      # Calling interface
└── README.md               # This file
```

## 🎮 Usage

1. **Landing Screen**: Click "ENTER" to proceed
2. **Sign In**: Click "CONTINUE WITH GOOGLE" to authenticate
3. **Dashboard**: View your profile and access features
4. **Browse Creators**: Click "BROWSE CREATORS" to see creator profiles
5. **Interact**: Use "TALK TO ME" or "WRITE TO ME" buttons

## 🎨 Design System

The app uses a retro anime aesthetic with:

- **Colors**: Cyan, Pink, Purple, Green, Amber, Yellow
- **Font**: VT323 (pixel font from Google Fonts)
- **Effects**: VHS noise, CRT glow, scanlines, glitch animations
- **Style**: Neon borders, glassmorphism, smooth transitions

## 🔧 Customization

### Change Colors

Edit CSS variables in `css/styles.css`:

```css
:root {
    --color-cyan: #00ffff;
    --color-pink: #ff69b4;
    /* ... more colors */
}
```

### Add New Screens

1. Create a new file in `js/screens/yourscreen.js`
2. Define a screen object with a `render()` method
3. Add the route in `js/router.js`
4. Import the script in `index.html`

## 🌐 Deployment

### Deploy to Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase Hosting
firebase init hosting

# Deploy
firebase deploy
```

### Deploy to Netlify

1. Drag and drop the `web-app` folder to [Netlify Drop](https://app.netlify.com/drop)
2. Or connect your Git repository for automatic deployments

### Deploy to Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
cd web-app
vercel
```

## 📱 Browser Support

- Chrome/Edge: ✅ Full support
- Firefox: ✅ Full support
- Safari: ✅ Full support
- Mobile browsers: ✅ Responsive design

## 🐛 Troubleshooting

**Firebase errors?**
- Check that you've replaced the config values in `js/config.js`
- Verify Google Sign-In is enabled in Firebase Console
- Check browser console for specific error messages

**Styles not loading?**
- Make sure you're running a local server (not opening `index.html` directly)
- Check that all file paths are correct

**Authentication not working?**
- Verify your domain is authorized in Firebase Console
- Check that popup blockers aren't preventing the Google Sign-In window

## 📄 License

This project is part of the ED Marketplace application.

## 🎉 Enjoy!

Experience the retro anime aesthetic and connect with creators in style! 🌟
