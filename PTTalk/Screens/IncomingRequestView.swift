////
////  IncomingRequestView.swift
////  PTTalk
////
////  Created by Noman belim on 09/01/26.
////
//import SwiftUI
//
//struct IncomingRequestView: View {
//    @EnvironmentObject var sessionManager: SessionManager
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("\(sessionManager.incomingRequestName ?? "") wants to connect")
//
//            HStack {
//                Button("Reject") {
//                    sessionManager.rejectRequest()
//                }
//
//                Button("Accept") {
//                    sessionManager.acceptRequest()
//                }
//            }
//        }
//        .padding()
//    }
//}
