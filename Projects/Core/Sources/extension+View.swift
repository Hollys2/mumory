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

// View.clipShape(RoundedCorner(radius: , corners: ))
struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
    }
}

extension View {
    
    public func pageLabel() -> some View {
        self.frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 42)
    }
    
    public func pageView() -> some View {
        self.frame(width: getUIScreenBounds().width, alignment: .center)
    }
    
    public func getUIScreenBounds() -> CGRect {
        //        return UIScreen.main.bounds
        UIScreen.main.bounds
    }
    
    public func getSafeAreaInsets() -> UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            let safeAreaInsets = window.safeAreaInsets
            
            return safeAreaInsets
        }
        
        return UIEdgeInsets.zero
    }
    
    public func calendarPopup<Content: View>(show: Binding<Bool>, yOffset: CGFloat, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                
                ZStack(alignment: .topLeading) {
                    
                    if show.wrappedValue {
                        
                        Color.black.opacity(0.01)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea()
                            .highPriorityGesture(DragGesture().onChanged() { _ in
                            })
                            .onTapGesture {
                                show.wrappedValue = false
                            }
                            .offset(y: -16)
                        
                        content()
                            .frame(width: 280, height: 279)
                            .cornerRadius(15)
                            .offset(x: 50, y: yOffset + 8)
                    }
                }
                
                , alignment: .topLeading
            )
    }
    
    public func popup<Content: View>(show: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                
                ZStack {
                    
                    if show.wrappedValue {
                        
                        Color.black.opacity(0.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea()
                            .onTapGesture {
                                show.wrappedValue = false
                            }
                        
                        content()
                    }
                }
                
                , alignment: .topLeading
            )
    }

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
