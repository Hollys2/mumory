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
    @Published var confirmPassword: String = ""
    
    @Published var isValidEmailStyle = false
    @Published var isAvailableEmail = false
    
    @Published var isCheckedRequiredItems: Bool = false
    @Published var isCheckedMarketingNotification: Bool = false
    @Published var isCheckedEventNotification: Bool = false

    @Published var genreList: [String] = []
    @Published var selectedTime = 0
    
    @Published var nickname = ""
    @Published var id = ""
    
    @Published var profileImageData: Data?
    @Published var profileImage: Image?


    

    public func getNavigationTitle() -> String {
        switch(step){
        case 0: return "이메일로 가입하기"
        case 1: return "비밀번호 입력하기"
        default: return ""
        }
    }
    
    public func getButtonTitle() -> String {
        switch(step){
        case 0, 1, 3, 4: return "다음"
        case 2: return "회원가입"
        case 5: return "완료"
        default: return ""
        }
    }
    
    public func isButtonEnabled() -> Bool {
        switch(step){
        case 0: return isValidEmailStyle && isAvailableEmail
        case 1: return isValidPassword() && isValidConfirmPassword()
        case 2: return isCheckedRequiredItems
        case 3: return genreList.count > 0
        case 4: return selectedTime != 0
        case 5: return id.count > 0 && nickname.count > 0
        default: return false
        }
    }

    
    //이메일 중복 체크
    public func checkEmail(){
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        if emailPredicate.evaluate(with: email){
            isValidEmailStyle = true
            
            let db = FirebaseManager.shared.db
            
            let emailCheckQuery = db.collection("User").whereField("email", isEqualTo: email)
            emailCheckQuery.getDocuments { snapshot, error in
                if let error = error {
                    print("getDocument error: \(error)")
                }else if let snapshot = snapshot {
                    self.isAvailableEmail = snapshot.documents.isEmpty
                }
            }
        }else{
            isValidEmailStyle = false
        }
        
      
    }
    
    
    public func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    public func isValidConfirmPassword() -> Bool {
        return (password == confirmPassword)
    }
    
    public func appendGenre(genre: String){
        if genreList.contains(where: {$0 == genre}){
            genreList.removeAll(where: {$0 == genre})
        }else {
            if genreList.count < 5 {
                genreList.append(genre)
            }
        }
    }
    
    public func contains(genre: String) -> Bool{
        return genreList.contains(where: {$0 == genre})
    }
}
