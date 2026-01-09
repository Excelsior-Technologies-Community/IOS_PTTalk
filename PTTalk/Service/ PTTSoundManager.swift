import SwiftUI
import AVFoundation
struct ProfessionalPTTButton: View {

    let onStart: () -> Void
    let onStop: () -> Void

    @State private var isPressed = false
    @State private var pulse = false

    var body: some View {
        ZStack {

            // 🔴 OUTER PULSE RING (LIVE)
            Circle()
                .stroke(
                    isPressed ? Color.red.opacity(0.8) : Color.clear,
                    lineWidth: 8
                )
                .frame(width: 280, height: 280)
                .scaleEffect(pulse ? 1.05 : 0.95)
                .opacity(pulse ? 0.6 : 0.2)
                .animation(
                    .easeInOut(duration: 0.9)
                        .repeatForever(autoreverses: true),
                    value: pulse
                )

            // 🌟 GLOW
            Circle()
                .fill(isPressed ? Color.red.opacity(0.25) : Color.clear)
                .frame(width: 240, height: 240)
                .blur(radius: 30)

            // 🎛️ MAIN BUTTON
            Circle()
                .fill(
                    LinearGradient(
                        colors: isPressed
                            ? [Color.red, Color.red.opacity(0.75)]
                            : [Color.gray.opacity(0.9), Color.gray.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 180, height: 180)
                .scaleEffect(isPressed ? 0.94 : 1.0) // 🔥 PRESS EFFECT
                .shadow(
                    color: .black.opacity(isPressed ? 0.2 : 0.6),
                    radius: isPressed ? 6 : 14,
                    y: isPressed ? 2 : 8
                )
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)

            // 🎙️ ICON + TEXT
            VStack(spacing: 10) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 42))
                    .foregroundColor(.white)

                Text(isPressed ? "LIVE" : "HOLD")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        pulse = true
                        onStart()
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    pulse = false
                    onStop()
                }
        )
    }
}


final class PTTSoundManager {

    static let shared = PTTSoundManager()
    private var player: AVAudioPlayer?

    private init() {}

    func playStart() {
        play("ptt_start")
    }

    func playStop() {
        play("ptt_stop")
    }

    private func play(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("❌ Sound file not found:", name)
            return
        }

        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
    }
}
struct RadioStatusView: View {

    var isLive: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isLive ? Color.red : Color.gray)
                .frame(width: 10, height: 10)
                .opacity(isLive ? 1 : 0.5)

            Text(isLive ? "LIVE TRANSMISSION" : "STANDBY")
                .font(.caption)
                .foregroundColor(isLive ? .red : .gray)
                .bold()
        }
    }
}
