//
//  UserViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Core

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
    @Published public var isCheckedServiceNewsNotification: Bool = false
    @Published public var isCheckedSocialNotification: Bool = false
    @Published public var profileImageURL: URL?
    @Published public var backgroundImageURL: URL?
    @Published public var bio: String = ""
    
    @Published public var width: CGFloat = 0
    @Published public var height: CGFloat = 0
    @Published public var topInset: CGFloat = 0
    @Published public var bottomInset: CGFloat = 0
    
    @Published public var playlistArray: [MusicPlaylist] = [
        MusicPlaylist(id: "addItem", title: "", songIDs: [], isPrivate: false, isAddItme: true)
    ]
    
    public func getBackgroundURL() async -> URL? {
        let db = FirebaseManager.shared.db
        
        guard let result = try? await db.collection("User").document(self.uid).getDocument() else {
            return nil
        }
        
        guard let data = result.data() else {
            return nil
        }
        
        guard let urlString = data["background_image_url"] as? String else {
            return nil
        }
        
        return URL(string: urlString)
    }
}
