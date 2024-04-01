//
//  StringManager.swift
//  Shared
//
//  Created by 다솔 on 2024/03/27.
//  Copyright © 2024 hollys. All rights reserved.
//


import Foundation

public struct StringManager {
    
    public static func maskString(_ input: String) -> String {
        guard input.count > 2 else { return input } // 문자열 길이가 2보다 작으면 그대로 반환
        
        let prefix = input.prefix(2) // 맨 앞 두 글자 가져오기
        let maskedString = prefix + String(repeating: "*", count: input.count - 2) // 나머지 문자 *로 대체
        
        return String(maskedString)
    }
}
