//
//  UserViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation

public class UserViewModel: ObservableObject {
    public init(){}
    
    //사용자 정보 및 디바이스 크기 정보
    @Published public var uid: String = ""
    @Published public var nickname: String = ""
    @Published public var id: String = ""
    @Published public var email: String = ""
    @Published public var favoriteGenres: [Int] = []
    @Published public var signInMethod: String = ""
    @Published public var selectedNotificationTime: Int = 0
    @Published public var isCheckedServiceNewsNotification: Bool?
    @Published public var isCheckedSocialNotification: Bool?
    
    @Published public var width: CGFloat = 0
    @Published public var height: CGFloat = 0
    @Published public var topInset: CGFloat = 0
    @Published public var bottomInset: CGFloat = 0
    @Published public var customTopbarHeight: CGFloat = 68 //라이브러리, 소셜 상단 바 높이(safe area height 제외)
    
    @Published public var playlistArray: [MusicPlaylist] = [
        MusicPlaylist(id: "addItem", title: "", songIDs: [], isPrivate: false, isFavorite: false, isAddItme: true)
    ]
}
