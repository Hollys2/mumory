//
//  extenstion+Bundle.swift
//  Shared
//
//  Created by Kane on 8/25/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation

extension Bundle {
    var kakaoAppKey: String? {
        return infoDictionary?["KakaoAppKey"] as? String
    }
}
