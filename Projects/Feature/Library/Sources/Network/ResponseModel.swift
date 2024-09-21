//
//  ResponseModel.swift
//  Feature
//
//  Created by 제이콥 on 2/9/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation

struct AppleMusicSongResponseModel: Decodable{
    let results: AppleMusicResults
}
struct AppleMusicResults: Decodable{
    let songs: [AppleMusicSongs]
}
struct AppleMusicSongs: Decodable{
    let data: [AppleMusicData]
}
struct AppleMusicData: Decodable{
    let id: String
}


