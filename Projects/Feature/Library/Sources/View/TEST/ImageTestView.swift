//
//  ImageTestView.swift
//  Feature
//
//  Created by 제이콥 on 2/15/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

struct ImageTestView: View {
    var body: some View {
        VStack{
            AsyncImage(url: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/01/b8/24/01b8243d-bbe1-478f-7856-2e90424e5b58/886448342465.jpg")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            } placeholder: {
                Rectangle()
                    .frame(width: 100, height: 100)
            }

        }
    }
}

#Preview {
    ImageTestView()
}
