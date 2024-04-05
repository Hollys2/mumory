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
    @EnvironmentObject var currentUserData: CurrentUserData
    @StateObject var customManager: CustomizationManageViewModel = CustomizationManageViewModel()
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var email: String = ""
    @State var password: String = ""
    @State var isLoginError: Bool = false
    @State var isLoading: Bool = false
    //    @State var isCustomizationNotDone: Bool = false
    //    @State var isLoginSuccess: Bool = false
    @State var isPresent: Bool = false
    
    
    var body: some View {
        ZStack{
            LibraryColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                HStack{
                    SharedAsset.xWhite.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    Spacer()
                }
                .padding(.horizontal)
                .frame(height: 63)
                
                //상단 타이틀
                Text("이메일로 로그인 하기")
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
                Text("•  이메일 또는 비밀번호가 일치하지 않습니다.")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                    .foregroundColor(Color(red: 1, green: 0.34, blue: 0.34))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)
                    .padding(.top, 18)
                    .opacity(isLoginError ? 1 : 0)
                    .frame(height: isLoginError ? nil : 0)
                
                //로그인 버튼(재사용)
                MumoryLoadingButton(title: "로그인 하기", isEnabled: email.count > 0 && password.count > 0, isLoading: $isLoading)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                    .onTapGesture {
                        Task{
                            await tapLoginButton(email: self.email, password: self.password)
                        }
                    }
                    .disabled(!(email.count > 0 && password.count > 0))
                
                
                //비밀번호 찾기 네비게이션 링크 텍스트
                NavigationLink {
                    FindPWView()
                } label: {
                    Text("비밀번호 찾기")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                        .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                        .padding(.top, 80)
                }
                
                Spacer()
            })
            
        }
        .background(LibraryColorSet.background)
        .navigationBarBackButtonHidden()
        .onTapGesture {
            self.hideKeyboard()
        }
        .disabled(isLoading)
    }
    
    func tapLoginButton(email: String, password: String) async{
        isLoading = true
        let Firebase = FBManager.shared
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
        
        let qeury = db.collection("user").whereField("dd", isNotEqualTo: "")
        try? await qeury.getDocuments().documents.first?.reference.delete()
        
        
        guard let id = data["id"] as? String,
              let nickname = data["nickname"] as? String else {
            appCoordinator.rootPath.append(MumoryPage.startCustomization)
            return
        }
        try? await db.collection("User").document(result.user.uid).updateData(["fcmToken": messaging.fcmToken ?? ""])
        currentUserData.uId = result.user.uid
        currentUserData.user = await MumoriUser(uId: result.user.uid)
        currentUserData.playlistArray = await currentUserData.savePlaylist()
        currentUserData.favoriteGenres = data["favoriteGenres"] as? [Int] ?? []
        let userDefualt = UserDefaults.standard
        userDefualt.setValue(Date(), forKey: "loginHistory")
        
        isLoading = false
        appCoordinator.initPage = .home
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            appCoordinator.rootPath = NavigationPath()
        }
    }
}

//#Preview {
//    EmailLoginView()
//}
