//
//  SocialLoadingView.swift
//  Feature
//
//  Created by 다솔 on 2024/08/01.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI

import Shared


public struct SocialLoadingView: View {
    
    @State var startAnimation: Bool = true
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                SharedAsset.backgroundColor.swiftUIColor
                    .frame(width: getUIScreenBounds().width, height: getUIScreenBounds().height)
                
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(SharedAsset.backgroundColor.swiftUIColor)
                        .frame(height: 68)
                        .padding(.top, getSafeAreaInsets().top)
                    
                    Group {
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
                        .padding(.horizontal, 10)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15, style: .circular)
                                .fill(self.startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                                .frame(width: getUIScreenBounds().width - 20, height: getUIScreenBounds().width - 20)
                            
                            VStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 5, style: .circular)
                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                    .frame(width: 139, height: 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 22)
                                    .padding(.horizontal, 20)
                                
                                Spacer()
                                
                                HStack(alignment: .bottom, spacing: 0) {
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        
                                        HStack(spacing: 8) {
                                            
                                            ForEach(0..<2) { _ in
                                                RoundedRectangle(cornerRadius: 40, style: .circular)
                                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                                    .frame(width: 75, height: 28)
                                            }
                                            Spacer()
                                        }
                                        
                                        RoundedRectangle(cornerRadius: 5, style: .circular)
                                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                            .frame(width: 258, height: 12)
                                    }
                                    
                                    VStack(spacing: 12) {
                                        Circle()
                                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                            .frame(width: 42, height: 42)
                                        
                                        Circle()
                                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                            .frame(width: 42, height: 42)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 27)
                            }
                            .frame(width: getUIScreenBounds().width - 20, height: getUIScreenBounds().width - 20)
                        }
                        .padding(.top, 14)
                    }
                    
                    Group {
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
                        .padding(.horizontal, 10)
                        .padding(.top, 40)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15, style: .circular)
                                .fill(self.startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                                .frame(width: getUIScreenBounds().width - 20, height: getUIScreenBounds().width - 20)
                            
                            VStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 5, style: .circular)
                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                    .frame(width: 139, height: 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 22)
                                    .padding(.horizontal, 20)
                                
                                Spacer()
                                
                                HStack(alignment: .bottom, spacing: 0) {
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        
                                        HStack(spacing: 8) {
                                            
                                            ForEach(0..<2) { _ in
                                                RoundedRectangle(cornerRadius: 40, style: .circular)
                                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                                    .frame(width: 75, height: 28)
                                            }
                                            Spacer()
                                        }
                                        
                                        RoundedRectangle(cornerRadius: 5, style: .circular)
                                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                            .frame(width: 258, height: 12)
                                    }
                                    
                                    VStack(spacing: 12) {
                                        Circle()
                                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                            .frame(width: 42, height: 42)
                                        
                                        Circle()
                                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                            .frame(width: 42, height: 42)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 27)
                            }
                            .frame(width: getUIScreenBounds().width - 20, height: getUIScreenBounds().width - 20)
                        }
                        .padding(.top, 14)
                    }
                }
                .padding(.top, 25)
            }
        }
        .scrollDisabled(true)
        .ignoresSafeArea()
        .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: self.startAnimation)
        .onAppear {
            startAnimation.toggle()
        }
    }
}
