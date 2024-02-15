//
//  BottomSheetView.swift
//  Shared
//
//  Created by 다솔 on 2024/01/09.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI


public struct BottemSheetMenuOption: Identifiable {
    
    public let id = UUID()
    public let iconImage: Image
    public let title: String
    public let action: () -> Void
    
    public init(iconImage: Image, title: String, action: @escaping () -> Void) {
        self.iconImage = iconImage
        self.title = title
        self.action = action
    }
}

public struct BottomSheetView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var menuOptions: [BottemSheetMenuOption]
    
    public init(menuOptions: [BottemSheetMenuOption]) {
        self.menuOptions = menuOptions
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 9)
            
            Image(uiImage: SharedAsset.dragIndicator.image)
                .resizable()
                .frame(width: 47, height: 4)
            
            Spacer().frame(height: 9)
            
            VStack(spacing: 0) {
                ForEach(menuOptions) { option in
                    Button(action: option.action) {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 20)
                            
                            option.iconImage
                                .frame(width: 30, height: 30)
                            
                            Spacer().frame(width: 10)
                            
                            Text(option.title)
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    }
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.5)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                }
                
            }
            .frame(width: UIScreen.main.bounds.width - 14 - 18, height: 54 * CGFloat(menuOptions.count))
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            .cornerRadius(15)
            
            Spacer().frame(height: 9)
        }
        .frame(width: UIScreen.main.bounds.width - 14, height: 54 * CGFloat(menuOptions.count) + 31)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(15)
    }
}

public struct SecondBottomSheetView: View {
    
    @Binding var locationTitleText: String
    @Binding var isShown: Bool
    
    @State private var searchText: String
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public init(isShown: Binding<Bool>, locationTitleText: Binding<String>, searchText: String) {
        self._isShown = isShown
        self._locationTitleText = locationTitleText
        self.searchText = searchText
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 9)
            
            Image(uiImage: SharedAsset.dragIndicator.image)
                .resizable()
                .frame(width: 47, height: 4)
            
            Spacer().frame(height: 33)
            
            VStack(spacing: 0) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("선택한 장소의 이름을 직접 입력해주세요")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("해당 장소에 대해 기억하기 쉬운 이름으로 변경해보세요")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 10)
                        .padding(.bottom, 33)
                }
                .padding(.horizontal, 10)
                
                ZStack(alignment: .leading) {
                    TextField("가나다라마바사", text: $searchText,
                              prompt: Text("장소명 입력").font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .padding(.horizontal, 25)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                    )
                    .foregroundColor(.white)
                    
                    if !self.searchText.isEmpty {
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                self.searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 17)
                    }
                }
                
                Button(action: {
                    self.locationTitleText = self.searchText
                    self.searchText = ""
                    
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.isShown = false
                    }
                }) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(self.searchText.isEmpty ? Color(red: 0.47, green: 0.47, blue: 0.47) : SharedAsset.mainColor.swiftUIColor)
                        .cornerRadius(35)
                        .overlay(
                            Text("완료")
                                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                        )
                        .padding(.top, 33)
                }
                .disabled(self.searchText.isEmpty)
              
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .frame(width: UIScreen.main.bounds.width - 14, height: 287)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(15)
    }
}



