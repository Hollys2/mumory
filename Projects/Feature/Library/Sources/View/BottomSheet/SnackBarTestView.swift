//
//  SnackBarTestView.swift
//  Feature
//
//  Created by 제이콥 on 3/18/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

struct SnackBarTestView: View {
    @State var isPresent: Bool = false
    var body: some View {
        ZStack(alignment: .top){
            VStack{
                if isPresent {
                    
                    Text("스낵바 알림!")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.yellow)
                        .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top)))
                        .padding(.top, 30)
                }
                Spacer()
            }
            
            
        }
        
        .onAppear {
            UIView.setAnimationsEnabled(true)
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                withAnimation {
                    isPresent = true
                }
            }
            
            Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { timer in
                withAnimation {
                    isPresent = false
                }
            }
            
        }
    }
}

#Preview {
    SnackBarTestView()
}
