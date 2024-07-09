//
//  MusicChartBottomSheetView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import MusicKit
import Shared
enum bottomSheetType {
    case withoutArtist
    case withoutBookmark
    case inPlayingView
}

struct SongBottomSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
        
    private let lineGray = Color(red: 0.28, green: 0.28, blue: 0.28)
    var song: Song
    var types: [bottomSheetType] = []
    
    init(song: Song, types: [bottomSheetType]) {
        self.song = song
        self.types = types
    }
    
    init(song: Song){
        self.song = song
    }

    var body: some View {
     
            VStack(spacing: 0, content: {
                HStack(alignment: .center,spacing: 0,content: {
                    
                    AsyncImage(url: song.artwork?.url(width: 300, height: 300),transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                        default:
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(ColorSet.skeleton)
                        }
                    }
                    .frame(width: 60, height: 60)



                    
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(song.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(song.artistName)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundStyle(ColorSet.charSubGray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 13)
                    
                    
                    SharedAsset.next.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .padding(.leading, 20)
                        .onTapGesture {
                            dismiss()
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                                playerViewModel.playNewSong(song: song)
                                playerViewModel.isPresentNowPlayingView = true
                            }
                        }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                
                Divider05()
                    .padding(.horizontal, 4)
                    .padding(.bottom, 10)
                
                if types.contains(.inPlayingView) {
         
                } else {
                    
                    if !types.contains(.withoutArtist) {
                        BottomSheetItem(image: SharedAsset.artist.swiftUIImage, title: "아티스트 노래 목록 보기")
                            .onTapGesture {
                                dismiss()
                                playerViewModel.isPresentNowPlayingView = false
                                getArtist(song: song) { artist in
                                    appCoordinator.rootPath.append(MumoryPage.artist(artist: artist))
                                }
                            }
                    }
                    
                    if !types.contains(.withoutBookmark){
                        if playerViewModel.favoriteSongIds.contains(song.id.rawValue) {
                            BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 삭제")
                                .onTapGesture {
                                    playerViewModel.removeFromFavorite(uid: currentUserViewModel.user.uId, songId: song.id.rawValue)
                                    dismiss()
                                    snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                                }
                        }else{
                            BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 추가")
                                .onTapGesture {
                                    self.generateHapticFeedback(style: .medium)
                                    playerViewModel.addToFavorite(uid: currentUserViewModel.user.uId, songId: song.id.rawValue)
                                    dismiss()
                                    snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                                }
                        }
                    }
                    
                    BottomSheetItem(image: SharedAsset.addPurple.swiftUIImage, title: "뮤모리 추가", type: .accent)
                        .onTapGesture {
                            dismiss()
                            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                                let musicModel = MusicModel(songID: song.id, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 300, height: 300))
                                mumoryDataViewModel.choosedMusicModel = musicModel
                                playerViewModel.setLibraryPlayerVisibilityWithoutAnimation(isShown: false)
                                withAnimation(Animation.easeInOut(duration: 0.1)) {
                                    appCoordinator.isCreateMumorySheetShown = true
                                    appCoordinator.offsetY = CGFloat.zero
                                }
                            }
                            
                        }
                    
                    
                    BottomSheetItem(image: SharedAsset.addPlaylist.swiftUIImage, title: "플레이리스트에 추가")
                        .onTapGesture {
                            dismiss()
                            appCoordinator.rootPath.append(MumoryPage.saveToPlaylist(songs: [song]))
                        }
                    BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기 (음악 URL 링크 복사)")
                        .onTapGesture {
                            dismiss()
                            UIPasteboard.general.string = song.url?.absoluteString
                            snackBarViewModel.setSnackBar(type: .copy, status: .success)
                        }
                    BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                        .onTapGesture {
                            dismiss()
                            appCoordinator.rootPath.append(MumoryPage.report)
                        }
                }
                
            })
            .padding(.bottom, 15)
            .background(ColorSet.background)
        }
    
    private func getArtist(song: Song, completion: @escaping (Artist) -> ())  {
    
        Task{
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: song.id)
            request.properties = [.artists]
            guard let response = try? await request.response().items else {
                return
            }
            guard let song = response.first else {
                print("no song")
                return
            }
            guard let artist = song.artists?.first else {
                print("no artist")
                return
            }
            
            completion(artist)
        }
    }

}

struct OptionalSongBottomSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
        
    private let lineGray = Color(red: 0.28, green: 0.28, blue: 0.28)
    @Binding var song: Song?
    var types: [bottomSheetType] = []
    
    init(song: Binding<Song?>, types: [bottomSheetType]) {
        self._song = song
        self.types = types
    }
    
    init(song: Binding<Song?>){
        self._song = song
    }

    var body: some View {
     
            VStack(spacing: 0, content: {
                HStack(alignment: .center,spacing: 0,content: {
                    
                    AsyncImage(url: song?.artwork?.url(width: 300, height: 300),transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                        default:
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(ColorSet.skeleton)
                        }
                    }
                    .frame(width: 60, height: 60)



                    
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(song?.title ?? "")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(song?.artistName ?? "")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundStyle(ColorSet.charSubGray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 13)

                    
                    SharedAsset.next.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .padding(.leading, 20)
                    
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .onTapGesture {
                    dismiss()
                    guard let song = self.song else {return}
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                        playerViewModel.playNewSong(song: song)
                        playerViewModel.isPresentNowPlayingView = true
                    }
                }
                
                Divider05()
                    .padding(.horizontal, 4)
                    .padding(.bottom, 10)
                
                if types.contains(.inPlayingView) {
                    BottomSheetItem(image: SharedAsset.artist.swiftUIImage, title: "아티스트 노래 목록 보기")
                        .onTapGesture {
                            dismiss()
                            playerViewModel.isPresentNowPlayingView = false
                            guard let unwrappedSong = self.song else {return}
                            getArtist(song: unwrappedSong) { artist in
                                appCoordinator.rootPath.append(MumoryPage.artist(artist: artist))
                            }
                        }
                    BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기 (음악 URL 링크 복사)")
                        .onTapGesture {
                            guard let unwrappedSong = self.song else {return}
                            dismiss()
                            UIPasteboard.general.string = unwrappedSong.url?.absoluteString
                            snackBarViewModel.setSnackBar(type: .copy, status: .success)
                        }
                    BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                        .onTapGesture {
                            dismiss()
                            appCoordinator.rootPath.append(MumoryPage.report)
                        }
                }else {
                    if !types.contains(.withoutArtist) {
                        BottomSheetItem(image: SharedAsset.artist.swiftUIImage, title: "아티스트 노래 목록 보기")
                            .onTapGesture {
                                dismiss()
                                playerViewModel.isPresentNowPlayingView = false
                                guard let unwrappedSong = self.song else {return}
                                getArtist(song: unwrappedSong) { artist in
                                    appCoordinator.rootPath.append(MumoryPage.artist(artist: artist))
                                }
                            }
                    }
                    
                    if !types.contains(.withoutBookmark){
                        if let song = self.song {
                            if playerViewModel.favoriteSongIds.contains(song.id.rawValue) {
                                BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 삭제")
                                    .onTapGesture {
                                        playerViewModel.removeFromFavorite(uid: currentUserViewModel.user.uId, songId: song.id.rawValue)
                                        dismiss()
                                        snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                                    }
                            }else{
                                BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 추가")
                                    .onTapGesture {
                                        self.generateHapticFeedback(style: .medium)
                                        playerViewModel.addToFavorite(uid: currentUserViewModel.user.uId, songId: song.id.rawValue)
                                        dismiss()
                                        snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                                    }
                            }
                        }
                    }
                    
                    BottomSheetItem(image: SharedAsset.addPurple.swiftUIImage, title: "뮤모리 추가", type: .accent)
                        .onTapGesture {
                            dismiss()
                            appCoordinator.rootPath = NavigationPath()
                            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                                guard let unwrappedSong = self.song else {return}
                                let musicModel = MusicModel(songID: unwrappedSong.id, title: unwrappedSong.title, artist: unwrappedSong.artistName, artworkUrl: unwrappedSong.artwork?.url(width: 300, height: 300))
                                mumoryDataViewModel.choosedMusicModel = musicModel
                                withAnimation(Animation.easeInOut(duration: 0.1)) {
                                    appCoordinator.isCreateMumorySheetShown = true
                                    appCoordinator.offsetY = CGFloat.zero
                                }
                            }
                            
                        }
                    
                    
                    BottomSheetItem(image: SharedAsset.addPlaylist.swiftUIImage, title: "플레이리스트에 추가")
                        .onTapGesture {
                            guard let unwrappedSong = self.song else {return}
                            dismiss()
                            appCoordinator.rootPath.append(MumoryPage.saveToPlaylist(songs: [unwrappedSong]))
                        }
                    BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기 (음악 URL 링크 복사)")
                        .onTapGesture {
                            guard let unwrappedSong = self.song else {return}
                            dismiss()
                            UIPasteboard.general.string = unwrappedSong.url?.absoluteString
                            snackBarViewModel.setSnackBar(type: .copy, status: .success)
                        }
                    BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                        .onTapGesture {
                            dismiss()
                            appCoordinator.rootPath.append(MumoryPage.report)
                        }
                }
                
            })
            .padding(.bottom, 15)
            .background(ColorSet.background)
        }
    
    private func getArtist(song: Song, completion: @escaping (Artist) -> ())  {
    
        Task{
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: song.id)
            request.properties = [.artists]
            guard let response = try? await request.response().items else {
                return
            }
            guard let song = response.first else {
                print("no song")
                return
            }
            guard let artist = song.artists?.first else {
                print("no artist")
                return
            }
            
            completion(artist)
        }
    }

}


struct SongBottomSheetViewWithoutPlaying: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
        
    private let lineGray = Color(red: 0.28, green: 0.28, blue: 0.28)
    var song: Song
    var types: [bottomSheetType] = []
    
    init(song: Song, types: [bottomSheetType]) {
        self.song = song
        self.types = types
    }
    
    init(song: Song){
        self.song = song
    }

    var body: some View {
     
            VStack(spacing: 0, content: {
                HStack(alignment: .center,spacing: 0,content: {
                    
                    AsyncImage(url: song.artwork?.url(width: 300, height: 300),transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                        default:
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(ColorSet.skeleton)
                        }
                    }
                    .frame(width: 60, height: 60)



                    
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(song.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(song.artistName)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundStyle(ColorSet.charSubGray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 13)
                    
                    
      
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                
                Divider05()
                    .padding(.horizontal, 4)
                    .padding(.bottom, 10)
                
                if types.contains(.inPlayingView) {
         
                } else {
                    
                    if !types.contains(.withoutArtist) {
                        BottomSheetItem(image: SharedAsset.artist.swiftUIImage, title: "아티스트 노래 목록 보기")
                            .onTapGesture {
                                dismiss()
                                playerViewModel.isPresentNowPlayingView = false
                                getArtist(song: song) { artist in
                                    appCoordinator.rootPath.append(MumoryPage.artist(artist: artist))
                                }
                            }
                    }
                    
                    if !types.contains(.withoutBookmark){
                        if playerViewModel.favoriteSongIds.contains(song.id.rawValue) {
                            BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 삭제")
                                .onTapGesture {
                                    playerViewModel.removeFromFavorite(uid: currentUserViewModel.user.uId, songId: song.id.rawValue)
                                    dismiss()
                                    snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                                }
                        }else{
                            BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 추가")
                                .onTapGesture {
                                    self.generateHapticFeedback(style: .medium)
                                    playerViewModel.addToFavorite(uid: currentUserViewModel.user.uId, songId: song.id.rawValue)
                                    dismiss()
                                    snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                                }
                        }
                    }
                    
                    BottomSheetItem(image: SharedAsset.addPurple.swiftUIImage, title: "뮤모리 추가", type: .accent)
                        .onTapGesture {
                            dismiss()
                            playerViewModel.isPresentNowPlayingView = false
                            playerViewModel.setLibraryPlayerVisibility(isShown: false)
                            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                                let musicModel = MusicModel(songID: song.id, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 300, height: 300))
                                mumoryDataViewModel.choosedMusicModel = musicModel
                                withAnimation(Animation.easeInOut(duration: 0.1)) {
                                    appCoordinator.isCreateMumorySheetShown = true
                                    appCoordinator.offsetY = CGFloat.zero
                                }
                            }
                            
                        }
                    
                    
                    BottomSheetItem(image: SharedAsset.addPlaylist.swiftUIImage, title: "플레이리스트에 추가")
                        .onTapGesture {
                            dismiss()
                            playerViewModel.isPresentNowPlayingView = false
                            appCoordinator.rootPath.append(MumoryPage.saveToPlaylist(songs: [song]))
                        }
                    BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기 (음악 URL 링크 복사)")
                        .onTapGesture {
                            dismiss()
                            UIPasteboard.general.string = song.url?.absoluteString
                            snackBarViewModel.setSnackBar(type: .copy, status: .success)
                        }
                    BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                        .onTapGesture {
                            dismiss()
                            playerViewModel.isPresentNowPlayingView = false
                            appCoordinator.rootPath.append(MumoryPage.report)
                        }
                }
                
            })
            .padding(.bottom, 15)
            .background(ColorSet.background)
    
        }
    
    private func getArtist(song: Song, completion: @escaping (Artist) -> ())  {
    
        Task{
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: song.id)
            request.properties = [.artists]
            guard let response = try? await request.response().items else {
                return
            }
            guard let song = response.first else {
                print("no song")
                return
            }
            guard let artist = song.artists?.first else {
                print("no artist")
                return
            }
            
            completion(artist)
        }
    }

}


struct OptionalSongBottomSheetViewWithoutPlaying: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
        
    private let lineGray = Color(red: 0.28, green: 0.28, blue: 0.28)
    @Binding var song: Song?
    var types: [bottomSheetType] = []
    
    init(song: Binding<Song?>, types: [bottomSheetType]) {
        self._song = song
        self.types = types
    }
    
    init(song: Binding<Song?>){
        self._song = song
    }

    var body: some View {
     
            VStack(spacing: 0, content: {
                HStack(alignment: .center,spacing: 0,content: {
                    
                    AsyncImage(url: song?.artwork?.url(width: 300, height: 300),transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                        default:
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(ColorSet.skeleton)
                        }
                    }
                    .frame(width: 60, height: 60)



                    
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(song?.title ?? "")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(song?.artistName ?? "")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundStyle(ColorSet.charSubGray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 13)
                    
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                
                Divider05()
                    .padding(.horizontal, 4)
                    .padding(.bottom, 10)
                
                if types.contains(.inPlayingView) {
                    BottomSheetItem(image: SharedAsset.artist.swiftUIImage, title: "아티스트 노래 목록 보기")
                        .onTapGesture {
                            dismiss()
                            playerViewModel.isPresentNowPlayingView = false
                            guard let unwrappedSong = self.song else {return}
                            getArtist(song: unwrappedSong) { artist in
                                appCoordinator.rootPath.append(MumoryPage.artist(artist: artist))
                            }
                        }
                    BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기 (음악 URL 링크 복사)")
                        .onTapGesture {
                            guard let unwrappedSong = self.song else {return}
                            dismiss()
                            UIPasteboard.general.string = unwrappedSong.url?.absoluteString
                            snackBarViewModel.setSnackBar(type: .copy, status: .success)
                        }
                    BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                        .onTapGesture {
                            dismiss()
                            playerViewModel.isPresentNowPlayingView = false
                            appCoordinator.rootPath.append(MumoryPage.report)
                        }
                }else {
                    if !types.contains(.withoutArtist) {
                        BottomSheetItem(image: SharedAsset.artist.swiftUIImage, title: "아티스트 노래 목록 보기")
                            .onTapGesture {
                                dismiss()
                                playerViewModel.isPresentNowPlayingView = false
                                guard let unwrappedSong = self.song else {return}
                                getArtist(song: unwrappedSong) { artist in
                                    appCoordinator.rootPath.append(MumoryPage.artist(artist: artist))
                                }
                            }
                    }
                    
                    if !types.contains(.withoutBookmark){
                        if let song = self.song {
                            if playerViewModel.favoriteSongIds.contains(song.id.rawValue) {
                                BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 삭제")
                                    .onTapGesture {
                                        playerViewModel.removeFromFavorite(uid: currentUserViewModel.user.uId, songId: song.id.rawValue)
                                        dismiss()
                                        snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                                    }
                            }else{
                                BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 추가")
                                    .onTapGesture {
                                        self.generateHapticFeedback(style: .medium)
                                        playerViewModel.addToFavorite(uid: currentUserViewModel.user.uId, songId: song.id.rawValue)
                                        dismiss()
                                        snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                                    }
                            }
                        }
                    }
                    
                    BottomSheetItem(image: SharedAsset.addPurple.swiftUIImage, title: "뮤모리 추가", type: .accent)
                        .onTapGesture {
                            dismiss()
                            
                            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                                guard let unwrappedSong = self.song else {return}
                                let musicModel = MusicModel(songID: unwrappedSong.id, title: unwrappedSong.title, artist: unwrappedSong.artistName, artworkUrl: unwrappedSong.artwork?.url(width: 300, height: 300))
                                mumoryDataViewModel.choosedMusicModel = musicModel
                                withAnimation(Animation.easeInOut(duration: 0.1)) {
                                    appCoordinator.isCreateMumorySheetShown = true
                                    appCoordinator.offsetY = CGFloat.zero
                                }
                            }
                            
                        }
                    
                    
                    BottomSheetItem(image: SharedAsset.addPlaylist.swiftUIImage, title: "플레이리스트에 추가")
                        .onTapGesture {
                            guard let unwrappedSong = self.song else {return}
                            dismiss()
                            appCoordinator.rootPath.append(MumoryPage.saveToPlaylist(songs: [unwrappedSong]))
                        }
                    BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기 (음악 URL 링크 복사)")
                        .onTapGesture {
                            guard let unwrappedSong = self.song else {return}
                            dismiss()
                            UIPasteboard.general.string = unwrappedSong.url?.absoluteString
                            snackBarViewModel.setSnackBar(type: .copy, status: .success)
                        }
                    BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                        .onTapGesture {
                            dismiss()
                            playerViewModel.isPresentNowPlayingView = false
                            appCoordinator.rootPath.append(MumoryPage.report)
                        }
                }
                
            })
            .padding(.bottom, 15)
            .background(ColorSet.background)

        }
    
    private func getArtist(song: Song, completion: @escaping (Artist) -> ())  {
    
        Task{
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: song.id)
            request.properties = [.artists]
            guard let response = try? await request.response().items else {
                return
            }
            guard let song = response.first else {
                print("no song")
                return
            }
            guard let artist = song.artists?.first else {
                print("no artist")
                return
            }
            
            completion(artist)
        }
    }

}


struct SongBottomSheetViewInUneditablePlaylist: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
        
    private let lineGray = Color(red: 0.28, green: 0.28, blue: 0.28)
    var song: Song
    var types: [bottomSheetType] = []
    
    init(song: Song, types: [bottomSheetType]) {
        self.song = song
        self.types = types
    }
    
    init(song: Song){
        self.song = song
    }

    var body: some View {
     
            VStack(spacing: 0, content: {
                HStack(alignment: .center,spacing: 0,content: {
                    
                    AsyncImage(url: song.artwork?.url(width: 300, height: 300),transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                        default:
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(ColorSet.skeleton)
                        }
                    }
                    .frame(width: 60, height: 60)



                    
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(song.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(song.artistName)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundStyle(ColorSet.charSubGray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 13)
                    
                    
                    SharedAsset.next.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .padding(.leading, 20)
                        .onTapGesture {
                            dismiss()
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                                playerViewModel.playNewSong(song: song)
                                playerViewModel.isPresentNowPlayingView = true
                            }
                        }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                
                Divider05()
                    .padding(.horizontal, 4)
                    .padding(.bottom, 10)
                
                if types.contains(.inPlayingView) {
         
                } else {
                    
                    if !types.contains(.withoutArtist) {
                        BottomSheetItem(image: SharedAsset.artist.swiftUIImage, title: "아티스트 노래 목록 보기")
                            .onTapGesture {
                                dismiss()
                                playerViewModel.isPresentNowPlayingView = false
                                getArtist(song: song) { artist in
                                    appCoordinator.rootPath.append(MumoryPage.artist(artist: artist))
                                }
                            }
                    }
                    
                    if !types.contains(.withoutBookmark){
                        if playerViewModel.favoriteSongIds.contains(song.id.rawValue) {
                            BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 삭제")
                                .onTapGesture {
                                    playerViewModel.removeFromFavorite(uid: currentUserViewModel.user.uId, songId: song.id.rawValue)
                                    dismiss()
                                    snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                                }
                        }else{
                            BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 추가")
                                .onTapGesture {
                                    self.generateHapticFeedback(style: .medium)
                                    playerViewModel.addToFavorite(uid: currentUserViewModel.user.uId, songId: song.id.rawValue)
                                    dismiss()
                                    snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                                }
                        }
                    }
                    
                    BottomSheetItem(image: SharedAsset.addPurple.swiftUIImage, title: "뮤모리 추가", type: .accent)
                        .onTapGesture {
                            dismiss()
                            appCoordinator.isMyPageViewShown = false
                            appCoordinator.rootPath = NavigationPath()
                            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                                let musicModel = MusicModel(songID: song.id, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 300, height: 300))
                                mumoryDataViewModel.choosedMusicModel = musicModel
                                playerViewModel.setLibraryPlayerVisibilityWithoutAnimation(isShown: false)
                                withAnimation(Animation.easeInOut(duration: 0.1)) {
                                    appCoordinator.isCreateMumorySheetShown = true
                                    appCoordinator.offsetY = CGFloat.zero
                                }
                            }
                            
                        }
                    
                    
                    BottomSheetItem(image: SharedAsset.addPlaylist.swiftUIImage, title: "플레이리스트에 추가")
                        .onTapGesture {
                            dismiss()
                            appCoordinator.rootPath.append(MumoryPage.saveToPlaylist(songs: [song]))
                        }
                    BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기 (음악 URL 링크 복사)")
                        .onTapGesture {
                            dismiss()
                            UIPasteboard.general.string = song.url?.absoluteString
                            snackBarViewModel.setSnackBar(type: .copy, status: .success)
                        }
                    BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                        .onTapGesture {
                            dismiss()
                            appCoordinator.rootPath.append(MumoryPage.report)
                        }
                }
                
            })
            .padding(.bottom, 15)
            .background(ColorSet.background)
        }
    
    private func getArtist(song: Song, completion: @escaping (Artist) -> ())  {
    
        Task{
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: song.id)
            request.properties = [.artists]
            guard let response = try? await request.response().items else {
                return
            }
            guard let song = response.first else {
                print("no song")
                return
            }
            guard let artist = song.artists?.first else {
                print("no artist")
                return
            }
            
            completion(artist)
        }
    }

}


struct SongModelBottomSheetView: View {
    // MARK: - Object lifecycle
    init(song: SongModel, types: [bottomSheetType]) {
        self.song = song
        self.types = types
    }
    init(song: SongModel){
        self.song = song
    }
    
    // MARK: - Propoerties
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    private let lineGray = Color(white: 0.28)
    var song: SongModel
    var types: [bottomSheetType] = []
    

    // MARK: - View
    var body: some View {
            VStack(spacing: 0, content: {
                HStack(alignment: .center,spacing: 0,content: {
                    
                    AsyncImage(url: song.artworkUrl,transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                        default:
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(ColorSet.skeleton)
                        }
                    }
                    .frame(width: 60, height: 60)



                    
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(song.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(song.artistName)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundStyle(ColorSet.charSubGray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 13)
                    
                    
                    SharedAsset.next.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .padding(.leading, 20)
                        .onTapGesture {
//                            dismiss()
//                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
//                                playerViewModel.playNewSong(song: song)
//                                playerViewModel.isPresentNowPlayingView = true
//                            }
                        }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                
                Divider05()
                    .padding(.horizontal, 4)
                    .padding(.bottom, 10)
                
                if types.contains(.inPlayingView) {
         
                } else {
                    
                    if !types.contains(.withoutArtist) {
                        BottomSheetItem(image: SharedAsset.artist.swiftUIImage, title: "아티스트 노래 목록 보기")
                            .onTapGesture {
                                dismiss()
                                playerViewModel.isPresentNowPlayingView = false
//                                getArtist(song: song) { artist in
//                                    appCoordinator.rootPath.append(MumoryPage.artist(artist: artist))
//                                }
                            }
                    }
                    
                    if !types.contains(.withoutBookmark){
                        if playerViewModel.favoriteSongIds.contains(song.id) {
                            BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 삭제")
                                .onTapGesture {
//                                    playerViewModel.removeFromFavorite(uid: currentUserViewModel.user.uId, songId: song.id.rawValue)
//                                    dismiss()
//                                    snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                                }
                        }else{
                            BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 추가")
                                .onTapGesture {
//                                    self.generateHapticFeedback(style: .medium)
//                                    playerViewModel.addToFavorite(uid: currentUserViewModel.user.uId, songId: song.id.rawValue)
//                                    dismiss()
//                                    snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                                }
                        }
                    }
                    
                    BottomSheetItem(image: SharedAsset.addPurple.swiftUIImage, title: "뮤모리 추가", type: .accent)
                        .onTapGesture {
//                            dismiss()
//                            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
//                                let musicModel = MusicModel(songID: song.id, title: song.title, artist: song.artistName, artworkUrl: song.artworkUrl)
//                                mumoryDataViewModel.choosedMusicModel = musicModel
//                                playerViewModel.setLibraryPlayerVisibilityWithoutAnimation(isShown: false)
//                                withAnimation(Animation.easeInOut(duration: 0.1)) {
//                                    appCoordinator.isCreateMumorySheetShown = true
//                                    appCoordinator.offsetY = CGFloat.zero
//                                }
//                            }
                            
                        }
                    
                    
                    BottomSheetItem(image: SharedAsset.addPlaylist.swiftUIImage, title: "플레이리스트에 추가")
                        .onTapGesture {
//                            dismiss()
//                            appCoordinator.rootPath.append(MumoryPage.saveToPlaylist(songs: [song]))
                        }
                    BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기 (음악 URL 링크 복사)")
                        .onTapGesture {
                            //fetch하고 복사하기
//                            dismiss()
//                            UIPasteboard.general.string = song.url?.absoluteString
//                            snackBarViewModel.setSnackBar(type: .copy, status: .success)
                        }
                    BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                        .onTapGesture {
                            dismiss()
                            appCoordinator.rootPath.append(MumoryPage.report)
                        }
                }
                
            })
            .padding(.bottom, 15)
            .background(ColorSet.background)
        }
    
    private func getArtist(song: Song, completion: @escaping (Artist) -> ())  {
    
        Task{
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: song.id)
            request.properties = [.artists]
            guard let response = try? await request.response().items else {
                return
            }
            guard let song = response.first else {
                print("no song")
                return
            }
            guard let artist = song.artists?.first else {
                print("no artist")
                return
            }
            
            completion(artist)
        }
    }


}
