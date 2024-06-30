//
//  SignUpView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Lottie
import Core

/// 회원가입 관련 스크린들을 크게 감싸는 뷰
struct SignUpCenterView: View {
    // MARK: - Propoerties
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    
    // MARK: - View
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                NavigationBar(leadingItem: BackButton, centerItem: TitleText)
                
                //이메일 회원 가입시에만 보여야함
                if signUpViewModel.signInMethod == .email {
                    ProcessIndicator
                }
                
                switch(signUpViewModel.step){
                case 0: EmailInputView()
                case 1: PasswordInputView()
                case 2: TermsOfServiceView()
                default: EmptyView()
                }
                
            }
            
            NextButton
            
        }
        .navigationBarBackButtonHidden()
        .onTapGesture {
            self.hideKeyboard()
        }
    }
    
    var BackButton: some View {
        Button(action: {
            if isSocialSignIn() || signUpViewModel.step == 0 {
                appCoordinator.pop(target: .auth)
            } else {
                signUpViewModel.goPrevious()
            }
        }, label: {
            SharedAsset.back.swiftUIImage
                .resizable()
                .frame(width: 30, height: 30)
        })
    }
    
    var TitleText: some View {
        Text(signUpViewModel.getNavigationTitle())
            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
            .foregroundColor(.white)
    }
    
    var NextButton: some View {
        VStack {
            Spacer()
            
            Button(action: {
                if signUpViewModel.step == 2 {
                    appCoordinator.push(destination: AuthPage.introOfCustomization)
                }
                signUpViewModel.goNext()
            }, label: {
                MumoryLoadingButton(title: signUpViewModel.getButtonTitle(),
                                    isEnabled: signUpViewModel.isButtonEnabled(),
                                    isLoading: $signUpViewModel.isLoading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            })
            .disabled(!signUpViewModel.isButtonEnabled())
        }
    }
    
    var ProcessIndicator: some View {
        ZStack(alignment: .leading){
            Rectangle()
                .fill(Color(white: 0.37))
                .frame(maxWidth: .infinity)
                .frame(height: 2)
            
            Rectangle()
                .fill(Color.white)
                .frame(height: 2)
                .frame(width: getStepIndicatorWidth())
                .animation(.default, value: signUpViewModel.step)
        }
    }
    
    
    // MARK: - Methods
    
    private func getStepIndicatorWidth() -> CGFloat {
        let stepToNaturalNumber = signUpViewModel.step + 1
        return getUIScreenBounds().width * (CGFloat(stepToNaturalNumber) / 3)
    }
    
    private func isSocialSignIn() -> Bool {
        switch signUpViewModel.signInMethod {
        case .kakao, .google, .apple: return true
        default: return false
        }
    }
}

struct TitleTextForSignUpField: View {
    // MARK: - Object lifecycle
    init(title: String, topPadding: CGFloat) {
        self.title = title
        self.topPadding = topPadding
    }
    
    // MARK: - Propoerties
    let title: String
    let topPadding: CGFloat
    
    // MARK: - View
    var body: some View {
        Text(title)
            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 23)
            .padding(.top, topPadding)
    }
}


struct FeedbackTextForSignUp: View {
    // MARK: - Object lifecycle
    init(title: String, isValid: Bool) {
        self.title = title
        self.isValid = isValid
    }
    
    // MARK: - Propoerties
    let title: String
    let isValid: Bool
    
    // MARK: - View
    var body: some View {
        Text(title)
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
            .foregroundColor(isValid ? ColorSet.validGreen : ColorSet.errorRed)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 40)
            .padding(.top, 15)
    }
    
    
}
