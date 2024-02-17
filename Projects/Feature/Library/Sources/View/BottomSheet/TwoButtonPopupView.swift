//
//  TwoButtonPopup.swift
//  Feature
//
//  Created by 제이콥 on 2/18/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct TwoButtonPopupView: View {
    @EnvironmentObject var userManager: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var lineGray = Color(red: 0.65, green: 0.65, blue: 0.65)
    
    var positiveAction: () -> Void
    var title: String
    var positiveButtonTitle: String
    
    init( title: String, positiveButtonTitle: String, positiveAction: @escaping () -> Void) {
        self.title = title
        self.positiveButtonTitle = positiveButtonTitle
        self.positiveAction = positiveAction

    }

        
    var body: some View {
        ZStack(alignment: .center){
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0, content: {
                Text(title)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .padding(.top, 30)
                    .padding(.bottom, 30)
                
                Divider()
                    .frame(height: 0.5)
                    .frame(maxWidth: .infinity)
                    .background(lineGray)
                
                HStack(spacing: 0, content: {
                    Button(action: {
                        UIView.setAnimationsEnabled(false)
                        dismiss()
                    }, label: {
                        Text("취소")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    
                    Divider()
                        .frame(width: 0.5, height: 50)
                        .background(lineGray)
                    
                    Button(action: {
                        positiveAction()
                    }, label: {
                        Text(positiveButtonTitle)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                            .foregroundStyle(ColorSet.mainPurpleColor)
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    
                    
                })
            })
            .background(ColorSet.darkGray)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
            .padding(.horizontal, 40)
        }
        .onAppear(perform: {
            UIView.setAnimationsEnabled(false)
        })
        .onDisappear(perform: {
            UIView.setAnimationsEnabled(true)
        })

    }
}

//#Preview {
//    TwoButtonPopupView()
//}
