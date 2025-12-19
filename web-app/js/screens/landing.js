// Landing Screen - Retro Anime Interface
const LandingScreen = {
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
                    <!-- ASCII Anime Character -->
                    <div class="ascii-art">       (\_/)
      ( •_•)
     / >❤️   WELCOME TO ED</div>
                    
                    <!-- Glitch Title -->
                    <div class="glitch-title">RETRO ANIME INTERFACE</div>
                    
                    <!-- Button Group -->
                    <div class="button-group">
                        <button class="retro-btn btn-cyan" onclick="Router.navigate('welcome')">
                            ENTER
                        </button>
                        
                        <button class="retro-btn btn-amber" onclick="alert('Profile feature coming soon!')">
                            PROFILE
                        </button>
                        
                        <button class="retro-btn btn-pink" onclick="alert('Creator mode coming soon!')">
                            I'M A CREATOR
                        </button>
                        
                        <button class="retro-btn btn-green" onclick="alert('Admirer mode coming soon!')">
                            I'M AN ADMIRER
                        </button>
                    </div>
                </div>
            </div>
        `;
    }
};
