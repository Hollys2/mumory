//
//  SlideTestView.swift
//  Feature
//
//  Created by 제이콥 on 2/24/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct SlideTestView: View {
    @State var toggle: Bool = false
    @State var title = "어쩔frame 영역을 지정해주지 않으면 콘텐츠 자체가 차지하는 영역이 기본 영역이다."
    var titlelist = [
        "아이폰15에욤",
        "안녕하세요! 제39대 총학생회 CHALLENGE입니다 요로시쿠오네가이시마스",
        "톽쉑시",
        "뿌링클클"
        
    ]
    var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            VStack{
                
                Text(title)
                    .fixedSize(horizontal: true, vertical: false)
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 20))
                    .foregroundStyle(Color.white)
                    .animation(.linear(duration: 5.0).delay(1.0).repeatForever(autoreverses: true), value: toggle)
                    .frame(maxWidth: 280, alignment: toggle ? .trailing : .leading)
                    .clipped()
                    .onAppear(perform: {
                        toggle.toggle()
                    })
                
                
                Button(action: {
                    self.title = titlelist[Int.random(in: 0..<4)]
                }, label: {
                    Text("Button")
                })
               
            }
        }
    }
    
    private func getTextWidth(term: String) -> CGFloat {
        let fontAttribute = [NSAttributedString.Key.font: SharedFontFamily.Pretendard.bold.font(size: 20)]
        let width = (term as NSString).size(withAttributes: fontAttribute).width
        return width
    }
    
}

//#Preview {
//    SlideTestView()
//}
