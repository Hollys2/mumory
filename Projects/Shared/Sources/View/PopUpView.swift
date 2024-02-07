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
}

public struct PopUpView: View {
    
    var type: PopUpType
    var title: String
    var buttonTitle: String
    
        
    public init(type: PopUpType, title: String, buttonTitle: String) {
        self.type = type
        self.title = title
        self.buttonTitle = buttonTitle
    }
    
    public var body: some View {
        Rectangle()
          .foregroundColor(.clear)
          .frame(width: 312, height: 133)
          .background(Color(red: 0.16, green: 0.16, blue: 0.16))
          .overlay(
            VStack(spacing: 0) {
                Text(self.title)
                  .font(
                    Font.custom("Pretendard", size: 16)
                      .weight(.semibold)
                  )
                  .multilineTextAlignment(.center)
                  .foregroundColor(.white)
                  .padding(.top, 36)
                
                Spacer()
                
                HStack(spacing: 0) {
                    Button(action: {
                        // Handle button action
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
                              .font(Font.custom("Pretendard", size: 16))
                              .multilineTextAlignment(.center)
                              .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: {
                        // Handle button action
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
                              .font(
                                Font.custom("Pretendard", size: 16)
                                  .weight(.semibold)
                              )
                              .multilineTextAlignment(.center)
                              .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                        }
                    }
                } // HStack
            } // VStack
          )
          .cornerRadius(15)
    }
}

struct PopUpView_Previews: PreviewProvider {
    static var previews: some View {
        PopUpView(type: .twoButton, title: ("훈민정음"), buttonTitle: ("세종대황"))

    }
}
