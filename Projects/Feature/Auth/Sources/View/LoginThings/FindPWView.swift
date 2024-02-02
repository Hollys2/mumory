//
//  FindPWView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core

struct FindPWView: View {
    @Environment(\.dismiss) private var dismiss
    @State var email: String = ""
    @State var isEmailStyle: Bool = false
    var body: some View {
        GeometryReader(content: { geometry in
        ZStack{
            LibraryColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                //상단 타이틀
                Text("비밀번호 찾기")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 22))
                    .foregroundColor(.white)
                    .padding(.top, 30)
                
                //이메일 텍스트 필드(재사용)
                AuthTextField(text: $email, prompt: "이메일")
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                    .padding(.top, 55)
                    .onChange(of: email, perform: { value in
                        isEmailStyle = isValidEmailStyle(email: value)
                    })
                
                //로그인 버튼(재사용)
                WhiteButton(title: "비밀번호 찾기", isEnabled: isEmailStyle)
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                    .padding(.top, 12)
                    .disabled(!isEmailStyle)
                
                //로그인 오류 텍스트
                Text("이메일 형식이 올바르지 않습니다 :(")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                    .foregroundColor(Color(red: 1, green: 0.34, blue: 0.34))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 60)
                    .padding(.top, 15)
                    .opacity(email.count < 1 ? 0 : isEmailStyle ? 0 : 1)
                
                Spacer()
            })
            
        }
        .frame(width: geometry.size.width + 1)
        .background(LibraryColorSet.background)
        .navigationBarBackButtonHidden()
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                SharedAsset.back.swiftUIImage
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        dismiss()
                    }
            }
        })
        .onTapGesture {
            self.hideKeyboard()
        }
        })
    }
    
    private func tapFindPWButton(){
        let auth = FirebaseManager.shared.auth
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                //다시 시도해주세요팝업
                print(error)
            }
        }
    }
    
    private func isValidEmailStyle(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
}

#Preview {
    FindPWView()
}
