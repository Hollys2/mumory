//
//  MumoryDetailScrollContentView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/27.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import MusicKit

import Core
import Shared

struct TagView: View {
    var text: String

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(uiImage: SharedAsset.tagMumoryDatail.image)
                .resizable()
                .frame(width: 14, height: 14)

            Text(text)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                .foregroundColor(.white)
        }
        .padding(.leading, 8)
        .padding(.trailing, 10)
        .padding(.vertical, 7)
        .background(.white.opacity(0.2))
        .cornerRadius(14)
    }
}

struct MumoryDetailScrollContentView: View {
    
    @Binding var mumory: Mumory
    @State var user: MumoriUser = MumoriUser()
    @State var isMapViewShown: Bool = false
    @State var isPopUpShown: Bool = true
    @State var playButtonOpacity: CGFloat = 1

    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack(alignment: .bottomTrailing) {
                
                Color.clear
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: UIScreen.main.bounds.width, height: 64)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.09, green: 0.09, blue: 0.09), location: 0.38),
                                Gradient.Stop(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0), location: 0.59),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 1.28),
                            endPoint: UnitPoint(x: 0.5, y: 0.56)
                        )
                    )
                
                SharedAsset.playButtonMumoryDatail.swiftUIImage
                    .resizable()
                    .frame(width: 42, height: 42)
                    .offset(x: -20)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onChange(of: geometry.frame(in: .global).minY) { newValue in
                                    let threshold = 150 + appCoordinator.safeAreaInsetsTop
                                    let distance = newValue - threshold
                                    let maxDistance: CGFloat = 90
                                    let opacity = min(max(distance / maxDistance, 0), 1)
                                    
                                    self.playButtonOpacity = Double(opacity)
                                }
                        }
                    )
                    .opacity(self.playButtonOpacity)
                    .onTapGesture {
                        Task {
                            guard let song = await fetchSong(songId: self.mumory.song.songId) else {return}
                            playerViewModel.playNewSongShowingPlayingView(song: song)
                            playerViewModel.userWantsShown = true
                            playerViewModel.isShownMiniPlayer = true
                        }
                    }

            }
            
            VStack(spacing: 0) {
                
                Group {

                    HStack(spacing: 8) {
                        AsyncImage(url: self.user.profileImageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                            default:
                                self.user.defaultProfileImage
                                    .resizable()
                            }
                        }
                        .scaledToFill()
                        .frame(width: 38, height: 38)
                        .mask {Circle()}
                        .onTapGesture {
                            Task {
                                if self.user.uId == currentUserData.user.uId {
                                    appCoordinator.rootPath.append(MumoryPage.myPage)
                                } else {
                                    let friend = await MumoriUser(uId: self.user.uId)
                                    appCoordinator.rootPath.append(MumoryPage.friend(friend: friend))
                                }
                            }
                        }
                        
                        VStack(spacing: 0) {
                            
                            Text("\(self.user.nickname)")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer(minLength: 0)
                            
                            HStack(spacing: 0) {

                                Text(DateManager.formattedDate(date: self.mumory.date, isPublic: self.mumory.isPublic))
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                    .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)

                                if !self.mumory.isPublic {
                                    Image(uiImage: SharedAsset.lockMumoryDatail.image)
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                }
                                
                                Spacer()
                                
                                Group {
                                    Image(uiImage: SharedAsset.locationMumoryDatail.image)
                                        .resizable()
                                        .frame(width: 17, height: 17)
                                    
                                    Spacer().frame(width: 5)
                                    
                                    Text("\(self.mumory.location.locationTitle)")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                        .frame(maxWidth: getUIScreenBounds().width * 0.27)
                                        .frame(height: 11, alignment: .leading)
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                                .onTapGesture {
                                    self.isMapViewShown = true
                                }
                            } // HStack
                        } // VStack
                        .frame(height: 38)
                    } // HStack
                    .frame(height: 38)
                    .padding(.top, 55)
                    .padding(.bottom, (self.mumory.tags ?? []).isEmpty && (self.mumory.content ?? "").isEmpty && (self.mumory.imageURLs ?? []).isEmpty ? 50 : 55 - 11)
                    
                    if let tags = self.mumory.tags, !tags.isEmpty {
                        HStack(spacing: 0) {
                            
                            ForEach(tags.indices, id: \.self) { index in
                                
                                TagView(text: "\(tags[index])")
                                
                                if index != 2 {
                                    Spacer().frame(width: 6)
                                }
                            }
                            
                            Spacer(minLength: 0)
                        } // HStack
                        .padding(.bottom, 25)
                    }
                    
                    if let content = self.mumory.content, !content.isEmpty {
                        Text("\(content)")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 25)
                    }

                        // MARK: Image
                    if let imageURLs = self.mumory.imageURLs, !imageURLs.isEmpty {
                        MumoryDetailImageScrollUIViewRepresentable(mumory: self.mumory)
                            .frame(width: UIScreen.main.bounds.width - 40 + 10, height: UIScreen.main.bounds.width - 40)
                            .padding(.bottom, 50 - 11)
                    }
                }
                
                MumoryDetailReactionBarView(mumory: self.mumory, isOn: false)
                    .background(GeometryReader { geometry in
                        Color.clear
                            .onAppear(perform: {
                                let isReactionBarShown = geometry.frame(in: .global).minY > UIScreen.main.bounds.height - 85
                               
                                if appCoordinator.isReactionBarShown != isReactionBarShown {
                                    appCoordinator.isReactionBarShown = isReactionBarShown
                                }
                            })
                            .onChange(of: geometry.frame(in: .global).minY) { minY in
                                let isReactionBarShown = minY > UIScreen.main.bounds.height - 85
                                
                                if appCoordinator.isReactionBarShown != isReactionBarShown {
                                    appCoordinator.isReactionBarShown = isReactionBarShown
                                }
                            }
                    })
                    .overlay(
                        ZStack {
                            SharedAsset.starPopup.swiftUIImage
                                .resizable()
                                .frame(width: 235, height: 42)
                                .offset(x: -15, y: 16)
                                .opacity(UserDefaults.standard.value(forKey: "starPopUp2") == nil ? 1 : 0)
                                .onTapGesture {
                                    self.isPopUpShown = false
                                    UserDefaults.standard.set(Date(), forKey: "starPopUp2")
                                }
                        }
                            .opacity(self.isPopUpShown ? 1: 0)
                        
                        , alignment: .bottomTrailing
                    )
                
                Spacer().frame(height: 70)
                
                    Group {
                        Text("같은 음악을 들은 친구 뮤모리")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 24)
                        
                        if self.mumoryDataViewModel.sameSongFriendMumorys.count > 0 {
                            VStack(spacing: 0) {
                                
                                MumoryDetailFriendMumoryScrollUIViewRepresentable(mumory: self.mumory)
                                    .frame(width: UIScreen.main.bounds.width - 40 + 10, height: 212)
                                
                                Spacer().frame(height: 25)
                                
                                HStack(spacing: 10) {
                                    
                                    ProgressView(value: CGFloat(self.appCoordinator.page) / CGFloat(Array(self.mumoryDataViewModel.sameSongFriendMumorys.prefix(min(3, self.mumoryDataViewModel.sameSongFriendMumorys.count))).count))
                                        .accentColor(SharedAsset.mainColor.swiftUIColor)
                                        .background(Color(red: 0.165, green: 0.165, blue: 0.165))
                                        .frame(width: getUIScreenBounds().width * 0.44102, height: 3)
                                        .animation(.easeInOut(duration: 0.1), value: self.appCoordinator.page)
                                    
                                    Text("\(self.appCoordinator.page)")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                        .foregroundColor(SharedAsset.mainColor.swiftUIColor)
                                    + Text(" / \(Array(self.mumoryDataViewModel.sameSongFriendMumorys.prefix(min(3, self.mumoryDataViewModel.sameSongFriendMumorys.count))).count)")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                        .foregroundColor(Color(red: 0.475, green: 0.475, blue: 0.475))
                                }
                                .padding(.bottom, 65)
                                .opacity(self.mumoryDataViewModel.sameSongFriendMumorys.count == 1 ? 0 : 1)
                            }
                        } else {
                            
                            VStack(spacing: 0) {
                                Text("아직 같은 음악을 들은 친구가 없습니다.")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                    .foregroundColor(Color(red: 0.475, green: 0.475, blue: 0.475))
                            }
                            .frame(height: 334 - 25)
                            .offset(y: -25)
                        }
                        
                        Rectangle()
                            .fill(Color(red: 0.055, green: 0.055, blue: 0.055))
                            .frame(width: getUIScreenBounds().width, height: 10)
                            .padding(.bottom, 74)
                    }
                
                Group {
                    Text("주변에서 뮤모리된 음악")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 24)
                    
                    if self.mumoryDataViewModel.surroundingMumorys.isEmpty {
                        VStack(spacing: 0) {
                            Text("주변에서 뮤모리된 음악이 없습니다.")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                .foregroundColor(Color(red: 0.475, green: 0.475, blue: 0.475))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(height: 334 - 25)
                        .offset(y: -25)
                    } else {
                        ForEach(self.mumoryDataViewModel.surroundingMumorys.prefix(3), id: \.self) { mumory in
                            MumoryDetailSameLocationMusicView(mumory: mumory)
                        }
                    }
                    Spacer().frame(height: 100)
                }
            } // VStack
            .frame(width: UIScreen.main.bounds.width - 40)
            .padding(.horizontal, 20) // 배경색을 채우기 위함
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            
            Spacer()
        } // VStack
        .ignoresSafeArea()
        .fullScreenCover(isPresented: self.$isMapViewShown) {
            FriendMumoryMapView(isShown: self.$isMapViewShown, mumorys: [self.mumory], user: self.user)
        }
        .onAppear {
            Task {
                mumoryDataViewModel.isUpdating = true
                self.mumory = await mumoryDataViewModel.fetchMumory(documentID: self.mumory.id ?? "")
                self.user = await MumoriUser(uId: self.mumory.uId)
                print("MumoryDetailScrollContentView onAppear")
                for friend in self.currentUserData.friends {
                    Task {
                        await mumoryDataViewModel.sameSongFriendMumory(friend: friend, songId: self.mumory.song.songId, mumory: self.mumory)
                    }
                    Task {
                        await mumoryDataViewModel.surroundingFriendMumory(friend: friend, mumory: self.mumory)
                    }
                }
                mumoryDataViewModel.isUpdating = false
            }
        }
    }
    
    private func fetchSong(songId: String) async -> Song? {
        let musicItemID = MusicItemID(rawValue: songId)
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        request.properties = [.genres, .artists]
        guard let response = try? await request.response() else {return nil}
        guard let song = response.items.first else {return nil}
        return song
    }
        
}
