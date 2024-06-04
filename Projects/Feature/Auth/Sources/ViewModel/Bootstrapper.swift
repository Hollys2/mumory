//
//  Bootstrapper.swift
//  Feature
//
//  Created by 제이콥 on 6/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation

///어플 로드될 때 수행할 기능들
class Bootstrapper: ObservableObject {
    init() {
        isShownSplashView = true
        isExistentSignInHistory = false
        timer = Timer(timeInterval: 3.0, repeats: false, block: { timer in
            self.isShownSplashView = false
        })
    }
    
    // MARK: - Propoerties
    @Published var isShownSplashView: Bool
    @Published var isExistentSignInHistory: Bool
    
    var timer: Timer?
    
    public func checkSignInHistory() -> Bool {
        guard let history = UserDefaults.standard.value(forKey: "SignInHistory") else {
            return false
        }
        return true
    }
    
    public func checkCurrentUser() {
        
    }
}
