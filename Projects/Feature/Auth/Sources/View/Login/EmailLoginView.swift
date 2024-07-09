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

struct EmailLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator

    @State var email: String = ""
    @State var password: String = ""
    @State var isLoginError: Bool = false
    @State var isLoading: Bool = false
    @State var isPresent: Bool = false
    
    // MARK: - View
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                NavigationBar(leadingItem: BackButton)
                
                Text("이메일로 로그인 하기")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 22))
                    .foregroundColor(.white)
                    .padding(.top, 30)
                
                RoundedTextField(text: $email, placeHolder: "이메일", fontSize: 18)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 55)
                
                RoundedSecureField(text: $password, placeHolder: "비밀번호", fontSize: 18)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 11)
                
                ErrorText
                
                LoginButton
                
                FindPasswordButton
   
            })
            
        }
        .background(LibraryColorSet.background)
        .navigationBarBackButtonHidden()
        .onTapGesture {
            self.hideKeyboard()
        }
        .disabled(isLoading)
    }
    
    var BackButton: some View {
        SharedAsset.xWhite.swiftUIImage
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .onTapGesture {
                appCoordinator.pop(target: .auth)
            }
        
    }
    
    var ErrorText: some View {
        Text("•  이메일 또는 비밀번호가 일치하지 않습니다.")
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
            .foregroundColor(Color(red: 1, green: 0.34, blue: 0.34))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 40)
            .padding(.top, 18)
            .opacity(isLoginError ? 1 : 0)
            .frame(height: isLoginError ? nil : 0)
    }
    
    var LoginButton: some View {
        CommonLoadingButton(title: "로그인 하기", isEnabled: email.count > 0 && password.count > 0, isLoading: $isLoading)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 20)
            .onTapGesture {
                Task{
                    await login(email: self.email, password: self.password)
                }
            }
            .disabled(!(email.count > 0 && password.count > 0))
    }
    
    var FindPasswordButton: some View {
        NavigationLink {
            FindPWView()
        } label: {
            Text("비밀번호 찾기")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                .padding(.top, 80)
        }
    }
    
    // MARK: - Method
    
    func login(email: String, password: String) async {
        isLoading = true
        let Firebase = FirebaseManager.shared
        let Auth = Firebase.auth
        let db = Firebase.db
        let messaging = Firebase.messaging
        
        guard let result = try? await Auth.signIn(withEmail: email, password: password),
              let snapshot = try? await db.collection("User").document(result.user.uid).getDocument(),
              let data = snapshot.data() else {
            self.isLoginError = true
            isLoading = false
            return
        }
        
        Task {
            await currentUserViewModel.initializeUserData()
            appCoordinator.isHomeViewShown = true
        }
    }
}
