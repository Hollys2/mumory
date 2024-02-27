//
//  RealmManager.swift
//  Core
//
//  Created by 제이콥 on 2/26/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import RealmSwift
import MusicKit

public class RealmManager {
    public static let shared = RealmManager()
    
    public init() {
        do {
            let realm = try Realm()
            print("realm init successful")
        }catch {
            print("realm init error: \(error)")
        }
    }
}



//public class PlaylistData: Object {
//    @objc dynamic var id: String
//    @objc dynamic var title: String
//    @objc dynamic var songIDs: [String]
//    @objc dynamic var isPrivate: Bool
//    var songs: [Song] = []
//
//        
//    public init(id: String, title: String, songIDs: [String], isPrivate: Bool) {
//        self.id = id
//        self.title = title
//        self.songIDs = songIDs
//        self.isPrivate = isPrivate
//    }
//}