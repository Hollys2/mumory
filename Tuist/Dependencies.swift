//
//  Dependencies.swift
//  Config
//
//  Created by 다솔 on 2023/11/08.
//


import ProjectDescription

let dependencie = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies([
        .remote(url: "https://github.com/firebase/firebase-ios-sdk.git", requirement: .exact("10.18.0")),
        .remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .upToNextMajor(from: "2.11.0")),
        .remote(url: "https://github.com/google/GoogleSignIn-iOS.git", requirement: .upToNextMajor(from: "7.0.0")),
        .remote(url: "https://github.com/airbnb/lottie-ios.git", requirement: .upToNextMajor(from: "4.4.0")),
        .remote(url: "https://github.com/Alamofire/Alamofire.git", requirement: .upToNextMajor(from: "5.6.0")),
        .remote(url: "https://github.com/realm/realm-swift.git", requirement: .exact("10.45.0"))
    ]
                                                         
//                                                         ,baseSettings: makeFrameworkSettings(),
//                                                         targetSettings: makeTargetSettings()
                                                        ),
    platforms: [.iOS]
    
)

func makeFrameworkSettings() -> Settings {
    .settings(
        base: makeFrameworkBaseSettings(),
        configurations: [
            .debug(name: .debug),
            .release(name: .release)
        ]
    )
}

public func makeTargetSettings() -> [String: SettingsDictionary] {
    var settings: [String: SettingsDictionary] = [:]
    let allYourDependencyNames  = ["FirebaseStorage"]
    
    allYourDependencyNames.forEach { dependency in
        settings[dependency] = makeBaseSettings()
    }
    
    settings["FirebaseStorage"] = [
        "OTHER_LDFLAGS" : "-ObjC",
        "HEADER_SEARCH_PATHS": "$(inherited) $(PROJECT_DIR)/../gtm-session-fetcher/Sources/Core/Public"
    ]

    return settings
}

func makeBaseSettings() -> SettingsDictionary {
    SettingsDictionary()
        .swiftOptimizeObjectLifetimes(false)
        .bitcodeEnabled(true)
        .merging([
            "OTHER_LDFLAGS": "-ObjC",
            "ALWAYS_SEARCH_USER_PATHS": "NO",
        ])
}


//
// this is a workaround for named configuration that are different to "Debug" and "Release".
func makeFrameworkBaseSettings() -> SettingsDictionary {
    [
        "FRAMEWORK_SEARCH_PATHS": "$(inherited)"
    ]
}
