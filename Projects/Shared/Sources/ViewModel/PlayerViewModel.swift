//
//  PlayerViewModel.swift
//  Shared
//
//  Created by 제이콥 on 4/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI
import MusicKit
import MediaPlayer

public struct PlayingInfo {
    var playingTime: TimeInterval
    var playbackRate: Double
}
public enum ShuffleState {
    case off
    case on
}
public enum RepeatState {
    case off
    case all
    case one
}
public class PlayerViewModel: ObservableObject {
    @Published public var isShownMiniPlayer: Bool = false
    @Published public var isShownMiniPlayerInLibrary: Bool = false
    @Published public var miniPlayerMoveToBottom: Bool = false
    @Published public var isShownPreview: Bool = false
    @Published public var userWantsShown: Bool = true
    @Published public var playQueue = ApplicationMusicPlayer.shared.queue
    @Published public var queue: [Song] = []
    @Published public var currentSong: Song?
    @Published public var queueTitle: String = ""
    
    @Published public var favoriteSongIds: [String] = []
    @Published public var playlistArray: [MusicPlaylist] = []
    @Published public var playingTime: TimeInterval = 0.0
    @Published public var isPresentNowPlayingView: Bool = false
    @Published public var shuffleState: ShuffleState = .off
    @Published public var repeatState: RepeatState = .off
    @Published public var isPlaying: Bool = false
    
    private var player = ApplicationMusicPlayer.shared
    var originQueue: [Song] = []
    
    let db = FirebaseManager.shared.db
    var timer: Timer?
    public init() {}
    
    public func changeCurrentEntry(song: Song){
        player.queue.currentEntry = player.queue.entries.first(where: {$0.item?.id == song.id})
        Task {
            do{
                try await player.play()
            }catch{
                print("fail to play song: \(error)")
            }
        }
    }
    
    public func playNewSong(song: Song, isPlayerShown: Bool = true) {
        player.queue = [song]
        self.queue = [song]
        self.originQueue = [song]
//        if isPlayerShown {
//            self.setPlayerVisibilityByUser(isShown: isPlayerShown)
//        }
        self.shuffleState = .off
        self.setRepeatMode(mode: .off)
        self.setShuffleMode(mode: .off)
        self.queueTitle = ""
        self.isPresentNowPlayingView = isPlayerShown
        Task {
            do {
                try await player.play()
                DispatchQueue.main.async {
                    self.currentSong = song
                    self.isPlaying = true
                    self.setPlayingTime()
                }
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
            
        }
    }
    
    public func playNewSongShowingPlayingView(song: Song){
        player.queue = [song]
        self.queue = [song]
        self.originQueue = [song]
        self.queueTitle = ""
        self.isPresentNowPlayingView = true
        self.setRepeatMode(mode: .off)
        self.setShuffleMode(mode: .off)
        Task {
            do {
                try await player.play()
                DispatchQueue.main.async {
                    self.currentSong = song
                    self.isPlaying = true
                    self.setPlayingTime()
                }
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
            
        }
    }
    public func playAll(title: String, songs: [Song], startingItem: Song? = nil) {
        if let startingItem = startingItem {
            self.player.queue = .init(for: songs, startingAt: startingItem)
        }else {
            self.player.queue = .init(for: songs)
        }
        self.queue = songs
        self.originQueue = songs
        self.queueTitle = title
//        self.setPlayerVisibilityByUser(isShown: true)
        self.setRepeatMode(mode: .off)
        self.setShuffleMode(mode: .off)
        Task {
            do {
                try await player.play()
                DispatchQueue.main.async {
                    self.currentSong = self.playingSong()
                    self.isPlaying = true
                    self.setPlayingTime()
                }
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
            
        }
    }
    
    public func skipToPrevious() {
        if player.playbackTime > 5 {
            player.restartCurrentEntry()
        }else {
            Task{
                do{
                    try await player.skipToPreviousEntry()
                    DispatchQueue.main.async {
                        self.currentSong = self.playingSong()
                    }
                }catch {
                    print("Failed to skip previous with error: \(error).")
                }
            }
        }
    }
    
    public func skipToNext() {
        Task{
            do{
                try await player.skipToNextEntry()
                DispatchQueue.main.async {
                    self.currentSong = self.playingSong()
                }

            }catch {
                print("Failed to skip next with error: \(error).")
            }
        }
    }
    
    public func setQueue(songs: [Song]) {
        self.queue = songs
        self.player.queue = .init(for: songs)
    }
    
    public func setQueue(songs: [Song], startSong: Song) {
        self.queue = songs
        self.player.queue = .init(for: songs, startingAt: startSong)
    }
    
    public func playingSong() -> Song? {
        guard let songID = player.queue.currentEntry?.item?.id else {
            return queue.first(where: {$0.title == player.queue.currentEntry?.title})
        }
        return queue.first(where: {$0.id == songID})
    }
    
    public func playbackRate() -> Double {
        return player.playbackTime == 0.0 ? 0.0 : self.player.playbackTime / (self.playingSong()?.duration ?? 0.0)
    }
    
    public func pause() {
        player.pause()
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.isPlaying = false
        }
    }
    
    public func play() {
        Task{
            do {
                try await player.play()
                DispatchQueue.main.async {
                    self.setPlayingTime()
                    self.isPlaying = true
                }
            }catch(let error) {
                print("failed to play music: \(error.localizedDescription)")
            }
        }
    }
    
    public func startEditingSlider() {
        self.timer?.invalidate()
    }
    
    public func updatePlaybackTime(to: TimeInterval) {
        player.playbackTime = to
        setPlayingTime()
    }
    
    private func setPlayingTime() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            DispatchQueue.main.async {
                self.playingTime = self.player.playbackTime
                self.isPlaying = self.player.state.playbackStatus == .playing
            }
            if Int(self.player.playbackTime) == 0 {
                DispatchQueue.main.async {
                    self.currentSong = self.playingSong()
                }
            }
        })
    }
    
    public func addToFavorite(uid: String, songId: String) {
        let query = db.collection("User").document(uid).collection("Playlist").document("favorite")
        query.updateData(["songIds": FirebaseManager.Fieldvalue.arrayUnion([songId])])
        self.favoriteSongIds.append(songId)

        let validCheckQuery = db.collection("User").document(uid).collection("MonthlyStat")
            .whereField("type", isEqualTo: "favorite")
            .whereField("songId", isEqualTo: songId)
            .order(by: "date", descending: true)
        
        validCheckQuery.getDocuments { querySnapshot, error in
            guard error == nil else {print("a");return}
            guard let snapshots = querySnapshot else {print("b");return}
            if let recentData = snapshots.documents.first {
                let data = recentData.data()
                guard let recentDate = (data["date"] as? FirebaseManager.Timestamp)?.dateValue() else {print("d");return}
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy년 MM월 dd일"
                
                let todayString = formatter.string(from: Date())
                let dateOfRecentDataString = formatter.string(from: recentDate)
                print("today string: \(todayString)")
                print("recent string: \(dateOfRecentDataString)")
                if todayString == dateOfRecentDataString {
                    recentData.reference.delete()
                }
            }
            
            let monthlyStatData: [String: Any] = [
                "date": Date(),
                "songId": songId,
                "type": "favorite"
            ]
            self.db.collection("User").document(uid).collection("MonthlyStat").addDocument(data: monthlyStatData)
        }
   
    }
    
    public func removeFromFavorite(uid: String, songId: String) {
        let query = db.collection("User").document(uid).collection("Playlist").document("favorite")
        query.updateData(["songIds": FirebaseManager.Fieldvalue.arrayRemove([songId])])
        self.favoriteSongIds.removeAll(where: {$0 == songId})
    }
    

    public func nowPlayingIndex() -> Int {
        return (self.queue.firstIndex(where: {$0.id == self.currentSong?.id}) ?? 0) + 1
    }
    
    public func setPreviewPlayer(tappedSong: Song) {
        if currentSong?.id == tappedSong.id {
            if isShownPreview {
                self.pause()
            } else {
                self.play()
            }
            DispatchQueue.main.async {
                self.isShownPreview.toggle()
            }
            
        }else {
            DispatchQueue.main.async {
                self.isShownPreview = true
            }
            self.playNewSong(song: tappedSong, isPlayerShown: false)
        }
    }
        
    
    public func isPlayerPlaying() -> Bool {
        return self.player.state.playbackStatus == .playing
    }
    
    public func setShuffleMode() {
        if self.shuffleState == .on {
            self.shuffleState = .off
            self.player.state.shuffleMode = .off
            self.queue = self.player.queue.entries.map({ entry in
                return queue.first(where: {$0.id == entry.item?.id})!
            })
        }else {
            self.shuffleState = .on
            self.player.state.shuffleMode = .songs
            self.queue = self.player.queue.entries.map({ entry in
                return queue.first(where: {$0.id == entry.item?.id})!
            })
        }
    }
    
    func setShuffleMode(mode: ShuffleState) {
        switch mode {
        case .off:
            self.player.state.shuffleMode = .off
            self.shuffleState = .off
        case .on:
            self.player.state.shuffleMode = .songs
            self.shuffleState = .on
        }
    }
    
    public func setRepeatMode(){
        let state = self.player.state.repeatMode
        if state == MusicPlayer.RepeatMode.none {
            self.repeatState = .all
            self.player.state.repeatMode = .all
        } else if state == .all {
            self.repeatState = .one
            self.player.state.repeatMode = .one
        } else {
            self.repeatState = .off
            self.player.state.repeatMode = MusicPlayer.RepeatMode.none
        }
    }
    
    func setRepeatMode(mode: RepeatState) {
        switch mode {
        case .off:
            self.player.state.repeatMode = MusicPlayer.RepeatMode.none
            self.repeatState = .off
        case .all:
            self.player.state.repeatMode = .all
            self.repeatState = .all
        case .one:
            self.player.state.repeatMode = .one
            self.repeatState = .one
        }
    }

//    public func setPlayerVisibilityByUser(isShown: Bool) {
//        withAnimation(.linear(duration: 0.2)) {
//            self.userWantsShown = isShown
//            self.isShownMiniPlayer = isShown
//            self.isShownMiniPlayerInLibrary = isShown
//        }
//    }
//    
//    public func setPlayerVisibilityByUser(isShown: Bool, moveToBottom: Bool) {
//        withAnimation(.linear(duration: 0.2)) {
//            self.miniPlayerMoveToBottom = moveToBottom
//            self.userWantsShown = isShown
//            self.isShownMiniPlayer = isShown
//            self.isShownMiniPlayerInLibrary = isShown
//        }
//    }
//    
//    public func setPlayerVisibilityByUserWithoutAnimation(isShown: Bool) {
//        self.userWantsShown = isShown
//        self.isShownMiniPlayer = isShown
//        self.isShownMiniPlayerInLibrary = isShown
//    }
//    
//    public func setPlayerVisibility(isShown: Bool, moveToBottom: Bool) {
//        withAnimation(.linear(duration: 0.2)) {
//            self.miniPlayerMoveToBottom = moveToBottom
//            isShownMiniPlayer = isShown ? self.userWantsShown ? true : false : false
//        }
//    }
//    
//    public func setPlayerVisibility(isShown: Bool) {
//        withAnimation(.linear(duration: 0.2)) {
//            isShownMiniPlayer = isShown ? self.userWantsShown ? true : false : false
//        }
//    }
//    public func setPlayerVisibilityWithoutAnimation(isShown: Bool){
//        isShownMiniPlayer = isShown ? self.userWantsShown ? true : false : false
//    }
//    
//    public func setPlayerVisibilityWithoutAnimation(isShown: Bool, moveToBottom: Bool){
//        self.miniPlayerMoveToBottom = moveToBottom
//        isShownMiniPlayer = isShown ? self.userWantsShown ? true : false : false
//    }
//    
//    public func setLibraryPlayerVisibility(isShown: Bool) {
//        withAnimation(.linear(duration: 0.2)) {
//            isShownMiniPlayerInLibrary = isShown ? self.userWantsShown ? true : false : false
//        }
//    }
//    
//    public func setLibraryPlayerVisibility(isShown: Bool, moveToBottom: Bool) {
//        withAnimation(.linear(duration: 0.2)) {
//            self.miniPlayerMoveToBottom = moveToBottom
//            isShownMiniPlayerInLibrary = isShown ? self.userWantsShown ? true : false : false
//        }
//    }
//    
//    public func setLibraryPlayerVisibilityWithoutAnimation(isShown: Bool){
//        isShownMiniPlayerInLibrary = isShown ? self.userWantsShown ? true : false : false
//    }
//    
//    public func setLibraryPlayerVisibilityWithoutAnimation(isShown: Bool, moveToBottom: Bool){
//        self.miniPlayerMoveToBottom = moveToBottom
//        isShownMiniPlayerInLibrary = isShown ? self.userWantsShown ? true : false : false
//    }
    
    public func fetchFavoriteSongId() {
        Task {
            let db = FirebaseManager.shared.db
            let auth = FirebaseManager.shared.auth
            guard let currentUser = auth.currentUser else {
                return
            }
            let query = db.collection("User").document(currentUser.uid).collection("Playlist").document("favorite")
            guard let document = try? await query.getDocument() else {
                print("no document")
                return
            }
            guard let data = document.data(),
                  let songIds = data["songIds"] as? [String] else {
                print("no songIds")
                return
            }
            
            DispatchQueue.main.async {
                self.favoriteSongIds = songIds
            }
        }
    }
}
