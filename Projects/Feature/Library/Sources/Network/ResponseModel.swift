//
//  ResponseModel.swift
//  Feature
//
//  Created by 제이콥 on 2/9/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation

struct SongResponseModel: Decodable{
    let results: results
}
struct results: Decodable{
    let songs: [data]
}
struct data: Decodable{
    let data: [song]
}
struct song: Decodable{
    let id: String
}


