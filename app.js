// Shot by Shot - Life as Cinema
// Every task is a shot, every day is a film

class ShotByShot {
    constructor() {
        this.shots = [];
        this.activeShot = null;
        this.completedShots = [];
        this.cycleStartTime = null;
        this.shotStartTime = null;
        this.timerInterval = null;
        this.shotTimerInterval = null;
        
        this.init();
    }
    
    init() {
        this.loadData();
        this.setupEventListeners();
        this.startCycleTimer();
        this.renderShots();
        this.renderTimeline();
        this.updateStats();
        
        // Initialize with some sample shots if empty
        if (this.shots.length === 0) {
            this.createSampleShots();
        }
    }
    
    setupEventListeners() {
        // Add shot button
        document.getElementById('addShotBtn').addEventListener('click', () => {
            this.openModal();
        });
        
        // Modal controls
        document.getElementById('closeModal').addEventListener('click', () => {
            this.closeModal();
        });
        
        document.getElementById('cancelBtn').addEventListener('click', () => {
            this.closeModal();
        });
        
        document.getElementById('createShotBtn').addEventListener('click', () => {
            this.createShot();
        });
        
        // Active shot controls
        document.getElementById('completeBtn').addEventListener('click', () => {
            this.completeActiveShot();
        });
        
        document.getElementById('pauseBtn').addEventListener('click', () => {
            this.pauseActiveShot();
        });
        
        document.getElementById('captureBtn').addEventListener('click', () => {
            this.captureFrame();
        });
        
        // Close modal on outside click
        document.getElementById('addShotModal').addEventListener('click', (e) => {
            if (e.target.id === 'addShotModal') {
                this.closeModal();
            }
        });
        
        // Enter key to create shot
        document.getElementById('shotTitleInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.createShot();
            }
        });
    }
    
    createSampleShots() {
        const samples = [
            { title: 'Morning meditation', type: 'broll', captureFrame: true },
            { title: 'Write blog post', type: 'action', captureFrame: true },
            { title: 'Team standup call', type: 'dialogue', captureFrame: false },
            { title: 'Coffee break & journaling', type: 'broll', captureFrame: true },
            { title: 'Code review session', type: 'action', captureFrame: false }
        ];
        
        samples.forEach(shot => {
            this.shots.push({
                id: this.generateId(),
                title: shot.title,
                type: shot.type,
                captureFrame: shot.captureFrame,
                createdAt: Date.now(),
                status: 'pending'
            });
        });
        
        this.saveData();
        this.renderShots();
    }
    
    startCycleTimer() {
        // 4-hour cycles
        const CYCLE_DURATION = 4 * 60 * 60 * 1000; // 4 hours in milliseconds
        
        if (!this.cycleStartTime) {
            this.cycleStartTime = Date.now();
            this.saveData();
        }
        
        this.updateCycleTimer();
        this.timerInterval = setInterval(() => {
            this.updateCycleTimer();
        }, 1000);
    }
    
    updateCycleTimer() {
        const CYCLE_DURATION = 4 * 60 * 60 * 1000;
        const elapsed = Date.now() - this.cycleStartTime;
        const remaining = CYCLE_DURATION - elapsed;
        
        if (remaining <= 0) {
            // New cycle!
            this.startNewCycle();
            return;
        }
        
        const hours = Math.floor(remaining / (60 * 60 * 1000));
        const minutes = Math.floor((remaining % (60 * 60 * 1000)) / (60 * 1000));
        const seconds = Math.floor((remaining % (60 * 1000)) / 1000);
        
        const timerValue = document.getElementById('timerValue');
        timerValue.textContent = `${hours}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    }
    
    startNewCycle() {
        // Archive current shots, start fresh
        this.cycleStartTime = Date.now();
        
        // Move incomplete shots to archive or carry over (you can customize this)
        const incompleteShotsCount = this.shots.filter(s => s.status === 'pending').length;
        
        if (incompleteShotsCount > 0) {
            // Show notification about new cycle
            this.showNotification(`🎬 New cycle started! ${incompleteShotsCount} shots carried over.`);
        }
        
        this.saveData();
        this.updateCycleTimer();
    }
    
    openModal() {
        const modal = document.getElementById('addShotModal');
        modal.classList.add('active');
        document.getElementById('shotTitleInput').focus();
    }
    
    closeModal() {
        const modal = document.getElementById('addShotModal');
        modal.classList.remove('active');
        document.getElementById('shotTitleInput').value = '';
        document.getElementById('shotTypeInput').value = 'action';
        document.getElementById('captureFrameCheck').checked = false;
    }
    
    createShot() {
        const title = document.getElementById('shotTitleInput').value.trim();
        const type = document.getElementById('shotTypeInput').value;
        const captureFrame = document.getElementById('captureFrameCheck').checked;
        
        if (!title) {
            alert('Please enter a shot title');
            return;
        }
        
        const shot = {
            id: this.generateId(),
            title,
            type,
            captureFrame,
            createdAt: Date.now(),
            status: 'pending'
        };
        
        this.shots.push(shot);
        this.saveData();
        this.renderShots();
        this.updateStats();
        this.closeModal();
        
        this.showNotification(`🎬 Shot "${title}" added to your list!`);
    }
    
    startShot(shotId) {
        const shot = this.shots.find(s => s.id === shotId);
        if (!shot) return;
        
        // Pause any active shot first
        if (this.activeShot) {
            this.pauseActiveShot();
        }
        
        this.activeShot = shot;
        this.shotStartTime = Date.now();
        shot.status = 'active';
        shot.startedAt = this.shotStartTime;
        
        this.saveData();
        this.renderActiveShot();
        this.renderShots();
        this.startShotTimer();
        
        if (shot.captureFrame) {
            this.showNotification('📸 Don\'t forget to capture a frame of this shot!');
        }
    }
    
    startShotTimer() {
        if (this.shotTimerInterval) {
            clearInterval(this.shotTimerInterval);
        }
        
        this.updateShotTimer();
        this.shotTimerInterval = setInterval(() => {
            this.updateShotTimer();
        }, 1000);
    }
    
    updateShotTimer() {
        if (!this.activeShot || !this.shotStartTime) return;
        
        const elapsed = Date.now() - this.shotStartTime;
        const minutes = Math.floor(elapsed / 60000);
        const seconds = Math.floor((elapsed % 60000) / 1000);
        
        const recordingTime = document.getElementById('recordingTime');
        recordingTime.textContent = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
        
        const shotDuration = document.getElementById('shotDuration');
        if (minutes > 0) {
            shotDuration.textContent = `${minutes}m ${seconds}s`;
        } else {
            shotDuration.textContent = `${seconds}s`;
        }
    }
    
    pauseActiveShot() {
        if (!this.activeShot) return;
        
        const duration = Date.now() - this.shotStartTime;
        
        this.activeShot.status = 'pending';
        if (!this.activeShot.totalDuration) {
            this.activeShot.totalDuration = 0;
        }
        this.activeShot.totalDuration += duration;
        
        this.activeShot = null;
        this.shotStartTime = null;
        
        if (this.shotTimerInterval) {
            clearInterval(this.shotTimerInterval);
        }
        
        this.saveData();
        this.renderActiveShot();
        this.renderShots();
    }
    
    completeActiveShot() {
        if (!this.activeShot) return;
        
        const duration = Date.now() - this.shotStartTime;
        if (!this.activeShot.totalDuration) {
            this.activeShot.totalDuration = 0;
        }
        this.activeShot.totalDuration += duration;
        
        this.activeShot.status = 'completed';
        this.activeShot.completedAt = Date.now();
        
        // Add to completed shots for timeline
        this.completedShots.push({
            ...this.activeShot,
            metadata: {
                duration: this.activeShot.totalDuration,
                completedAt: this.activeShot.completedAt,
                shotNumber: this.completedShots.length + 1
            }
        });
        
        // Remove from active shots
        this.shots = this.shots.filter(s => s.id !== this.activeShot.id);
        
        this.showNotification(`✅ Shot completed! Duration: ${this.formatDuration(this.activeShot.totalDuration)}`);
        
        this.activeShot = null;
        this.shotStartTime = null;
        
        if (this.shotTimerInterval) {
            clearInterval(this.shotTimerInterval);
        }
        
        this.saveData();
        this.renderActiveShot();
        this.renderShots();
        this.renderTimeline();
        this.updateStats();
    }
    
    captureFrame() {
        // In a real app, this would trigger camera/screen capture
        // For now, we'll simulate it
        this.showNotification('📸 Frame captured! (In production, this would open your camera)');
        
        if (this.activeShot) {
            if (!this.activeShot.capturedFrames) {
                this.activeShot.capturedFrames = 0;
            }
            this.activeShot.capturedFrames++;
            this.saveData();
            this.updateStats();
        }
    }
    
    renderActiveShot() {
        const noActiveShot = document.getElementById('noActiveShot');
        const activeShotCard = document.getElementById('activeShotCard');
        
        if (!this.activeShot) {
            noActiveShot.style.display = 'block';
            activeShotCard.style.display = 'none';
            return;
        }
        
        noActiveShot.style.display = 'none';
        activeShotCard.style.display = 'block';
        
        document.getElementById('activeShotTitle').textContent = this.activeShot.title;
        document.getElementById('shotNumber').textContent = this.completedShots.length + 1;
        document.getElementById('shotType').textContent = this.getShotTypeName(this.activeShot.type);
    }
    
    renderShots() {
        const grid = document.getElementById('shotsGrid');
        
        if (this.shots.length === 0) {
            grid.innerHTML = '<p style="grid-column: 1/-1; text-align: center; color: var(--color-text-muted); padding: 2rem;">No shots in the queue. Click "+ New Shot" to add one!</p>';
            return;
        }
        
        grid.innerHTML = this.shots.map(shot => `
            <div class="shot-card" onclick="app.startShot('${shot.id}')">
                <div class="shot-card-header">
                    <h3 class="shot-card-title">${shot.title}</h3>
                    <span class="shot-type-badge shot-type-${shot.type}">${this.getShotTypeEmoji(shot.type)}</span>
                </div>
                <div class="shot-card-meta">
                    ${shot.captureFrame ? '📸 Frame capture enabled' : ''}
                    ${shot.totalDuration ? ` • ${this.formatDuration(shot.totalDuration)} recorded` : ''}
                </div>
            </div>
        `).join('');
    }
    
    renderTimeline() {
        const timeline = document.getElementById('reelTimeline');
        
        if (this.completedShots.length === 0) {
            timeline.innerHTML = '<p style="color: var(--color-text-muted); padding: 2rem;">No completed shots yet. Start shooting to build your life reel!</p>';
            return;
        }
        
        // Show most recent shots first
        const recentShots = [...this.completedShots].reverse().slice(0, 10);
        
        timeline.innerHTML = recentShots.map(shot => `
            <div class="timeline-item">
                <div class="timeline-item-header">
                    <span class="timeline-item-title">${shot.title}</span>
                    <span class="timeline-item-time">${this.formatTime(shot.completedAt)}</span>
                </div>
                <div class="timeline-item-duration">
                    ${this.getShotTypeEmoji(shot.type)} ${this.getShotTypeName(shot.type)} • ${this.formatDuration(shot.metadata.duration)}
                    ${shot.capturedFrames ? ` • ${shot.capturedFrames} frames` : ''}
                </div>
            </div>
        `).join('');
    }
    
    updateStats() {
        const totalShots = this.completedShots.length;
        const totalTime = this.completedShots.reduce((sum, shot) => sum + (shot.metadata.duration || 0), 0);
        const capturedFrames = this.completedShots.reduce((sum, shot) => sum + (shot.capturedFrames || 0), 0);
        
        document.getElementById('totalShots').textContent = totalShots;
        document.getElementById('totalTime').textContent = this.formatDuration(totalTime);
        document.getElementById('capturedFrames').textContent = capturedFrames;
        
        // Calculate streak (simplified - days with at least one completed shot)
        const streak = this.calculateStreak();
        document.getElementById('streakCount').textContent = streak;
    }
    
    calculateStreak() {
        // Simplified streak calculation
        // In production, you'd check consecutive days
        const today = new Date().toDateString();
        const hasCompletedToday = this.completedShots.some(shot => 
            new Date(shot.completedAt).toDateString() === today
        );
        
        return hasCompletedToday ? 1 : 0;
    }
    
    getShotTypeName(type) {
        const names = {
            action: 'Action',
            dialogue: 'Dialogue',
            montage: 'Montage',
            broll: 'B-Roll',
            establishing: 'Establishing'
        };
        return names[type] || 'Action';
    }
    
    getShotTypeEmoji(type) {
        const emojis = {
            action: '🎬',
            dialogue: '💬',
            montage: '🎞️',
            broll: '📹',
            establishing: '🌅'
        };
        return emojis[type] || '🎬';
    }
    
    formatDuration(ms) {
        const seconds = Math.floor(ms / 1000);
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);
        
        if (hours > 0) {
            return `${hours}h ${minutes % 60}m`;
        } else if (minutes > 0) {
            return `${minutes}m`;
        } else {
            return `${seconds}s`;
        }
    }
    
    formatTime(timestamp) {
        const date = new Date(timestamp);
        return date.toLocaleTimeString('en-US', { 
            hour: '2-digit', 
            minute: '2-digit'
        });
    }
    
    generateId() {
        return Date.now().toString(36) + Math.random().toString(36).substr(2);
    }
    
    showNotification(message) {
        // Simple notification (in production, use a proper toast library)
        console.log('📢', message);
        
        // You could add a toast notification UI here
        const notification = document.createElement('div');
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: linear-gradient(135deg, #ff6b35 0%, #f7931e 100%);
            color: white;
            padding: 1rem 1.5rem;
            border-radius: 12px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
            z-index: 3000;
            animation: slideInRight 0.3s ease;
            max-width: 300px;
        `;
        notification.textContent = message;
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }
    
    saveData() {
        const data = {
            shots: this.shots,
            completedShots: this.completedShots,
            cycleStartTime: this.cycleStartTime,
            activeShot: this.activeShot,
            shotStartTime: this.shotStartTime
        };
        localStorage.setItem('shotByShot', JSON.stringify(data));
    }
    
    loadData() {
        const saved = localStorage.getItem('shotByShot');
        if (saved) {
            const data = JSON.parse(saved);
            this.shots = data.shots || [];
            this.completedShots = data.completedShots || [];
            this.cycleStartTime = data.cycleStartTime;
            this.activeShot = data.activeShot;
            this.shotStartTime = data.shotStartTime;
        }
    }
}

// Add CSS animations for notifications
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from {
            opacity: 0;
            transform: translateX(100px);
        }
        to {
            opacity: 1;
            transform: translateX(0);
        }
    }
    
    @keyframes slideOutRight {
        from {
            opacity: 1;
            transform: translateX(0);
        }
        to {
            opacity: 0;
            transform: translateX(100px);
        }
    }
`;
document.head.appendChild(style);

// Initialize app
let app;
document.addEventListener('DOMContentLoaded', () => {
    app = new ShotByShot();
});
