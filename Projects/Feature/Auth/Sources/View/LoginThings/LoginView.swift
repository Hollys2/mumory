//
//  LoginView.swift
//  Feature
//
//  Created by 제이콥 on 12/9/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import CryptoKit
import Shared
import Core
//import KakaoSDKUser
import Lottie
import GoogleSignIn
import AuthenticationServices
import Firebase

public struct LoginView: View {
    public init() {}
    @State fileprivate var currentNonce: String?
    @State var isLoginCompleted: Bool = false
    @State var isLoading: Bool = false
    public var body: some View {
        NavigationStack {
            ZStack{
                LibraryColorSet.background.ignoresSafeArea()
                
                VStack(spacing: 0){
                    
                    SharedAsset.logo.swiftUIImage
                        .padding(.top, 127)
                    
                    //로그인 버튼. 이메일부터 시작 (이후에 끝 주석 있음)
                    //이메일 로그인 버튼
                    NavigationLink {
                        EmailLoginView()
                    } label: {
                        LoginButtonItem(type: .email, action: tapEmailButton)
                            .padding(.top, 150)
                    }
                    .buttonStyle(EmpeyActionStyle())
                    
                    //카카오 로그인 버튼
                    LoginButtonItem(type: .kakao, action: tapKakaoButton)
                    
                    //구글 로그인 버튼
                    LoginButtonItem(type: .google, action: tapGoogleButton)
                    
                    //애플 로그인 버튼 및 기능
                    SignInWithAppleButton(.continue) { request in
                        let nonce = randomNonceString()
                        currentNonce = nonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = sha256(nonce)
                    } onCompletion: { result in
                        switch(result){
                        case .success(let authResult):
                            print("apple sign in success")
                            isLoading = true

                            guard let appleIDCredential = authResult.credential as? ASAuthorizationAppleIDCredential else {return}
                            
                            guard let nonce = currentNonce else {
                                print("nonce error")
                                return
                            }
                            
                            guard let appleIDToken = appleIDCredential.identityToken else {
                                print("id token error")
                                return
                            }
                            
                            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                print("string convert error")
                                return
                            }
                            
                            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                                           rawNonce: nonce,
                                                                           fullName: appleIDCredential.fullName)
                            
                            Auth.auth().signIn(with: credential, completion: { result, error in
                                if let error = error {
                                    print("fire sign in error: \(error)")
                                }else if let authResult = result {
                                    print("firebase sign in success ")
                                    guard let email = authResult.user.email else {
                                        print("email error")
                                        return
                                    }
                                    setLoginHistory()
                                    isLoading = false
                                    isLoginCompleted = true
                                    
                                }
                            })
                            
                        case .failure(let error):
                            print("apple sign in failure: \(error)")
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular))
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                    //로그인 버튼 UI 및 기능 끝
                    
                    NavigationLink {
                        SignUpManageView()
//                        TesttseView()
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
                    .buttonStyle(EmpeyActionStyle()) //터치 애니메이션 삭제
                    
                }
                
                //로딩 로티 애니메이션 - Z스택 최상단
                LottieView(animation: .named("loading", bundle: .module))
                    .looping()
                    .opacity(isLoading ? 1 : 0)
                
            }
            .navigationDestination(isPresented: $isLoginCompleted) {
                //로그인 완료시 홈 화면으로 이동
                HomeView()
            }
            
        }
        .navigationBarBackButtonHidden()
        
        
    }
    
    
    //카카오 로그인은 비즈 전환 후 다시 테스트해봐야함
    private func tapKakaoButton(){
//        if UserApi.isKakaoTalkLoginAvailable(){
//            //카카오톡 어플 사용이 가능하다면
//            UserApi.shared.loginWithKakaoTalk { authToken, error in
//                //앱로그인
//                if let error = error{
//                    //카카오 로그인 실패
//                    print("kakao login error: \(error)")
//                }else if let authToken = authToken {
//                    //카카오 로그인 성공
//                    print("login successful with app")
//                    createUserWithKakao()
//                }
//            }
//        }else{
//            //카카오톡 어플 사용이 불가하다면
//            UserApi.shared.loginWithKakaoAccount { authToken, error in
//                //계정로그인
//                if let error = error{
//                    print(error)
//                }else{
//                    print("login successful with account")
//                    createUserWithKakao()
//                }
//            }
//        }
    }
    
    private func tapEmailButton(){
        print("tap email button")
    }
    
    //구글 로그인 기능
    private func tapGoogleButton(){
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
            print("after")
            if let error = error{
                print("google error: \(error)")
            }else{
                print("google login success")
                isLoading = true
                guard let idToken = result?.user.idToken?.tokenString else {print("no idToken");return}
                guard let accessToken = result?.user.accessToken.tokenString else {print("no accessToken");return}
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                
                Auth.auth().signIn(with: credential){(result, error) in
                    if let error = error {
                        print("create user error: \(error)")
                    }else{
                        print("success creating user ")
                        setLoginHistory()
                        isLoginCompleted = true
                        isLoading = false
                    }
                }
            }
        }
        
    }
    
    private func tapAppleButton(){
        print("tap apple button")
    }
    
    //카카오 로그인 관련 코드 - 비즈 전환 후 재테스트 해야함
    private func createUserWithKakao(){
//        let auth = FirebaseManager.shared.auth
//        let db = FirebaseManager.shared.db
//        
//        //유저 정보 접근
//        UserApi.shared.me { user, error in
//            if let error = error {
//                //유저 정보 접근 에러
//                print("error in getting user info \(error)")
//            }else if let user = user{
//                //유저 정보 접근 성공
//                //동의,비동의 항목에 따라 가지고 올 수 있는 데이터가 다름
//                guard let email = user.kakaoAccount?.email else {return}
//                guard let uid = user.id else {return} //카카오 uid
//                
//                print("email: \(email)") //이메일 필수 체크할 수 있도록 해야함
//                print("uid: \(uid)")
//                
//                //저장된 유저데이터에서 기존유저 판단 쿼리
//                let validUserCheckQuery = db.collection("User").whereField("email", isEqualTo: email)
//                
//                //쿼리 기반 데이터 가져오기
//                validUserCheckQuery.getDocuments { snapShot, error in
//                    if let error = error {
//                        //에러발생
//                        print("fire base query error: \(error)")
//                    }else if let snapShot = snapShot {
//                        //카카오 이메일과 동일한 회원 데이터가 있는지 확인
//                        if snapShot.isEmpty {
//                            //카카오 이메일이 동일한 회원이 없으니 회원가입
//                            print("no user")
//                            auth.createUser(withEmail: email, password: String(uid)){result, error in
//                                if let error = error{
//                                    print("firebase sign up error: \(error)")
//                                }else{
//                                    guard let userResult = result?.user else {return}
//                                    print("uid: \(userResult.uid)")
//                                    setLoginHistory()
//                                    isLoginCompleted = true
//                                    print("firebase sign up successful")
//                                }
//                                
//                            }
//                        }else {
//                            //카카오 이메일이 동일한 회원 데이터가 존재하면 로그인
//                            auth.signIn(withEmail: email, password: String(uid)) { authDataResult, error in
//                                if let error = error {
//                                    print("login error \(error)")
//                                }else {
//                                    print("success login")
//                                    setLoginHistory()
//                                    isLoginCompleted = true
//                                }
//                            }
//                        }
//                    }
//                }
//                
//            }
//            
//        }
    }
    
    //애플 로그인 관련 코드
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func setLoginHistory() {
        let userDefualt = UserDefaults.standard
        userDefualt.setValue(Date(), forKey: "loginHistory")
    }
    
}

#Preview {
    LoginView()
}
