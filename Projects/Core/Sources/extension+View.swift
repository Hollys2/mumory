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
        self.clipShape(RoundedCorner(radius: radius, corners: corners))
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


extension View {
    
    public func pageLabel() -> some View {
        self.frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 42)
    }
    
    public func pageView() -> some View {
        self.frame(width: getUIScreenBounds().width, alignment: .center)
    }
    
    public func getUIScreenBounds() -> CGRect {
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
    
    public func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.height < 800
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
                            .onTapGesture {
                                show.wrappedValue = false
                            }
                        
                        content()
                            .frame(width: 280)
                            .cornerRadius(15)
                            .offset(x: 50, y: yOffset + 8)
                    }
                }
                , alignment: .topLeading
            )
    }
    
    public func popup<Content: View>(show: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(PopupModifier(show: show, content: content))
    }
}

struct PopupModifier<PopupContent: View>: ViewModifier {
    @Binding var show: Bool
    let content: () -> PopupContent
    
    func body(content: Content) -> some View {
        ZStack {
            content // Original content
            
            if show {
                Color.red.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            show = false
                        }
                    }
                
                self.content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 20)
                    .padding(40)
                    .transition(.scale)
                    .zIndex(1)
            }
        }
    }
}
