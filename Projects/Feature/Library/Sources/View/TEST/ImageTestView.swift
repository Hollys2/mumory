//
//  ImageTestView.swift
//  Feature
//
//  Created by 제이콥 on 2/15/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

struct ImageTestView: View {
    var string = ["Attempted to register account monitor for types client is not authorized to access: {(" , "아빠다리", "<ICMonitoredAccountStore: 0x280bfc390> Failed to register for account monitoring. err=Error Domain=com.apple.accounts Code=7", "흠냐리"]
    @State var title: String = "후에"
    @State var count: Int = 0
    @State var bool: Bool = true
    var body: some View {
        VStack{
            Button {
                title = string[count%4]
                count += 1
                withAnimation {
                    bool = true
                }
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                        bool.toggle()
                    }
                }
            } label: {
                Text("button")
            }
            .frame(width: 300)
            .overlay {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: bool ? .leading : .trailing)
                    .onAppear(perform: {
                        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                            bool.toggle()
                        }
                    })
                    .offset(y: 200)
            }
      
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                
                }
            }
        }
    }
}
