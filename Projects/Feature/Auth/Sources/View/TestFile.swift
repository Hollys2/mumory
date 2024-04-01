//
//  TestFile.swift
//  App
//
//  Created by 제이콥 on 1/27/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct TestFile: View {
    @State var email: String = ""
    var body: some View {
        HStack(spacing: 0){
            TextField("email", text: $email)
                .frame(maxWidth: .infinity)
                .padding(.leading, 25)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundColor(.white)
            
            SharedAsset.xWhiteCircle.swiftUIImage
                .resizable()
                .frame(width: 23, height: 23)
                .padding(.trailing, 17)
                .padding(.leading, 5)
                .onTapGesture {
                    email = ""
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))    }
}

//#Preview {
//    TestFile()
//}
