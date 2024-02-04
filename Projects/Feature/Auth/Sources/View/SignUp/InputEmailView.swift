//
//  SignUpViewEmailView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

public struct InputEmailView: View {
    @EnvironmentObject var manager: SignUpManageViewModel
    @State var email: String = ""
    
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
                        manager.email = value.lowercased()
                        manager.checkEmail()
                    })
                
                //이메일 형식 오류 텍스트
                Text(getErrorMessage())
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                    .foregroundColor(Color(red: 1, green: 0.34, blue: 0.34))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)
                    .padding(.top, 15)
            })
            .onAppear(perform: {
                if manager.isValidEmailStyle && manager.isAvailableEmail {
                    email = manager.email
                }
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
}

//#Preview {
//    InputEmailView()
//}