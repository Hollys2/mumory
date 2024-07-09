//
//  InputPasswordView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct PasswordInputView: View {
    // MARK: - Propoerties
    enum PasswordField {
        case password
        case confirm
    }
    
    enum PasswordValidationStatus {
        case none
        case error
        case valid
    }
    
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @FocusState private var focusedField: PasswordField?
    @State var password: String = ""
    @State var confirmPassword: String = ""
    
    @State private var timer: Timer?
    
    @State var passwordValidationStatus: PasswordValidationStatus = .none
    @State var confirmValidationStatus: PasswordValidationStatus = .none
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0){
                TitleTextForSignUpField(title: "비밀번호", topPadding: 43)
                
                RoundedSecureField(text: $password, placeHolder: "영문, 숫자, 특수기호로 모두 조합된 8~20자", fontSize: 16)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .onChange(of: password, perform: { value in
                        passwordValidationStatus = .none
                        signUpViewModel.isValidPassword = false
                    })
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        focusedField = .confirm
                    }
                
                FeedbackTextForSignUp(title: getFeedbackMsgOfPassword(),
                                      isValid: passwordValidationStatus == .valid)

                
                TitleTextForSignUpField(title: "비밀번호 확인", topPadding: 33)
                
                RoundedSecureField(text: $confirmPassword, placeHolder: "한 번 더 입력해 주세요!", fontSize: 16)
                    .padding(.horizontal, 20)
                    .padding(.top, 11)
                    .onChange(of: confirmPassword, perform: { value in
                        confirmValidationStatus = .none
                        signUpViewModel.isValidPassword = false
                    })
                    .focused($focusedField, equals: .confirm)
                    .onSubmit {
                        focusedField = .none
                    }
                
                FeedbackTextForSignUp(title: getFeedbackMsgOfConfirm(),
                                      isValid: confirmValidationStatus == .valid)

            }
        }
        .onAppear(perform: {
            if signUpViewModel.isValidPassword {
                guard let pw = signUpViewModel.password else {return}
                password = pw
            }
            setTimerToCheckValidation()
            focusedField = .password
        })
        .onDisappear(perform: {
            self.timer?.invalidate()
        })

    }
    
    
    // MARK: - Methods
    
    private func setTimerToCheckValidation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true, block: { _ in
            if password.isEmpty {
                passwordValidationStatus = .none
                confirmValidationStatus = .none
                return
            }
            
            guard isCorrectFormat() else {
                passwordValidationStatus = .error
                confirmValidationStatus = .none
                return
            }
            
            passwordValidationStatus = .valid
            
            if confirmPassword.isEmpty {
                return
            }
            
            guard isConfirmSameToPassword() else {
                confirmValidationStatus = .error
                return
            }
            
            passwordValidationStatus = .valid
            confirmValidationStatus = .valid
            signUpViewModel.isValidPassword = true
            signUpViewModel.password = self.password
        })
    }
    
    private func isCorrectFormat() -> Bool {
        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,20}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: self.password)
    }
    
    
    private func isConfirmSameToPassword() -> Bool {
        return self.password == self.confirmPassword
    }
    
    private func getFeedbackMsgOfConfirm() -> String {
        switch confirmValidationStatus {
        case .none:
            return ""
        case .error:
            return "비밀번호가 다릅니다. 다시 한 번 확인해 주세요."
        case .valid:
            return "비밀번호가 일치합니다."
        }
    }
    
    private func getFeedbackMsgOfPassword() -> String {
        switch passwordValidationStatus {
        case .none:
            return ""
        case .error:
            return "영문, 숫자, 특수기호로 모두 조합된 8~20자"
        case .valid:
            return "올바른 형식 입니다."
        }
    }
}
