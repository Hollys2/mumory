//
//  AddPlaylistSongView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct AddSongView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var playerViewModel: PlayerViewModel

    @State var originPlaylist: MusicPlaylist
    @State var selection: Int = 0
    private let noneSelectedColor = Color(white: 0.65)
    
    init(originPlaylist: MusicPlaylist) {
        _originPlaylist = State<MusicPlaylist>.init(initialValue: originPlaylist)
    }

    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                //상단바
                HStack(spacing: 0){
                        SharedAsset.back.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                appCoordinator.rootPath.removeLast()
                            }

                    Spacer()
                    
                    Text("음악 추가")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(width: 30, height: 30)
                    
                }
                .padding(.horizontal, 20)
                .frame(height: 40)
                
                HStack(spacing: 0, content: {
                    Text("즐겨찾기")
                        .font(selection == 0 ?  SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundStyle(selection == 0 ? .white : noneSelectedColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            withAnimation (.linear(duration: 0.2)){
                                selection = 0
                            }
                        }
                    
                    Text("검색")
                        .font(selection == 1 ?  SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundStyle(selection == 1 ? noneSelectedColor : .white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            withAnimation (.linear(duration: 0.2)) {
                                selection = 1
                            }
                        }
                })
                .padding(.vertical, 14)
                
                //선택시 움직이는 보라색 선
                VStack(content: {
                    Rectangle()
                        .frame(width: getUIScreenBounds().width/2, height: 3)
                        .foregroundStyle(.clear)
                        .overlay(content: {
                            Rectangle()
                                .frame(width: selection == 0 ? 55 : 28, height: 3)
                                .foregroundStyle(ColorSet.mainPurpleColor)
                        })
                })
                .frame(maxWidth: .infinity, alignment: selection == 0 ? .leading : .trailing)
                
                Divider05()
                
                TabView(selection: $selection, content:  {
                    AddSongFromFavoriteView(originPlaylist: $originPlaylist).tag(0)
                    AddSongFromSearchView(originPlaylist: $originPlaylist).tag(1)
                })
                .tabViewStyle(.page(indexDisplayMode: .never))
            })
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            
        }
        .ignoresSafeArea()
        .onAppear {
            playerViewModel.setPlayerVisibility(isShown: false)
        }
        .onDisappear {
            playerViewModel.setPlayerVisibility(isShown: true)
        }

    }
}



