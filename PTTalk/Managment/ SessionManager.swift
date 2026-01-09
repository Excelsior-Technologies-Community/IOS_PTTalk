//
//   SessionManager.swift
//  PTTalk
//
//  Created by Noman belim on 09/01/26.
//
import Foundation

class SessionManager: ObservableObject {

    enum ConnectionState {
        case searching
        case connected(peerName: String)
        case disconnected
    }

    @Published var connectionState: ConnectionState = .searching
    @Published var remoteIsSpeaking: Bool = false

    // MARK: - Connection State Updates

    func startSearching() {
        print("🔍 Searching for nearby users...")
        connectionState = .searching
    }

    func connected(to peerName: String) {
        print("✅ Connected to peer: \(peerName)")
        connectionState = .connected(peerName: peerName)
    }

    func disconnect() {
        print("❌ Disconnected from peer")
        connectionState = .disconnected
        remoteIsSpeaking = false
    }
}
