//
//  EmailLoginView.swift
//  Feature
//
//  Created by 제이콥 on 12/9/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import Lottie

struct EmailLoginForWithdrawView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserViewModel
    @EnvironmentObject var withdrawManager: WithdrawViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State var isLoginError: Bool = false
    @State var isLoading: Bool = false
    @State var isWithdrawSuccess: Bool = false
    @State var errorText = "•  이메일 또는 비밀번호가 일치하지 않습니다."

    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack{
                LibraryColorSet.background.ignoresSafeArea()
                
                VStack(spacing: 0, content: {
                    //상단 타이틀
                    Text("계정 인증 하기")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 22))
                        .foregroundColor(.white)
                        .padding(.top, 30)
                    
                    //이메일 텍스트 필드(재사용)
                    AuthTextField(text: $email, prompt: "이메일")
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.top, 55)
                    
                    //비밀번호 보안 텍스트 필드(재사용)
                    AuthSecureTextField(text: $password, prompt: "비밀번호")
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.top, 11)
                    
                    //로그인 오류 텍스트
                    Text(errorText)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                        .foregroundColor(Color(red: 1, green: 0.34, blue: 0.34))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 40)
                        .padding(.top, 18)
                        .opacity(isLoginError ? 1 : 0)
                        .frame(height: isLoginError ? nil : 0)
                    
                    //로그인 버튼(재사용)
                    WhiteButton(title: "로그인", isEnabled: true)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                        .onTapGesture {
                            isLoading = true
                            if email == userManager.email{
                                withdrawManager.EmailLogin(email: email, password: password) { isSuccessful in
                                    if isSuccessful {
                                        isWithdrawSuccess = true
                                    }else {
                                        isLoginError = !isSuccessful
                                    }
                                    isLoading = false
                                }
                            }else {
                                isLoading = false
                                isLoginError = true
                            }
                        }
                    
                
                    
                    
                    //비밀번호 찾기 네비게이션 링크 텍스트
                    Spacer()
                })
                    
                
                LoadingAnimationView(isLoading: $isLoading)
            }
            .navigationDestination(isPresented: $isWithdrawSuccess, destination: {
                LoginView()
            })
            .frame(width: geometry.size.width + 1)
            .background(LibraryColorSet.background)
            .navigationBarBackButtonHidden()
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    SharedAsset.xWhite.swiftUIImage
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            dismiss()
                        }
                }
            })
            .onTapGesture {
                self.hideKeyboard()
            }
        })
    }
}

#Preview {
    EmailLoginForWithdrawView()
}
