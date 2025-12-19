// Firebase Configuration
// IMPORTANT: Replace these values with your actual Firebase project credentials
// Get these from: Firebase Console > Project Settings > Your apps > Web app

const firebaseConfig = {
    apiKey: "AIzaSyBLzTpU-oUhfiCWadYHF25koMZOZ6fVuX0",
    authDomain: "estv01-8a473bce.firebaseapp.com",
    projectId: "estv01-8a473bce",
    storageBucket: "estv01-8a473bce.firebasestorage.app",
    messagingSenderId: "503909518866",
    appId: "1:503909518866:web:YOUR_WEB_APP_ID"  // You may need to add web app in Firebase Console
};

// Initialize Firebase
try {
    firebase.initializeApp(firebaseConfig);
    console.log('🔥 Firebase initialized successfully');
} catch (error) {
    console.error('Firebase initialization error:', error);
}

// Firebase services
const auth = firebase.auth();
const db = firebase.firestore();
