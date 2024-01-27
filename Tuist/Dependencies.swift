//
//  Dependencies.swift
//  Config
//
//  Created by 다솔 on 2023/11/08.
//  


import ProjectDescription

let dependencie = Dependencies(
    swiftPackageManager: [
        .remote(url: "https://github.com/firebase/firebase-ios-sdk.git", requirement: .upToNextMinor(from: "10.19.0")),
        .remote(url: "https://github.com/Moya/Moya.git", requirement: .upToNextMajor(from: "15.0.0")),
        .remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .upToNextMajor(from: "2.11.0")),
        .remote(url: "https://github.com/google/gtm-session-fetcher.git", requirement: .upToNextMajor(from: "2.2.0"))
//        .remote(url: "https://github.com/google/GoogleSignIn-iOS.git", requirement: .upToNextMajor(from:"7.0.0"))
    ],
    platforms: [.iOS]
)
