//
//  PopUpView.swift
//  Shared
//
//  Created by 다솔 on 2024/01/09.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI


public enum PopUpType {
    case oneButton
    case twoButton
    case delete
    
    var height: CGFloat {
        switch self {
        case .oneButton:
            return 167
        case .twoButton:
            return 167
        case .delete:
            return 217
        }
    }
}

public struct PopUpView: View {
    
    @Binding private var isPopUpShown: Bool
    
    @State private var isButtonEnabled = true
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    
    var type: PopUpType
    var title: String
    var subTitle: String?
    var buttonTitle: String
    var buttonAction: (() -> Void)?
    
    //    public init(isShown: Binding<Bool>, type: PopUpType, title: String, subTitle: String? = nil, buttonTitle: String, buttonAction: @escaping () -> Void) {
    public init(isShown: Binding<Bool>, type: PopUpType, title: String, subTitle: String? = nil, buttonTitle: String, buttonAction: (() -> Void)? = nil) {
        self._isPopUpShown = isShown
        self.type = type
        self.title = title
        self.subTitle = subTitle
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
    
    public var body: some View {
        
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 312, height: self.type.height)
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(15)
            
            VStack(spacing: 0) {
                
                Text(self.title)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .frame(maxHeight: .infinity)
                
                if let subTitle = self.subTitle {
                    Text(subTitle)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .lineSpacing(2)
                        .frame(height: 52, alignment: .top)
                        .offset(y: -8)
                }
                
                switch self.type {
                case .oneButton:
                    HStack(spacing: 0) {
                        Button(action: {
                            self.isPopUpShown = false
                        }) {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 312, height: 50)
                                    .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                                    .overlay(
                                        Rectangle()
                                            .inset(by: -0.25)
                                            .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 0.3)
                                    )
                                
                                Text(self.buttonTitle)
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            }
                        }
                    }
                case .twoButton:
                    HStack(spacing: 0) {
                        Button(action: {
                            self.isPopUpShown = false
                        }) {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 156, height: 50)
                                    .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                                    .overlay(
                                        Rectangle()
                                            .inset(by: -0.25)
                                            .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 0.3)
                                    )
                                
                                Text("취소")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Button(action: {
                            isButtonEnabled = false
                            self.buttonAction?()
                            
//                            self.isShown = false // 추후 성공했을 때만 팝업창이 사라지게 하기
                        }) {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 156, height: 50)
                                    .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                                    .overlay(
                                        Rectangle()
                                            .inset(by: -0.25)
                                            .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 0.3)
                                    )
                                
                                Text(self.buttonTitle)
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            }
                        }
                        .disabled(!isButtonEnabled)
                    } // HStack
                case .delete:
                    VStack(spacing: 0) {
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                self.buttonAction?()
                                
//                                self.isPopUpShown = false
//                                withAnimation(.easeInOut(duration: 3)) {
//                                    self.appCoordinator.isCreateMumorySheetShown = false
//                                }
                                
                            }) {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 312, height: 50)
                                        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                                        .overlay(
                                            Rectangle()
                                                .inset(by: -0.25)
                                                .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 0.3)
                                        )
                                    
                                    Text("삭제하기")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                self.isPopUpShown = false
                            }) {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 312, height: 50)
                                        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                                        .overlay(
                                            Rectangle()
                                                .inset(by: -0.25)
                                                .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 0.3)
                                        )
                                    
                                    Text(self.buttonTitle)
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                                }
                            }
                        }
                    }
                }
            } // VStack
            .frame(height: self.type.height)
            .cornerRadius(15)
            
            if self.mumoryDataViewModel.isUpdating {
                Color.black.opacity(0.5).ignoresSafeArea()
                
                ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
            }
            
            if self.mumoryDataViewModel.isCreating {
                Color.black.opacity(0.5).ignoresSafeArea()
                
                ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}
