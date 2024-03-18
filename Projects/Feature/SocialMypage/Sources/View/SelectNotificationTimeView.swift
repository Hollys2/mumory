//
//  SelectNotificationTimeView.swift
//  Feature
//
//  Created by 제이콥 on 2/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Core
import Shared

enum time{
    case morning
    case afternoon
    case evening
    case night
    case auto
}

struct SelectNotificationTimeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var settingViewModel: SettingViewModel

    @State var selectIndex: Int = 0
    
    var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                HStack {
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    
                    Spacer()
                    
                    Text("알림 시각")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundStyle(Color.clear)
                        .frame(width: 30, height: 30)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .frame(height: 65)
                .padding(.bottom, 7)
                
                SelectTimeItem(time: .morning, index: $settingViewModel.notificationTime)
                SelectTimeItem(time: .afternoon, index: $settingViewModel.notificationTime)
                SelectTimeItem(time: .evening, index: $settingViewModel.notificationTime)
                SelectTimeItem(time: .night, index: $settingViewModel.notificationTime)
                SelectTimeItem(time: .auto, index: $settingViewModel.notificationTime)
                 
                Spacer()
            })
            .padding(.top, 12)

        }
    }
}

//#Preview {
//    SelectNotificationTimeView()
//}

struct SelectTimeItem: View {
    @State var time: time = .morning
    @Binding var index: Int
    var body: some View {
        switch(time){
        case .morning:
            HStack(spacing: 0, content: {
                
                Text("아침")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(index == 1 ? ColorSet.mainPurpleColor : .white)
                
                Text("6:00AM ~ 11:00AM")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                    .foregroundStyle(ColorSet.subGray)
                    .padding(.leading, 9)
                
                
                Spacer()
                
                SharedAsset.checkFill.swiftUIImage
                    .frame(width: 23, height: 23)
                    .opacity(index == 1 ? 1 : 0)
                
            })
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 18)
            .padding(.bottom, 18)
            .background(ColorSet.background)
            .onTapGesture {
                index = 1
            }
            
        case .afternoon:
            HStack(spacing: 0, content: {
                Text("점심")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(index == 2 ? ColorSet.mainPurpleColor : .white)
                
                Text("11:00AM ~ 4:00PM")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                    .foregroundStyle(ColorSet.subGray)
                    .padding(.leading, 9)
                
                Spacer()
                
                SharedAsset.checkFill.swiftUIImage
                    .frame(width: 23, height: 23)
                    .opacity(index == 2 ? 1 : 0)
            })
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 18)
            .padding(.bottom, 18)
            .background(ColorSet.background)
            .onTapGesture {
                index = 2
            }
            
        case .evening:
            HStack(spacing: 0, content: {
                
                Text("저녁")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(index == 3 ? ColorSet.mainPurpleColor : .white)
                
                Text("4:00PM ~ 9:00PM")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                    .foregroundStyle(ColorSet.subGray)
                    .padding(.leading, 9)
                
                
                Spacer()
                
                SharedAsset.checkFill.swiftUIImage
                    .frame(width: 23, height: 23)
                    .opacity(index == 3 ? 1 : 0)
            })
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 18)
            .padding(.bottom, 18)
            .background(ColorSet.background)
            .onTapGesture {
                index = 3
            }
            
        case .night:
            HStack(spacing: 0, content: {
                
                Text("밤")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(index == 4 ? ColorSet.mainPurpleColor : .white)
                
                Text("9:00PM ~ 2:00AM")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                    .foregroundStyle(ColorSet.subGray)
                    .padding(.leading, 9)
                
                
                Spacer()
                
                SharedAsset.checkFill.swiftUIImage
                    .frame(width: 23, height: 23)
                    .opacity(index == 4 ? 1 : 0)
            })
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 18)
            .padding(.bottom, 18)
            .background(ColorSet.background)
            .onTapGesture {
                index = 4
            }
            
        case .auto:
            HStack(spacing: 0, content: {
                
                Text("이용 시간대를 분석해 자동으로 설정")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(index == 5 ? ColorSet.mainPurpleColor : .white)
                
                Spacer()
                
                SharedAsset.checkFill.swiftUIImage
                    .frame(width: 23, height: 23)
                    .opacity(index == 5 ? 1 : 0)
            })
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 18)
            .padding(.bottom, 18)
            .background(ColorSet.background)
            .onTapGesture {
                index = 5
            }
        }
        
    }
}
