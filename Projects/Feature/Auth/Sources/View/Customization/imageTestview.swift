//
//  imageTestview.swift
//  Feature
//
//  Created by 제이콥 on 2/29/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

struct imageTestview: View {
    var body: some View {
        VStack{
            AsyncImage(url: URL(string: "https://cdn.huffingtonpost.kr/news/photo/201903/80794_153503.jpeg")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 105, height: 105)
                    .clipShape(Circle())
            } placeholder: {
                EmptyView()
            }
            

                
        }
    }
}

//#Preview {
//    imageTestview()
//}
