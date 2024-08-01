//
//  MumoryDetailLoadingView.swift
//  Feature
//
//  Created by 다솔 on 2024/08/01.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI

import Shared


public struct MumoryDetailLoadingView: View {
    
    @State var startAnimation: Bool = true
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public var body: some View {
        ScrollView {
            
            ZStack(alignment: .top) {
                
                Color(red: 0.184, green: 0.184, blue: 0.184)
                    .frame(width: getUIScreenBounds().width, height: getUIScreenBounds().height)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    ZStack(alignment: .bottomLeading) {
                        
                        SharedAsset.albumFilterMumoryDetail.swiftUIImage
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                            .offset(y: -getSafeAreaInsets().top)
                        
                        Rectangle()
                            .fill(SharedAsset.backgroundColor.swiftUIColor)
                            .frame(width: UIScreen.main.bounds.width, height: 64)
                            .background(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: Color(red: 0.09, green: 0.09, blue: 0.09), location: 0.38),
                                        Gradient.Stop(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0), location: 0.59),
                                    ],
                                    startPoint: UnitPoint(x: 0.5, y: 1.28),
                                    endPoint: UnitPoint(x: 0.5, y: 0.56)
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 10) {
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                .frame(width: 255, height: 23)
                            
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                .frame(width: 86, height: 18)
                        }
                        .padding(.leading, 20)
                    } // ZStack
                    
                    SharedAsset.backgroundColor.swiftUIColor
                    
                    HStack(spacing: 0) {
                        Circle()
                            .fill(self.startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                            .frame(width: 38, height: 38)
                        
                        Spacer().frame(width: 8)
                        
                        VStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                .frame(width: 95, height: 14)
                            
                            HStack {
                                RoundedRectangle(cornerRadius: 5, style: .circular)
                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                    .frame(width: 60, height: 14)
                                
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 5, style: .circular)
                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                    .frame(width: 124, height: 14)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 68)
                    .background(SharedAsset.backgroundColor.swiftUIColor)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<3) { _ in
                            RoundedRectangle(cornerRadius: 40, style: .circular)
                                .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                .frame(width: 75, height: 28)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 55)
                    .background(SharedAsset.backgroundColor.swiftUIColor)
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        RoundedRectangle(cornerRadius: 40, style: .circular)
                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                            .frame(width: getUIScreenBounds().width - 40, height: 15)
                        
                        RoundedRectangle(cornerRadius: 40, style: .circular)
                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                            .frame(width: 313, height: 15)
                            .padding(.top, 13)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                    .background(SharedAsset.backgroundColor.swiftUIColor)
                    
                    
                    Rectangle()
                        .fill(self.startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                        .frame(width: getUIScreenBounds().width - 40, height: getUIScreenBounds().width - 40)
                        .padding(.horizontal, 20)
                        .padding(.top, 21)
                        .background(SharedAsset.backgroundColor.swiftUIColor)
                        .clipped()
                }
            }
        }
        .frame(width: getUIScreenBounds().width, height: getUIScreenBounds().height)
        .scrollDisabled(true)
        .ignoresSafeArea()
        .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: self.startAnimation)
        .onAppear {
            startAnimation.toggle()
        }
    }
}
