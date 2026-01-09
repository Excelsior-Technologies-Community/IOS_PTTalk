import SwiftUI

struct ContentView: View {

    @StateObject private var callManager = CallManager()

    var body: some View {
        VStack(spacing: 24) {

            // 📞 Incoming Call
            if callManager.hasIncomingCall {

                Text("📞 Incoming Call")
                    .font(.title2)
                    .bold()

                Text("\(callManager.incomingPeerName ?? "") wants to connect")
                    .foregroundColor(.gray)

                HStack(spacing: 20) {
                    Button("❌ Reject") {
                        callManager.rejectCall()
                    }
                    .foregroundColor(.red)

                    Button("✅ Accept") {
                        callManager.acceptCall()
                    }
                    .foregroundColor(.green)
                }
            }

            // ✅ Connected
            else if callManager.isConnected {

                Text("📞 Connected")
                    .font(.title2)
                    .bold()

                Text("Connected to \(callManager.peerName ?? "")")
                    .foregroundColor(.gray)

                Button {
                    callManager.startTalking()
                } label: {
                    Text("🎙️ Hold to Talk")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    callManager.startTalking()
                                }
                                .onEnded { _ in
                                    callManager.stopTalking()
                                }
                        )
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            callManager.stopTalking()
                        }
                )

                Button("🔴 End Call") {
                    callManager.endCall()
                }
                .foregroundColor(.red)
            }

            // 🔍 Nearby Devices List
            else {

                Text("Nearby Devices")
                    .font(.title2)
                    .bold()

                if callManager.nearbyPeers.isEmpty {
                    Text("Searching for devices…")
                        .foregroundColor(.gray)
                } else {
                    List(callManager.nearbyPeers, id: \.self) { peer in
                        Button {
                            callManager.callPeer(peer)
                        } label: {
                            HStack {
                                Text(peer.displayName)
                                Spacer()
                                Text("Call")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}
