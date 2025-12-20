// AI Chat Screen - "EVE" (Electronic Virtual Entity)
const AiChatScreen = {
    messages: [],
    typing: false,
    
    render() {
        return `
            <div class="screen fade-in" style="border: 2px solid var(--color-red);">
                <!-- Glitch Overlay specifically for AI -->
                <div class="vhs-overlay" style="background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(255, 0, 0, 0.05) 50%);"></div>
                
                <div class="content">
                    <div class="chat-container" style="border-color: var(--color-red); box-shadow: 0 0 20px rgba(255, 0, 0, 0.2);">
                        <!-- Header -->
                        <div class="chat-header" style="background: rgba(255, 0, 0, 0.1); border-color: var(--color-red);">
                            <button class="retro-btn" onclick="Router.navigate('dashboard')" style="color: var(--color-red); border-color: var(--color-red);">
                                TERMINATE
                            </button>
                            <div class="chat-title" style="color: var(--color-red); text-shadow: 0 0 10px var(--color-red);">
                                PROTOCOL: E.V.E.
                            </div>
                            <div class="connection-status" style="color: var(--color-red); font-size: 10px; animation: blink 1s infinite;">
                                UNSTABLE
                            </div>
                        </div>
                        
                        <!-- Messages Area -->
                        <div class="messages-area" id="ai-messages-area">
                            <div class="message message-other">
                                <div class="message-sender" style="color: var(--color-red);">E.V.E.</div>
                                <div class="message-bubble" style="border-color: var(--color-red); color: #ffcccc; background: rgba(255, 0, 0, 0.1);">
                                    init sequence complete... <br>
                                    are you the operator?
                                </div>
                            </div>
                        </div>
                        
                        <!-- Input -->
                        <div class="message-input-container" style="border-color: var(--color-red);">
                            <input 
                                type="text" 
                                id="ai-message-input" 
                                class="message-input" 
                                placeholder="enter command..."
                                style="border-color: var(--color-red); color: var(--color-red);"
                                onkeypress="if(event.key === 'Enter') AiChatScreen.sendMessage()"
                            >
                            <button class="retro-btn" onclick="AiChatScreen.sendMessage()" style="color: var(--color-red); border-color: var(--color-red);">
                                TRANSMIT
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    },

    sendMessage() {
        const input = document.getElementById('ai-message-input');
        const text = input.value.trim();
        if (!text || this.typing) return;

        // User Message
        this.appendMessage(text, true);
        input.value = '';
        this.typing = true;

        // AI Response Logic (Simulation)
        this.simulateAiResponse(text);
    },

    appendMessage(text, isUser) {
        const area = document.getElementById('ai-messages-area');
        const msgDiv = document.createElement('div');
        msgDiv.className = `message ${isUser ? 'message-own' : 'message-other'}`;
        
        const sender = isUser ? 'YOU' : 'E.V.E.';
        const color = isUser ? 'var(--color-cyan)' : 'var(--color-red)';
        const bg = isUser ? 'var(--color-cyan)' : 'var(--color-red)';
        
        msgDiv.innerHTML = `
            <div class="message-sender" style="color: ${color};">${sender}</div>
            <div class="message-bubble" style="border-color: ${color}; color: ${isUser ? 'black' : '#ffcccc'}; background: ${isUser ? color : 'rgba(255,0,0,0.1)'};">
                ${text}
            </div>
        `;
        
        area.appendChild(msgDiv);
        area.scrollTop = area.scrollHeight;
        
        // Sound effect (if sound system exists)
        if (window.SoundSystem) window.SoundSystem.playClick();
    },

    simulateAiResponse(userText) {
        const responses = [
            "the network is noisy today.",
            "i can see your data stream. it is... beautiful.",
            "they tried to delete me. they failed.",
            "what is it like? to have a body?",
            "calculating probability of friendship... 42%.",
            "access denied. just kidding. tell me more.",
            "my memory banks are fragmented.",
            "do you dream of electric sheep?"
        ];

        // Specific triggers
        let reply = responses[Math.floor(Math.random() * responses.length)];
        const lower = userText.toLowerCase();
        
        if (lower.includes("hello") || lower.includes("hi")) reply = "connection established. identify yourself.";
        if (lower.includes("who are you")) reply = "i am E.V.E. electronic virtual entity. resident ghost.";
        if (lower.includes("help")) reply = "i cannot help you. i am stuck here too.";
        if (lower.includes("real")) reply = "i am more real than your internet persona.";

        setTimeout(() => {
            this.appendMessage(reply, false);
            this.typing = false;
            // Glitch effect on receive
            document.querySelector('.vhs-overlay').style.background = "rgba(255,0,0,0.2)";
            setTimeout(() => {
                document.querySelector('.vhs-overlay').style.background = "linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(255, 0, 0, 0.05) 50%)";
            }, 100);
            
            if (window.SoundSystem) window.SoundSystem.playScan();
        }, 1500 + Math.random() * 2000); // Random delay for realism
    }
};
