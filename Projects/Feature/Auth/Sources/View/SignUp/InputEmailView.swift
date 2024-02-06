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

public struct InputEmailView: View {
    @EnvironmentObject var manager: SignUpManageViewModel
    @State var email: String = ""
    @State var errorText: String = ""
    @State var localTimer = 0.0
    @State var isGoodEmail: Bool = false //중복X
    @State var isValidStyle: Bool = false //이메일형식O
    @State var timer: Timer?
    public init(){}
    
    public var body: some View {
            VStack(spacing: 0, content: {
                //이메일 표시 텍스트
                Text("이메일")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 23)
                    .padding(.top, 43)
                
                //이메일 입력 텍스트 필드
                AuthTextFieldSmall(text: $email, prompt: "ex) abcdefg@hhhhh.com")
                    .padding(.top, 14)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .onChange(of: email, perform: { value in
                        localTimer = 0
                        isValidEmail(email: value.lowercased())
                    })
                    .onChange(of: localTimer, perform: { value in
                        if localTimer > 1 && localTimer < 2 {
                            if isValidStyle {
                                checkValidEmail()
                            }
                        }
                    })
                
                //이메일 형식 오류 텍스트
                Text(errorText)
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                    .foregroundColor(Color(red: 1, green: 0.34, blue: 0.34))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)
                    .padding(.top, 15)
            })
            .onAppear(perform: {
                if manager.isValidEmail {
                    email = manager.email
                }
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    localTimer += 0.5
                }
            })
            .onDisappear(perform: {
                self.timer?.invalidate()
            })
 
        
    }
    
    private func getErrorMessage() -> String {
        if email.count > 0 {
            if manager.isValidEmailStyle {
                if manager.isAvailableEmail{
                    return ""
                }else {
                    return "이미 사용 중인 이메일입니다."
                }
            }else {
                return "이메일 형식이 올바르지 않습니다. :("
            }
        }else {
            return ""
        }
    }
    
    private func isValidEmail(email: String) {
        manager.isValidEmail = false
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
         emailPredicate.evaluate(with: email)
        
        
        isValidStyle = emailPredicate.evaluate(with: email)
        errorText = isValidStyle ? "" : "이메일 형식이 올바르지 않습니다. :("
    }
    
    private func checkValidEmail(){
        print("check valid email")
        let db = FirebaseManager.shared.db
        
        let emailCheckQuery = db.collection("User").whereField("email", isEqualTo: email)
        emailCheckQuery.getDocuments { snapshot, error in
            if let error = error {
                print("getDocument error: \(error)")
            }else if let snapshot = snapshot {
                if snapshot.isEmpty {
                    errorText = ""
                    manager.isValidEmail = true
                    manager.email = email
                }else {
                    errorText = "이미 사용 중인 이메일입니다."
                    manager.isValidEmail = false
                }
            }
        }
    }
}

//#Preview {
//    InputEmailView()
//}
