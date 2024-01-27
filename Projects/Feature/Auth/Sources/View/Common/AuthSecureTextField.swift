//
//  AuthTextField.swift
//  Feature
//
//  Created by 제이콥 on 12/9/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct AuthSecureTextField: View {
    @Binding var text: String
    var prompt: String = ""

    var body: some View {
        HStack(spacing: 0){
            SecureField("", text: $text, prompt: getPrompt())
                .frame(maxWidth: .infinity)
                .padding(.leading, 25)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                .foregroundColor(.white)
            
            SharedAsset.xWhiteCircle.swiftUIImage
                .frame(width: 23, height: 23)
                .padding(.trailing, 17)
                .padding(.leading, 5)
                .onTapGesture {
                    text = ""
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
        

    }
    
    func getPrompt() -> Text {
        return Text(prompt)
            .foregroundColor(Color(red: 0.77, green: 0.77, blue: 0.77))
            .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 18))
    }
}

//#Preview {
//    AuthTextField()
//}
