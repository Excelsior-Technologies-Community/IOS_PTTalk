//
//  RootView.swift
//  PTTalk
//
//  Created by Noman belim on 09/01/26.
//

import SwiftUI

struct RootView: View {

    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        Group {
            if userManager.user == nil {
                WelcomeView()
                    .onAppear {
                        print("➡️ Showing WelcomeView")
                    }

            } else if case .connected = sessionManager.connectionState {
                TalkView()
                    .onAppear {
                        print("➡️ Showing TalkView (Connected)")
                    }

            } else {
                HomeView()
                    .onAppear {
                        print("➡️ Showing HomeView")
                        sessionManager.startSearching()
                    }
            }
        }
    }
}
