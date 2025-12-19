// Authentication Service
const AuthService = {
    currentUser: null,
    
    // Initialize auth state listener
    init() {
        auth.onAuthStateChanged((user) => {
            this.currentUser = user;
            if (user) {
                console.log('✅ User signed in:', user.email);
            } else {
                console.log('❌ User signed out');
            }
        });
    },
    
    // Sign in with Google
    async signInWithGoogle() {
        try {
            const provider = new firebase.auth.GoogleAuthProvider();
            const result = await auth.signInWithPopup(provider);
            console.log('🎉 Google sign-in successful:', result.user.email);
            return result.user;
        } catch (error) {
            console.error('Google sign-in error:', error);
            alert('Sign-in failed: ' + error.message);
            return null;
        }
    },
    
    // Sign out
    async signOut() {
        try {
            await auth.signOut();
            console.log('👋 User signed out');
            return true;
        } catch (error) {
            console.error('Sign-out error:', error);
            return false;
        }
    },
    
    // Get current user
    getCurrentUser() {
        return this.currentUser;
    },
    
    // Check if user is authenticated
    isAuthenticated() {
        return this.currentUser !== null;
    }
};

// Initialize auth service
AuthService.init();
