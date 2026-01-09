//
//  PTTalkApp.swift
//  PTTalk
//
//  Created by Noman belim on 09/01/26.
//
import SwiftUI

@main
struct PTTalkApp: App {

    @StateObject private var userManager = UserManager()
    @StateObject private var sessionManager = SessionManager()

    init() {
        print("🚀 App Launched")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userManager)
                .environmentObject(sessionManager)
        }
    }
}
