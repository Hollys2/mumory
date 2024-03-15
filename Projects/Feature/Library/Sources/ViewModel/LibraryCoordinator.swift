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

public class LibraryCoordinator: ObservableObject{
//    @Published public var isPop: Bool = false
    @Published public var stack: [LibraryPage] = []
    @Published public var xOffset: CGFloat = .zero
    public var width: CGFloat = .zero
    public init() {}
    
    
    func pop() {
        _ = self.stack.removeLast()
    }
    
    func push(destination: LibraryPage) {
        self.stack.append(destination)
    }
    
    @ViewBuilder
    func getView(page: LibraryPage) -> some View {
        switch(page){
        case .search(term: let term):
            SearchView(term: term)
            
        case .artist(artist: let artist):
            ArtistView(artist: artist)
                
            
        case .playlistManage:
            PlaylistManageView()
            
        case .chart:
            ChartListView()
            
        case .playlist(playlist: let playlist):
            PlaylistView(playlist: playlist)

            
        case .shazam:
            ShazamView()
            
        case .addSong(originPlaylist: let originPlaylist):
            AddPlaylistSongView(originPlaylist: originPlaylist)
            
        case .play:
            NowPlayingView()
            
        case .saveToPlaylist(songs: let songs):
            SaveToPlaylistView(songs: songs)
            
        case .recommendation(genreID: let genreID):
            RecommendationListView(genreID: genreID)

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


public enum LibraryPage: Hashable{
    
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
    
    public func hash(into hasher: inout Hasher) {
          switch self {
          case .chart:
              hasher.combine(1)
          case .search(let term):
              hasher.combine(2)
              hasher.combine(term)
          case .playlistManage:
              hasher.combine(3)
          case .artist(let artist):
              hasher.combine(4)
              hasher.combine(artist)
          case .playlist(let playlist):
              hasher.combine(5)
              hasher.combine(playlist)
          case .shazam:
              hasher.combine(6)
          case .addSong(let originPlaylist):
              hasher.combine(7)
              hasher.combine(originPlaylist)
          case .play:
              hasher.combine(8)
          case .saveToPlaylist(let songs):
              hasher.combine(9)
              hasher.combine(songs)
          case .recommendation(let genreID):
              hasher.combine(10)
              hasher.combine(genreID)
          }
      }
}

