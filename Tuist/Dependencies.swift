//
//  Dependencies.swift
//  Config
//
//  Created by 다솔 on 2023/11/08.
//  


import ProjectDescription

let dependencie = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies([
        .remote(url: "https://github.com/firebase/firebase-ios-sdk.git", requirement: .upToNextMinor(from: "10.19.0")),
        .remote(url: "https://github.com/Moya/Moya.git", requirement: .upToNextMajor(from: "15.0.0")),
        .remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .upToNextMajor(from: "2.11.0"))
    ]
                                                         ,
                                                         baseSettings: makeFrameworkSettings()
//                                                         ,targetSettings: makeTargetSettings()
    ),
    platforms: [.iOS]
    
)

//public func makeTargetSettings() -> [String: SettingsDictionary] {
//    var settings: [String: SettingsDictionary] = [:]
//    let allYourDependencyNames  = ["FirebaseStorage"]
//    // add all other dependency names here, this is at least what I am doing
//    allYourDependencyNames.forEach { dependency in
//        settings[dependency] = makeBaseSettings()
//        settings[dependency] = [
//            "HEADER_SEARCH_PATHS": "Tuist/Dependencies/SwiftPackageManager/.build/checkouts/gtm-session-fetcher/Sources/Core/Public/GTMSessionFetcher"
//        ]
//    }
//
//    return settings
//}
//
//func makeBaseSettings() -> SettingsDictionary {
//    SettingsDictionary()
//        .swiftOptimizeObjectLifetimes(false)
//        .bitcodeEnabled(true)
//        .merging([
//            "OTHER_LDFLAGS": "-ObjC",
//            "ALWAYS_SEARCH_USER_PATHS": "NO",
//        ])
//}
//
func makeFrameworkSettings() -> Settings {
    .settings(
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ]
    )
}
//
// this is a workaround for named configuration that are different to "Debug" and "Release".
//func makeFrameworkBaseSettings() -> SettingsDictionary {
//    [
//        "FRAMEWORK_SEARCH_PATHS": "$(inherited) $(SYMROOT)"
//    ]
//}
