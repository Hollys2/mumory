//
//  SignUpManageViewModel.swift
//  Feature
//
//  Created by 제이콥 on 1/30/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI
import Core

public class SignUpManageViewModel: ObservableObject{
    public init(){}
    @Published var step: Int = 0
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isValidEmail = false
    
    @Published var isValidPassword: Bool = false
    @Published var isValidConfirmPassword: Bool = false
    
    @Published var isCheckedRequiredItems: Bool = false
    @Published var isCheckedServiceNewsNotification: Bool = false
    
    @Published var isLoading: Bool = false

    public func getNavigationTitle() -> String {
        switch(step){
        case 0: return "이메일로 가입하기"
        case 1: return "비밀번호 입력하기"
        default: return ""
        }
    }
    
    public func getButtonTitle() -> String {
        switch(step){
        case 0, 1: return "다음"
        case 2: return "회원가입"
        default: return "다음"
        }
    }
    
    public func isButtonEnabled() -> Bool {
        switch(step){
        case 0: return isValidEmail
        case 1: return isValidPassword && isValidConfirmPassword
        case 2: return isCheckedRequiredItems
        default: return false
        }
    }
    

}
