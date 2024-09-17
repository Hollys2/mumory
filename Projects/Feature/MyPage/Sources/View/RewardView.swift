//
//  RewardView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/30.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared

public struct RewardView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public init() {}
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            TopBarView(title: "리워드", rightBarButtonNavigationPath: nil, paddingBottom: 28)
            
            ZStack(alignment: .top) {
                
                ScrollView(showsIndicators: false) {
                    
                    RewardContentView()
                }
            }
        }
        .background(SharedAsset.backgroundColor.swiftUIColor)
        .preferredColorScheme(.dark)
    }
}

struct RewardContentView: View {
    
    let attendanceRewards: [Image] = [
        SharedAsset._1AttendanceReward.swiftUIImage,
        SharedAsset._3AttendanceReward.swiftUIImage,
        SharedAsset._7AttendanceReward.swiftUIImage,
        SharedAsset._14AttendanceReward.swiftUIImage,
        SharedAsset._30AttendanceReward.swiftUIImage
    ]
    
    var body: some View {
        
        VStack(spacing: 15) {
            
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: getUIScreenBounds().width - 40, height: 60)
              .background(Color(red: 0.16, green: 0.16, blue: 0.16))
              .cornerRadius(15)
              .overlay(
                Text("획득한 리워드")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                
                + Text("  0개")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
              )
              .padding(.top, 15)
            
            ForEach(0..<5) { i in
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: getUIScreenBounds().width - 40, height: 186)
                    .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                    .cornerRadius(15)
                    .overlay(
                        VStack(spacing: 0) {
                        
                            VStack(alignment: .leading, spacing: 8) {
                                Text("출석 리워드")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                    .foregroundColor(.white)
                                
                                Text("꾸준히 출석해서 리워드를 받아보세요!")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            
                            Spacer().frame(height: 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                
                                HStack(spacing: getUIScreenBounds().width * 0.025) {
                                    
                                    ForEach(0..<5) { i in
                                        
                                        VStack(spacing: 13) {
                                            
                                            ZStack {
                                                
                                                attendanceRewards[i]
                                                    .resizable()
                                                    .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                    .blur(radius: 3)
                                                    .mask(
                                                        Rectangle()
                                                            .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                            .cornerRadius(10)
                                                    )
                                                
                                                Rectangle()
                                                  .foregroundColor(.clear)
                                                  .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                  .background(Color(red: 0.24, green: 0.24, blue: 0.24).opacity(0.6))
                                                  .cornerRadius(10)
//
                                                SharedAsset.lockReward.swiftUIImage
                                                    .resizable()
                                                    .frame(width: getUIScreenBounds().width * 0.082, height: getUIScreenBounds().width * 0.082)
                                            }
                                            
                                            
                                            Text("첫 출석")
                                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                            
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                        }
                    )
            }
            
            Spacer(minLength: 100)
        }
        
    }
}

struct RewardView_Previews: PreviewProvider {
    static var previews: some View {
        RewardView()
    }
}
