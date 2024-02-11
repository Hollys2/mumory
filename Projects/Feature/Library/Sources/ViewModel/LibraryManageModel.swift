//
//  LibraryManageModel.swift
//  Feature
//
//  Created by 제이콥 on 1/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit

public class LibraryManageModel: ObservableObject{
    public init(){}
    enum entrySubView {
        case myMusic
        case recomendation
    }
    enum LibraryPage{
        case entry(entrySubView)
        case chart
        case search
        case playlist
        case artist
    }
    
    @Published var page: LibraryPage = .entry(.myMusic)
    @Published var searchTerm: String = ""
    @Published var tappedArtist: Artist?
    @Published var previousPage: LibraryPage = .entry(.myMusic)
}
