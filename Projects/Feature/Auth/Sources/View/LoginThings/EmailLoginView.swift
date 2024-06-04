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
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @StateObject var customManager: CustomizationManageViewModel = CustomizationManageViewModel()

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
                NavigationBar
                
                Text("이메일로 로그인 하기")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 22))
                    .foregroundColor(.white)
                    .padding(.top, 30)
                
                AuthTextField(text: $email, prompt: "이메일")
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 55)
                
                AuthSecureTextField(text: $password, prompt: "비밀번호")
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
    
    var NavigationBar: some View {
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
    
    // 이메일 로그인 기능
    // 로그인 완료 후 커스터마이징 여부 확인 후 홈 화면 혹은 커스터마이징 시작 화면으로 이동
    func tapLoginButton(email: String, password: String) async {
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
        
        self.mumoryDataViewModel.fetchRewards(uId: currentUserData.user.uId)
        self.mumoryDataViewModel.fetchActivitys(uId: currentUserData.user.uId)
        self.mumoryDataViewModel.fetchMumorys(uId: currentUserData.user.uId) { result in
            switch result {
            case .success(let mumorys):
                print("fetchMumorys successfully: \(mumorys)")
                DispatchQueue.main.async {
                    self.mumoryDataViewModel.myMumorys = mumorys
                    self.mumoryDataViewModel.listener = self.mumoryDataViewModel.fetchMyMumoryListener(uId: self.currentUserData.uId)
                    self.mumoryDataViewModel.rewardListener = self.mumoryDataViewModel.fetchRewardListener(user: self.currentUserData.user)
                    self.mumoryDataViewModel.activityListener = self.mumoryDataViewModel.fetchActivityListener(uId: self.currentUserData.uId)
                }
            case .failure(let error):
                print("ERROR: \(error)")
            }
            
            DispatchQueue.main.async {
                self.mumoryDataViewModel.isUpdating = false
            }
        }
        
        isLoading = false
        appCoordinator.initPage = .home
        appCoordinator.isCreateMumorySheetShown = false
        appCoordinator.selectedTab = .home
        
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
