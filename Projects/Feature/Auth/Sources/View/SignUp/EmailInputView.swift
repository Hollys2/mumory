//
//  SignUpViewEmailView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core


public struct EmailInputView: View {
    // MARK: - Object lifecycle
    init() {}
    
    // MARK: - Propoerties
    ///유효성 검사 결과 타입
    public enum EmailValidationStatDate {
        case none
        case valid
        case formatError
        case duplicationError
    }
    
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @State var email: String = ""
    @State var previousEmail: String = ""
    @State var timer: Timer?
    @State private var validationStatus: EmailValidationStatDate = .none
    @FocusState var isFocused: Bool
    
    // MARK: - View
    public var body: some View {
        VStack(spacing: 0, content: {
            
            TitleTextForSignUpField(title: "이메일", topPadding: 43)
            
            AuthTextField_16(text: $email, prompt: "ex) abcdefg@hhhhh.com")
                .padding(.top, 14)
                .padding(.horizontal, 20)
                .focused($isFocused)
                .onChange(of: email, perform: { value in
                    setSignUpData(status: .none)
                    if !(timer?.isValid ?? false) {
                        setTimerFunctionedForCheckingEmailValidation()
                    }
                })
            
            FeedbackTextForSignUp(title: getFeedbackMsg(), isValid: signUpViewModel.isValidEmail)
        })
        .onAppear(perform: {
            if signUpViewModel.isValidEmail {
                self.email = signUpViewModel.email
            }
            setTimerFunctionedForCheckingEmailValidation()
        })
        .onDisappear(perform: {
            self.timer?.invalidate()
        })
    }
    
    // MARK: - Methods
    private func setTimerFunctionedForCheckingEmailValidation() {
        self.previousEmail = self.email
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            signUpViewModel.isLoading = true
            guard !email.isEmpty else {
                setSignUpData(status: .none)
                return
            }
            
            let isEndEditing = (previousEmail == email)
            guard isEndEditing else {
                previousEmail = email
                return
            }
            
            guard isCorrectFormat() else {
                setSignUpData(status: .formatError)
                return
            }
            
            Task {
                if await isValidEmail() {
                    setSignUpData(status: .valid)
                    self.timer?.invalidate()
                } else {
                    setSignUpData(status: .duplicationError)
                }
            }
            
        }
    }
    
    private func isCorrectFormat() -> Bool{
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: self.email)
    }
    
    private func isValidEmail() async -> Bool {
        let db = FirebaseManager.shared.db
        let query = db.collection("User").whereField("email", isEqualTo: email)
        guard let documents = try? await query.getDocuments() else {return false}
        
        return documents.isEmpty
    }
    
    private func getFeedbackMsg() -> String {
        switch self.validationStatus {
        case .valid:
            return "올바른 형식 입니다."
        case .formatError:
            return "이메일 형식이 올바르지 않습니다. :("
        case .duplicationError:
            return "이미 사용 중인 이메일입니다."
        default: return ""
        }
    }
    
    ///유효성 결과 설정 및 로딩 상태, 회원가입 뷰모델 내부 이메일 값 수정
    private func setSignUpData(status: EmailValidationStatDate) {
        self.validationStatus = status
        switch status {
        case .valid:
            signUpViewModel.isValidEmail = true
            signUpViewModel.email = self.email
        default:
            signUpViewModel.isValidEmail = false
            signUpViewModel.email = ""
        }
        signUpViewModel.isLoading = false
    }
}
