// Chat Screen - Real-time Messaging
const ChatScreen = {
    currentChatId: null,
    unsubscribe: null,
    
    render(params = {}) {
        const user = AuthService.getCurrentUser();
        if (!user) {
            Router.navigate('welcome');
            return '';
        }
        
        const chatWith = params.chatWith || 'Partner';
        const chatWithId = params.chatWithId || 'partner';
        
        // Create or get chat ID (sorted user IDs for consistency)
        this.currentChatId = this.getChatId(user.uid, chatWithId);
        
        return `
            <div class="screen fade-in">
                <!-- VHS Overlay -->
                <div class="vhs-overlay"></div>
                
                <!-- CRT Glow -->
                <div class="crt-glow"></div>
                
                <!-- Scanlines -->
                <div class="scanlines"></div>
                
                <!-- Chat Content -->
                <div class="content">
                    <div class="chat-container">
                        <!-- Chat Header -->
                        <div class="chat-header">
                            <button class="retro-btn btn-pink" onclick="Router.navigate('dashboard')" style="margin: 0; padding: 8px 16px; font-size: 16px;">
                                ← BACK
                            </button>
                            <div class="chat-title">CHAT WITH ${chatWith.toUpperCase()}</div>
                            <div style="width: 80px;"></div>
                        </div>
                        
                        <!-- Messages Area -->
                        <div class="messages-area" id="messages-area">
                            <div class="loading-messages">
                                <div class="ascii-art" style="font-size: 16px; color: var(--color-cyan);">Loading messages...</div>
                            </div>
                        </div>
                        
                        <!-- Message Input -->
                        <div class="message-input-container">
                            <input 
                                type="text" 
                                id="message-input" 
                                class="message-input" 
                                placeholder="Type your message..."
                                onkeypress="if(event.key === 'Enter') ChatScreen.sendMessage()"
                            >
                            <button class="retro-btn btn-cyan" onclick="ChatScreen.sendMessage()" style="margin: 0; padding: 12px 24px;">
                                SEND
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    },
    
    // Get consistent chat ID from two user IDs
    getChatId(userId1, userId2) {
        return [userId1, userId2].sort().join('_');
    },
    
    // Initialize real-time listener
    initializeChat() {
        const user = AuthService.getCurrentUser();
        if (!user || !this.currentChatId) return;
        
        // Unsubscribe from previous listener
        if (this.unsubscribe) {
            this.unsubscribe();
        }
        
        // Listen to messages in real-time
        this.unsubscribe = db.collection('chats')
            .doc(this.currentChatId)
            .collection('messages')
            .orderBy('timestamp', 'asc')
            .onSnapshot((snapshot) => {
                this.renderMessages(snapshot.docs);
            }, (error) => {
                console.error('Error listening to messages:', error);
            });
    },
    
    // Render messages
    renderMessages(messageDocs) {
        const user = AuthService.getCurrentUser();
        const messagesArea = document.getElementById('messages-area');
        
        if (!messagesArea) return;
        
        if (messageDocs.length === 0) {
            messagesArea.innerHTML = `
                <div class="no-messages">
                    <div class="ascii-art" style="font-size: 16px; color: var(--color-purple);">
      (\\_/)
     ( •_•)
    / >💬  No messages yet...
    
    Start the conversation!
                    </div>
                </div>
            `;
            return;
        }
        
        let html = '';
        messageDocs.forEach(doc => {
            const msg = doc.data();
            const isOwn = msg.senderId === user.uid;
            const time = msg.timestamp ? new Date(msg.timestamp.toDate()).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) : 'Now';
            
            html += `
                <div class="message ${isOwn ? 'message-own' : 'message-other'}">
                    <div class="message-sender">${isOwn ? 'You' : msg.senderName}</div>
                    <div class="message-bubble">${this.escapeHtml(msg.text)}</div>
                    <div class="message-time">${time}</div>
                </div>
            `;
        });
        
        messagesArea.innerHTML = html;
        
        // Scroll to bottom
        messagesArea.scrollTop = messagesArea.scrollHeight;
    },
    
    // Send message
    async sendMessage() {
        const user = AuthService.getCurrentUser();
        const input = document.getElementById('message-input');
        const text = input.value.trim();
        
        if (!text || !user || !this.currentChatId) return;
        
        try {
            // Add message to Firestore
            await db.collection('chats')
                .doc(this.currentChatId)
                .collection('messages')
                .add({
                    text: text,
                    senderId: user.uid,
                    senderName: user.displayName || 'Anonymous',
                    timestamp: firebase.firestore.FieldValue.serverTimestamp()
                });
            
            // Update chat metadata
            await db.collection('chats')
                .doc(this.currentChatId)
                .set({
                    lastMessage: text,
                    lastMessageTime: firebase.firestore.FieldValue.serverTimestamp(),
                    participants: firebase.firestore.FieldValue.arrayUnion(user.uid)
                }, { merge: true });
            
            // Clear input
            input.value = '';
            
            console.log('✅ Message sent');
        } catch (error) {
            console.error('Error sending message:', error);
            alert('Failed to send message: ' + error.message);
        }
    },
    
    // Escape HTML to prevent XSS
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    },
    
    // Cleanup
    cleanup() {
        if (this.unsubscribe) {
            this.unsubscribe();
            this.unsubscribe = null;
        }
    }
};
