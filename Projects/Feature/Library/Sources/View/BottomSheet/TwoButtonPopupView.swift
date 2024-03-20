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
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    private var lineGray = Color(red: 0.65, green: 0.65, blue: 0.65)
    
    var title: String
    var subTitle: String = ""
    var positiveButtonTitle: String
    var positiveAction: () -> Void
  
    
    init(title: String, positiveButtonTitle: String, positiveAction: @escaping () -> Void) {
        self.title = title
        self.positiveButtonTitle = positiveButtonTitle
        self.positiveAction = positiveAction

    }
    
    init(title: String, subTitle: String, positiveButtonTitle: String, positiveAction: @escaping () -> Void) {
        self.title = title
        self.subTitle = subTitle
        self.positiveButtonTitle = positiveButtonTitle
        self.positiveAction = positiveAction
    }
        
    var body: some View {
        ZStack(alignment: .center){
            Color.black.opacity(0.7).ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(alignment: .center, spacing: 0, content: {
                Text(title)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .padding(.top, subTitle.isEmpty ? 34 : 30)
                    .padding(.bottom, subTitle.isEmpty ? 34 : 14)

                Text(subTitle)
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .frame(height: subTitle.isEmpty ? 0 : nil)
                    .padding(.bottom, subTitle.isEmpty ? 0 : 32)
                
                Divider05()
                
                HStack(spacing: 0, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("취소")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    
                    Divider()
                        .frame(width: 0.5, height: 50)
                        .background(ColorSet.skeleton02)
                    
                    Button(action: {
                        Task {
                            positiveAction()
                        }
                        dismiss()
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
        .onDisappear {
            UIView.setAnimationsEnabled(true)
        }

    }
}

//#Preview {
//    TwoButtonPopupView()
//}
