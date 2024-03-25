//
//  PathModel.swift
//  Shared
//
//  Created by 제이콥 on 3/16/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit
import SwiftUI

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
    case friendPlaylist(playlist: Binding<MusicPlaylist>)
    case friendPlaylistManage(friend: MumoriUser, playlist: Binding<[MusicPlaylist]>)
    
    public static func == (lhs: MumoryPage, rhs: MumoryPage) -> Bool {
        switch (lhs, rhs) {
        case (.customization, .customization),
             (.startCustomization, .startCustomization),
             (.signUp, .signUp),
             (.emailLogin, .emailLogin),
             (.lastOfCustomization, .lastOfCustomization),
             (.login, .login),
             (.requestFriend, .requestFriend),
             (.blockFriend, .blockFriend):
            return true
        case let (.home(selectedTab: selectedTab1), .home(selectedTab: selectedTab2)):
            return selectedTab1 == selectedTab2
        case let (.friend(friend: friend1), .friend(friend: friend2)):
            return friend1 == friend2
        case let (.friendPlaylist(playlist: playlist1), .friendPlaylist(playlist: playlist2)):
            return playlist1.wrappedValue == playlist2.wrappedValue
        case let (.friendPlaylistManage(friend: friend1, playlist: playlist1), .friendPlaylistManage(friend: friend2, playlist: playlist2)):
            return friend1 == friend2 && playlist1.wrappedValue == playlist2.wrappedValue
        default:
            return false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .customization:
            hasher.combine(0)
        case .startCustomization:
            hasher.combine(1)
        case .signUp:
            hasher.combine(2)
        case .home(selectedTab: let selectedTab):
            hasher.combine(3)
            hasher.combine(selectedTab)
        case .emailLogin:
            hasher.combine(4)
        case .lastOfCustomization:
            hasher.combine(5)
        case .login:
            hasher.combine(6)
        case .requestFriend:
            hasher.combine(7)
        case .blockFriend:
            hasher.combine(8)
        case .friend(friend: let friend):
            hasher.combine(9)
            hasher.combine(friend)
        case .friendPlaylist(playlist: let playlist):
            hasher.combine(10)
            hasher.combine(playlist.wrappedValue)
        case .friendPlaylistManage(friend: let friend, playlist: let playlist):
            hasher.combine(11)
            hasher.combine(friend)
            hasher.combine(playlist.wrappedValue)
        }
    }
}

public enum LibraryPage: Hashable{    
    case chart
    case search(term: String)
    case playlistManage
    case artist(artist: Artist)
    case playlist(playlist: Binding<MusicPlaylist>)
    case shazam
    case addSong(originPlaylist: MusicPlaylist)
    case play
    case saveToPlaylist(songs: [Song])
    case recommendation(genreID: Int)
    case selectableArtist(artist: Artist)
    case favorite
    case playlistWithIndex(index: Int)
    
    
    public static func == (lhs: LibraryPage, rhs: LibraryPage) -> Bool {
        switch (lhs, rhs) {
        case (.chart, .chart):
            return true
        case let (.search(term: lhsTerm), .search(term: rhsTerm)):
            return lhsTerm == rhsTerm
        case (.playlistManage, .playlistManage):
            return true
        case let (.artist(lhsArtist), .artist(rhsArtist)):
            return lhsArtist == rhsArtist
        case let (.playlist(lhsPlaylist), .playlist(rhsPlaylist)):
            return lhsPlaylist.wrappedValue == rhsPlaylist.wrappedValue
        case (.shazam, .shazam):
            return true
        case let (.addSong(originPlaylist: lhsOriginPlaylist), .addSong(originPlaylist: rhsOriginPlaylist)):
            return lhsOriginPlaylist == rhsOriginPlaylist
        case (.play, .play):
            return true
        case let (.saveToPlaylist(lhsSongs), .saveToPlaylist(rhsSongs)):
            return lhsSongs == rhsSongs
        case let (.recommendation(lhsGenreID), .recommendation(rhsGenreID)):
            return lhsGenreID == rhsGenreID
        case let (.selectableArtist(lhsArtist), .selectableArtist(rhsArtist)):
            return lhsArtist == rhsArtist
        case (.favorite, .favorite):
            return true
        default:
            return false
        }
    }

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
              hasher.combine(playlist.wrappedValue)
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
          case .playlistWithIndex(index: let index):
              hasher.combine(13)
              hasher.combine(index)
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
    case friendList
    case friendPage(friend: MumoriUser)
    case activityList
}

public enum Tab {
    case home
    case social
    case library
    case notification
}
