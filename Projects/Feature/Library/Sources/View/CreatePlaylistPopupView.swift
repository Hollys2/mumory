//
//  CreatePlaylistPopupView.swift
//  Feature
//
//  Created by 제이콥 on 1/26/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct CreatePlaylistPopupView: View {
    @State var playlistTitle: String = ""
    var body: some View {
        ZStack{
            LibraryColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0){
                HStack{
                    Spacer()
                    SharedAsset.playerX.swiftUIImage
                        .frame(width: 25, height: 25)
                        .padding(.trailing, 20)
                }
                
                Text("새 플레이리스트")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                    .foregroundStyle(.white)
                
                TextField("playlist_textfield", text: $playlistTitle, prompt: getPrompt())
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .padding(.top, 17)
                    .padding(.bottom, 17)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    .background(LibraryColorSet.deepGray)
                    .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
                
                Menu {
                    Text("aaa")
                } label: {
                    Text("bbb")
                }
                
                
                
                GroupBox {
                    DisclosureGroup("Menu 1") {
                        Text("Item 1")
                        Text("Item 2")
                        Text("Item 3")
                    }
                }


                
            }
        }
    }
    
    private func getPrompt() -> Text {
        return Text("플레이리스트 이름")
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
            .foregroundColor(LibraryColorSet.subGray)
    }
}

#Preview {
    CreatePlaylistPopupView()
}
