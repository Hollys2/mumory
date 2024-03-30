//
//  HomeMapView.swift
//  Feature
//
//  Created by 다솔 on 2024/03/28.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import MapKit

import Shared


struct HomeMapView: View {
    
    @State private var isAppleMusicPopUpShown: Bool = true
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var currentUserData: CurrentUserData
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var keyboardResponder: KeyboardResponder
    @EnvironmentObject var settingViewModel: SettingViewModel
    @EnvironmentObject var withdrawViewModel: WithdrawViewModel
    
    var body: some View {
        
        ZStack {
            
            HomeMapViewRepresentable(annotationSelected: $appCoordinator.isMumoryPopUpShown)
                .onAppear {
                    print("HomeMapViewRepresentable onAppear: \(self.currentUserData.user.uId)")
                }

            
            VStack(spacing: 0) {
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 95)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.64, green: 0.51, blue: 0.99).opacity(0.9), location: 0.08),
                                Gradient.Stop(color: Color(red: 0.64, green: 0.51, blue: 0.99).opacity(0), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
                
                Spacer()
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 159.99997)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.64, green: 0.51, blue: 0.99), location: 0.36),
                                Gradient.Stop(color: Color(red: 0.64, green: 0.51, blue: 0.99).opacity(0), location: 0.83),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 1),
                            endPoint: UnitPoint(x: 0.5, y: 0)
                        )
                    )
                    .offset(y: 89)
            }
            .allowsHitTesting(false)
            
            VStack {
                PlayingMusicBarView()
                    .padding(.top, appCoordinator.safeAreaInsetsTop + (getUIScreenBounds().height > 800 ? 12 : 16))
                
                AppleMusicPopUpView(isShown: self.$isAppleMusicPopUpShown)
                    .padding(.top, 15)
                    .opacity(self.isAppleMusicPopUpShown ? 1 : 0)
                
                Spacer()
            }
        }
        .onAppear {
            playerViewModel.isShownMiniPlayer = false
        }
    }
}

