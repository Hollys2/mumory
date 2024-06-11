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

struct LoginButton: View {
    init(type: loginType, action: @escaping () -> Void) {
        self.type = type
        self.action = action
        
        switch type {
        case .kakao:
            backgroundColor = Color(red: 0.98, green: 0.88, blue: 0)
            textForegroundColor = Color.black
            image = SharedAsset.kakao.swiftUIImage
            title = "카카오로 로그인"
        case .google:
            backgroundColor = Color.white
            textForegroundColor = Color.black
            image = SharedAsset.google.swiftUIImage
            title = "구글로 로그인"
        case .apple:
            backgroundColor = Color.black
            textForegroundColor = Color.white
            image = SharedAsset.apple.swiftUIImage
            title = "애플로 로그인"
        case .email:
            backgroundColor = Color(red: 0.64, green: 0.51, blue: 0.99)
            textForegroundColor = Color.black
            image = SharedAsset.mail.swiftUIImage
            title = "이메일로 로그인"
        }
    }
    
    let type: loginType
    var action: () -> Void
    private let backgroundColor: Color
    private let textForegroundColor: Color
    private let title: String
    private let image: Image
    
    var body: some View {
        HStack(spacing: 0){
            image
                .resizable()
                .frame(width: 23, height: 23)
            
            Text(title)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .padding(.leading, 18)
                .foregroundStyle(textForegroundColor)
        }
        .padding(.top, 18)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.top, 10)
        .onTapGesture {
            action()
        }
        
    }
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

struct KakaoLoginButton: View {
    var body: some View {
        HStack(spacing: 0){
            SharedAsset.kakao.swiftUIImage
                .frame(width: 23, height: 23)
            
            Text("카카오로 로그인")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(Color.black)
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
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

