//
//  SplashView.swift
//  Feature
//
//  Created by 제이콥 on 6/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Lottie

/// 초반 스플래시 뷰
public struct SplashView: View {
    // MARK: - Object lifecycle
    public init() {}
    
    // MARK: - Propoerties
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    // MARK: - View
    public var body: some View {
        ZStack(alignment: .center) {
            ColorSet.mainPurpleColor.ignoresSafeArea()
                .overlay {
                    LottieView(animation: .named("splash", bundle: .module))
                        .looping()
                }
        }
        .onAppear {
            Task {
//                self.appCoordinator.isLoading = true
                
                if await currentUserViewModel.initializeUserData() {
                    self.appCoordinator.isHomeViewShown = true
                } else {
                    self.appCoordinator.isLoginViewShown = true
                }
                
//                self.appCoordinator.isLoading = false
            }

            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                self.appCoordinator.isSplashViewShown = false
            }
        }
    }
    
    // MARK: - Methods
}
