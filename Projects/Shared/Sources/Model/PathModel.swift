//
//  PathModel.swift
//  Shared
//
//  Created by 제이콥 on 3/16/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit

public enum MumoryPage: Hashable {
    case customization
    case startCustomization
    case signUp
    case home(selectedTab: Tab)
    case emailLogin
    case lastOfCustomization
    case login
    case requestFriend
    case blockFriend
    case friend(friend: MumoriUser)
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
    case selectableArtist(artist: Artist)
    case favorite
    
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
          case .selectableArtist(artist: let artist):
              hasher.combine(11)
              hasher.combine(artist)
          case .favorite:
              hasher.combine(12)
          }
      }
}

public enum MyPage: Hashable {
    case myPage
    case setting
    case account
    case notification
    case setPW
    case question
    case emailVerification
    case selectNotificationTime
    case login
    case friendList(friends: [MumoriUser])
    case friendPage(friend: MumoriUser)
    case activityList
}
public enum Tab {
    case home
    case social
    case library
    case notification
}
