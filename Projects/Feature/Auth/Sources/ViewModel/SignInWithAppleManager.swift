//
//  AppleSignInManager.swift
//  Feature
//
//  Created by 제이콥 on 2/5/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth

public class SignInWithAppleManager: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    @Published var isUserAuthenticated = false
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
            print("credential1122")
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("sign in with firebase error: \(error)")
                }else if let result = result {
                    print("sign in successful")
                    self.isUserAuthenticated = true
                }
            }
        }
    }
    

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first ?? UIWindow()
    }
}
