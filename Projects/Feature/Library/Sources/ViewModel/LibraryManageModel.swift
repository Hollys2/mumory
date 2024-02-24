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
    @Published public var isPop: Bool = false
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

public enum artistParameter {
    case fromArtist(data: Artist)
    case fromSong(data: Song)
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
    case artist(artistParameter)
    case playlist(playlist: MusicPlaylist)
    case shazam
    case addSong(originPlaylist: MusicPlaylist)
    case play
    case saveToPlaylist(song: Song)
    case recommendation(genreID: Int)
}
//extension LibraryPage: Equatable {
//    static func == (lhs: LibraryPage, rhs: LibraryPage) -> Bool {
//        switch(lhs, rhs) {
//        case (.entry(.myMusic), .entry(.myMusic)),
//            (.entry(.recomendation), .entry(.recomendation)),
//            (.chart, .chart),
//            (.search(term: _), .search(term: _)),
//            (.playlistManage, .playlistManage),
//            (.artist(_), .artist(_)),
//            (.playlist(playlist: _), .playlist(playlist: _)),
//            (.shazam, .shazam),
//            (.addSong(originPlaylist: _), .addSong(originPlaylist: _)),
//            (.play, .play),
//            (.saveToPlaylist(song: _), .saveToPlaylist(song: _)),
//            (.recommendation(genreID: _), .recommendation(genreID: _)):
//            return true
//        default: return false
//        }
//    }
//}
//extension LibraryPage: Identifiable, Hashable {
//    var id: ObjectIdentifier {
//        //
//    }
//    
//    var identifier: String {
//        return UUID().uuidString
//    }
//    
//    public func hash(into hasher: inout Hasher) {
//        return hasher.combine(identifier)
//    }
//    
//    public static func == (lhs: LibraryPage, rhs: LibraryPage) -> Bool {
//        return lhs.identifier == rhs.identifier
//    }
//}
