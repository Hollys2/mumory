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
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator

    @State var musicList: [Song] = []
    @State var exists: Bool = false
    @State var spacing: CGFloat = 0
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
            
            if mumoryDataViewModel.myMumorys.isEmpty{
                NoMumoryView()
                    .frame(maxHeight: .infinity, alignment: .center)
                    .padding(.bottom, 7)
            }else {
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: spacing, content: {
                        ForEach(mumoryDataViewModel.myMumorys, id: \.self) { mumory in
                            RecentMusicItem(songId: mumory.musicModel.songID.rawValue)
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
        })
    }
    
    private func searchRecentMusicPost(){
        //임의로 즐겨찾기 목록이 나오게 함
        let Firebase = FBManager.shared
        let db = Firebase.db
        //        let uid = currentUserData.uid
        let uid = "tester" //테스트용도
        let query = db.collection("Mumory")
            .whereField("uId", isEqualTo: uid)
            .order(by: "date", descending: true)
        
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {return}
            snapshot.documents.forEach { doc in
                let data = doc.data()
                guard let songID = data["songIds"] as? String else {return}
                Task {
                    if let song = await fetchSong(songID: songID) {
                        musicList.append(song)
                    }
                }
            }
        }
    }
    

}




struct NoMumoryView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel 
    var body: some View {
        VStack(alignment: .center,spacing: 0, content: {
            Text("나의 뮤모리를 기록하고")
                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 13))
                .foregroundStyle(ColorSet.charSubGray)
            Text("음악 리스트를 채워보세요!")
                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 13))
                .foregroundStyle(ColorSet.charSubGray)
                .padding(.top, 3)
            
            Text("뮤모리 기록하러 가기")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(ColorSet.mainPurpleColor)
                .padding(.top, 9)
                .padding(.bottom, 9)
                .padding(.leading, 13)
                .padding(.trailing, 13)
                .background(ColorSet.darkGray)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
                .padding(.top, 25)
                .onTapGesture {
                    withAnimation(Animation.easeInOut(duration: 0.1)) {
                        appCoordinator.isCreateMumorySheetShown = true
                        appCoordinator.offsetY = CGFloat.zero
                        playerViewModel.setPlayerVisibility(isShown: false)
                    }
                }

        })
    }
}
