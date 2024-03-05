//
//  UserViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Core

public class CurrentUserData: ObservableObject {
    //사용자 정보 및 디바이스 크기 정보
    @Published public var uid: String = "" {
        didSet {
            DispatchQueue.main.async {
                Task{
                    self.user = await MumoriUser(uid: self.uid)
                }
            }
            
        }
    }
    @Published public var user: MumoriUser = MumoriUser()
    @Published public var favoriteGenres: [Int] = []
    
    @Published public var width: CGFloat = 0
    @Published public var height: CGFloat = 0
    @Published public var topInset: CGFloat = 0
    @Published public var bottomInset: CGFloat = 0
    
    @Published public var playlistArray: [MusicPlaylist] = [
        MusicPlaylist(id: "addItem", title: "", songIDs: [], isPrivate: false, isAddItme: true)
    ]
    
    public init(){
    }

}
