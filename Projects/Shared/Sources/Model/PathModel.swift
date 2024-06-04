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
    case friendPlaylist(playlistIndex: Int)
    case friendPlaylistManage
    case searchFriend
    case mostPostedSongList(songs: Binding<[Song]>)
    case similarTasteList(songs: Binding<[Song]>)
    case myRecentMumorySongList
    case report
    case mumoryReport(mumoryId: String)
    case chart
    case search(term: String)
    case playlistManage
    case artist(artist: Artist)
    case playlist(playlist: Binding<MusicPlaylist>)
    case shazam(type: ShazamViewType)
    case addSong(originPlaylist: MusicPlaylist)
    case saveToPlaylist(songs: [Song])
    case recommendation(genreID: Int)
    case selectableArtist(artist: Artist)
    case favorite
    case playlistWithIndex(index: Int)
    case myPage
    case setting
    case account
    case notification(iconHidden: Bool = false)
    case setPW
    case question
    case emailVerification
    case selectNotificationTime
    case friendList
    case friendPage(friend: MumoriUser)
    case reward
    case monthlyStat
    case activityList
    
    public static func == (lhs: MumoryPage, rhs: MumoryPage) -> Bool {
        switch (lhs, rhs) {
        case (.customization, .customization),
             (.startCustomization, .startCustomization),
             (.signUp, .signUp),
             (.emailLogin, .emailLogin),
             (.lastOfCustomization, .lastOfCustomization),
             (.login, .login),
             (.requestFriend, .requestFriend),
             (.blockFriend, .blockFriend),
            (.friendPlaylistManage, .friendPlaylistManage):
            return true
        case let (.friend(friend: friend1), .friend(friend: friend2)):
            return friend1 == friend2
        case let (.friendPlaylist(playlistIndex: index1), .friendPlaylist(playlistIndex: index2)):
            return index1 == index2
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
        case .friendPlaylist(playlistIndex: let playlistIndex):
            hasher.combine(10)
            hasher.combine(playlistIndex)
        case .friendPlaylistManage:
            hasher.combine(11)
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
        case .mumoryReport(mumoryId: let mumoryId):
            hasher.combine(17)
            hasher.combine(mumoryId)
        case .chart:
            hasher.combine(18)
        case .search(let term):
            hasher.combine(19)
            hasher.combine(term)
        case .playlistManage:
            hasher.combine(20)
        case .artist(let artist):
            hasher.combine(21)
            hasher.combine(artist)
        case .playlist(let playlist):
            hasher.combine(22)
            hasher.combine(playlist.wrappedValue)
        case .shazam(let shazamViewType):
            hasher.combine(23)
            hasher.combine(shazamViewType)
        case .addSong(let originPlaylist):
            hasher.combine(24)
            hasher.combine(originPlaylist)
        case .saveToPlaylist(let songs):
            hasher.combine(25)
            hasher.combine(songs)
        case .recommendation(let genreID):
            hasher.combine(26)
            hasher.combine(genreID)
        case .selectableArtist(artist: let artist):
            hasher.combine(27)
            hasher.combine(artist)
        case .favorite:
            hasher.combine(28)
        case .playlistWithIndex(index: let index):
            hasher.combine(29)
            hasher.combine(index)
        case .myPage:
            hasher.combine(30)
        case .setting:
            hasher.combine(31)
        case .account:
            hasher.combine(32)
        case .notification(let iconHidden):
            hasher.combine(33)
            hasher.combine(iconHidden)
        case .setPW:
            hasher.combine(34)
        case .question:
            hasher.combine(35)
        case .emailVerification:
            hasher.combine(36)
        case .selectNotificationTime:
            hasher.combine(37)
        case .activityList:
            hasher.combine(38)
        case .friendList:
            hasher.combine(39)
        case .friendPage(let friend):
            hasher.combine(40)
            hasher.combine(friend)
        case .reward:
            hasher.combine(41)
        case .monthlyStat:
            hasher.combine(42)

        }
    }
}
public enum ShazamViewType {
    case normal
    case createMumory
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


public enum AuthPage {
    case login
    case singUpCenter
    case TOSForSocial
    case introOfCustomization
    case customizationManage
    case customizationCenter
    case profileCard
}
