//
//  WhiteButton.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared


struct WhiteButton: View {
    var title: String = ""
    var isEnabled: Bool = false
    var body: some View {
        VStack{
            Text(title)
                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .foregroundColor(.black)
        .background(isEnabled ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
        .shadow(color: Color.black.opacity(0.25), radius: 10, y: 6)

    }
}

//#Preview {
//    WhiteButton()
//}
