//
//  PlaylistView.swift
//  Feature
//
//  Created by 제이콥 on 1/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import FirebaseFirestore

struct PlaylistManageView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @State var isCreatePlaylistCompleted: Bool = false
    @State var isShowCreatePopup: Bool = false
    @State var isEditing: Bool = false
    @State var editButtonHeight: CGFloat?
    @State var itemSize: CGFloat = .zero
    var body: some View {
        ZStack(alignment: .top){
            LibraryColorSet.background.ignoresSafeArea()
            
            VStack(alignment: .center){
                //상단바
                HStack(){
                    if isEditing{
                        Rectangle()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.clear)
                    }else {
                        SharedAsset.back.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                appCoordinator.rootPath.removeLast()
                            }
                    }
                    
                    
                    Spacer()
                    
                    Text("내 플레이리스트")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    if isEditing {
                        CompleteButton()
                            .transition(.opacity)
                            .onTapGesture {
                                withAnimation {
                                    isEditing = false
                                    editButtonHeight = nil
                                }
                            }
                    }else{
                        
                        SharedAsset.add.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                isShowCreatePopup = true
                            }
                    }
                    
                }
                .padding(.horizontal, 20)
                .frame(height: 63)
                .fullScreenCover(isPresented: $isShowCreatePopup, content: {
                    CreatePlaylistPopupView()
                        .background(TransparentBackground())
                })
            
          

                
                
                //편집버튼
                EditButton()
                    .padding(.trailing, 20)
                    .frame(height: editButtonHeight)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(isEditing ? 0 : 1)
                    .onTapGesture {
                        withAnimation {
                            isEditing = true
                            editButtonHeight = 0
                        }
                        AnalyticsManager.shared.setSelectContentLog(title: "PlaylistManageViewEditButton")
                    }
                //플레이리스트 스크롤뷰
                ScrollView(.vertical) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: itemSize * 2, maximum: itemSize * 2 + 10), spacing: 12),
                        GridItem(.flexible(minimum: itemSize * 2, maximum: itemSize * 2 + 10), spacing: 12)
                    ], spacing: 30, content: {
                        ForEach(0 ..< currentUserData.playlistArray.count, id: \.self) { index in
                            PlaylistItem_Big(playlist: $currentUserData.playlistArray[index], isEditing: $isEditing)
                                .onTapGesture {
                                    if currentUserData.playlistArray[index].id == "favorite"{
                                        appCoordinator.rootPath.append(MumoryPage.favorite)
                                    }else {
                                        appCoordinator.rootPath.append(MumoryPage.playlistWithIndex(index: index))
                                    }
                                }
                        }
                        AddSongItemBig()
                            .opacity(isEditing ? 0 : 1)
                    })
                    
                    Rectangle()
                        .foregroundStyle(Color.clear)
                        .frame(height: 90)
                }
                .padding(.top, isEditing ? 0 : 10)
                .scrollIndicators(.hidden)
                .refreshable {
                    Task {
                        currentUserData.playlistArray = await currentUserData.savePlaylist()
                    }
                }
                
             
            }

        }
        .onAppear {
            itemSize = getUIScreenBounds().width * 0.21
            playerViewModel.setLibraryPlayerVisibility(isShown: true, moveToBottom: true)
            UIRefreshControl.appearance().tintColor = UIColor(white: 0.47, alpha: 1)
            AnalyticsManager.shared.setScreenLog(screenTitle: "PlaylistManageView")
        }
  
    }
}

struct EditButton: View {
    var body: some View {
        HStack(spacing: 5, content: {
            SharedAsset.editMumoryDetailMenu.swiftUIImage
                .resizable()
                .frame(width: 12, height: 12)
            
            Text("편집")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(ColorSet.subGray)
        })
        .padding(.horizontal, 13)
        .frame(height: 33)
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .circular)
                .stroke(ColorSet.subGray, lineWidth: 1)
        }
    }
}

struct CompleteButton: View {
    var body: some View {
        Text("완료")
            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
            .foregroundStyle(Color.white)
    }
}

