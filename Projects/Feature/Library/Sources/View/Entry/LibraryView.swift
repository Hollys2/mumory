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
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @State var isTapMyMusic: Bool = true
    @State var changeDetectValue: Bool = false
    @State var contentOffset: CGPoint = .zero
    @State var screenWidth: CGFloat = .zero
    @State var scrollDirection: ScrollDirection = .up
    @State var scrollYOffset: CGFloat = 0
      
    let topBarHeight = 68.0
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            StickyHeaderScrollView(changeDetectValue: $changeDetectValue, contentOffset: $contentOffset,viewWidth: $screenWidth,scrollDirection: $scrollDirection, topbarYoffset: $scrollYOffset, refreshAction: {
                generateHapticFeedback(style: .light)
                Task {
                 await currentUserViewModel.playlistViewModel.savePlaylist()
                }
            }, content: {
                
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
                                .frame(width: getUIScreenBounds().width)
                        }else {
                            MumoryRecommendationView()
                                .padding(.top, 26)
                        }
                        
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: 87)
                        
                    }
                    .frame(width: getUIScreenBounds().width)
                }
                .frame(width: getUIScreenBounds().width)
            })
            .frame(width: getUIScreenBounds().width)
            .scrollIndicators(.hidden)
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
                        appCoordinator.rootPath.append(MumoryPage.search(term: ""))
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
            
            ColorSet.background
                .ignoresSafeArea()
                .frame(maxWidth: .infinity)
                .frame(height: appCoordinator.safeAreaInsetsTop)
        }
        .frame(width: getUIScreenBounds().width)
        .onAppear(perform: {
            Task {
                let authorizationStatus = await MusicAuthorization.request()
                if authorizationStatus != .authorized {
                    print("음악 권한 거절")
                    DispatchQueue.main.async {
                        self.showAlertToRedirectToSettings()
                    }
                } else {
                    playerViewModel.setPlayerVisibilityWithoutAnimation(isShown: false)
                    guard !appCoordinator.isCreateMumorySheetShown else {return}
                    if playerViewModel.isShownMiniPlayerInLibrary {
                        playerViewModel.setLibraryPlayerVisibility(isShown: true, moveToBottom: false)
                    } else {
                        playerViewModel.setLibraryPlayerVisibilityWithoutAnimation(isShown: true, moveToBottom: false)
                    }
                    await currentUserViewModel.playlistViewModel.savePlaylist()
                }
            }
        })
        
    }
    
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
        //        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        //            if let window = windowScene.windows.first {
        //                window.rootViewController?.present(alertController, animated: true, completion: nil)
        //            }
        //        }
    }
}

