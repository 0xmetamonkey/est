// Profile Screen - Creator Profile View
const ProfileScreen = {
    render(params = {}) {
        const name = params.name || 'Sakura';
        const bio = params.bio || 'Digital artist & anime enthusiast';
        const price = params.price || 150;
        
        return `
            <div class="screen fade-in">
                <!-- VHS Overlay -->
                <div class="vhs-overlay"></div>
                
                <!-- CRT Glow -->
                <div class="crt-glow"></div>
                
                <!-- Scanlines -->
                <div class="scanlines"></div>
                
                <!-- Profile Content -->
                <div class="content">
                    <div class="profile-card">
                        <!-- ASCII Anime Face -->
                        <div class="ascii-art">      (\\_/)
     ( •_•)  < Hi…
    / >💖</div>
                        
                        <!-- Creator Name -->
                        <div class="creator-name">${name}</div>
                        
                        <!-- Creator Bio -->
                        <div class="creator-bio">${bio}</div>
                        
                        <!-- Pricing -->
                        <div class="creator-price">₹${price} / minute</div>
                        
                        <!-- Action Buttons -->
                        <div class="button-group">
                            <button class="retro-btn btn-green" onclick="Router.navigate('calling')">
                                TALK TO ME
                            </button>
                            
                            <button class="retro-btn btn-cyan" onclick="alert('Chat feature coming soon!')">
                                WRITE TO ME
                            </button>
                            
                            <button class="retro-btn btn-pink" onclick="Router.navigate('dashboard')">
                                BACK TO DASHBOARD
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
};
