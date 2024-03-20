//
//  AuthTextFieldSmall.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct AuthTextFieldSmall: View {
    @Binding var text: String
    var prompt: String = ""
    
    var body: some View {
        HStack(spacing: 0){
            TextField("", text: $text, prompt: getPrompt())
                .frame(maxWidth: .infinity)
                .padding(.leading, 25)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundColor(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            
            Button(action: {
                text = ""
            }, label: {
                SharedAsset.xWhiteCircle.swiftUIImage
                    .frame(width: 23, height: 23)
                    .padding(.trailing, 17)
                    .padding(.leading, 5)
                    .opacity(text.count > 0 ? 1 : 0)
            })
            
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
        .padding(.bottom, 18)
        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
        .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
    }
    
    func getPrompt() -> Text {
        return Text(prompt)
            .foregroundColor(ColorSet.subGray)
            .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 16))
    }
}

//#Preview {
//    AuthTextFieldSmall()
//}
