//
//  LoginView.swift
//  Feature
//
//  Created by 제이콥 on 12/9/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared


public struct LoginView: View {
    public init() {}
    @State var isTapFindPassword: Bool = false
    public var body: some View {
        NavigationStack {
            ZStack{
                LibraryColorSet.background.ignoresSafeArea()
                
                VStack(spacing: 0){
                    
                    SharedAsset.logo.swiftUIImage
                        .padding(.top, 127)
                    
                    NavigationLink {
                        EmailLoginView()
                    } label: {
                        LoginButtonItem(type: .email)
                            .padding(.top, 150)
                    }
                    
                    LoginButtonItem(type: .kakao)
                    
                    LoginButtonItem(type: .google)
                    
                    LoginButtonItem(type: .apple)
                    
                    NavigationLink {
                        SignUpView()
                    } label: {
                        VStack(spacing: 0){
                            Text("뮤모리 계정이 없으시다면?")
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                .padding(.top, 40)
                            
                            Text("이메일로 가입하기")
                                .underline()
                                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                .padding(.top, 8)
                                .padding(.bottom, 50)
                            
                        }
                    }
                    
                }
                
            }
        }
        .navigationBarBackButtonHidden()
        
    }
    
    private func tapKakaoButton(){
        print("tap kakao button")
    }
    private func tapEmailButton(){
        print("tap email button")
    }
    private func tapGoogleButton(){
        print("tap google button")
    }
    private func tapAppleButton(){
        print("tap apple button")
    }
}

#Preview {
    LoginView()
}
