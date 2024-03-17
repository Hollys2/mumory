//
//  FriendPageView.swift
//  Feature
//
//  Created by 제이콥 on 3/8/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import MusicKit

struct FriendPageView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    let friend: MumoriUser
    init(friend: MumoriUser) {
        self.friend = friend
    }
    init(uId: String) async {
        self.friend = await MumoriUser(uid: uId)
    }
    
    let lineGray = Color(white: 0.37)

    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background
            ScrollView{
                VStack(spacing: 0, content: {
                    FriendInfoView(friend: friend)
                    
                    Divider()
                        .frame(maxWidth: .infinity)
                        .frame(height: 0.5)
                        .background(lineGray)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: 187)
                                            
                    Divider()
                        .frame(maxWidth: .infinity)
                        .frame(height: 0.5)
                        .background(lineGray)
                    
                    FriendPlaylistView(friend: friend)
                })
            }
            
            HStack{
                SharedAsset.back.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        appCoordinator.rootPath.removeLast()
                    }
                
                Spacer()
                
                SharedAsset.menuGradient.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            .padding(.horizontal, 20)
            .frame(height: 44)
            .padding(.top, currentUserData.topInset)
        }
        .ignoresSafeArea()
    }
}

//#Preview {
//    FriendPageView()
//}

struct FriendInfoView: View {
    @State var isPresentBottomSheet: Bool = false
    let friend: MumoriUser
    init(friend: MumoriUser) {
        self.friend = friend
    }
    
    var body: some View {
        
        VStack(spacing: 0, content: {
            AsyncImage(url: friend.backgroundImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: getUIScreenBounds().width, height: 150)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(width: getUIScreenBounds().width)
                    .frame(height: 150)
                    .foregroundStyle(ColorSet.darkGray)
            }
            .overlay {
                LinearGradient(colors: [ColorSet.background.opacity(0.8), Color.clear], startPoint: .top, endPoint: .init(x: 0.5, y: 0.76))
            }
            
            VStack(alignment: .leading, spacing: 4, content: {
                Text(friend.nickname)
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 24))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)

                Text("@\(friend.id)")
                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 16))
                        .foregroundStyle(ColorSet.charSubGray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                Text(friend.bio)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(ColorSet.subGray)
                        .frame(height: 52, alignment: .bottom)
                        .padding(.bottom, 18)
         


                })
                .overlay {
                    AsyncImage(url: friend.profileImageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 90, height: 90)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(y: -50)

                }
                .padding(.horizontal, 20)

            HStack(spacing: 4, content: {
                SharedAsset.friendPurple.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                
                Text("친구")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(ColorSet.mainPurpleColor)
                
                SharedAsset.downArrowPurple.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 19, height: 19)
                    .padding(.leading, 2)

                  
            })
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(ColorSet.darkGray)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
            .onTapGesture {
                isPresentBottomSheet = true
            }
            .fullScreenCover(isPresented: $isPresentBottomSheet, content: {
                
            })
        })
    }
}

struct FriendPlaylistView: View {
    let friend: MumoriUser
    init(friend: MumoriUser) {
        self.friend = friend
    }
    
    let db = FBManager.shared.db
    
    @State var playlists: [MusicPlaylist] = []
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0, content: {
                HStack(spacing: 0, content: {
                    Text("\(friend.nickname)의 플레이리스트")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                    Spacer()
                    Text("\(playlists.count)")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(ColorSet.charSubGray)
                        .padding(.trailing, 3)
                    
                    SharedAsset.next.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                })
                .frame(height: 67)
                .padding(.horizontal, 20)
                
                ScrollView(.horizontal) {
                    HStack(alignment: .top,spacing: 10, content: {
                        ForEach(playlists, id: \.id) { playlist in
                            PlaylistItem(playlist: playlist, itemSize: 85)
                        }
                        .padding(.horizontal, 20)
                    })
                }
            })
        }
        .onAppear {
            Task {
                guard let snapshot = try? await db.collection("User").document(friend.uid).collection("Playlist").getDocuments() else {
                    print("error")
                    return
                }
                for document in snapshot.documents {
                    let data = document.data()
                    guard let isPublic = data["isPublic"] as? Bool else {
                        return
                    }
                    if !isPublic {continue}
                    guard let title = data["title"] as? String else {
                        return
                    }
                    guard let songIdentifiers = data["songIds"] as? [String] else {
                        return
                    }
                    let id = document.documentID
                    self.playlists.append(MusicPlaylist(id: id, title: title, songIDs: songIdentifiers, isPublic: isPublic))
                }
          
            }
        }
    }
    
    private func fetchSongInfo(songIdentifiers: [String]) async -> [Song] {
        var songs: [Song] = []
        for id in songIdentifiers {
            let musicItemID = MusicItemID(rawValue: id)
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            let response = try? await request.response()
            guard let song = response?.items.first else {
                continue
            }
            songs.append(song)
        }
        return songs
    }
}
