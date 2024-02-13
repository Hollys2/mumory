//
//  LoginButtonItem.swift
//  Feature
//
//  Created by 제이콥 on 12/9/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

enum loginType{
    case kakao
    case google
    case apple
    case email
}

struct LoginButtonItem: View {
    var type: loginType
    var action: () -> Void
    var body: some View {
        HStack(spacing: 0){
            switch(type){
            case .email:
                EmailLoginButton()
            case .apple:
                AppleLoginButton()
            case .google:
                GoogleLoginButton()
            case .kakao:
                KakaoLoginButton()
            }
        }
        .padding(.top, 10)
        .onTapGesture {
            action()
        }
    
        
        
    }
}

//#Preview {
//    LoginButtonItem(type: .google) {
//        //
//    }
//}

struct KakaoLoginButton: View {
    var body: some View {
        HStack(spacing: 0){
            SharedAsset.kakao.swiftUIImage
                .frame(width: 23, height: 23)
            
            Text("카카오로 로그인")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .padding(.leading, 18)
        }
        .padding(.top, 18)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.98, green: 0.88, blue: 0))
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular))
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

struct GoogleLoginButton: View {
    var body: some View {
        HStack(spacing: 0){
            SharedAsset.google.swiftUIImage
                .frame(width: 23, height: 23)
            
            Text("Google로 로그인")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .padding(.leading, 18)
                .foregroundStyle(.black)
        }
        .padding(.top, 18)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular))
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}


struct AppleLoginButton: View {
    var body: some View {
        HStack(spacing: 0){
            SharedAsset.apple.swiftUIImage
                .frame(width: 23, height: 23)
            
            Text("Apple로 로그인")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .padding(.leading, 18)
                .foregroundStyle(.white)
        }
        .padding(.top, 18)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular))
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

struct EmailLoginButton: View {
    var body: some View {
        HStack(spacing: 0){
            SharedAsset.mail.swiftUIImage
                .frame(width: 23, height: 23)
            
            Text("이메일로 로그인")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .padding(.leading, 18)
                .foregroundStyle(.black)
        }
        .padding(.top, 18)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.64, green: 0.51, blue: 0.99))
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular))
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

