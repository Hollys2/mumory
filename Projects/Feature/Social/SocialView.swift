//
//  SocialView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/03.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI

struct SocialView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("소셜")
                      .font(
                        Font.custom("Pretendard", size: 24)
                          .weight(.semibold)
                      )
                      .foregroundColor(.white)
                
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Image("Search_BT")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    
                }
            }
        }
    }
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
    }
}
