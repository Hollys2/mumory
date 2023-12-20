//
//  AnnotationViewModel.swift
//  Feature
//
//  Created by 다솔 on 2023/12/19.
//  Copyright © 2023 hollys. All rights reserved.
//


import Foundation
import Shared
import MusicKit

// 추후 Core나 Shared로 이동 예정
final public class MumoryDataViewModel: ObservableObject {

    @Published public var mumoryModels: [MumoryModel] = []
    @Published public var mumoryAnnotations: [MumoryAnnotation] = []
    
    public init(){}

//    func fetchSongInfo(songId: String) async throws -> AnnotationModel {
//        let musicItemID = MusicItemID(rawValue: songId)
//        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
//        let response = try await request.response()
//        guard let song = response.items.first else {
//            throw NSError(domain: "GoogleMapSample", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
//        }
////        print("response.items.first: \(song)")
//
//        if let artworkUrl = song.artwork?.url(width: 400, height: 400) {
//                  return AnnotationModel(date: Date(), location: "Nowhere", songID: musicItemID, title: song.title, artist: song.artistName, artworkUrl: artworkUrl)
//        } else {
//            // nil인 경우, 기본값으로 URL을 설정하거나 에러를 처리하는 등의 작업을 수행할 수 있습니다.
//            // 여기서는 기본값으로 빈 URL을 설정했습니다.
//            return AnnotationModel(date: Date(), location: "Nowhere", songID: musicItemID, title: song.title, artist: song.artistName, artworkUrl: URL(string: "https://previews.123rf.com/images/martialred/martialred1507/martialred150700740/42614010-%EC%95%B1%EA%B3%BC-%EC%9B%B9-%EC%82%AC%EC%9D%B4%ED%8A%B8%EC%97%90-%EB%8C%80%ED%95%9C-%EC%9D%B8%ED%84%B0%EB%84%B7-url-%EB%A7%81%ED%81%AC-%EB%9D%BC%EC%9D%B8-%EC%95%84%ED%8A%B8-%EC%95%84%EC%9D%B4%EC%BD%98.jpg")!)
//        }
//    }

}
