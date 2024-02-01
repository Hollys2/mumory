//
//  RewardPopUpView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/31.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared

public struct RewardPopUpView: View {
    
    public init() {}
    
    public var body: some View {
        
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width * 0.964, height: 349)
                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                .cornerRadius(15)
            
            VStack(spacing: 0) {
                Spacer().frame(height: 35)
                
                SharedAsset._1AttendanceReward.swiftUIImage
                    .resizable()
                    .frame(width: getUIScreenBounds().width * 0.287, height: getUIScreenBounds().width * 0.287)
                
                Spacer().frame(height: 21)
                
                Text("첫 출석")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Spacer().frame(height: 16)
                
                Text("뮤모리 출석 1일차 입니다. 꾸준히 출석해서 \n리워드를 받아보세요!")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                    .frame(width: 296, alignment: .top)
                
                Spacer()
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: getUIScreenBounds().width * 0.861, height: 58)
                    .background(Color(red: 0.64, green: 0.51, blue: 0.99))
                    .cornerRadius(35)
                    .overlay(
                        Text("확인")
                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                    )
                
                Spacer().frame(height: 30)
            }
        }
        .frame(height: 349)
    }
}

struct RewardPopUpView_Previews: PreviewProvider {
    static var previews: some View {
        RewardPopUpView()
            .frame(width: UIScreen.main.bounds.width * 0.964, height: 349)
    }
}
