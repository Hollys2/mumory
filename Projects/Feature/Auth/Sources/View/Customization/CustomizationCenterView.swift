//
//  CustomizationView.swift
//  Feature
//
//  Created by 제이콥 on 12/26/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Core
import Shared
import Lottie


public struct CustomizationCenterView: View {
    public init(){}

    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel

        
    // MARK: - View
    public var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
               NavigationBar(leadingItem: BackButton)
                
                ProcessIndicator
                
                switch(signUpViewModel.step){
                case 4: SelectGenreView()
                case 5: SelectTimeView()
                case 6: ProfileSetUpView()
                default: EmptyView()
                }
                
            })
            
            
            BackgroundGradient
            
            NextButton
            

        }
        .navigationBarBackButtonHidden()
        .onTapGesture {
            self.hideKeyboard()
        }
        
    }
    
    var NextButton: some View {
        VStack{
            Spacer()
            Button(action: {
                if signUpViewModel.step == 6 {
                    signUp()
                }else{
                    signUpViewModel.goNext()
                }
            }, label: {
                CommonLoadingButton(title: signUpViewModel.getButtonTitle(), isEnabled: signUpViewModel.isButtonEnabled(), isLoading: $signUpViewModel.isLoading)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)
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
        .animation(.default, value: signUpViewModel.step)
    }
    
    var BackButton: some View {
        Button(action: {
            if signUpViewModel.step == 4 {
                appCoordinator.pop(target: .auth)
            }else{
                signUpViewModel.goPrevious()
            }
        }, label: {
            SharedAsset.back.swiftUIImage
                .resizable()
                .frame(width: 30, height: 30)
        })
    }
    
    var BackgroundGradient: some View {
        VStack{
            Spacer()
            SharedAsset.underGradientLarge.swiftUIImage
                .resizable()
                .ignoresSafeArea()
                .scaledToFit()
        }
    }
    
    // MARK: - Methods
    
    private func getStepIndicatorWidth() -> CGFloat {
        let stepToNaturalNumber = signUpViewModel.step%4 + 1
        return getUIScreenBounds().width * (CGFloat(stepToNaturalNumber) / 3)
    }
    
    private func signUp() {
        Task {
            let uId = await signUpViewModel.signUp()
            let profileImageURL = await signUpViewModel.getUploadedImageURL(uId: uId)
            await signUpViewModel.uploadFavoritePlaylist(uId: uId)
            await signUpViewModel.uploadUserData(uId: uId, profileImageURL: profileImageURL)
            await currentUserViewModel.initializeUserData()
            appCoordinator.push(destination: AuthPage.profileCard)
        }
    }
}
