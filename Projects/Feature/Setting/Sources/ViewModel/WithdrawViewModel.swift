//
//  WithdrawViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/5/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Core
import KakaoSDKAuth
import KakaoSDKUser
import Firebase
import GoogleSignIn

class WithdrawViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @Published var isAppleUserAuthenticated = false
    @Published var isEmailUserAuthenticated = false
    var currentNonce: String?

    func performSignIn() {
        print("perfon sign in")
        let request = createAppleIdRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])

        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self

        authorizationController.performRequests()
    }

    private func createAppleIdRequest() -> ASAuthorizationRequest  {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]

        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce

        return request
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
       precondition(length > 0)
       let charset: [Character] =
       Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
       var result = ""
       var remainingLength = length
       
       while remainingLength > 0 {
           let randoms: [UInt8] = (0 ..< 16).map { _ in
               var random: UInt8 = 0
               let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
               if errorCode != errSecSuccess {
                   fatalError(
                       "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                   )
               }
               return random
           }

           randoms.forEach { random in
               if remainingLength == 0 {
                   return
               }
               
               if random < charset.count {
                   result.append(charset[Int(random)])
                   remainingLength -= 1
               }
           }
       }
       return result
   }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else  {
                fatalError("DEBUG: Invalid state: A login callback was recieved, but no login request was sent")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("DEBUG: Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("DEBUG: Unable to serialize token string from data \(appleIDToken.debugDescription)")
                return
            }
            
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("sign in with firebase error: \(error)")
                }else if let result = result {
                    print("sign in successful")
                    self.isAppleUserAuthenticated = true
                }
            }
        }
    }
    
    

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first ?? UIWindow()
    }
    
    func AppleLogin() {
        performSignIn()
    }

    
    func EmailLogin(email: String, password: String, completion: @escaping (_ isLoginError: Bool) -> Void){
        //Core에 정의해둔 FirebaseAuth
        let Firebase = FirebaseManager.shared
        let Auth = Firebase.auth
        let db = Firebase.db
        
        Auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("로그인 실패, \(error)")
                completion(true) //isLoginError = true -> 오류발생
            }else if let result = result{
                print("login success")
                self.isEmailUserAuthenticated = true
                completion(false) //isLoginError = false -> 오류 미발생
            }
        }
    }
    
    func KakaoLogin(completion: @escaping(_ isSuccessful: Bool) -> Void){
        if UserApi.isKakaoTalkLoginAvailable(){
            //카카오톡 어플 사용이 가능하다면
            UserApi.shared.loginWithKakaoTalk { authToken, error in
                //앱로그인
                if let error = error{
                    //카카오 로그인 실패
                    print("kakao login error: \(error)")
                    completion(false)
                }else if authToken != nil {
                    //카카오 로그인 성공
                    print("login successful with app")
                    UserApi.shared.me { user, error in
                        if let user = user {
                            let email = user.kakaoAccount?.email ?? ""
                            let id = user.id ?? 0
                            
                            Auth.auth().signIn(withEmail: "kakao/\(email)", password: "kakao/\(id)") { result, error in
                                if let error = error {
                                    print("sign in error: \(error)")
                                    completion(false)
                                }else if result != nil {
                                    completion(true)
                                }
                            }
                        }
                    }
                    
                }
            }
        }else{
            //카카오톡 어플 사용이 불가하다면
            UserApi.shared.loginWithKakaoAccount { authToken, error in
                //계정로그인
                if let error = error{
                    print("kakao acount login error: \(error)")
                    completion(false)
                }else if authToken != nil{
                    print("login successful with account")
                    UserApi.shared.me { user, error in
                        if let user = user {
                            let email = user.kakaoAccount?.email ?? ""
                            let id = user.id ?? 0
                            
                            Auth.auth().signIn(withEmail: "kakao/\(email)", password: "kakao/\(id)") { result, error in
                                if let error = error {
                                    print("sign in error: \(error)")
                                    completion(false)
                                }else if result != nil {
                                    completion(true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func GoogleLogin(completion: @escaping(_ isSuccessful: Bool) -> Void){
        if let id = FirebaseApp.app()?.options.clientID {
            let config = GIDConfiguration(clientID: id)
            GIDSignIn.sharedInstance.configuration = config
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let presentingVC = window.rootViewController {
                
                GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
                    if let error = error{
                        print("google error: \(error)")
                        completion(false)
                    }else{
                        print("google login success")
                        guard let idToken = result?.user.idToken?.tokenString else {print("no idToken");return}
                        guard let accessToken = result?.user.accessToken.tokenString else {print("no accessToken");return}
                        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                        Auth.auth().signIn(with: credential) { result, error in
                            if let error = error {
                                print("sign in error: \(error)")
                                completion(false)
                            }else{
                                completion(true)
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
}
