import SwiftUI
import MultipeerConnectivity

import SwiftUI

struct ContentView: View {

    @StateObject private var callManager = CallManager()

    var body: some View {
        Group {
            if callManager.hasIncomingCall {
                incomingCallView
            } else if callManager.isConnected {
                connectedView
            } else {
                nearbyDevicesView
            }
        }
    }

    // MARK: - Incoming Call UI

    private var incomingCallView: some View {
        VStack(spacing: 20) {
            Text("📞 Incoming Call")
                .font(.title2)
                .bold()

            Text("\(callManager.incomingPeerName ?? "Unknown") wants to connect")
                .foregroundColor(.gray)

            HStack(spacing: 40) {
                Button("Reject") {
                    callManager.rejectCall()
                }
                .foregroundColor(.red)

                Button("Accept") {
                    callManager.acceptCall()
                }
                .foregroundColor(.green)
            }
        }
        .padding()
    }

    // MARK: - Connected Walkie-Talkie UI

    private var connectedView: some View {
        WalkieTalkieConnectedView(callManager: callManager)
    }

    // MARK: - Nearby Devices UI

    private var nearbyDevicesView: some View {
        VStack(spacing: 24) {

            // Header
            VStack(spacing: 6) {
                Text("WALKIE-TALKIE")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))

                Text("Scanning nearby devices")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Scanning Indicator
            HStack(spacing: 10) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .green))

                Text("Scanning channels…")
                    .foregroundColor(.green)
                    .font(.caption)
            }

            Divider()
                .background(Color.gray.opacity(0.4))
                .padding(.horizontal, 40)

            // Device List
            if callManager.nearbyPeers.isEmpty {
                Spacer()

                Text("No devices found")
                    .foregroundColor(.gray)
                    .font(.footnote)

                Text("Make sure both devices are on the same Wi-Fi")
                    .foregroundColor(.gray.opacity(0.7))
                    .font(.caption)

                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(callManager.nearbyPeers, id: \.self) { peer in
                            NearbyDeviceCard(
                                deviceName: peer.displayName,
                                onCall: {
                                    callManager.callPeer(peer)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Spacer(minLength: 20)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

// MARK: - Device Row Component
struct DeviceRow: View {
    let peer: MCPeerID
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "00d4ff"), Color(hex: "0077ff")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "iphone")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                
                // Device Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(peer.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Available")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                // Call Button
                HStack(spacing: 6) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14))
                    
                    Text("Call")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color(hex: "0077ff"))
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Push to Talk Button
struct PushToTalkButton: View {
    let onStart: () -> Void
    let onStop: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            // Outer Glow Rings
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        isPressed ? Color(hex: "ff3b30").opacity(0.3 - Double(index) * 0.1) : Color(hex: "0077ff").opacity(0.2 - Double(index) * 0.05),
                        lineWidth: 2
                    )
                    .frame(
                        width: 200 + CGFloat(index * 30),
                        height: 200 + CGFloat(index * 30)
                    )
                    .scaleEffect(isPressed ? 1.1 : 1.0)
                    .opacity(isPressed ? 0.8 : 0.4)
            }
            
            // Main Button
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isPressed ?
                                [Color(hex: "ff3b30"), Color(hex: "ff6b60")] :
                                [Color(hex: "0077ff"), Color(hex: "00d4ff")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 180, height: 180)
                    .shadow(
                        color: (isPressed ? Color(hex: "ff3b30") : Color(hex: "0077ff")).opacity(0.5),
                        radius: 30,
                        x: 0,
                        y: 15
                    )
                
                VStack(spacing: 12) {
                    Image(systemName: isPressed ? "mic.fill" : "mic.slash.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(isPressed ? "LIVE" : "HOLD")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(2)
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isPressed = true
                        }
                        haptic(.heavy)
                        PTTSoundManager.shared.playStart()
                        onStart()
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                    haptic(.light)
                    PTTSoundManager.shared.playStop()
                    onStop()
                }
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
    }
}
func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}
// MARK: - Supporting Components
struct LiveMicIndicator: View {
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "ff3b30"))
                .frame(width: 16, height: 16)
                .scaleEffect(pulse ? 1.4 : 1.0)
                .opacity(pulse ? 0.3 : 1)
            
            Circle()
                .fill(Color(hex: "ff3b30"))
                .frame(width: 16, height: 16)
        }
        .animation(
            .easeInOut(duration: 0.8)
            .repeatForever(autoreverses: true),
            value: pulse
        )
        .onAppear {
            pulse = true
        }
    }
}

// MARK: - Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


struct WalkieTalkieConnectedView: View {

    @ObservedObject var callManager: CallManager

    var body: some View {
        VStack(spacing: 36) {

            headerView

            RadioStatusView(isLive: callManager.isTransmitting)

            ProfessionalPTTButton(
                onStart: {
                    haptic(.heavy)
                    PTTSoundManager.shared.playStart()
                    callManager.startTalking()
                },
                onStop: {
                    haptic(.light)
                    PTTSoundManager.shared.playStop()
                    callManager.stopTalking()
                }
            )

            Text("Hold to talk • Release to listen")
                .font(.footnote)
                .foregroundColor(.gray)

            Spacer()

            Button("End Session") {
                callManager.endCall()
            }
            .foregroundColor(.red)
            .padding(.bottom, 24)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 6) {
            Text("WALKIE-TALKIE")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))

            Text("Connected to \(callManager.peerName ?? "")")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}


struct NearbyDeviceCard: View {

    let deviceName: String
    let onCall: () -> Void

    var body: some View {
        HStack {

            // Radio icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 48, height: 48)

                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.green)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(deviceName)
                    .foregroundColor(.white)
                    .font(.headline)

                Text("Available")
                    .foregroundColor(.green)
                    .font(.caption)
            }

            Spacer()

            Button(action: onCall) {
                Text("CALL")
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
}
