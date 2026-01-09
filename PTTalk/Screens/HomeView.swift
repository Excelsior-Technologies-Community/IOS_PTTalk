//
//  HomeView.swift
//  PTTalk
//
//  Created by Noman belim on 09/01/26.
//
import SwiftUI

struct HomeView: View {

    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var sessionManager: SessionManager

    @State private var showConnect = false

    var body: some View {
        VStack(spacing: 20) {

            Text("Hello, \(userManager.user?.name ?? "")")
                .font(.title2)

            Text("Your Code")
                .font(.headline)
            Button("TEST: Simulate Connected") {
                sessionManager.connected(to: "Test iPhone")
            }

            Button("TEST: Simulate Disconnect") {
                sessionManager.disconnect()
            }
            Text(userManager.user?.code ?? "")
                .font(.largeTitle)
                .bold()

            // 🔹 Connection Status
            statusView

            Button("Connect to Someone") {
                print("🔘 Connect button tapped")
                showConnect = true
            }
        }
        .sheet(isPresented: $showConnect) {
            ConnectView()
                .onAppear {
                    print("📤 ConnectView opened")
                }
        }
        .padding()
        .onAppear {
            print("🏠 HomeView appeared")
        }
    }

    // MARK: - Status View

    private var statusView: some View {
        switch sessionManager.connectionState {

        case .searching:
            return AnyView(
                HStack {
                    ProgressView()
                    Text("Searching for nearby users...")
                }
            )

        case .connected(let peerName):
            return AnyView(
                Text("✅ Connected to \(peerName)")
                    .foregroundColor(.green)
            )

        case .disconnected:
            return AnyView(
                Text("❌ Disconnected")
                    .foregroundColor(.red)
            )
        }
    }
}
