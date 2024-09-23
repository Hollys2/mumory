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
import KakaoSDKAuth

struct LoginData {
    var uid: String = ""
    var email: String = ""
    var fcmToken: String = ""
    var method: String = ""
}

public struct LoginView: View {
    public init() {
    }
    
    // MARK: - Properties
    let Firebase = FirebaseManager.shared
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @State var isLoading: Bool = false
    
    @StateObject var signUpViewModel: SignUpViewModel = .init()

    // 여러 개의 메서드에서 중복되어 사용되는 로그인 관련 변수만 정의해둔 구조체
    @State var loginData: LoginData = .init()
    
    // MARK: - View
    public var body: some View {
        NavigationStack(path: $appCoordinator.authPath) {
            ZStack{
                ColorSet.background.ignoresSafeArea()
                VStack(spacing: 0){
                    SharedAsset.logo.swiftUIImage
                        .padding(.top, getUIScreenBounds().height > 700 ? 127 : 71)
                    
                    LoginButton(type: .email, action: emailLogin)
                        .padding(.top, getUIScreenBounds().height > 700 ? 116 : 90)
                    LoginButton(type: .kakao, action: kakaoLogin)
                    LoginButton(type: .google, action: googleLogin)
                    AppleSignInButton()
                    .environmentObject(signUpViewModel)
                    .padding(.top, 10)
                    .frame(height: 60)

                    
                    signUpButton
                }

                //                LoadingAnimationView(isLoading: $isLoading)
                
                if appCoordinator.isOnboardingShown {
                    OnboardingView()
                }
            }            
            .navigationBarBackButtonHidden()
            .onOpenURL(perform: { url in
                if (AuthApi.isKakaoTalkLoginUrl(url)) {
                    AuthController.handleOpenUrl(url: url)
                }
            })
            .navigationDestination(for: AuthPage.self) { page in
                switch page {
                case .signUpCenter:
                    SignUpCenterView()
                        .environmentObject(signUpViewModel)
                    
                case .introOfCustomization:
                    IntroOfCustomization()
                        .environmentObject(signUpViewModel)
                    
                case .customizationCenter:
                    CustomizationCenterView()
                        .environmentObject(signUpViewModel)
                    
                case .emailLogin:
                    EmailLoginView()
                        .environmentObject(signUpViewModel)
                    
                case .profileCard:
                    ProfileCardView()
                        .environmentObject(signUpViewModel)
                    
                default:
                    EmptyView()
                }
            }
            .navigationBarBackButtonHidden()


        }

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
    
    private var handleSignUpGesture: some Gesture {
        TapGesture()
            .onEnded { gesture in
                signUpViewModel.setSignUpData(method: .email)
                appCoordinator.push(destination: AuthPage.signUpCenter)
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
        
        Task {
            guard let gidResult = try? await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) else {return}
            guard let idToken = gidResult.user.idToken?.tokenString else {return}
            let accessToken = gidResult.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            guard let email = gidResult.user.profile?.email else {return}
        
            if await FetchManager.shared.isNewUser(email: email, method: .google) {
                signUpViewModel.setSignUpData(method: .google, email: email, googleCredential: credential)
                appCoordinator.push(destination: AuthPage.signUpCenter)
            } else {
                guard let result = try? await FirebaseManager.shared.auth.signIn(with: credential) else {return}
                await currentUserViewModel.initializeUserData()
                appCoordinator.isHomeViewShown = true
                appCoordinator.isLoginViewShown = false
            }

        }
    }
    
    private func emailLogin() {
        appCoordinator.push(destination: AuthPage.emailLogin)
    }
    
    
    private func kakaoLogin(){
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
        firebaseSignUpWithKakao()
    }
    
    private func firebaseSignUpWithKakao() {
        UserApi.shared.me { user, error in
            if let error = error { return }
            guard let user = user else {return}
            guard let email = user.kakaoAccount?.email else {return}
            guard let kakaoUid = user.id else {return}
            let password = String(kakaoUid)
            Task {
                if await FetchManager.shared.isNewUser(email: email, method: .kakao) {
                    signUpViewModel.setSignUpData(method: .kakao, email: email, password: password)
                    appCoordinator.push(destination: AuthPage.signUpCenter)
                } else {
                    let firebaseEmail = "kakao/\(email)"
                    let firebasePassword = "kakao/\(kakaoUid)"
                    guard let result = try? await FirebaseManager.shared.auth.signIn(withEmail: firebaseEmail, password: firebasePassword) else {return}
                    await currentUserViewModel.initializeUserData()
                    appCoordinator.isHomeViewShown = true
                    appCoordinator.isLoginViewShown = false
                }
            }
        }
    }

    private func setLoginHistory() {
        let userDefualt = UserDefaults.standard
        userDefualt.setValue(Date(), forKey: "loginHistory")
    }
}


