//
//  Feature
//
//  Created by 제이콥 on 11/27/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import Foundation
import SwiftUI
import MusicKit

struct PlayingInfo {
    var playingTime: TimeInterval
    var playbackRate: Double
}

public class PlayerViewModel: ObservableObject {
    public init() {}
    
    @Published var playingSong: Song?
    @Published var isMiniPlayerPresent: Bool = true
    @Published var isPlayingViewPresent: Bool = false
    @Published var isPlaying: Bool = false
    
    @Published var playingInfo: PlayingInfo = PlayingInfo(playingTime: 0.0, playbackRate: 0.0)
    
    private var queue: [Song] = []
    private var player = ApplicationMusicPlayer.shared

    var timer: Timer?
    
    public func playNewSong(song: Song) {
        player.queue = [song]
        Task {
            do {
                try await player.play()
                DispatchQueue.main.async {
                    self.playingSong = song
                    self.isPlaying = true
                    self.setPlayingTime()
                }
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
            
        }
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
    
    public func endEditingSlider() {
        player.playbackTime = playingInfo.playingTime
        setPlayingTime()
    }
    
    private func setPlayingTime() {
        playingInfo.playingTime = player.playbackTime
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            DispatchQueue.main.async {
                self.playingInfo.playingTime = self.player.playbackTime
                self.playingInfo.playbackRate = self.player.playbackTime / (self.playingSong?.duration ?? 0.0)
            }
        })
    }
    
    

 
}
