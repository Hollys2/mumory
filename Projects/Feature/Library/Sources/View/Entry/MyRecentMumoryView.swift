//
//  MyRecentMusicView.swift
//  Feature
//
//  Created by 제이콥 on 11/20/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import Core
public struct MyRecentMumoryView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var playerViewModel: PlayerViewModel

    @State var musicList: [Song] = []
    @State var exists: Bool = false
    @State var spacing: CGFloat = 0
    @State var recentSongIds: [String] = []
    public init() {
        
    }
    
    public var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                Text("나의 최근 뮤모리 뮤직")
                    .foregroundStyle(.white)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                Spacer()
                SharedAsset.next.swiftUIImage
                    .resizable()
                    .frame(width: 17, height: 17)
                    .onTapGesture {
                        appCoordinator.rootPath.append(MumoryPage.myRecentMumorySongList)
                    }
            })
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            if self.currentUserViewModel.mumoryViewModel.myMumorys.isEmpty{
                InitialSettingView(title: "나의 뮤모리를 기록하고\n음악 리스트를 채워보세요!", buttonTitle: "뮤모리 기록하러 가기") {
                    self.appCoordinator.isCreateMumorySheetShown = true
                }
                .frame(maxHeight: .infinity, alignment: .center)
                
            }else {
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: spacing, content: {
                        ForEach(recentSongIds, id: \.self) { songId in
                            RecentMusicItem(songId: songId)
                        }
                    })
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
                .padding(.top, 12)
            }
        })
        .onAppear(perform: {
            spacing = getUIScreenBounds().width <= 375 ? 8 : 12
            let mumorys = Array(self.currentUserViewModel.mumoryViewModel.myMumorys.prefix(15))
            for mumory in self.currentUserViewModel.mumoryViewModel.myMumorys {
                if recentSongIds.contains(where: {$0 == mumory.song.id}) {continue}
                recentSongIds.append(mumory.song.id)
            }
        })
    }

}

