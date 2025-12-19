// Main Application Entry Point
const App = {
    init() {
        console.log('🚀 ED Marketplace - Initializing...');
        
        // Wait for Firebase to be ready
        setTimeout(() => {
            // Initialize router
            Router.init();
            
            // Hide loading overlay
            document.getElementById('loading-overlay').classList.add('hidden');
            
            console.log('✨ App ready!');
        }, 500);
    }
};

// Start the app when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => App.init());
} else {
    App.init();
}
