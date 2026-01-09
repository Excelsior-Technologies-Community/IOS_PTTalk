//
//  CodeGenerator.swift
//  PTTalk
//
//  Created by Noman belim on 09/01/26.
//

import SwiftUI
struct CodeGenerator {

    static func generate() -> String {
        let code = String(Int.random(in: 100000...999999))
        print("🔢 Generated user code: \(code)")
        return code
    }
}
