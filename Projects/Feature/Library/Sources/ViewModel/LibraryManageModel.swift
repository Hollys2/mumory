//
//  LibraryManageModel.swift
//  Feature
//
//  Created by 제이콥 on 1/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit
import SwiftUI
import Shared

public class LibraryManageModel: ObservableObject{
    @Published public var page: LibraryPage = .entry
//    @Published public var isPop: Bool = false
    @Published public var stack: [LibraryPage] = [.entry]
    @Published public var xOffset: CGFloat = .zero
    public var width: CGFloat = .zero
    public init() {}
    
    func pop() {
        DispatchQueue.main.async {
            withAnimation(.spring(duration: 0.2)){
                self.xOffset = self.width
            }
        }

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
            DispatchQueue.main.async {
                _ = self.stack.popLast()
                self.xOffset = 0
            }
        }
    }
    
    func push(destination: LibraryPage) {
        DispatchQueue.main.async {
            withAnimation(.spring(duration: 0.2)){
                self.stack.append(destination)
            }
        }

    }
}

enum entrySubView {
    case myMusic
    case recomendation
}


enum moveStatus {
    case pop
    case push
}


public enum LibraryPage{
    
    case entry
    case chart
    case search(term: String)
    case playlistManage
    case artist(artist: Artist)
    case playlist(playlist: MusicPlaylist)
    case shazam
    case addSong(originPlaylist: MusicPlaylist)
    case play
    case saveToPlaylist(songs: [Song])
    case recommendation(genreID: Int)
}

