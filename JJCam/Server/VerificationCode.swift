//
//  VerificationCode.swift
//  testSwifter
//
//  Created by Jairo Pereira Junior on 01/02/21.
//

import Foundation

class VerificationCode {
    public static let shared = VerificationCode()
    private var code = 0
    
    func generateCode() -> Int {
        code = Int.random(in: 100000...999999)
        return code
    }
    
    func verificateCode(code: Int) -> Bool {
        return self.code == code
    }
}
