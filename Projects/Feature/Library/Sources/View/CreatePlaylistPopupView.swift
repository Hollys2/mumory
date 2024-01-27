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
    @State var isTapPublic: Bool = true
    var xButtonAction: () -> Void
//    var finishButtonAction: () -> Void
    var body: some View {
            VStack(spacing: 0){
                HStack{
                    Spacer()
                    SharedAsset.playerX.swiftUIImage
                        .frame(width: 25, height: 25)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            xButtonAction()
                        }
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
                    .padding(.top, 30)
                
                Menu {
                    Button(action: {
                        isTapPublic = true
                    }, label: {
                        Text("전체공개")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                            .foregroundStyle(.white)
                    })
                    
                    Button(action: {
                        isTapPublic = false
                    }, label: {
                        Text("나만보기")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                            .foregroundStyle(.white)
                    })
                    
                } label: {
                    HStack{
                        if isTapPublic{
                            SharedAsset.unlock.swiftUIImage
                            Text("전체공개")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                .foregroundStyle(LibraryColorSet.charSubGray)
                        }else{
                            SharedAsset.lock.swiftUIImage
                            Text("나만보기")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                .foregroundStyle(LibraryColorSet.charSubGray)
                        }
                        Spacer()
                        
                        SharedAsset.detail.swiftUIImage
                            .frame(width: 16, height: 16)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 17)
                    .padding(.bottom, 17)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    .background(LibraryColorSet.deepGray)
                    .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
                    .padding(.top, 30)
                    .menuStyle(DarkMenuStyle())
                }
                
                Button(action: {}, label: {
                    Text("만들기")
                        .frame(maxWidth: .infinity)
                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                        .foregroundStyle(.black)
                        .padding(.top, 17)
                        .padding(.bottom, 17)
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                        .background(LibraryColorSet.purpleBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
                        .padding(.leading, 30)
                        .padding(.trailing, 30)
                        .padding(.top, 30)
                })
            }
            .padding(.top, 20)
            .padding(.bottom, 44)
            .background(LibraryColorSet.background)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))

        
    }
    
    private func getPrompt() -> Text {
        return Text("플레이리스트 이름")
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
            .foregroundColor(LibraryColorSet.subGray)
    }
}

struct DarkMenuStyle: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .background(Color.black) // 배경색을 검은색으로 설정합니다.
            .foregroundColor(.white) // 텍스트 색상을 흰색으로 설정합니다.
    }
}

//#Preview {
//    CreatePlaylistPopupView()
//}
