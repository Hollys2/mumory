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
    @EnvironmentObject var manager: SettingViewModel
    var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                HStack{
                    Text("이메일")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Text(verbatim: manager.email)
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
                    
                    Text(manager.getSignInMethodText())
                        .foregroundStyle(ColorSet.charSubGray)
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                }
                .padding(20)

                
                //이메일 가입 유저만 비밀번호 재설정 가능하=
                if manager.signinMethod == "Email" {
                    
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 0.5)
                        .foregroundStyle(ColorSet.subGray)
                        .padding(.top, 7)
                        .padding(.bottom, 7)
                    
                    
                    NavigationLink {
                        SetPWView()
                            .environmentObject(manager)
                    } label: {
                        SettingItem(title: "비밀번호 재설정")
                        
                    }
                }


                
                
                
                
                Spacer()

            })
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    SharedAsset.back.swiftUIImage
                        .frame(width: 30, height: 30)
                }
                
            }
            
            ToolbarItem(placement: .principal) {
                Text("계정 정보 / 보안")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    .foregroundStyle(.white)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                
                NavigationLink {
                    HomeView()
                } label: {
                    SharedAsset.home.swiftUIImage
                        .frame(width: 30, height: 30)
                }
                
            }
        }
    }
    
}

//#Preview {
//    AccountManageView()
//}
