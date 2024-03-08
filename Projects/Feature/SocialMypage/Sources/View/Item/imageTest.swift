//
//  imageTest.swift
//  Feature
//
//  Created by 제이콥 on 3/8/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

struct imageTest: View {
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                AsyncImage(url: URL(string: "https://image.yes24.com/goods/94055089/XL")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray)
                }
                AsyncImage(url: URL(string: "https://image.yes24.com/goods/94055089/XL")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray)
                }

            })
            HStack(spacing: 0, content: {
                AsyncImage(url: URL(string: "https://image.yes24.com/goos/94055089/XL")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray)
                }
                AsyncImage(url: URL(string: "https://image.yes24.com/goods/94055089/XL")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray)
                }
            })
        })
    }
}

#Preview {
    imageTest()
        .frame(width: 200, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
}
