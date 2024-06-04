//
//  InitialSettingFunction.swift
//  Feature
//
//  Created by 제이콥 on 4/5/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit
import Shared

func setSimilarTaste(songs: [Song] = []) async {
    var songs: [Song] = []
    var songIds = songs.map { $0.id.rawValue }
    songIds = Array(songIds.prefix(20))
    try? await  FirebaseManager.shared.db.collection("User").document("adminFavoriteGenres")
        .setData(["favoriteGenres": MusicGenreHelper().genres.map({$0.id})])
    
    try? await FirebaseManager.shared.db.collection("User").document("adminFavoriteGenres").collection("Playlist").document("favorite").setData(["songIds": songIds])
}


let banNicknameList = ["mumory","뮤모리", "삭제된아이디", "시발", "씨발", "ㅅㅂ", "ㅈㄴ", "죽어", "mumoryㅗ",
                       "뮤모리망해라", "뮤모리꺼져", "뮤모리닥쳐", "ㅗㅗㅗㅗㅗㅗㅗ", "존나", "ㅈㄹ", "지랄", "ㅈ같다", "좆같다",
                       "잦같다", "개같다", "뮤모리시발", "뮤모리병신", "뮤모리죽어", "뮤모리지랄", "뮤모리뻐큐", "장애", "장애인", "버러지", "뻐큐", "엿같다", "엿먹어",
                       "fuckyou", "뮤모리씨발", "뮤모리ㅅㅂ", "뮤모리ㅆㅂ", "뮤모리ㅂㅅ", "뮤모리븅신", "병신", "븅신", "ㅂㅅ", "빙신", "니엄마", "니아빠", "니엄",
                       "ㅆㅂ", "뮤모리좆같다", "뮤모리잣같다", "뮤모리개같다", "뮤모리엿먹어", "느금", "느금마", "fuck", "sibal", "bitch", "jonna", "asshole", "쌍년",
                       "썅놈", "뮤모리좆같아", "뮤모리잣같아", "뮤모리개같아", "개병신", "shit", "shutup", "dick", "dickhead", "없는아이디", "시벌", "샹년", "샹놈", "뮤모리ㅈㄴ",
                       "뮤모리개새끼", "뮤모리fuck", "씨벌", "fucker", "cunt", "개새끼", "좆까", "염병", "개새끼", "좆까", "염병", "개새", "시발놈", "씨발놈", "씨발년", "시발년", "시발개새끼",
                       "씨발개새끼", "병신새끼", "뮤모리니엄", "뮤모리느금", "뮤모리씨발년", "뮤모리엿같다", "뮤모리입니다", "병신시발", "병신씨발", "존나시발", "존나씨발", "병신시발놈", "병신씨발놈",
                       "존나시발놈", "존나시발놈", "존나씨발놈", "병신시발넘", "병신씨발넘", "존나시발넘", "존나씨발넘", "앙기모찌", "앙기모띠", "자살", "장애새끼", "병신시발년", "병신씨발년", "존나시발년",
                       "존나시발냔", "존나씨발냔", "병신씨발냔", "병신시발냔"
]

func setBanNicknameList() {
    let db = FirebaseManager.shared.db
    
    banNicknameList.indices.forEach { index in
        db.collection("User").document("adminNicknameDocument\(index)").setData(["nickname": banNicknameList[index]])
    }
}


