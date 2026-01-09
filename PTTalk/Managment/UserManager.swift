//
//  UserManager.swift
//  PTTalk
//
//  Created by Noman belim on 09/01/26.
//

import SwiftUI
import Foundation

import Foundation

class UserManager: ObservableObject {

    @Published var user: User?

    func createUser(name: String) {
        print("👤 Creating user with name: \(name)")
        let code = CodeGenerator.generate()
        user = User(name: name, code: code)
        print("✅ User created: \(name) | Code: \(code)")
    }
}
