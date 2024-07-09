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
    enum PlaylistType {
        case new
        case old
    }
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @State var isLoading: Bool = false
    @State var playlistTitle: String = ""
    @State var isTapPublic: Bool = true
    @State var backgroundOpacity = 0.0
    var title: String = "새 플레이리스트"
    let titleMaxLength = 30
    
    var body: some View {
        ZStack{
            Color.black.opacity(backgroundOpacity).ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 0){
                HStack{
                    Spacer()
                    SharedAsset.playerX.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            backgroundOpacity = 0
                            dismiss()
                        }
                }
                
                Text(title)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                    .foregroundStyle(.white)
                    .padding(.top, 5)
                
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
                    .frame(height: 50)
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
                            .id("publicMenu")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                            .foregroundStyle(.white)
                    })
                    
                    Button(action: {
                        isTapPublic = false
                    }, label: {
                        Text("나만보기")
                            .id("privateMenu")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                            .foregroundStyle(.white)
                    })
                    
                } label: {
                    HStack{
                        if isTapPublic{
                            SharedAsset.unlock.swiftUIImage
                            Text("전체공개")
                                .id("publicLabel")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                .foregroundStyle(LibraryColorSet.charSubGray)
                        }else{
                            SharedAsset.lock.swiftUIImage
                            Text("나만보기")
                                .id("privateLabel")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                .foregroundStyle(LibraryColorSet.charSubGray)
                        }
                        Spacer()
                        
                        SharedAsset.detail.swiftUIImage
                            .frame(width: 16, height: 16)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
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
                    CommonLoadingButtonSmall(title: "만들기", isEnabled: !playlistTitle.isEmpty, isLoading: $isLoading)
                        .padding(.horizontal, 30)
                })
                .frame(height: 50)
                .padding(.top, 40)
                .disabled(playlistTitle.isEmpty)
            }
            .padding(.top, 20)
            .padding(.bottom, 44)
            .background(LibraryColorSet.background)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
            .frame(width: getUIScreenBounds().width * 0.8)

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
        isLoading = true
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        
        let data: [String: Any] = [
            "title": playlistTitle,
            "isPublic": isTapPublic,
            "songIds": [],
            "date": Date()
        ]
        
        db.collection("User").document(currentUserViewModel.user.uId).collection("Playlist").addDocument(data: data) { error in
            if error == nil {
                print("success")
                isLoading = false
                dismiss()
                Task {
                    currentUserViewModel.playlistViewModel.savePlaylist()
                }
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
