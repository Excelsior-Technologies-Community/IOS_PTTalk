//
//  WelcomeView.swift
//  PTTalk
//
//  Created by Noman belim on 09/01/26.
//
import SwiftUI
import SwiftUI

struct WelcomeView: View {

    @EnvironmentObject var userManager: UserManager
    @State private var name = ""

    var body: some View {
        VStack(spacing: 20) {

            Text("PTTalk")

            TextField("Enter your name", text: $name)

            Button("Continue") {
                print("➡️ Continue tapped with name: \(name)")
                userManager.createUser(name: name)
            }
            .disabled(name.isEmpty)
        }
        .padding()
        .onAppear {
            print("📱 WelcomeView appeared")
        }
    }
}
