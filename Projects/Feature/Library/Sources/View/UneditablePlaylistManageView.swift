//
//  UneditablePlaylistManageView.swift
//  Feature
//
//  Created by 제이콥 on 3/19/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct UneditablePlaylistManageView: View {
    @EnvironmentObject var friendDataViewModel: FriendDataViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @State var itemSize: CGFloat = .zero
    @State var isPresentBottomSheet: Bool = false

    var body: some View {
        ZStack(alignment: .top){
            LibraryColorSet.background.ignoresSafeArea()
            
            VStack(alignment: .center){
                //상단바
                HStack(){
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    
                    Spacer()
                    
                    Text("\(friendDataViewModel.friend.nickname) 플레이리스트")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    SharedAsset.menuWhite.swiftUIImage
                        .resizable()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            UIView.setAnimationsEnabled(false)
                            isPresentBottomSheet = true
                        }
                    
                }
                .padding(.horizontal, 20)
                .frame(height: 65)

            
     
                
                //플레이리스트 스크롤뷰
                ScrollView(.vertical) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: itemSize * 2, maximum: itemSize * 2 + 10), spacing: 12),
                        GridItem(.flexible(minimum: itemSize * 2, maximum: itemSize * 2 + 10), spacing: 12)
                    ] , spacing: 30, content: {
                        ForEach(friendDataViewModel.playlistArray.indices, id: \.self) { index in
                            UneditablePlaylistBigItem(playlist: $friendDataViewModel.playlistArray[index])
                                .onTapGesture {
                                    appCoordinator.rootPath.append(MumoryPage.friendPlaylist(playlistIndex: index))
                                }
                            
                        }
                    })
                    
                    Rectangle()
                        .foregroundStyle(Color.clear)
                        .frame(height: 90)
                }
                .padding(.top, 10)
                .scrollIndicators(.hidden)
 
                
             
            }

        }
        .navigationBarBackButtonHidden()
        .onAppear {
            itemSize = getUIScreenBounds().width * 0.21
            playerViewModel.setLibraryPlayerVisibility(isShown: true, moveToBottom: true)
        }
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            BottomSheetDarkGrayWrapper(isPresent: $isPresentBottomSheet) {
                BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                    .onTapGesture {
                        isPresentBottomSheet.toggle()
                        appCoordinator.rootPath.append(MumoryPage.report)
                    }
            }
            .background(TransparentBackground())
        }
  
    }
}

struct UneditablePlaylistBigItem: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserViewModel
    @Binding var playlist: MusicPlaylist
    @State var itemSize: CGFloat = .zero

    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    var favoriteEditingTitleTextColor = Color(red: 0.6, green: 0.6, blue: 0.6)
    var favoriteEditingSubTextColor = Color(red: 0.45, green: 0.45, blue: 0.45)
    var radius: CGFloat = 10
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                ZStack(alignment: .bottom){
                    VStack(spacing: 0, content: {
                        HStack(spacing: 0, content: {
                            //1번째 이미지
                            if playlist.songs.count < 1 {
                                Rectangle()
                                    .frame(width: itemSize, height: itemSize)
                                    .foregroundStyle(emptyGray)
                            }else{
                                AsyncImage(url: playlist.songs[0].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                    image
                                        .resizable()
                                        .frame(width: itemSize, height: itemSize)
                                } placeholder: {
                                    Rectangle()
                                        .frame(width: itemSize, height: itemSize)
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
                                    .frame(width: itemSize, height: itemSize)
                                    .foregroundStyle(emptyGray)
                            }else{
                                AsyncImage(url: playlist.songs[1].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                    image
                                        .resizable()
                                        .frame(width: itemSize, height: itemSize)
                                } placeholder: {
                                    Rectangle()
                                        .frame(width: itemSize, height: itemSize)
                                        .foregroundStyle(emptyGray)
                                }
                            }
                            
                            
                        })
                        
                        //가로줄(구분선)
                        Rectangle()
                            .frame(width: itemSize * 2, height: 1)
                            .foregroundStyle(ColorSet.background)
                        
                        HStack(spacing: 0,content: {
                            //3번째 이미지
                            if playlist.songs.count < 3 {
                                Rectangle()
                                    .frame(width: itemSize, height: itemSize)
                                    .foregroundStyle(emptyGray)
                            }else{
                                AsyncImage(url: playlist.songs[2].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                    image
                                        .resizable()
                                        .frame(width: itemSize, height: itemSize)
                                } placeholder: {
                                    Rectangle()
                                        .frame(width: itemSize, height: itemSize)
                                        .foregroundStyle(emptyGray)
                                }
                            }
                            
                            //세로줄 구분선
                            Rectangle()
                                .frame(width: 1, height: itemSize)
                                .foregroundStyle(ColorSet.background)
                            
                            //4번째 이미지
                            if playlist.songs.count <  4 {
                                Rectangle()
                                    .frame(width: itemSize, height: itemSize)
                                    .foregroundStyle(emptyGray)
                            }else{
                                AsyncImage(url: playlist.songs[3].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                    image
                                        .resizable()
                                        .frame(width: itemSize, height: itemSize)
                                } placeholder: {
                                    Rectangle()
                                        .frame(width: itemSize, height: itemSize)
                                        .foregroundStyle(emptyGray)
                                }
                            }
                            
                        })
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                    
                }
                
                
                Text(playlist.title)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .frame(maxWidth: itemSize * 2, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.top, 10)
                    .foregroundStyle(Color.white)
                
                Text("\(playlist.songIDs.count)곡")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(ColorSet.charSubGray)
                    .frame(maxWidth: itemSize * 2, alignment: .leading)
                    .padding(.top, 5)
                
            }
        }
        .onAppear(perform: {
            itemSize = getUIScreenBounds().width * 0.22

        })
    }
    
//    private func fetchSongInfo(songIDs: [String]) async {
//        for id in songIDs {
//            let musicItemID = MusicItemID(rawValue: id)
//            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
//            request.properties = [.genres, .artists]
//            
//            do {
//                let response = try await request.response()
//                
//                guard let song = response.items.first else {
//                    print("no song")
//                    continue
//                }
//                
//                self.songs.append(song)
//            } catch {
//                print("Error: \(error)")
//            }
//        }
//    }
}
