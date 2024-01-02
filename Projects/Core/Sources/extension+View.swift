//
//  extension+View.swift
//  Core
//
//  Created by 다솔 on 2023/12/20.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI

extension View {
    
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
    }
}

enum PopUpType {
    case oneButton
    case twoButton
}
//
//func handleScrollDirection(_ direction: ScrollDirection) {
//    switch direction {
//    case .up:
//        withAnimation(Animation.easeInOut(duration: 0.2)) {
//            parent.appCoordinator.isNavigationBarShown = true
//        }
//    case .down:
//        withAnimation(Animation.easeInOut(duration: 0.2)) {
//            parent.appCoordinator.isNavigationBarShown = false
//        }
//    }
//}

public struct PopUpView: View {
    
    @Binding var type: PopUpType
        
    init(type: Binding<PopUpType>) {
        self._type = type
    }
    
    public var body: some View {
        Rectangle()
          .foregroundColor(.clear)
          .frame(width: 312, height: 133)
          .background(Color(red: 0.16, green: 0.16, blue: 0.16))
          .cornerRadius(15)
          .overlay(
            VStack(spacing: 0) {
                Text("나의 댓글을 삭제하시겠습니까?")
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
                                .cornerRadius(15, corners: [.bottomLeft])
                                .overlay(
                                    Rectangle()
                                        .inset(by: 0.25)
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
                                .cornerRadius(15, corners: [.bottomRight])
                                .overlay(
                                    Rectangle()
                                        .inset(by: 0.25)
                                        .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 0.3)
                                )
                            
                            Text("댓글 삭제")
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
    }
}


struct MumoryDetailCommentSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PopUpView(type: .constant(.oneButton))
    }
}
