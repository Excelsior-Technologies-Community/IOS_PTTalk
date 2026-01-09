//
//  ContentView.swift
//  PTTalk
//

import SwiftUI
struct ContentView: View {

    @StateObject private var callManager = CallManager()

    var body: some View {
        VStack(spacing: 24) {

            if callManager.isConnected {

                // ✅ Connected UI (replaces TalkView)
                Text("📞 Call Connected")
                    .font(.title2)
                    .bold()

                if let peer = callManager.peerName {
                    Text("Connected to \(peer)")
                        .foregroundColor(.gray)
                }

                Text("You can talk normally")
                    .foregroundColor(.green)

            } else {

                // 🔍 Searching UI
                Text("🔍 Searching for nearby device…")
                    .font(.title2)

                Text("Make sure both devices are on the same Wi-Fi")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
        }
        .padding()
        .onAppear {
            print("📱 ContentView appeared")
        }
    }
}
//
//// MARK: - Login View (Fixed Binding Errors)
//struct LoginView: View {
//    @ObservedObject var viewModel: CallViewModel
//    @State private var name = "" // Use this local state for the TextField
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("PTTalk").font(.largeTitle).bold()
//            
//            // FIX: Bind to $name (local), NOT viewModel
//            TextField("Enter your name", text: $name)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            
//            Button("Start") {
//                viewModel.setup(name: name)
//            }
//            .disabled(name.isEmpty)
//            .buttonStyle(.borderedProminent)
//        }
//        .padding()
//    }
//}
//
//// 3. Active Call View
//struct ActiveCallView: View {
//    @ObservedObject var viewModel: CallViewModel
//    
//    var body: some View {
//        VStack(spacing: 40) {
//            Text("Connected to").foregroundColor(.gray)
//            Text(viewModel.p2p.connectedPeer?.displayName ?? "Unknown")
//                .font(.largeTitle)
//                .bold()
//            
//            // Visualizer Circle
//            Circle()
//                .fill(Color.green)
//                .frame(width: 150, height: 150)
//                .overlay(Text("Live Audio").foregroundColor(.white))
//            
//            Text("Talking Automatically...")
//                .font(.footnote)
//                .foregroundColor(.gray)
//        }
//    }
//}
//struct PeersListView: View {
//    @ObservedObject var viewModel: CallViewModel
//    
//    var body: some View {
//        NavigationView {
//            List(viewModel.p2p.availablePeers, id: \.self) { peer in
//                HStack {
//                    Text(peer.displayName)
//                        .font(.headline)
//                    Spacer()
//                    Button("Connect") {
//                        viewModel.p2p.connect(to: peer)
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
//            }
//            .navigationTitle("Nearby Users")
//        }
//    }
//}
