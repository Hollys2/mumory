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
    // MARK: - Propoerties
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    /// 마이뮤직탭과 뮤모리추천탭 디스플레이 여부
    @State var isShowingMyMusic: Bool = true
    @State var contentOffset: CGPoint = .zero
    @State var screenWidth: CGFloat = .zero
    @State var scrollDirection: ScrollDirection = .up
    @State var topBarYOffset: CGFloat = 0
    
    /// 상단바 높이
    let navigationBarHeight: CGFloat = 65.0
    
    // MARK: - View
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            StickyHeaderScrollView(contentOffset: $contentOffset,viewWidth: $screenWidth,scrollDirection: $scrollDirection, topbarYoffset: $topBarYOffset, refreshAction: {
                generateHapticFeedback(style: .light)
                currentUserViewModel.playlistViewModel.savePlaylist()
            }, content: {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        
                        HStack(spacing: 6, content: {
                            MyMusicButton
                            MumoryRecommendationButton
                        })
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, navigationBarHeight + 17 )
                        
                        Group {
                            if isShowingMyMusic{
                                MyMusicView()
                            }else {
                                MumoryRecommendationView()
                            }
                        }
                        .padding(.top, 26)
                        
                        
                        SpacerView(height: 87)
                        
                    }
                }
                .frame(width: getUIScreenBounds().width)

            })
            .scrollIndicators(.hidden)
            .padding(.top, getSafeAreaInsets().top)
            
            NavigationBar
        
            // 상단 safe area를 가리는 용도
            ColorSet.background
                .ignoresSafeArea()
                .frame(maxWidth: .infinity)
                .frame(height: getSafeAreaInsets().top)
        }
        .onAppear(perform: {
           handleMusicAuthorization()
        })
        
    }
    
    var MyMusicButton: some View {
        Button(action: {
            isShowingMyMusic = true
        }, label: {
            Text("마이뮤직")
                .font(isShowingMyMusic ? SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13) : SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                .padding(.horizontal, 16)
                .frame(height: 33)
                .foregroundStyle(isShowingMyMusic ? Color.black : LibraryColorSet.lightGrayForeground)
                .background(isShowingMyMusic ? LibraryColorSet.purpleBackground : LibraryColorSet.darkGrayBackground)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 22, height: 22), style: .circular))
        })
    }
    
    var MumoryRecommendationButton: some View {
        Button(action: {
            isShowingMyMusic = false
        }, label: {
            Text("뮤모리 추천")
                .font(isShowingMyMusic ? SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13) :SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                .padding(.horizontal, 16)
                .frame(height: 33)
                .foregroundStyle(isShowingMyMusic ? LibraryColorSet.lightGrayForeground : Color.black)
                .background(isShowingMyMusic ? LibraryColorSet.darkGrayBackground : LibraryColorSet.purpleBackground)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 22, height: 22), style: .circular))
        })
    }
    
    
    var NavigationBar: some View {
        HStack {
            NavigationTitle
            Spacer()
            SearchButton
        }
        .frame(height: 65)
        .padding(.horizontal, 20)
        .padding(.top, getSafeAreaInsets().top)
        .background(ColorSet.background)
        .offset(x: 0, y: topBarYOffset)
        .onChange(of: scrollDirection) { newValue in
            if newValue == .up {
                //스크롤뷰는 safearea공간 내부부터 offset이 0임. 따라서 세이프공간을 무시하고 스크롤 시작하면 safearea 높이 만큼의 음수부터 시작임
                //하지만 현재 상단뷰는 safearea를 무시해도 최상단이 0임. 따라서 스크롤뷰와 시작하는 offset이 다름
                if contentOffset.y >= navigationBarHeight/*상단뷰의 높이만큼의 여유 공간이 있는 경우*/{
                    topBarYOffset = -navigationBarHeight/*-topbar height -safearea */
                }
            }
        }
    }
    
    var NavigationTitle: some View {
        Text("라이브러리")
            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 24))
            .foregroundStyle(Color.white)
            .lineLimit(1)
    }
    
    var SearchButton: some View {
        SharedAsset.search.swiftUIImage
            .resizable()
            .frame(width: 30, height: 30)
            .onTapGesture {
                appCoordinator.rootPath.append(MumoryPage.search(term: ""))
            }
    }
    
    // MARK: - Methods
    
    func showAlertToRedirectToSettings() {
        let alertController = UIAlertController(title: "음악 권한 허용", message: "뮤모리를 이용하려면 음악 권한이 필요합니다. 설정으로 이동하여 권한을 허용해주세요.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func handleMusicAuthorization() {
        Task {
            let authorizationStatus = await MusicAuthorization.request()
            if authorizationStatus != .authorized {
                print("음악 권한 거절")
                DispatchQueue.main.async {
                    self.showAlertToRedirectToSettings()
                }
            } else {
//                playerViewModel.setPlayerVisibilityWithoutAnimation(isShown: false)
                if !appCoordinator.isCreateMumorySheetShown {
                    if playerViewModel.isShownMiniPlayerInLibrary {
//                        playerViewModel.setLibraryPlayerVisibility(isShown: true, moveToBottom: false)
                    } else {
//                        playerViewModel.setLibraryPlayerVisibilityWithoutAnimation(isShown: true, moveToBottom: false)
                    }
                }
                currentUserViewModel.playlistViewModel.savePlaylist()
                currentUserViewModel.playlistViewModel.fetchFavoriteGenres()
            }
        }
    }
    
    
}

