//
//  MusicKitMethod.swift
//  Feature
//
//  Created by 제이콥 on 3/30/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit

public func fetchSong(songID: String) async -> Song? {
    let musicItemID = MusicItemID(rawValue: songID)
    var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
    guard let response = try? await request.response() else {
        return nil
    }
    guard let song = response.items.first else {
        return nil
    }
    return song
}


public func fetchDetailSong(songID: String) async -> Song? {
    let musicItemID = MusicItemID(rawValue: songID)
    var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
    request.properties = [.artists, .station]
    guard let response = try? await request.response() else {
        return nil
    }
    guard let song = response.items.first else {
        return nil
    }
    return song
}

public func fetchDetailArtist(artistID: String) async -> Artist? {
    let musicItemID = MusicItemID(rawValue: artistID)
    var request = MusicCatalogResourceRequest<Artist>(matching: \.id, equalTo: musicItemID)
    request.properties = [.albums, .appearsOnAlbums]
    guard let response = try? await request.response() else {
        return nil
    }
    guard let artist = response.items.first else {
        return nil
    }
    return artist
}

public func fetchDetailAlbum(albumID: String) async -> Album? {
    let musicItemID = MusicItemID(rawValue: albumID)
    var request = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: musicItemID)
    request.properties = [.tracks]
    guard let response = try? await request.response() else {
        return nil
    }
    guard let album = response.items.first else {
        return nil
    }
    return album
}

public func fetchSongs(songIDs: [String]) async -> [Song]{
    var returnValue: [Song] = []
    for id in songIDs {
        let musicItemID = MusicItemID(rawValue: id)
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        guard let response = try? await request.response() else {
            continue
        }
        guard let song = response.items.first else {
            continue
        }
        returnValue.append(song)
    }
    return returnValue
}

public func getModeGenre(songIds: [String]) async -> String {
    
    let songs = await withTaskGroup(of: Song?.self) { taskGroup -> [Song] in
        var returnValue: [Song] = []
        for songId in songIds {
            taskGroup.addTask {
                return await fetchSong(songID: songId)
            }
        }
        
        for await value in taskGroup {
            guard let song = value else {continue}
            returnValue.append(song)
        }
        
        return returnValue
    }
    
    var genres: [String: Int] = [:]

    songs.forEach { song in
        song.genreNames.forEach { genre in
            let uppercasedGenre = genre.uppercased()
            if uppercasedGenre == "MUSIC" {return}
            if genres.contains(where: {$0.key == uppercasedGenre}) {
                genres[uppercasedGenre]! += 1
            }else {
                genres[uppercasedGenre] = 1
            }
        }
    }
    
    let result = genres.sorted { value1, value2 in
        return value1.value > value2.value
    }
    guard let modeGenre = result.first?.key else {return "--"}
    return modeGenre
}
