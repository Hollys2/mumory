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
    case home
    case emailLogin
    case lastOfCustomization
    case login
    case requestFriend
    case blockFriend
    case friend(friend: MumoriUser)
    case friendPlaylist(friend: MumoriUser, playlist: Binding<MusicPlaylist>)
    case friendPlaylistManage(friend: MumoriUser, playlist: Binding<[MusicPlaylist]>)
    case searchFriend
    case mostPostedSongList(songs: Binding<[Song]>)
    case similarTasteList(songs: Binding<[Song]>)
    case myRecentMumorySongList
    case report
    
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
        case let (.friend(friend: friend1), .friend(friend: friend2)):
            return friend1 == friend2
        case let (.friendPlaylist(friend: friend1, playlist: playlist1), .friendPlaylist(friend: friend2, playlist: playlist2)):
            return (friend1 == friend2) && (playlist1.wrappedValue == playlist2.wrappedValue)
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
        case .home:
            hasher.combine(3)
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
        case .friendPlaylist(friend: let friend, playlist: let playlist):
            hasher.combine(10)
            hasher.combine(friend)
            hasher.combine(playlist.wrappedValue)
        case .friendPlaylistManage(friend: let friend, playlist: let playlist):
            hasher.combine(11)
            hasher.combine(friend)
            hasher.combine(playlist.wrappedValue)
        case .searchFriend:
            hasher.combine(12)
        case .mostPostedSongList(songs: let songs):
            hasher.combine(13)
            hasher.combine(songs.wrappedValue)
        case .similarTasteList(songs: let songs):
            hasher.combine(14)
            hasher.combine(songs.wrappedValue)
        case .myRecentMumorySongList:
            hasher.combine(15)
        case .report:
            hasher.combine(16)
 
        }
    }
}
public enum ShazamViewType {
    case normal
    case createMumory
}

public enum LibraryPage: Hashable{
    case chart
    case search(term: String)
    case playlistManage
    case artist(artist: Artist)
    case playlist(playlist: Binding<MusicPlaylist>)
    case shazam(type: ShazamViewType)
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
        case let (.shazam(lhsShazamType), .shazam(rhsShazamType)):
            return lhsShazamType == rhsShazamType
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
          case .shazam(let shazamViewType):
              hasher.combine(6)
              hasher.combine(shazamViewType)
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
    case notification(iconHidden: Bool = false)
    case setPW
    case question
    case emailVerification
    case selectNotificationTime
    case login
    case friendList
    case friendPage(friend: MumoriUser)
    case reward
    case monthlyStat
    case activityList
}

public enum Tab {
    case home
    case social
    case library
    case notification
}

public enum InitPage {
    case login
    case onBoarding
    case home
}
