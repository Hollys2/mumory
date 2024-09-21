//
//  AccountManageView.swift
//  Feature
//
//  Created by 제이콥 on 2/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core

struct AccountManageView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settingViewModel: SettingViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        ZStack(alignment: .top){
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
                    Text("계정 정보 / 보안")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                    Spacer()
                    SharedAsset.home.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.isMyPageViewShown = false
                            appCoordinator.isSocialCommentSheetViewShown = false
                            appCoordinator.isMumoryDetailCommentSheetViewShown = false
                            appCoordinator.selectedTab = .home
                            appCoordinator.rootPath = NavigationPath()
                        }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .frame(height: 65)
                .padding(.bottom, 7)
                
                HStack{
                    Text("이메일")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Text(verbatim: settingViewModel.email)
                        .foregroundStyle(ColorSet.charSubGray)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                }
                .padding(20)
                .padding(.top, 12)
                
                HStack{
                    Text("소셜 로그인")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Text(settingViewModel.getSignInMethodText())
                        .foregroundStyle(ColorSet.charSubGray)
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                }
                .padding(20)

                
                //이메일 가입 유저만 비밀번호 재설정 가능하=
                if settingViewModel.signinMethod == "Email"{
                    Divider05()
                        .padding(.top, 7)
                        .padding(.bottom, 7)
                    
                    SettingItem(title: "비밀번호 재설정")
                        .onTapGesture {
                            appCoordinator.rootPath.append(MumoryPage.setPW)
                        }
                }

            })
        }
        .navigationBarBackButtonHidden()

    }
    
    public func getSignInMethodText(method: String) -> String {
        switch(method){
        case "Kakao":
            return "카카오 계정 로그인"
        case "Google":
            return "Google 계정 로그인"
        case "Apple":
            return "Apple 계정 로그인"
        default: return "소셜 계정 없음"
        }
    }
    
}
