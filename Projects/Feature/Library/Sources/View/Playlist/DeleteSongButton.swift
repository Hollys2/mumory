//
//  WhiteButton.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared


struct DeleteSongButton: View {
    var title: String = ""
    var isEnabled: Bool = false
    var action: () -> Void
    var deleteSongCount: Int
    
    init(title: String, isEnabled: Bool, deleteSongCount: Int, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.deleteSongCount = deleteSongCount
        self.action = action
    }
    
    var body: some View {
        
        Button(action: {
            action()
        }, label: {
            
            HStack(spacing: 0, content: {
                Text(title)
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                    .foregroundStyle(Color.black)
                    .padding(.trailing, 7)
                
                if deleteSongCount > 0 {
                    Text("\(deleteSongCount)")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                        .foregroundStyle(ColorSet.lightGray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ColorSet.moreDeepGray)
                        .clipShape(RoundedRectangle(cornerRadius: 40, style: .circular))
                }
            })
          
          
        })
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(isEnabled ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
        .padding(20)
        .shadow(color: Color.black.opacity(0.25), radius: 10, y: 6)
        .disabled(!isEnabled)


    }
}

#Preview {
    DeleteSongButton(title: "삭제", isEnabled: true, deleteSongCount: 1) {
        print("aaa")
    }
    
}
