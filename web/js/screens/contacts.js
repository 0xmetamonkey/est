// Contacts Screen - Choose who to chat with
const ContactsScreen = {
    render() {
        const user = AuthService.getCurrentUser();
        
        if (!user) {
            Router.navigate('welcome');
            return '';
        }
        
        return `
            <div class="screen fade-in">
                <!-- VHS Overlay -->
                <div class="vhs-overlay"></div>
                
                <!-- CRT Glow -->
                <div class="crt-glow"></div>
                
                <!-- Scanlines -->
                <div class="scanlines"></div>
                
                <!-- Contacts Content -->
                <div class="content">
                    <div class="dashboard-container">
                        <!-- Header -->
                        <div class="dashboard-header">
                            <button class="retro-btn btn-pink" onclick="Router.navigate('dashboard')" style="margin: 0; padding: 8px 16px; font-size: 16px;">
                                ← BACK
                            </button>
                            <div class="dashboard-title">MESSAGES</div>
                            <div style="width: 80px;"></div>
                        </div>
                        
                        <!-- ASCII Art -->
                        <div class="ascii-art mb-30" style="font-size: 18px;">      (\\_/)
     ( •_•)
    / >💬  Choose who to chat with</div>
                        
                        <!-- Contact List -->
                        <div class="contacts-list">
                            <!-- Partner Contact -->
                            <div class="contact-card" onclick="Router.navigate('chat', { chatWith: 'Partner', chatWithId: 'partner' })">
                                <div class="contact-avatar">👤</div>
                                <div class="contact-info">
                                    <div class="contact-name">Partner</div>
                                    <div class="contact-status">Click to start chatting</div>
                                </div>
                                <div class="contact-action">
                                    <span style="color: var(--color-cyan); font-size: 24px;">→</span>
                                </div>
                            </div>
                            
                            <!-- Add more contacts here -->
                            <div class="contact-card" onclick="Router.navigate('chat', { chatWith: 'Friend', chatWithId: 'friend' })">
                                <div class="contact-avatar">👥</div>
                                <div class="contact-info">
                                    <div class="contact-name">Friend</div>
                                    <div class="contact-status">Click to start chatting</div>
                                </div>
                                <div class="contact-action">
                                    <span style="color: var(--color-cyan); font-size: 24px;">→</span>
                                </div>
                            </div>
                            
                            <!-- Creator Contact -->
                            <div class="contact-card" onclick="Router.navigate('chat', { chatWith: 'Sakura (Creator)', chatWithId: 'sakura' })">
                                <div class="contact-avatar">🎨</div>
                                <div class="contact-info">
                                    <div class="contact-name">Sakura (Creator)</div>
                                    <div class="contact-status">Digital artist</div>
                                </div>
                                <div class="contact-action">
                                    <span style="color: var(--color-pink); font-size: 24px;">→</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
};
