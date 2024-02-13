//
//  AppleMusicService.swift
//  Feature
//
//  Created by 제이콥 on 2/9/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Alamofire
import Core

enum NetworkResult{
    case success(Any)
    case failure(Any)
}

enum AppleMusicType{
    case song
    case album
    case artist
}

public class AppleMusicService {
    public init() {}

    public static let shared = AppleMusicService()
    
    let baseURL = "https://api.music.apple.com/v1"
    let chartURL = "/catalog/kr/charts"
    
    
    func getToken(){
        
    }
    
    func getRecommendationMusicIDList(genre: Int, limit: Int, offset: Int, completion: @escaping(NetworkResult) -> Void){
        let url = baseURL + chartURL
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        
        db.collection("Admin").document("Key").getDocument { snapshot, error in
            if let snapshot = snapshot {
                guard let data = snapshot.data() else{
                    print("no data")
                    return
                }
                
                guard let token = data["apple_music_token"] else {
                    print("no token")
                    return
                }
                                
                let header : HTTPHeaders = ["Content-Type" : "application/json",
                                            "Authorization": "Bearer \(token)"]
                
                let parameter:Parameters = [
                    "types": "songs",
                    "genre": genre,
                    "limit":limit,
                    "offset": offset
                ]
                
                AF.request(url, method: .get, parameters: parameter, headers: header)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: SongResponseModel.self) { response in
                        switch(response.result){
                        case .success(let result):
                            guard let songs = result.results.songs.first?.data else {
                                print("error1")
                                return
                            }
                            completion(.success(songs))
                            
                        case .failure(let error):
                            completion(.failure("failure"))
                        }
                    }
                
            }
        }
    }
}
