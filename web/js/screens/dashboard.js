// Dashboard Screen
const DashboardScreen = {
    render() {
        const user = AuthService.getCurrentUser();
        
        if (!user) {
            Router.navigate('welcome');
            return '';
        }
        
        const displayName = user.displayName || 'Unknown User';
        const email = user.email || '';
        const photoURL = user.photoURL || '';
        
        return `
            <div class="screen fade-in">
                <!-- VHS Overlay -->
                <div class="vhs-overlay"></div>
                
                <!-- CRT Glow -->
                <div class="crt-glow"></div>
                
                <!-- Scanlines -->
                <div class="scanlines"></div>
                
                <!-- Dashboard Content -->
                <div class="content">
                    <div class="dashboard-container">
                        <!-- Header -->
                        <div class="dashboard-header">
                            <div class="dashboard-title">DASHBOARD</div>
                            <button class="retro-btn btn-red" onclick="DashboardScreen.handleLogout()" style="margin: 0; padding: 10px 20px; font-size: 16px;">
                                LOGOUT
                            </button>
                        </div>
                        
                        <!-- Profile Section -->
                        <div class="profile-section">
                            ${photoURL ? 
                                `<img src="${photoURL}" alt="Profile" class="profile-avatar">` :
                                `<div class="profile-avatar" style="display: flex; align-items: center; justify-content: center; background: rgba(255, 105, 180, 0.2);">
                                    <span style="font-size: 32px;">👤</span>
                                </div>`
                            }
                            <div class="profile-info">
                                <div class="profile-name">${displayName}</div>
                                <div class="profile-email">${email}</div>
                            </div>
                        </div>
                        
                        <!-- Action Buttons -->
                        <div class="dashboard-actions">
                            <button class="retro-btn btn-pink" onclick="alert('Become a Creator - Coming Soon!')">
                                BECOME A CREATOR
                            </button>
                            
                            <button class="retro-btn btn-cyan" onclick="Router.navigate('profile', { name: 'Sakura', bio: 'Digital artist & anime enthusiast', price: 150 })">
                                BROWSE CREATORS
                            </button>
                            
                            <button class="retro-btn btn-amber" onclick="Router.navigate('contacts')">
                                MESSAGES
                            </button>
                            
                            <button class="retro-btn btn-green" onclick="alert('Wallet - Coming Soon!')">
                                WALLET
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    },
    
    async handleLogout() {
        const success = await AuthService.signOut();
        if (success) {
            Router.navigate('landing');
        }
    }
};
