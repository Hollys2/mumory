//
//  LibraryManageModel.swift
//  Feature
//
//  Created by 제이콥 on 1/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit
import Shared

public class LibraryManageModel: ObservableObject{
    public init(){}
    enum entrySubView {
        case myMusic
        case recomendation
    }
    
    enum artistParameter {
        case fromArtist(data: Artist)
        case fromSong(data: Song)
    }
    enum LibraryPage{
        case entry(entrySubView)
        case chart
        case search(term: String)
        case playlistManage
        case artist(artistParameter)
        case playlist(playlist: MusicPlaylist)
        case shazam
        case addSong(originPlaylist: MusicPlaylist)
        case play
        case saveToPlaylist(song: Song)
    }
    
    
    @Published var page: LibraryPage = .entry(.myMusic)
    @Published private var stack: [LibraryPage] = [.entry(.myMusic)]
    
    func pop() {
        page = self.stack.popLast() ?? .entry(.myMusic)
    }
    
    func push(destination: LibraryPage) {
        self.stack.append(self.page)
        self.page = destination
    }
}