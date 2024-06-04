//
//  LoginView.swift
//  Feature
//
//  Created by 제이콥 on 12/9/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import KakaoSDKUser
import Lottie
import GoogleSignIn
import Firebase

struct LoginData {
    var uid: String = ""
    var email: String = ""
    var fcmToken: String = ""
    var method: String = ""
}

public struct LoginView: View {
    public init() {}
    
    // MARK: - Properties
    
    let Firebase = FBManager.shared
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @StateObject var signInWithAppleManager: SignInWithAppleManager = SignInWithAppleManager()
    @State var isLoading: Bool = false
    
    // 여러 개의 메서드에서 중복되어 사용되는 로그인 관련 변수만 정의해둔 구조체
    @State var loginData: LoginData = .init()
    
    // MARK: - View
    
    public var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0){
                SharedAsset.logo.swiftUIImage
                    .padding(.top, getUIScreenBounds().height > 700 ? 127 : 71)
                
                LoginButton(type: .email, action: emailLogin)
                    .padding(.top, getUIScreenBounds().height > 700 ? 116 : 90)
                LoginButton(type: .kakao, action: kakaoLogin)
                LoginButton(type: .google, action: googleLogin)
                LoginButton(type: .apple, action: appleLogin)
                    .onChange(of: signInWithAppleManager.isUserAuthenticated) { isUserAuthenticated in
                        if isUserAuthenticated{
                            if let currentUser = Firebase.auth.currentUser {
                                Task {
                                    await finishSignInProcess()
                                }
                            }
                        }
                    }
                
                signUpButton
            }
            LoadingAnimationView(isLoading: $isLoading)
        }
        .navigationBarBackButtonHidden()
        //애플 로그인 하고서 커스텀에서 다시 로그인으로 왔을 때, 애플로그인이 다시 안 되는 에러가 있어서 인증 여부를 해제함
        .onDisappear(perform: {
            isLoading = false
            signInWithAppleManager.isUserAuthenticated = false
        })
    }
    
    
    private var signUpButton: some View {
        VStack(spacing: 0){
            Text("뮤모리 계정이 없으시다면?")
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .padding(.top, getUIScreenBounds().height > 700 ? 68 : 51)
            
            Text("이메일로 가입하기")
                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                .padding(.top, 8)
        }
        .gesture(handleSignUpGesture)
    }
    
    // 회원 가입 버튼 제스처 정의
    private var handleSignUpGesture: some Gesture {
        TapGesture()
            .onEnded { gesture in
                appCoordinator.rootPath.append(MumoryPage.signUp)
            }
    }
        
    // MARK: - Methods
    
    private func googleLogin(){
        isLoading = true
        guard let id = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: id)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let presentingVC = window.rootViewController else {
            print("No root view controller")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            guard error == nil else {isLoading = false; return}
            guard let idToken = result?.user.idToken?.tokenString else {return}
            guard let accessToken = result?.user.accessToken.tokenString else {return}
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            Task {
                await firebaseSignInWithCredential(credential: credential, method: "Google")
                await finishSignInProcess()
                isLoading = false
            }
       
        }
    }
    
    private func firebaseSignInWithCredential(credential: AuthCredential, method: String) async {
        guard let result = try? await FirebaseManager.shared.auth.signIn(with: credential) else {return}
        loginData.uid = result.user.uid
        loginData.email = result.user.email ?? ""
        loginData.fcmToken = Messaging.messaging().fcmToken ?? ""
        loginData.method = method
    }

    private func emailLogin() {
        appCoordinator.rootPath.append(MumoryPage.emailLogin)
    }
    
    private func appleLogin(){
        isLoading = true
        signInWithAppleManager.performSignIn()
    }
    
    
    public func kakaoLogin(){
        isLoading = true
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { authToken, error in
                self.handleKakaoLogin(error: error)
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { authToken, error in
                self.handleKakaoLogin(error: error)
            }
        }
    }
    
    private func handleKakaoLogin(error: Error?) {
        guard error == nil else {self.isLoading = false; return}
        Task {
            await firebaseSignUpWithKakao()
        }
    }
    
    private func firebaseSignUpWithKakao() async {
        UserApi.shared.me { user, error in
            if let error = error { return }
            guard let user = user else {return}
            guard let email = user.kakaoAccount?.email else {return}
            guard let kakaoUid = user.id else {return}
            
            Task {
                let firebaseEmail = "kakao/\(email)"
                let firebasePassword = "kakao/\(kakaoUid)"
                
                if await self.isNewKakaoUser(email: email) {
                    guard let result = try? await FirebaseManager.shared.auth.createUser(withEmail: firebaseEmail, password: firebasePassword) else {return}
                    self.loginData.uid = result.user.uid
                }else {
                    guard let result = try? await FirebaseManager.shared.auth.signIn(withEmail: firebaseEmail, password: firebasePassword) else {return}
                    self.loginData.uid = result.user.uid
                }
                
                self.loginData.email = email
                self.loginData.method = "Kakao"
                self.loginData.fcmToken = Messaging.messaging().fcmToken ?? ""
                
                await self.finishSignInProcess()
            }
        }
    }
    
    private func isNewKakaoUser(email: String) async -> Bool{
        let db = FirebaseManager.shared.db
        let checkOldUserQuery = db.collection("User")
            .whereField("email", isEqualTo: email)
            .whereField("signInMethod", isEqualTo: "Kakao")
        
        guard let documents = try? await checkOldUserQuery.getDocuments() else {return false}
        return documents.isEmpty
    }

        
    private func setLoginHistory() {
        let userDefualt = UserDefaults.standard
        userDefualt.setValue(Date(), forKey: "loginHistory")
    }
    
        
    private func finishSignInProcess() async {
        setLoginHistory()
        let query = Firebase.db.collection("User").document(loginData.uid)
        guard let snapshot = try? await query.getDocument() else {
            self.isLoading = false
            return
        }
        let isOldUser = snapshot.exists
        
        if isOldUser {
            guard let data = snapshot.data() else {return}
            if !isCompletedCustomization(data: data) {
                appCoordinator.rootPath.append(MumoryPage.customization)
                return
            }
            await handleOldUser(data: data)
        }else {
           await handleNewUser()
        }
     }
    
    private func handleOldUser(data: [String: Any]) async{
        let query = Firebase.db.collection("User").document(loginData.uid)

        currentUserData.uId = loginData.uid
        currentUserData.user = await MumoriUser(uId: loginData.uid)
        currentUserData.favoriteGenres = data["favoriteGenres"] as? [Int] ?? []
        try? await query.updateData(["fcmToken": loginData.fcmToken])
        appCoordinator.selectedTab = .home
        appCoordinator.initPage = .home
        
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
        
        var transaction = Transaction()
        transaction.disablesAnimations = true
        appCoordinator.isCreateMumorySheetShown = false
        withTransaction(transaction) {
            appCoordinator.rootPath = NavigationPath()
        }
    }
    
    private func handleNewUser() async {
        let query = Firebase.db.collection("User").document(loginData.uid)
        var userData: [String: Any] = [
            "uid": loginData.uid,
            "email": loginData.email,
            "signInMethod": loginData.method,
            "fcmToken": loginData.fcmToken,
            "signUpDate": Date()
        ]
        try? await query.setData(userData)
        self.isLoading = false
        appCoordinator.rootPath.append(MumoryPage.customization)
    }
    
    private func isCompletedCustomization(data: [String: Any]) -> Bool {
        guard let id = data["id"] as? String,
              let nickname = data["nickname"] as? String else {
            return false
        }
        return true
    }
    
}


