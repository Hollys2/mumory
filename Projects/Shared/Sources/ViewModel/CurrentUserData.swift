//
//  CurrentUserData.swift
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
                Task {
                    let query = FBManager.shared.db.collection("User").document(self.uid)
                    guard let data = try? await query.getDocument().data() else {return}
                    guard let friends = data["friends"] as? [String] else {return}
                    self.friends = friends
                }
            }
        }
    }
    @Published public var user: MumoriUser = MumoriUser()
    @Published public var friends: [String] = []
    
    //삭제 예정...
    @Published public var favoriteGenres: [Int] = []
    @Published public var topInset: CGFloat = 0
    @Published public var bottomInset: CGFloat = 0
    @Published public var playlistArray: [MusicPlaylist] = []
    
    public init(){
    }

}
