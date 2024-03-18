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
    @Published var isShownMiniPlayer: Bool = true
    @Published var isPlayingViewPresent: Bool = false
    @Published var isPlaying: Bool = false
    
    @Published var playingInfo: PlayingInfo = PlayingInfo(playingTime: 0.0, playbackRate: 0.0)
    @Published var playQueue = ApplicationMusicPlayer.shared.queue
    @Published var queue: [Song] = []
    @Published var currentSong: Song?
    @Published var queueTitle: String = ""
    
    @Published var favoriteSongIds: [String] = []
    @Published public var playlistArray: [MusicPlaylist] = []

    @Published var isPresentNowPlayingView: Bool = false
        
    private var player = ApplicationMusicPlayer.shared

    @Published var playingTime: TimeInterval = 0.0

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
        self.queueTitle = ""
        
        Task {
            do {
                try await player.play()
                DispatchQueue.main.async {
                    self.isPlaying = true
                    self.currentSong = song
                    self.setPlayingTime()
                }
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
            
        }
    }
    public func playAll(title: String, songs: [Song]) {
        self.player.queue = .init(for: songs)
        self.queue = songs
        self.queueTitle = title
        Task {
            do {
                try await player.play()
                DispatchQueue.main.async {
                    self.isPlaying = true
                    self.currentSong = self.playingSong()
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
            self.isPlaying = false
            self.timer?.invalidate()
        }
    }
    
    public func play() {
        Task{
            do {
                try await player.play()
                DispatchQueue.main.async {
                    self.isPlaying = true
                    self.setPlayingTime()
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
    }
    
    public func removeFromFavorite(uid: String, songId: String) {
        let query = db.collection("User").document(uid).collection("Playlist").document("favorite")
        query.updateData(["songIds": FBManager.Fieldvalue.arrayRemove([songId])])
        self.favoriteSongIds.removeAll(where: {$0 == songId})
    }
    

 
}
