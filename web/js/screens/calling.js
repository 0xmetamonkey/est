// Calling Screen - Retro Call Interface
const CallingScreen = {
    render() {
        return `
            <div class="screen fade-in">
                <!-- Vibrating Retro Backdrop -->
                <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(to bottom, #000000, rgba(155, 48, 255, 0.2), #000000); z-index: 1;"></div>
                
                <!-- Scanlines -->
                <div class="scanlines"></div>
                
                <!-- Calling Content -->
                <div class="content">
                    <div class="calling-container">
                        <div class="calling-status">📞 CALL CONNECTING…
// retro sci-fi modem noises //</div>
                        
                        <button class="retro-btn btn-red" onclick="Router.navigate('profile')">
                            END CALL
                        </button>
                    </div>
                </div>
            </div>
        `;
    }
};
