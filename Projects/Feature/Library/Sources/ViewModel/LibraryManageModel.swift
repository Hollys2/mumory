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
    
    enum LibraryPage{
        case entry
        case search
        case playlist
        case artist
    }
    
    @Published var nowPage: LibraryPage = .entry
    @Published var searchTerm: String = ""
    @Published var tappedArtist: Artist?
}
