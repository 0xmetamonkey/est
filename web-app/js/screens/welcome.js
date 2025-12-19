// Welcome Screen - Google Sign-In
const WelcomeScreen = {
    render() {
        return `
            <div class="screen fade-in">
                <!-- VHS Overlay -->
                <div class="vhs-overlay"></div>
                
                <!-- CRT Glow -->
                <div class="crt-glow"></div>
                
                <!-- Scanlines -->
                <div class="scanlines"></div>
                
                <!-- Main Content -->
                <div class="content">
                    <div class="ascii-art">       (\_/)
      ( •_•)
     / >🔐   AUTHENTICATION</div>
                    
                    <div class="glitch-title mb-30">SIGN IN TO CONTINUE</div>
                    
                    <button class="retro-btn btn-cyan" onclick="WelcomeScreen.handleGoogleSignIn()">
                        CONTINUE WITH GOOGLE
                    </button>
                    
                    <div class="mt-20">
                        <button class="retro-btn btn-pink" onclick="Router.navigate('landing')">
                            BACK
                        </button>
                    </div>
                </div>
            </div>
        `;
    },
    
    async handleGoogleSignIn() {
        // Show loading
        document.getElementById('loading-overlay').classList.remove('hidden');
        
        const user = await AuthService.signInWithGoogle();
        
        // Hide loading
        document.getElementById('loading-overlay').classList.add('hidden');
        
        if (user) {
            Router.navigate('dashboard');
        }
    }
};
