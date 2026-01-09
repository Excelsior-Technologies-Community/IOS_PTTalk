//
//  ContentView.swift
//  PTTalk
//
//  Created by Noman belim on 09/01/26.
//
import SwiftUI

struct ConnectView: View {

    @Environment(\.dismiss) var dismiss
    @State private var enteredCode = ""

    var body: some View {
        VStack(spacing: 20) {

            Text("Connect to Someone")

            TextField("Enter code", text: $enteredCode)

            Button("Connect") {
                print("📨 User entered code: \(enteredCode)")
                print("⚠️ Code-based connection not implemented yet")
                dismiss()
            }
            .disabled(enteredCode.isEmpty)

            Button("Cancel") {
                print("❎ Connect cancelled")
                dismiss()
            }
        }
        .padding()
        .onAppear {
            print("📲 ConnectView appeared")
        }
    }
}
