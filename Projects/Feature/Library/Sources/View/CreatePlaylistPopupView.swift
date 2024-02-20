//
//  CreatePlaylistPopupView.swift
//  Feature
//
//  Created by 제이콥 on 1/26/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core

struct CreatePlaylistPopupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserViewModel
    
    @State var playlistTitle: String = ""
    @State var isTapPublic: Bool = true
    @State var backgroundOpacity = 0.0
    
    let titleMaxLength = 30
    
    var body: some View {
        ZStack{
            Color.black.opacity(backgroundOpacity).ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 0){
                HStack{
                    Spacer()
                    SharedAsset.playerX.swiftUIImage
                        .frame(width: 25, height: 25)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            UIView.setAnimationsEnabled(true)
                            backgroundOpacity = 0
                            dismiss()
                        }
                }
                
                Text("새 플레이리스트")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                    .foregroundStyle(.white)
                
                HStack(spacing: 0) {
                    Text("\(playlistTitle.count) ")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                        .foregroundStyle(ColorSet.mainPurpleColor)
                    
                    Text("/ 30")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                        .foregroundStyle(ColorSet.subGray)

                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 45)
                .padding(.top, 30)

                
                TextField("playlist_textfield", text: $playlistTitle, prompt: getPrompt())
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .padding(.vertical, 17)
                    .padding(.horizontal, 25)
                    .background(LibraryColorSet.deepGray)
                    .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    .onChange(of: playlistTitle) { value in
                        if value.count > 30 {
                            playlistTitle = String(value.prefix(30))
                        }
                    }
                
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
                    .padding(.vertical, 17)
                    .padding(.horizontal, 25)
                    .background(LibraryColorSet.deepGray)
                    .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
                    .padding(.horizontal, 30)
                    .padding(.top, 15)
                    .menuStyle(DarkMenuStyle())
                }
                
                Button(action: {
                    createPlaylist()
                }, label: {
                    Text("만들기")
                        .frame(maxWidth: .infinity)
                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                        .foregroundStyle(.black)
                        .padding(.vertical, 17)
                        .padding(.horizontal, 25)
                        .background(LibraryColorSet.purpleBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
                        .padding(.horizontal, 30)
                        .padding(.top, 40)
                })
            }
            .padding(.top, 20)
            .padding(.bottom, 44)
            .background(LibraryColorSet.background)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
            .padding(.horizontal, 40)
            
        }
        .onAppear(perform: {
            withAnimation(.easeIn(duration: 0.5)){
                backgroundOpacity = 0.7
            }
        })
    }
    
    
    private func getPrompt() -> Text {
        return Text("플레이리스트 이름")
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
            .foregroundColor(LibraryColorSet.subGray)
    }
    
    private func createPlaylist() {
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        
        let data: [String: Any] = [
            "title": playlistTitle,
            "is_private": !isTapPublic,
            "song_IDs": [],
            "is_favorite": false
        ]
        
        db.collection("User").document(userManager.uid).collection("Playlist").addDocument(data: data) { error in
            if error == nil {
                print("success")
                UIView.setAnimationsEnabled(true)
                dismiss()
            }
        }
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
