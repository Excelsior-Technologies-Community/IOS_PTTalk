# 📻 PTTalk

> A real-time peer-to-peer walkie-talkie iOS application with Push-to-Talk functionality

PTTalk enables nearby iOS devices to communicate instantly through voice, replicating the simplicity and immediacy of professional walkie-talkie systems. No phone numbers, servers, or accounts required—just pure, local peer-to-peer communication.

![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

---

## ✨ Features

- **🔍 Automatic Discovery** - Nearby devices are detected automatically on the local network
- **📞 Manual Connection** - Initiate calls deliberately with accept/reject functionality
- **🎙️ Push-to-Talk** - Classic walkie-talkie interaction model
- **🔴 Live Indicators** - Real-time visual feedback for microphone transmission
- **🔊 Loudspeaker Output** - Audio plays through device speaker for hands-free use
- **🔔 Audio Feedback** - Beep sounds on press/release for enhanced UX
- **📳 Haptic Response** - Physical feedback simulating hardware button press
- **🔒 Secure Connection** - Encrypted local peer-to-peer communication
- **🎨 Professional UI** - Radio-style interface optimized for one-handed operation

---

## 🚀 How It Works

### User Flow

```
1. Launch App → Auto-discover nearby devices
2. View Available Devices → Select and initiate call
3. Incoming Call → Accept or reject transmission
4. Connected Mode → Push-to-Talk communication
5. End Session → Return to discovery mode
```

### Technical Flow

The app leverages Apple's Multipeer Connectivity framework for local device discovery and secure peer-to-peer connections. Audio is streamed in real-time using AVFoundation with echo cancellation, while SwiftUI provides reactive UI updates through Combine's publisher pattern.

---

## 🏗️ Architecture

```
PTTalk/
├── UI/                          # SwiftUI Views
│   ├── ContentView.swift        # Main navigation
│   ├── WalkieTalkieConnectedView.swift
│   ├── ProfessionalPTTButton.swift
│   ├── IncomingCallView.swift
│   ├── NearbyDeviceCard.swift
│   └── RadioStatusView.swift
│
├── Services/                    # Business Logic
│   └── CallManager.swift        # Multipeer & Audio handling
│
├── Utilities/                   # Helper Classes
│   └── PTTSoundManager.swift    # Audio feedback system
│
├── App/
│   └── PTTalkApp.swift          # App entry point
│
└── Resources/
    └── Info.plist               # Permissions & configuration
```

**Design Pattern**: MVVM with reactive state management

---

## 🔧 Technology Stack

### SwiftUI
Modern declarative UI framework enabling:
- Reactive interface updates
- Smooth animations and transitions
- Clean view composition

### Multipeer Connectivity
Handles peer-to-peer networking:
- Zero-configuration service discovery (Bonjour)
- Encrypted local connections
- Reliable data transmission
- No internet or central server required

**Use Cases**: Offline gaming, file sharing, collaborative tools, proximity-based communication

### AVFoundation
Powers real-time audio streaming:
- Low-latency microphone capture
- Speaker output control
- Echo cancellation via `.voiceChat` mode
- Audio session management for PTT workflow

### Combine Framework
Provides reactive state management:
- `@Published` properties trigger UI updates
- `ObservableObject` ensures view synchronization
- Automatic cleanup of subscriptions

---

## 💡 Key Implementation Details

### State Management

```swift
@Published var isConnected = false
@Published var isTransmitting = false
@Published var nearbyPeers: [MCPeerID] = []
```

**Why**: SwiftUI automatically re-renders views when `@Published` properties change, keeping the interface perfectly synchronized with app state.

---

### Push-to-Talk Logic

```swift
func startTalking() {
    isTransmitting = true
    // Audio engine remains active
}

func stopTalking() {
    isTransmitting = false
}
```

**Design Decision**: The audio engine runs continuously to prevent latency and audio glitches. Only the transmission flag is toggled, mirroring professional radio systems.

---

### Loudspeaker Routing

```swift
try audioSession.overrideOutputAudioPort(.speaker)
```

**Why**: Forces audio through the loudspeaker instead of the earpiece, essential for the walkie-talkie experience and hands-free operation.

---

### Audio Feedback System

```swift
PTTSoundManager.shared.playStart()  // Button press
PTTSoundManager.shared.playStop()   // Button release
```

**Purpose**: Provides auditory confirmation of transmission state, improving usability and realism. Users instantly know when they're broadcasting.

---

### Haptic Feedback

```swift
UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
```

**Why**: Simulates the tactile experience of pressing a physical walkie-talkie button, increasing user confidence and engagement.

---

## 🎨 Design Philosophy

The interface draws inspiration from professional radio equipment:

- **Dark, radio-style background** - Reduces eye strain during extended use
- **Prominent PTT button** - Large tap target for single-handed operation
- **Press-in animation** - Visual feedback mimicking physical hardware
- **Pulsing transmission indicator** - Clear "on-air" status
- **Minimal distractions** - Focus on core communication function

This is production-quality UI, not a proof-of-concept.

---

## 🧪 Testing Instructions

### Requirements
- Two physical iOS devices (iOS 15.0+)
- Both devices on the same Wi-Fi network
- Bluetooth enabled on both devices

### Steps
1. Install the app on both devices
2. Grant required permissions:
   - Microphone access
   - Local Network access
3. Launch the app on both devices
4. Device A: Tap a discovered peer and press **CALL**
5. Device B: **Accept** the incoming transmission
6. Hold the **PTT button** and speak
7. Release to listen

**Note**: The simulator does not support Multipeer Connectivity. Physical devices are required for testing.

---

## 📋 Permissions

Add these entries to `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for voice communication</string>

<key>NSLocalNetworkUsageDescription</key>
<string>Local network access is needed to discover nearby devices</string>

<key>NSBonjourServices</key>
<array>
    <string>_pttalk._tcp</string>
</array>
```

---
 
