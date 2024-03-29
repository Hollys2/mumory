//
//  Feature
//
//  Created by 제이콥 on 11/27/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import Foundation
import SwiftUI
import MusicKit
import MediaPlayer
import Shared

struct PlayingInfo {
    var playingTime: TimeInterval
    var playbackRate: Double
}

public class PlayerViewModel: ObservableObject {
    enum ShuffleState {
        case off
        case on
    }
    enum RepeatState {
        case off
        case all
        case one
    }
    
    @Published public var isShownMiniPlayer: Bool = false
    @Published var miniPlayerMoveToBottom: Bool = false
    @Published var isShownPreview: Bool = false
    @Published var userWantsInvisible: Bool = false
    @Published var playQueue = ApplicationMusicPlayer.shared.queue
    @Published var queue: [Song] = []
    @Published var currentSong: Song?
    @Published var queueTitle: String = ""
    
    @Published var favoriteSongIds: [String] = []
    @Published public var playlistArray: [MusicPlaylist] = []
    @Published var playingTime: TimeInterval = 0.0
    @Published var isPresentNowPlayingView: Bool = false
    @Published var shuffleState: ShuffleState = .off
    @Published var repeatState: RepeatState = .off
    @Published var isPlaying: Bool = false
    private var player = ApplicationMusicPlayer.shared
    var originQueue: [Song] = []
    
    let db = FBManager.shared.db
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
    
    public func playNewSong(song: Song) {
        player.queue = [song]
        self.queue = [song]
        self.originQueue = [song]
        self.queueTitle = ""
        isPresentNowPlayingView = true
        isShownMiniPlayer = true
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
        print("set queue")
        self.queue = songs
        self.player.queue = .init(for: songs)
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
                self.currentSong = self.playingSong()
            }
        })
    }
    
    public func addToFavorite(uid: String, songId: String) {
        let query = db.collection("User").document(uid).collection("Playlist").document("favorite")
        query.updateData(["songIds": FBManager.Fieldvalue.arrayUnion([songId])])
        self.favoriteSongIds.append(songId)
        let monthlyStatData: [String: Any] = [
            "date": Date(),
            "songId": songId,
            "type": "favorite"
        ]
        db.collection("User").document(uid).collection("MonthlyStat").addDocument(data: monthlyStatData)
    }
    
    public func removeFromFavorite(uid: String, songId: String) {
        let query = db.collection("User").document(uid).collection("Playlist").document("favorite")
        query.updateData(["songIds": FBManager.Fieldvalue.arrayRemove([songId])])
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
            self.playNewSong(song: tappedSong)
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

    public func hiddenMiniPlayerByUser() {
        userWantsInvisible = true
    }
    
    public func setMiniPlayerVisibiliy(isHidden: Bool) {
        if isHidden {
            isShownMiniPlayer = false
        }else {
            isShownMiniPlayer = self.userWantsInvisible ? false : true
        }
    }
}
