//
//  Dependencies.swift
//  Config
//
//  Created by 다솔 on 2023/11/08.
//  


import ProjectDescription

let dependencie = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies([
        .remote(url: "https://github.com/firebase/firebase-ios-sdk.git", requirement: .upToNextMajor(from: "10.0.0")),
//        .remote(url: "https://github.com/Moya/Moya.git", requirement: .upToNextMajor(from: "15.0.0")),
    ]
                                                         ),
    platforms: [.iOS]
    
)
