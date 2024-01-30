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

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetView(menuOptions: [])
    }
}
