//
//  AppleSignInButton.swift
//  Feature
//
//  Created by 제이콥 on 6/18/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Shared
import UIKit


struct AppleSignInButton: UIViewControllerRepresentable {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    typealias UIViewControllerType = UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        
        let buttonBackground = UIView()
        buttonBackground.backgroundColor = UIColor.black
        buttonBackground.clipsToBounds = true
        buttonBackground.layer.cornerRadius = 30
        
        let appleLogo: UIImageView = UIImageView(image: SharedAsset.apple.image)
        appleLogo.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        
        let title = UILabel()
        title.font = UIFont(font: SharedFontFamily.Pretendard.semiBold, size: 16)
        title.textColor = UIColor.white
        title.text = "Apple로 로그인"

        let contentHorizStack: UIStackView = UIStackView()
        contentHorizStack.axis = .horizontal
        contentHorizStack.spacing = 18
        contentHorizStack.addArrangedSubview(appleLogo)
        contentHorizStack.addArrangedSubview(title)

        vc.view.addSubview(buttonBackground)
        buttonBackground.addSubview(contentHorizStack)
        
        buttonBackground.translatesAutoresizingMaskIntoConstraints = false
        contentHorizStack.translatesAutoresizingMaskIntoConstraints = false
        appleLogo.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonBackground.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            buttonBackground.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            buttonBackground.topAnchor.constraint(equalTo: vc.view.topAnchor),
            buttonBackground.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            contentHorizStack.centerXAnchor.constraint(equalTo: buttonBackground.centerXAnchor),
            contentHorizStack.centerYAnchor.constraint(equalTo: buttonBackground.centerYAnchor)
        ])
        
        buttonBackground.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.performSignIn)))
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> AppleSignInCoordinator {
        AppleSignInCoordinator(appCoordinator: appCoordinator, signUpViewModel: signUpViewModel, currentUserViewModel: currentUserViewModel)
    }
    
    
    class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        init(appCoordinator: AppCoordinator, signUpViewModel: SignUpViewModel, currentUserViewModel: CurrentUserViewModel) {
            self.appCoordinator = appCoordinator
            self.signUpViewModel = signUpViewModel
            self.currentUserViewModel = currentUserViewModel
        }
        var appCoordinator: AppCoordinator
        var signUpViewModel: SignUpViewModel
        var currentUserViewModel: CurrentUserViewModel
        var currentNonce: String?
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
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
                
                Task {
                    let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
                    if let email = appleIDCredential.email {
                        signUpViewModel.setSignUpData(method: .apple, email: email, appleCredential: credential)
                        appCoordinator.push(destination: AuthPage.signUpCenter)
                    } else {
                        guard let result = try? await FirebaseManager.shared.auth.signIn(with: credential) else {return}
                        if await currentUserViewModel.initializeUserData() {
                            appCoordinator.isHomeViewShown = true
                            appCoordinator.isLoginViewShown = false
                        }
                    }
                }
                
            }
        }

        @objc public func performSignIn() {
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
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first ?? UIWindow()
        }
    }
    
}



