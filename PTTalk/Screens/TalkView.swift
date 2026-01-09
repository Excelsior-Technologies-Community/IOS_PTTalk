//
//  TalkView.swift
//  PTTalk
//
//  Created by Noman belim on 09/01/26.
//
import SwiftUI

struct TalkView: View {

    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var audioManager = AudioManager()

    var body: some View {
        VStack(spacing: 30) {

            Text(statusText)

            Text("Hold To Talk")
                .frame(width: 200, height: 200)
                .background(buttonColor)
                .foregroundColor(.white)
                .clipShape(Circle())
                .gesture(
                    LongPressGesture(minimumDuration: 0.1)
                        .onChanged { _ in
                            print("👇 Button pressed")
                            if !sessionManager.remoteIsSpeaking {
                                audioManager.startSpeaking()
                            } else {
                                print("⛔ Cannot speak, remote user is speaking")
                            }
                        }
                        .onEnded { _ in
                            print("☝️ Button released")
                            audioManager.stopSpeaking()
                        }
                )

            Button("Disconnect") {
                print("🔴 Disconnect button tapped")
                sessionManager.disconnect()
            }
        }
        .padding()
        .onAppear {
            print("🎧 TalkView appeared")
        }
        .onDisappear {
            print("👋 TalkView disappeared")
        }
    }

    private var statusText: String {
        if sessionManager.remoteIsSpeaking {
            return "Other user is speaking"
        } else if audioManager.isSpeaking {
            return "You are speaking"
        } else {
            return "Listening"
        }
    }

    private var buttonColor: Color {
        if sessionManager.remoteIsSpeaking {
            return .gray
        } else if audioManager.isSpeaking {
            return .red
        } else {
            return .blue
        }
    }
}
