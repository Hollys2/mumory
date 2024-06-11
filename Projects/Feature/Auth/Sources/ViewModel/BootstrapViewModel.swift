//
//  Bootstrapper.swift
//  Feature
//
//  Created by 제이콥 on 6/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Shared

///가장 처음 로드될 때 실행시킬 기능
public class BootstrapViewModel: ObservableObject {
    // MARK: - Object lifecycle
    public init() {
        isShownSplashView = true
        isShownHomeView = false
        isShownOnBoarding = false
        bootstrap()
    }
    
    // MARK: - Propoerties
    @Published public var isShownSplashView: Bool
    @Published public var isShownHomeView: Bool
    @Published public var isShownOnBoarding: Bool
    
    
    // MARK: - Methods
    private func bootstrap() {
        isShownHomeView = checkCurrentUser()
        isShownOnBoarding = checkSignInHistory()
    }
        
    private func checkSignInHistory() -> Bool {
        return UserDefaults.standard.value(forKey: "SignInHistory") == nil
    }
    
    private func checkCurrentUser() -> Bool {
        let auth = FirebaseManager.shared.auth
        return auth.currentUser != nil
    }
}
