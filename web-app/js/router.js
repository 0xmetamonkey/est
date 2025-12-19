// Router - Client-side navigation
const Router = {
    currentRoute: 'landing',
    currentParams: {},
    
    // Navigate to a route
    navigate(route, params = {}) {
        this.currentRoute = route;
        this.currentParams = params;
        
        // Update URL hash
        window.location.hash = route;
        
        // Render the route
        this.render();
    },
    
    // Render current route
    render() {
        const app = document.getElementById('app');
        
        let html = '';
        
        switch(this.currentRoute) {
            case 'landing':
                html = LandingScreen.render();
                break;
                
            case 'welcome':
                html = WelcomeScreen.render();
                break;
                
            case 'dashboard':
                // Check authentication
                if (!AuthService.isAuthenticated()) {
                    this.navigate('welcome');
                    return;
                }
                html = DashboardScreen.render();
                break;
                
            case 'profile':
                // Check authentication
                if (!AuthService.isAuthenticated()) {
                    this.navigate('welcome');
                    return;
                }
                html = ProfileScreen.render(this.currentParams);
                break;
                
            case 'calling':
                // Check authentication
                if (!AuthService.isAuthenticated()) {
                    this.navigate('welcome');
                    return;
                }
                html = CallingScreen.render();
                break;
                
            default:
                html = LandingScreen.render();
        }
        
        app.innerHTML = html;
    },
    
    // Initialize router
    init() {
        // Handle browser back/forward
        window.addEventListener('hashchange', () => {
            const hash = window.location.hash.substring(1);
            if (hash && hash !== this.currentRoute) {
                this.currentRoute = hash;
                this.render();
            }
        });
        
        // Initial render
        const hash = window.location.hash.substring(1);
        if (hash) {
            this.currentRoute = hash;
        }
        this.render();
    }
};
