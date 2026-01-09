//
//  AudioManager.swift
//  PTTalk
//
//  Created by Noman belim on 09/01/26.
//
import AVFoundation
import AVFoundation

class AudioManager: ObservableObject {

    @Published var isSpeaking = false

    init() {
        print("🎤 AudioManager initialized")
    }

    func startSpeaking() {
        print("🎙️ START speaking (Mic ON)")
        isSpeaking = true
    }

    func stopSpeaking() {
        print("🔇 STOP speaking (Mic OFF)")
        isSpeaking = false
    }
}
