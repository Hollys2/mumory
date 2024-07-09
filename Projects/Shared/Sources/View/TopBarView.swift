//
//  TopBarView.swift
//  Shared
//
//  Created by 다솔 on 2024/01/30.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI


public struct TopBarView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    let title: String
    let rightBarButtonNavigationPath: Int?
    let paddingBottom: CGFloat
    
    public init(title: String, rightBarButtonNavigationPath: Int? = nil, paddingBottom: CGFloat) {
         self.title = title
         self.rightBarButtonNavigationPath = rightBarButtonNavigationPath
         self.paddingBottom = paddingBottom
     }
    
    public var body: some View {
        
        ZStack {
            
            HStack(spacing: 0) {
                
                Button(action: {
                    self.appCoordinator.rootPath.removeLast()
                }, label: {
                    SharedAsset.backButtonTopBar.swiftUIImage
                        .resizable()
                        .frame(width: 30, height: 30)
                })
                
                Spacer()
                
//                if let rightBarButtonNavigationPath = self.rightBarButtonNavigationPath {
//                    Button(action: {
//                        self.appCoordinator.rootPath.append(rightBarButtonNavigationPath)
//                    }, label: {
//                        SharedAsset.searchButtonMypage.swiftUIImage
//                            .resizable()
//                            .frame(width: 30, height: 30)
//                    })
//                }
            }
            
            Text("\(title)")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .frame(height: 65)
        .padding(.horizontal, 20)
        .overlay(
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width, height: 0.5)
                .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
            , alignment: .bottom
        )
    }
}

