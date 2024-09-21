//
//  SnackbarViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/22/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI
import Shared

public enum SnackbarStatus {
    case success
    case failure
    case delete
}
public enum SnackbarType {
    case playlist
    case favorite
    case copy
    case readAllNotification
}
public class SnackBarViewModel: ObservableObject {
    @Published public var isPresent: Bool = false
    @Published public var status: SnackbarStatus = .success
    @Published public var type: SnackbarType = .playlist
    @Published public var title: String = ""
    var timer: Timer?
    
    struct RecentSaveData{
        var playlistId: String
        var songIds: [String]
    }
    var recentSaveData = RecentSaveData(playlistId: "", songIds: [])

    public func setSnackBarAboutPlaylist(status: SnackbarStatus, playlistTitle: String) {
        self.timer?.invalidate()
        self.isPresent = false
        
        DispatchQueue.main.async {
            self.type = .playlist
            self.status = status
            self.title = playlistTitle
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { timer in
                self.setPresentValue(isPresent: true)
            }
        }

        self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { timer in
            self.setPresentValue(isPresent: false)
        })
    }
    
    public func setSnackBar(type: SnackbarType, status: SnackbarStatus) {
        self.timer?.invalidate()
        self.isPresent = false
        
        DispatchQueue.main.async {
            self.type = type
            self.status = status
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { timer in
                self.setPresentValue(isPresent: true)
            }
        }

        self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { timer in
            self.setPresentValue(isPresent: false)
        })
    }
    
    public func setRecentSaveData(playlist: MusicPlaylist, songIds: [String]) {
        self.recentSaveData = RecentSaveData(playlistId: playlist.id, songIds: songIds)
    }
    
    public func removeRecentSaveData(uId: String) {
        let db = FirebaseManager.shared.db
        db.collection("User").document(uId).collection("Playlist").document(self.recentSaveData.playlistId)
            .updateData(["songIds": FirebaseManager.Fieldvalue.arrayRemove(self.recentSaveData.songIds)])
        
        setSnackBar(type: .playlist, status: .delete)
    }
    
    public func setPresentValue(isPresent: Bool) {
        DispatchQueue.main.async {
            withAnimation(.linear(duration: 0.25)){
                self.isPresent = isPresent
            }
        }
    }

    public init(){}
    
    
   
}



public struct SnackBarView: View {
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    var additionalAction: () -> Void = {}
    public init(){}
    public init(additionalAction: @escaping () -> Void) {
        self.additionalAction = additionalAction
    }
    
    public var body: some View {
        VStack{
            switch (snackBarViewModel.type, snackBarViewModel.status) {
                
            case (.playlist, .success):
                PlaylistSuccessView
                    .offset(y: snackBarViewModel.isPresent ? 53 : -70)
                    .opacity(snackBarViewModel.isPresent ? 1 : 0)
                
            case (.playlist, .failure):
                PlaylistFailureView
                    .offset(y: snackBarViewModel.isPresent ? 53 : -70)
                    .opacity(snackBarViewModel.isPresent ? 1 : 0)
                
            case (.favorite, .success):
                FavoriteAddView
                    .offset(y: snackBarViewModel.isPresent ? 53 : -70)
                    .opacity(snackBarViewModel.isPresent ? 1 : 0)
                
            case (.favorite, .delete):
                FavoriteDeleteView
                    .offset(y: snackBarViewModel.isPresent ? 53 : -70)
                    .opacity(snackBarViewModel.isPresent ? 1 : 0)
            case (.copy, .success):
                CopySongURLView
                    .offset(y: snackBarViewModel.isPresent ? 53 : -70)
                    .opacity(snackBarViewModel.isPresent ? 1 : 0)
            case (.playlist, .delete):
                PlaylistDeleteView
                    .offset(y: snackBarViewModel.isPresent ? 53 : -70)
                    .opacity(snackBarViewModel.isPresent ? 1 : 0)
                
            case (.readAllNotification, .failure):
                AlreadyReadAllNotificationView
                    .offset(y: snackBarViewModel.isPresent ? 53 : -70)
                    .opacity(snackBarViewModel.isPresent ? 1 : 0)
                
            default:
                EmptyView()
            }
            Spacer()
        }
        .ignoresSafeArea()
        .gesture(drag)
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { drag in
                withAnimation(.linear(duration: 0.25)) {
                    snackBarViewModel.setPresentValue(isPresent: false)
                }
            }
    }
    
    
    var PlaylistSuccessView: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0, content: {
                Text("플레이리스트")
                    .foregroundStyle(Color.black)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                
                
                Text("\"\(snackBarViewModel.title)")
                    .foregroundStyle(Color.black)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text("\"")
                    .foregroundStyle(Color.black)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                
                Text("에 추가되었습니다.")
                    .fixedSize()
                    .foregroundStyle(Color.black)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                snackBarViewModel.removeRecentSaveData(uId: currentUserViewModel.user.uId)
                snackBarViewModel.setPresentValue(isPresent: false)
            } label: {
                Text("실행취소")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .padding(.leading, 18)
                    .foregroundStyle(ColorSet.mainPurpleColor)
            }
            
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 48)
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
        .padding(.horizontal, 15)
    }
    
    var PlaylistDeleteView: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0, content: {
                Text("플레이리스트")
                    .foregroundStyle(Color.black)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                
                Text("\"\(snackBarViewModel.title)")
                    .foregroundStyle(Color.black)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text("\"")
                    .foregroundStyle(Color.black)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                
                Text("에서 삭제되었습니다.")
                    .fixedSize()
                    .foregroundStyle(Color.black)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
            })
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 48)
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
        .padding(.horizontal, 15)
    }
    
    var PlaylistFailureView: some View {
        HStack(spacing: 0) {
            Text("이미 플레이리스트")
                .foregroundStyle(Color.black)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
            
            Text("\"\(snackBarViewModel.title)")
                .foregroundStyle(Color.black)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text("\"")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
            
            Text("에 존재합니다.")
                .fixedSize()
                .foregroundStyle(Color.black)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 48)
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
        .padding(.horizontal, 15)
    }
    
    var FavoriteAddView: some View {
        HStack(spacing: 0) {
            SharedAsset.checkFill.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 17, height: 17)
                .padding(.trailing, 8)
            
            Text("즐겨찾기 목록에 추가되었습니다.")
                .foregroundStyle(Color.black)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
            
            Spacer()
            
            Text("목록 보기")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                .padding(.leading, 18)
                .foregroundStyle(ColorSet.skeleton02)
                .onTapGesture {
                    appCoordinator.rootPath.append(MumoryPage.favorite)
                    additionalAction()
                }
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 48)
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
        .padding(.horizontal, 15)
     
    }
    
    var FavoriteDeleteView: some View {
        HStack(spacing: 0) {
            SharedAsset.xRed.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 17, height: 17)
                .padding(.trailing, 8)
            
            Text("즐겨찾기 목록에서 삭제되었습니다.")
                .foregroundStyle(Color.black)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
            
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 48)
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
        .padding(.horizontal, 15)
   
    }
    
    var CopySongURLView: some View {
        HStack(spacing: 0) {
            SharedAsset.checkFill.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 17, height: 17)
                .padding(.trailing, 8)
            
            Text("음악 URL 링크가 복사 되었습니다.")
                .foregroundStyle(Color.black)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
            
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 48)
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
        .padding(.horizontal, 15)
    }
    
    var AlreadyReadAllNotificationView: some View {
        HStack(spacing: 0) {
            Text("알림을 모두 읽었습니다.")
                .foregroundStyle(Color.black)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 48)
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
        .padding(.horizontal, 15)
    }
}
