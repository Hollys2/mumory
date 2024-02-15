//
//  PlaylistItem.swift
//  Feature
//
//  Created by 제이콥 on 11/28/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import MusicKit

//플레이리스트 아이템(플레이리스트 뷰)
struct PlaylistItem_Big: View {
    @EnvironmentObject var manager: LibraryManageModel
    @EnvironmentObject var userManager: UserViewModel
    @Binding var playlist: MusicPlaylist
    var isAddSongItem: Bool
    @Binding var isEditing: Bool
    var radius: CGFloat = 10
    @State var isDeletePupupPresent: Bool = false
    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    var favoriteEditingTitleTextColor = Color(red: 0.6, green: 0.6, blue: 0.6)
    var favoriteEditingSubTextColor = Color(red: 0.45, green: 0.45, blue: 0.45)

    var body: some View {
        if isAddSongItem {
            if !isEditing {
                AddSongItem()
            }
        }else{
            VStack(spacing: 0){
                ZStack(alignment: .bottom){
                    VStack(spacing: 0, content: {
                        HStack(spacing: 0, content: {
                            //1번째 이미지
                            if playlist.songs.count < 1 {
                                Rectangle()
                                    .frame(width: 84, height: 84)
                                    .foregroundStyle(emptyGray)
                            }else{
                                AsyncImage(url: playlist.songs[0].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                    image
                                        .resizable()
                                        .frame(width: 84, height: 84)
                                } placeholder: {
                                    Rectangle()
                                        .frame(width: 84, height: 84)
                                        .foregroundStyle(emptyGray)
                                }
                            }
                            
                            //세로줄(구분선)
                            Rectangle()
                                .frame(width: 1, height: 84)
                                .foregroundStyle(ColorSet.background)
                            
                            //2번째 이미지
                            if playlist.songs.count < 2{
                                Rectangle()
                                    .frame(width: 84, height: 84)
                                    .foregroundStyle(emptyGray)
                            }else{
                                AsyncImage(url: playlist.songs[1].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                    image
                                        .resizable()
                                        .frame(width: 84, height: 84)
                                } placeholder: {
                                    Rectangle()
                                        .frame(width: 84, height: 84)
                                        .foregroundStyle(emptyGray)
                                }
                            }
                            
                            
                        })
                        
                        //가로줄(구분선)
                        Rectangle()
                            .frame(width: 169, height: 1)
                            .foregroundStyle(ColorSet.background)
                        
                        HStack(spacing: 0,content: {
                            //3번째 이미지
                            if playlist.songs.count < 3 {
                                Rectangle()
                                    .frame(width: 84, height: 84)
                                    .foregroundStyle(emptyGray)
                            }else{
                                AsyncImage(url: playlist.songs[2].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                    image
                                        .resizable()
                                        .frame(width: 84, height: 84)
                                } placeholder: {
                                    Rectangle()
                                        .frame(width: 84, height: 84)
                                        .foregroundStyle(emptyGray)
                                }
                            }
                            
                            //세로줄 구분선
                            Rectangle()
                                .frame(width: 1, height: 84)
                                .foregroundStyle(ColorSet.background)
                            
                            //4번째 이미지
                            if playlist.songs.count <  4 {
                                Rectangle()
                                    .frame(width: 84, height: 84)
                                    .foregroundStyle(emptyGray)
                            }else{
                                AsyncImage(url: playlist.songs[3].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                    image
                                        .resizable()
                                        .frame(width: 84, height: 84)
                                } placeholder: {
                                    Rectangle()
                                        .frame(width: 84, height: 84)
                                        .foregroundStyle(emptyGray)
                                }
                            }
                            
                        })
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                    .overlay {
                        SharedAsset.bookmarkWhite.swiftUIImage
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            .opacity(playlist.isFavorite ? 1 : 0)
                        
                        SharedAsset.lockPurple.swiftUIImage
                            .resizable()
                            .frame(width: 23, height: 23)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .opacity(playlist.isFavorite ? 0 : playlist.isPrivate ? 1 : 0)
                        
                        SharedAsset.deletePlaylist.swiftUIImage
                            .resizable()
                            .frame(width: 23, height: 23)
                            .padding(.horizontal, 9)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .offset(y: 11)
                            .opacity(playlist.isFavorite ? 0 : isEditing ? 1 : 0) //기본 즐겨찾기 목록은 삭제 불가
                            .transition(.opacity)
                            .onTapGesture {
                                UIView.setAnimationsEnabled(false)
                                isDeletePupupPresent = true
                            }

                        //즐겨찾기 항목 삭제 불가 나타냄
                        Color.black.opacity(0.4)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                            .opacity(playlist.isFavorite && isEditing ? 1 : 0)
                    }
                    
                    
                }
                //삭제하시겠습니까 팝업
                .fullScreenCover(isPresented: $isDeletePupupPresent, content: {
                    DeletePopupView(isDeletePupupPresent: $isDeletePupupPresent){
                        let Firebase = FirebaseManager.shared
                        let db = Firebase.db
                        
                        let ref = db.collection("User").document(userManager.uid).collection("Playlist").document(playlist.id)
                        ref.delete()
                        
                        withAnimation {
                            userManager.playlistArray.removeAll(where: {$0.id == playlist.id})
                        }
                    }
                    .background(TransparentBackground())
                })

         

                //노래 제목 및 아티스트 이름
                Text(playlist.title)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .frame(maxWidth: 169, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.top, 10)
                    .foregroundStyle(playlist.isFavorite && isEditing ? favoriteEditingTitleTextColor : .white)
                
                Text("\(playlist.songIDs.count)곡")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(playlist.isFavorite && isEditing ? favoriteEditingSubTextColor : .white)
                    .frame(maxWidth: 169, alignment: .leading)
                    .padding(.top, 5)
                
            }
            .onTapGesture {
                manager.push(destination: .playlist(playlist: playlist))
            }
        }
    }
    
}

//새 플레이리스트 아이템
private struct AddSongItem: View {
    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    
    var body: some View {
        VStack(spacing: 0, content: {
            RoundedRectangle(cornerRadius: 10, style: .circular)
                .frame(width: 169, height: 169)
                .foregroundStyle(emptyGray)
                .overlay {
                    SharedAsset.addPurple.swiftUIImage
                        .resizable()
                        .frame(width: 53, height: 53)
                }
            
            Text("새 플레이리스트")
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(ColorSet.mainPurpleColor)
                .frame(width: 169, alignment: .leading)
                .padding(.top, 10)
            
            Spacer()
            
        })
        .frame(height: 220)
    }
}

//플레이리스트 삭제 팝업
struct DeletePopupView: View {
    @EnvironmentObject var userManager: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    @Binding var isDeletePupupPresent: Bool
    private var lineGray = Color(red: 0.65, green: 0.65, blue: 0.65)
    var deleteAction: () -> Void
    
    public init(isDeletePupupPresent: Binding<Bool>, deleteAction: @escaping () -> Void){
        self._isDeletePupupPresent = isDeletePupupPresent
        self.deleteAction = deleteAction
    }

        
    var body: some View {
        ZStack(alignment: .center){
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0, content: {
                Text("해당 플레이리스트를 삭제하시겠습니까?")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .padding(.top, 30)
                    .padding(.bottom, 30)
                
                Rectangle()
                    .frame(height: 0.7)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(lineGray)
                
                HStack(spacing: 0, content: {
                    Button(action: {
                        UIView.setAnimationsEnabled(false)
                        dismiss()
                    }, label: {
                        Text("취소")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    
                    
                    Rectangle()
                        .frame(width: 0.7, height: 50)
                        .foregroundStyle(lineGray)
                    
                    Button(action: {
                        deleteAction()
                    }, label: {
                        Text("플레이리스트 삭제")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                            .foregroundStyle(ColorSet.mainPurpleColor)
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    
                    
                })
            })
            .background(ColorSet.darkGray)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
            .padding(.horizontal, 40)
        }

    }
}

// 투명 fullScreenCover
//extension View {
//    func transparentFullScreenCoverWithoutAnimation<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
//        fullScreenCover(isPresented: isPresented) {
//            ZStack {
//                content()
//            }
//            .background(TransparentBackground())
//        }
//        .transaction { transaction in
//            transaction.disablesAnimations = true
//        }
//
//    }
//}


//#Preview {
//    DeletePopupView(isDeletePupupPresent: .constant(true)) {
//        //
//    }
//}
