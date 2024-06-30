//
//  MusicGenre.swift
//  Feature
//
//  Created by 제이콥 on 2/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit

public struct MusicGenre: Hashable{
    public init(name: String, id: Int) {
        self.name = name
        self.id = id
    }
    public let name: String
    public let id: Int
}

public struct MusicGenreHelper{
    public init(){}
    
    public func genreName(id: Int) -> String {
        let name = genreDictionary[id] ?? "ERROR"
        return name
    }
    
    public let genreDictionary: [Int: String] = [
        2: "블루스",
        4: "키즈",
        5: "클래식",
        6: "컨트리",
        7: "일렉트로닉",
        9: "오페라",
        10: "싱어송라이터",
        11: "재즈",
        12: "라틴",
        13: "뉴에이지",
        14: "POP",
        15: "R&B/소울",
        16: "OST",
        17: "댄스",
        18: "힙합/랩",
        20: "얼터너티브",
        21: "록",
        22: "크리스천",
        24: "레게",
        27: "J-POP",
        29: "일본 애니메이션",
        50: "피트니스",
        51: "K-POP",
        8: "홀리데이",
        1122: "브라질 음악",
        1153: "메탈",
        1203: "아프리카 음악",
        1289: "포크",
        25: "이지 리스닝",
        53: "악기",
        1014: "자장가",
        1029: "오케스트라",
        1263: "발리우드",
        50000066: "독일팝"
    ]
    
    public let genres: [MusicGenre] = [
        MusicGenre(name: "K-POP", id: 51),
        MusicGenre(name: "POP", id: 14),
        MusicGenre(name: "클래식", id: 5),
        MusicGenre(name: "록", id: 21),
        
        MusicGenre(name: "오케스트라", id: 1029),
        MusicGenre(name: "컨트리", id: 6),
        MusicGenre(name: "블루스", id: 2),

        MusicGenre(name: "싱어송라이터", id: 10),
        MusicGenre(name: "재즈", id: 11),
        MusicGenre(name: "라틴", id: 12),
        
        MusicGenre(name: "크리스천", id: 22),
        MusicGenre(name: "키즈", id: 4),
        MusicGenre(name: "OST", id: 16),
        MusicGenre(name: "메탈", id: 1153),
        
        MusicGenre(name: "브라질 음악", id: 1122),
        MusicGenre(name: "이지 리스닝", id: 25),
        
        MusicGenre(name: "자장가", id: 1014),
        MusicGenre(name: "일렉트로닉", id: 7),
        MusicGenre(name: "힙합/랩", id: 18),
        
        MusicGenre(name: "얼터너티브", id: 20),
        MusicGenre(name: "레게", id: 24),
        MusicGenre(name: "J-POP", id: 27),
        
        MusicGenre(name: "뉴에이지", id: 13),
        MusicGenre(name: "R&B/소울", id: 15),
        MusicGenre(name: "댄스", id: 17),

        MusicGenre(name: "일본 애니메이션", id: 29),
        MusicGenre(name: "홀리데이", id: 8),
        MusicGenre(name: "포크", id: 1289),
        
        MusicGenre(name: "아프리카 음악", id: 1203),
        MusicGenre(name: "악기", id: 53),
        MusicGenre(name: "피트니스", id: 50),
        
        MusicGenre(name: "발리우드", id: 1263),
        MusicGenre(name: "독일팝", id: 50000066)


    ]
}


