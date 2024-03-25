//
//  LibraryEntryView.swift
//  Feature
//
//  Created by 제이콥 on 1/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct LibraryView: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @StateObject var snackbarViewModel: SnackBarViewModel = SnackBarViewModel()
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @State var isTapMyMusic: Bool = true
    @State var changeDetectValue: Bool = false
    @State var contentOffset: CGPoint = .zero
    @State var screenWidth: CGFloat = .zero
    @State var scrollDirection: ScrollDirection = .up
    @State var scrollYOffset: CGFloat = 0
    
    @State var isLoadingPlaylist: Bool = false
  
    let topBarHeight = 68.0
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            StickyHeaderScrollView(changeDetectValue: $changeDetectValue, contentOffset: $contentOffset,viewWidth: $screenWidth,scrollDirection: $scrollDirection, topbarYoffset: $scrollYOffset, content: {
                
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        
                        //마이뮤직, 추천 선택 스택
                        HStack(spacing: 6, content: {
                            
                            //마이뮤직버튼
                            Button(action: {
                                isTapMyMusic = true
                            }, label: {
                                Text("마이뮤직")
                                    .font(isTapMyMusic ? SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13) : SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                    .padding(.horizontal, 16)
                                    .frame(height: 33)
                                    .foregroundStyle(isTapMyMusic ? Color.black : LibraryColorSet.lightGrayForeground)
                                    .background(isTapMyMusic ? LibraryColorSet.purpleBackground : LibraryColorSet.darkGrayBackground)
                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 22, height: 22), style: .circular))
                            })
                            
                            //추천버튼
                            Button(action: {
                                isTapMyMusic = false
                            }, label: {
                                Text("뮤모리 추천")
                                    .font(isTapMyMusic ? SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13) :SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                                    .padding(.horizontal, 16)
                                    .frame(height: 33)
                                    .foregroundStyle(isTapMyMusic ? LibraryColorSet.lightGrayForeground : Color.black)
                                    .background(isTapMyMusic ? LibraryColorSet.darkGrayBackground : LibraryColorSet.purpleBackground)
                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 22, height: 22), style: .circular))
                            })
                            
                        })
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top, 17)
                        .padding(.top, topBarHeight )//상단뷰높이
                        
                        //마이뮤직, 추천에 따라 바뀔 뷰
                        if isTapMyMusic{
                            MyMusicView()
                                .padding(.top, 26)
                        }else {
                            MumoryRecommendationView()
                                .padding(.top, 26)
                            
                        }
                        
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: 87)
                    }
                    
                  
                }
                .frame(width: screenWidth)
                .onAppear {
                    print("screent width: \(getUIScreenBounds().width), height: \(getUIScreenBounds().height)")
                }
                
            })
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            
            //상단바
            HStack(){
                Text("라이브러리")
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 24))
                    .foregroundStyle(Color.white)
                    .padding(.leading, 20)
                    .padding(.bottom, 5)
                
                Spacer()
                
                SharedAsset.search.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 20)
                    .padding(.top, 5)
                    .onTapGesture {
                        appCoordinator.rootPath.append(LibraryPage.search(term: ""))
                    }
            }
            .frame(height: topBarHeight, alignment: .center)
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            .background(ColorSet.background)
            .offset(x: 0, y: scrollYOffset)
            .onChange(of: scrollDirection) { newValue in
                if newValue == .up {
                    //스크롤뷰는 safearea공간 내부부터 offset이 0임. 따라서 세이프공간을 무시하고 스크롤 시작하면 safearea 높이 만큼의 음수부터 시작임
                    //하지만 현재 상단뷰는 safearea를 무시해도 최상단이 0임. 따라서 스크롤뷰와 시작하는 offset이 다름
                    if contentOffset.y >= topBarHeight/*상단뷰의 높이만큼의 여유 공간이 있는 경우*/{
                        scrollYOffset = -topBarHeight/*-topbar height -safearea */
                    }
                }
            }
//            .onChange(of: contentOffset.y, perform: { value in
//                print("y offset: \(value)")
//                if value < -30 {
//                    if !isLoadingPlaylist {
//                        isLoadingPlaylist = true
//                        Task {
//                            await getPlayList()
//                        }
//                        
//                    }
//                }
//            })
            
            ColorSet.background
                .ignoresSafeArea()
                .frame(maxWidth: .infinity)
                .frame(height: appCoordinator.safeAreaInsetsTop)
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            playerViewModel.miniPlayerMoveToBottom = false
            Task {
                await getPlayList()
            }
        })
        
    }
    

        
    
    private func getPlayList() async {
        let Firebase = FBManager.shared
        let db = Firebase.db
        
        currentUserData.playlistArray.removeAll()
        
        let query = db.collection("User").document(currentUserData.uId).collection("Playlist")
            .order(by: "date", descending: false)
        
        guard let snapshot = try? await query.getDocuments() else {
            return
        }
        var count = 0
        snapshot.documents.forEach { document in
            count += 1
            print("count in looop: \(count)")
            let data = document.data()
            guard let title = data["title"] as? String else {
                print("no title")
                return
            }
            guard let isPublic = data["isPublic"] as? Bool else {
                print("no private thing")
                return
            }
            guard let songIDs = data["songIds"] as? [String] else {
                print("no id list")
                return
            }
            let id = document.reference.documentID
            let playlist = MusicPlaylist(id: id, title: title, songIDs: songIDs, isPublic: isPublic)
            currentUserData.playlistArray.append(playlist)
            fetchSong(playlist: $currentUserData.playlistArray[currentUserData.playlistArray.count-1])
        }
        isLoadingPlaylist = false
    }

    private func fetchSongWithPlaylistID(songIDs: [String]) async -> [Song] {
        var count = 0
        var returnValue: [Song] = []
        for id in songIDs {
            if count >= 4 {
                break
            }
            count += 1
            let musicItemID = MusicItemID(rawValue: id)
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            request.properties = [.genres, .artists]
            guard let response = try? await request.response() else {continue}
            guard let song = response.items.first else {continue}
            returnValue.append(song)
        }
        return returnValue
    }
    
    private func fetchSong(playlist: Binding<MusicPlaylist>) {
        var count = 0
        Task {
            for id in playlist.songIDs.wrappedValue {
                if count >= 4 {
                    break
                }
                count += 1
                let musicItemID = MusicItemID(rawValue: id)
                var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                request.properties = [.genres, .artists]
                guard let response = try? await request.response() else {continue}
                guard let song = response.items.first else {continue}
                playlist.songs.wrappedValue.append(song)
            }
        }
    }
}


//#Preview {
//    LibraryView()
//}

