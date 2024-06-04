//
//  MumoryDetailReactionBarView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/27.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared
import FirebaseFunctions

struct MumoryDetailReactionBarView: View {
    
    let mumory: Mumory
    
    @State var isOn: Bool
    @State private var isButtonDisabled = false
    @State private var isStarButtonTapped = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var currentUserData: CurrentUserData
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width, height: 85)
                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                        .offset(y: self.isOn ? 0 : 75)
                    , alignment: .top
                )
        
            HStack(alignment: .center) {
                
                Button(action: {
                    self.generateHapticFeedback(style: .medium)
                    isButtonDisabled = true
                    let originLikes = self.mumory.likes

                    Task {
                        await mumoryDataViewModel.likeMumory(mumoryAnnotation: self.mumory, uId: currentUserData.user.uId) { likes in
                            self.mumory.likes = likes
                            isButtonDisabled = false
                            
                            lazy var functions = Functions.functions()
                            functions.httpsCallable("like").call(["mumoryId": mumory.id]) { result, error in
                                if let error = error {
//                                    self.mumory.likes = originLikes
                                    print("Error Functions \(error.localizedDescription)")
                                } else {
//                                    self.mumory.likes = likes
                                    print("라이크 성공: \(mumory.likes.count)")
                                }
                            }
                        }
                    }
                }, label: {
                    mumory.likes.contains(currentUserData.user.uId) ?
                    Image(uiImage: SharedAsset.heartOnButtonMumoryDetail.image)
                        .resizable()
                        .frame(width: 42, height: 42)
                    : Image(uiImage: SharedAsset.heartOffButtonMumoryDetail.image)
                        .resizable()
                        .frame(width: 42, height: 42)
                })
                .disabled(isButtonDisabled)
                
                if mumory.likes.count != 0 {
                    Spacer().frame(width: 4)
                    
                    Text("\(mumory.likes.count)")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                        .foregroundColor(.white)
                }
                
                Spacer().frame(width: 13)
                
                Button(action: {
                    mumoryDataViewModel.selectedMumoryAnnotation = mumory
                    withAnimation(.easeInOut(duration: 0.1)) {
//                        self.appCoordinator.isMumoryDetailCommentSheetViewShown = true
                        self.appCoordinator.sheet = .comment
                    }
                }, label: {
                    Image(uiImage: SharedAsset.commentButtonMumoryDetail.image)
                        .resizable()
                        .frame(width: 42, height: 42)
                })
                
                
                if mumory.commentCount != 0 {
                    Spacer().frame(width: 4)
                    
                    Text("\(mumory.commentCount)")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if playerViewModel.favoriteSongIds.contains(mumory.musicModel.songID.rawValue) {
                    SharedAsset.starOnMumoryDetail.swiftUIImage
                        .resizable()
                        .frame(width: 42, height: 42)
                        .onTapGesture {
                            playerViewModel.removeFromFavorite(uid: currentUserData.uId, songId: mumory.musicModel.songID.rawValue)
                            snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                        }
                } else {
                    SharedAsset.starOffMumoryDetail.swiftUIImage
                        .resizable()
                        .frame(width: 42, height: 42)
                        .onTapGesture {
                            self.generateHapticFeedback(style: .medium)
                            playerViewModel.addToFavorite(uid: currentUserData.uId, songId: mumory.musicModel.songID.rawValue)
                            snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                        }
                }
     
            }
            .padding(.horizontal, 20)
            .padding(.top, 11)
        }
        .offset(y: self.isOn ? UIScreen.main.bounds.height - 85 : 0)
        
    }
}

