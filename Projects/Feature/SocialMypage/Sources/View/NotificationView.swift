//
//  NotificationView.swift
//  Feature
//
//  Created by 제이콥 on 2/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core

enum notificationCategory {
    case social
    case service
}

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var settingViewModel: SettingViewModel
    
    @State var isEntireOn: Bool = false
    @State var checkedResult = 0

    var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                //상단바
                HStack {
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    Spacer()
                    Text("알림")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                    Spacer()
                    SharedAsset.home.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.bottomAnimationViewStatus = .remove
                            appCoordinator.rootPath.removeLast(2)
                        }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .frame(height: 65)
                .padding(.bottom, 7)
                
                
                NotificationItem(title: "전체 알림", isOn: $isEntireOn)
                    .padding(.top, 12)
                    .onChange(of: isEntireOn, perform: { value in
                        settingViewModel.isSubscribedToSocial = value
                        settingViewModel.isSubscribedToService = value
                    })
                
                NotificationItem(title: "소셜 알림", isOn: $settingViewModel.isSubscribedToSocial)
                    .onChange(of: settingViewModel.isSubscribedToSocial, perform: { value in
                        withAnimation {
                            isEntireOn = settingViewModel.isSubscribedToSocial && settingViewModel.isSubscribedToService
                        }
                    })
                
                NotificationItem(title: "서비스 소식 알림", isOn: $settingViewModel.isSubscribedToService)
                    .onChange(of: settingViewModel.isSubscribedToService, perform: { value in
                        withAnimation {
                            isEntireOn = settingViewModel.isSubscribedToSocial && settingViewModel.isSubscribedToService
                        }
                    })
                

                Divider05()
                    .padding(.top, 7)
                    .padding(.bottom, 7)
                
                
                HStack(spacing: 0, content: {
                    Text("알림 시각")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(settingViewModel.getNotificationTimeText())
                        .foregroundStyle(ColorSet.mainPurpleColor)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                })
                .padding(20)
                .background(ColorSet.background)
                .onTapGesture {
                    appCoordinator.rootPath.append(MyPage.selectNotificationTime)
                }
     
                Spacer()
            })
            
        }
    }
    
}

//#Preview {
//    NotificationView()
//}

struct NotificationItem: View {
    @State var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 0, content: {
            Text(title)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                .foregroundStyle(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(CustomToggleStyle())
                
        })
        .padding(20)

    }
}

//커스텀한 스위치 스타일 - onColor, offColor: on/off 배경색깔, thumbColor: 스위치 원형 색
struct CustomToggleStyle: ToggleStyle {

    var onColor: Color = ColorSet.mainPurpleColor
    var offColor: Color = ColorSet.lightGray
    var thumbColor: Color = ColorSet.darkGray

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .fill(configuration.isOn ? onColor : offColor)
                .frame(width: 50, height: 30)
                .overlay(content: {
                    Circle()
                        .fill(thumbColor)
                        .padding(2)
                        .offset(x: configuration.isOn ? 10 : -10)
                })
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        configuration.isOn.toggle()
                    }
                }
               
        }
    }
}
