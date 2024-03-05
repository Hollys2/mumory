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
    
    func AppleLogin() {
        let request = createAppleIdRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])

        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self

        authorizationController.performRequests()
    }

    
    func EmailLogin(email: String, password: String, completion: @escaping (_ isSuccessful: Bool) -> Void){
        //Core에 정의해둔 FirebaseAuth
        let Firebase = FirebaseManager.shared
        let Auth = Firebase.auth
        let db = Firebase.db
        
        Auth.signIn(withEmail: email, password: password) { result, error in
            guard error == nil else {
                print("sign in error: \(error!)")
                completion(false)
                return
            }
            
            guard let user = result?.user else {
                completion(false)
                return
            }
                        
            user.delete { error in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                db.collection("User").document(user.uid).delete { error in
                    guard let error = error else {
                        completion(true)
                        return
                    }
                    completion(false)
                }
                
            }
            
        }
    }
    
    func KakaoLogin(originalEmail: String, completion: @escaping(_ isSuccessful: Bool) -> Void){
        if UserApi.isKakaoTalkLoginAvailable(){
            //카카오톡 어플 사용이 가능하다면
            UserApi.shared.loginWithKakaoTalk { authToken, error in
                //앱로그인
                guard error == nil else {
                    completion(false)
                    return
                }
                
                UserApi.shared.me { user, error in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    guard let email = user?.kakaoAccount?.email,
                          let id = user?.id else {
                        completion(true)
                        return
                    }
                    
                    if email == originalEmail {
                        Auth.auth().signIn(withEmail: "kakao/\(email)", password: "kakao/\(id)") { result, error in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        }
                    }else {
                        completion(false)
                    }
                    
                }
            }
                
        }else{
            //카카오톡 어플 사용이 불가하다면
            UserApi.shared.loginWithKakaoAccount { authToken, error in
                //계정로그인
                guard error == nil else {
                    completion(false)
                    return
                }
                
                UserApi.shared.me { user, error in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    guard let email = user?.kakaoAccount?.email,
                          let id = user?.id else {
                        completion(true)
                        return
                    }
                    
                    if email == originalEmail {
                        Auth.auth().signIn(withEmail: "kakao/\(email)", password: "kakao/\(id)") { result, error in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        }
                    }else {
                        completion(false)
                    }
                    
                }
            }
        }
    }
    

    func GoogleLogin(originalEmail: String, completion: @escaping(_ isSuccessful: Bool) -> Void){
        if let id = FirebaseApp.app()?.options.clientID {
            let config = GIDConfiguration(clientID: id)
            GIDSignIn.sharedInstance.configuration = config
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let presentingVC = window.rootViewController {
                
                guard let user = Auth.auth().currentUser else {
                    print("no user")
                    return
                }
                
                GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
                    if error != nil {
                        completion(false)
                    }
                    if let error = error{
                        print("google error: \(error)")
                        completion(false)
                    }else if let result = result{
                        print("google login success")
                        
                        guard let googleEmail = result.user.profile?.email else {
                            print("no email")
                            return
                        }
                        
                        //기존에 가입했던 구글 계정과 현재 계정 인증한 계정이 동일할 시에만 탈퇴 진행
                        if googleEmail == originalEmail {
                            guard let idToken = result.user.idToken?.tokenString else {print("no idToken");return}
                            let accessToken = result.user.accessToken.tokenString
                            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                            
                            Auth.auth().signIn(with: credential) { result, error in
                                if let error = error {
                                    print("sign in error: \(error)")
                                    completion(false)
                                }else{
                                    completion(true)
                                }
                            }
                        }else {
                            completion(false)
                        }
                        
                    }
                }
            }
                
        }
    }
    
    
    var currentNonce: String?
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
    

    
}
