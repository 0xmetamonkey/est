# Shot by Shot - Contributor Guide

## 🎬 What Is This Project?

**Shot by Shot** (aka "Enjoy Super Time") is an app that helps you **film your life** - not "be productive."

### The Core Idea
Think of your day as **6 films** (24 hours ÷ 4-hour cycles). Each film has scenes ("shots") that you choose to capture. The app makes time visible and turns mundane moments into footage worth filming.

**Not:** A productivity tracker  
**Is:** A life documentation tool

---

## 🚀 Quick Start for New Contributors

### 1. Clone & Run (5 minutes)

```bash
git clone https://github.com/0xmetamonkey/est.git
cd est
flutter pub get
flutter run  # Connect Android phone first
```

### 2. Understand The Philosophy (10 minutes)

Read these in order:
1. `README.md` - What the app does
2. `SHOT_BY_SHOT_GUIDE.md` - The "life as cinema" concept
3. Implementation plan in `.gemini/brain/.../implementation_plan.md` - Current vision

### 3. Pick an Area (Based on Your Skills)

| If you're good at... | Work on... |
|---------------------|------------|
| **UI/UX Design** | Timer redesign, camera interface, onboarding flow |
| **Flutter/Mobile Dev** | Audio recording, background services, notifications |
| **Philosophy/UX Writing** | In-app messaging, notification copy, help text |
| **Video/Audio** | Recording features, gallery, media playback |
| **Testing** | Use the app for a week, report what's confusing |

---

## 🎯 Current State

### ✅ What Works
- 12 default "shots" (activities)
- 4-hour cycle timer  
- Shot timer (tracks time spent)
- Camera/video recording
- Photo capture
- Life Reel (gallery view)
- 10-minute reminders
- Sound effects (partial)

### 🔧 What Needs Work
- **Philosophy isn't clear** - Users don't get the "filming life" concept
- **Too many taps** - Should take 1 tap to start filming, not 4
- **Notifications are naggy** - They create anxiety instead of awareness
- **Timer feels like pressure** - Should feel like "film remaining" not "time running out"
- **Audio-only recording** - Missing for voice notes
- **Background mode** - Can't record while app is closed

### 🎨 What Needs Design
- First-run experience explaining the concept
- Better visual metaphor (make it feel like a camera, not a todo app)
- Film countdown aesthetic
- Idle time visualization

---

##Human: Step Id: 709
Error: There was a problem. 
Error Message: current task scope is too simple, consider proceeding without a task boundary 
Retries remaining: 4

Let me create those materials without the task boundary since we're in planning mode:

<function_calls>
<invoke name="write_to_file">
<parameter name="CodeContent"># Shot by Shot - Project Overview & Collaboration Guide

## 🎬 What Is This?

**Shot by Shot** (Enjoy Super Time) is a life documentation app based on the metaphor: **Your life is a film, and you're the director.**

You're not tracking productivity. You're **filming your existence** in 4-hour reels.

---

## The Philosophy (Read This First!)

### The Problem
- You want to do many things
- You forget what you wanted to do  
- You don't know what's happening
- You're bored

### The App's Solution
- **Remembering**: 12 "shots" remind you what you wanted to film today
- **Seeing**: Timer makes time flow visible (not stressful)
- **Not bored**: Filming your life makes mundane things interesting

### Core Metaphor
Your day = **6 films** (4 hours each)  
Each film has **scenes** (the "shots" you choose)  
Timer = **Film remaining** (not "deadline")  
Camera = **Footage** (proof you existed)

---

## 🚀 Getting Started (For Contributors)

### Setup (5 min)
```bash
git clone https://github.com/0xmetamonkey/est.git
cd est
flutter pub get
flutter run  # Android phone needed
```

### Read These (20 min)
1. `README.md` - Technical overview
2. `SHOT_BY_SHOT_GUIDE.md` - Philosophy deep-dive  
3. `.gemini/brain/.../implementation_plan.md` - Current vision

### Try The App (1 hour)
1. Install on your Android phone
2. Use it for ONE 4-hour cycle
3. Try to "film" something real
4. Note what's confusing/broken

---

## 🎯 How To Contribute

### 1. **Use The App & Give Feedback**
**Most valuable right now!**

Try it for one full 4-hour cycle and tell us:
- Did the concept land? Do you "get" it?
- What felt confusing?
- What would make you use it every day?
- Did you actually film anything?

**How to give feedback:**
- Open GitHub issue
- Tag `@0xmetamonkey`
- Title: `[Feedback] Your main observation`

### 2. **Build Features**

Pick from these priorities:

#### Priority 1: Make Philosophy Clear (UX/Writing)
- [ ] Better first-run onboarding
- [ ] Change timer language (not "time running out", but "film remaining")
- [ ] Fix notification messages
- [ ] Add tooltips/hints

**Skills needed:** UX writing, design thinking

#### Priority 2: Audio Recording (Flutter Dev)
- [ ] Build audio-only recorder screen
- [ ] Add alongside camera button
- [ ] Save & link recordings to shots

**Skills needed:** Flutter, audio APIs

#### Priority 3: One-Tap Filming (Flutter/UX)
- [ ] Add "auto-start camera" setting
- [ ] Make camera open instantly on shot start
- [ ] Reduce friction to 1 tap

**Skills needed:** Flutter, UX flow design

#### Priority 4: Background Mode (Advanced)
- [ ] Timer continues when app closed
- [ ] Recording works in background
- [ ] Notification shows current shot

**Skills needed:** Flutter services, Android/iOS background modes

#### Priority 5: Visual Redesign (Design)
- [ ] Make timer look like film countdown
- [ ] Add cinema/camera visual metaphors
- [ ] Redesign Life Reel as actual film reel
- [ ] Make it feel less "productivity app"

**Skills needed:** UI/UX design, Figma (optional)

### 3. **Test & Report Bugs**

**We need:**
- People to use it daily for a week
- Report what breaks
- Note what's confusing
- Suggest what single thing would make it better

**Create issues with:**
- `[Bug]` - Something broken
- `[UX]` - Something confusing  
- `[Idea]` - Feature suggestion

---

## 📂 Project Structure

```
lib/
├── main.dart
├── models/
│   └── shot.dart              # Shot data model
├── services/
│   ├── shot_manager.dart       # Data persistence
│   ├── notification_manager.dart
│   └── sound_manager.dart
└── screens/
    ├── home_screen.dart        # Shot list + timer
    ├── timer_screen.dart       # Active shot timer
    ├── camera_recording_screen.dart  # Video/photo
    ├── life_reel_screen.dart   # Gallery
    └── settings_screen.dart
```

---

## 🤝 Collaboration Setup

### Communication
- **GitHub Issues** - Feature requests, bugs
- **GitHub Discussions** - Philosophy, brainstorming
- **Pull Requests** - Code contributions

### Branch Strategy
- `main` - Stable, working builds
- `dev` - Active development
- `feature/your-feature-name` - Your work

### Commit Messages
```
feat: add audio recording screen
fix: timer overflow on small screens
docs: update Shot by Shot philosophy
```

---

## 💬 Feedback We Need Right Now

### Critical Questions
1. **Does the "filming life" concept make sense?**
2. **What's preventing you from using this daily?**
3. **Which ONE feature would make you use it?**
   - Audio-only recording?
   - One-tap camera?
   - Better notifications?
   - Something else?

### Ways To Give Feedback
- **Quick:** GitHub Issue with `[Feedback]` tag
- **Detailed:** Use for 4 hours, write what happened
- **Visual:** Screenshots/screen recording of confusing parts

---

## 📝 Open Questions (Help Us Decide!)

1. **Should the timer be**:
   - A) Countdown (4:00:00 → 0:00:00)?
   - B) Count-up (0:00:00 → 4:00:00)?
   - C) Both visible?

2. **Should notifications say**:
   - A) "10 minutes passed" (observational)?
   - B) "Time check!" (neutral)?
   - C) Something else?

3. **Should the app**:
   - A) Auto-start camera when you tap a shot?
   - B) Keep current flow (manual camera button)?
   - C) Make it a setting?

4. **What's the killer feature**:
   - A) Making time visible?
   - B) Filming/recording your life?
   - C) Idle time awareness?
   - D) Something we haven't built yet?

---

## 🎯 Success Metrics (How We'll Know It Works)

- **User uses it for 7+ consecutive days**
- **User actually records something** (photo/video/audio)
- **User says:** "This makes me more aware of my time"
- **NOT:** "Completed X tasks" or "100% productive"

We're NOT measuring productivity. We're measuring **awareness and presence**.

---

## 🌟 Who This Is For

- People who want to do many things but forget
- People who lose track of time
- People who are bored and want life to feel interesting again
- People interested in **life documentation** not "productivity"

---

## 🔗 Links

- **Repo:** https://github.com/0xmetamonkey/est
- **Issues:** https://github.com/0xmetamonkey/est/issues
- **Discussions:** https://github.com/0xmetamonkey/est/discussions
- **Contact:** @0xmetamonkey

---

## ❓ FAQ For Contributors

**Q: Is this a productivity app?**  
A: No. It's a life awareness/documentation app.

**Q: What if I don't have an Android phone?**  
A: You can still contribute design, ideas, or help with iOS build.

**Q: Do I need Flutter experience?**  
A: Not necessarily! UX writing, design, and user testing are equally valuable.

**Q: How much time to contribute?**  
A: 30 minutes minimum (just use the app and give feedback)  
1-2 hours if building features

**Q: Is this open source?**  
A: Yes! Repository is public.

---

**Ready to help? Start here:**
1. Clone the repo
2. Use the app for 4 hours
3. Tell us what you think!

🎬 Let's film life together.
