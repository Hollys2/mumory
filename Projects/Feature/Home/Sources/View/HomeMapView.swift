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
    
    @Binding var isAnnotationTapped: Bool
    
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            HomeMapViewRepresentable(isAnnotationTapped: self.$isAnnotationTapped)
                .frame(height: getUIScreenBounds().height - 89)
            
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
                .allowsHitTesting(false)
            
            VStack(spacing: 0) {
                PlayingMusicBarView()
                    .padding(.top, getSafeAreaInsets().top + (getUIScreenBounds().height > 800 ? 8 : 16))
                
                AppleMusicPopUpView()
                    .padding(.top, 15)
            }

            
        }
        .onAppear {
            print("HomeMapView onAppear")
            playerViewModel.isPresentNowPlayingView = false
            playerViewModel.setPlayerVisibilityWithoutAnimation(isShown: false, moveToBottom: false)
            playerViewModel.setLibraryPlayerVisibilityWithoutAnimation(isShown: false)
        }
        .onDisappear {
            print("HomeMapView onDisappear")
            playerViewModel.setPlayerVisibilityWithoutAnimation(isShown: true)
        }
    }
}
