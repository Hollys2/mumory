import ProjectDescription
import ProjectDescriptionHelpers


let project = Project(name: "Shared",
                      organizationName: "hollys",
                      packages: [],
                      targets: [Target(name: "Shared",
                                       platform: .iOS,
                                       product: .framework,
                                       bundleId: Project.bundleId + ".shared",
                                       deploymentTarget: .iOS(targetVersion: Project.iOSTargetVersion, devices: .iphone),
                                       infoPlist: .default,
                                       sources: ["Sources/**"],
                                       resources: ["Resources/**"],

                                       dependencies: [
                                        .external(name: "FirebaseAuth"),
                                        .external(name: "FirebaseFirestore"),
                                        .external(name: "FirebaseStorage"),
                                        .external(name: "FirebaseMessaging"),
                                        .external(name: "FirebaseDatabase"),
                                        .external(name: "FirebaseFunctions"),
                                        .external(name: "FirebaseAnalytics"),
                                        .external(name: "GoogleSignIn"),
                                        .external(name: "KakaoSDKUser"),
                                        .external(name: "KakaoSDKAuth"),
                                        .external(name: "Alamofire"),
                                        .external(name: "RealmSwift"),
                                        .external(name: "Lottie")
                                       ],
                                       settings: Settings.settings(base: [
                                        "HEADER_SEARCH_PATHS": "$(inherited) $(SRCROOT)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/gtm-session-fetcher/Sources/Core/Public $(SRCROOT)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/realm-swift",
                                        "OTHER_LDFLAGS" : "-ObjC"

                                       ])
                                      )
                      ])





//public static func makeInfoPlist(merging other: [String: InfoPlist.Value] = [:]) -> InfoPlist {
//    var extendedPlist: [String: InfoPlist.Value] = [
//        //        "UIApplicationSceneManifest": ["UIApplicationSupportMultipleScenes": true],
//        "UILaunchScreen": [],
//        "UISupportedInterfaceOrientations":
//            [
//                "UIInterfaceOrientationPortrait", // 인터페이스 방향을 세로만 지원.
//            ],
//        "CFBundleVersion": "\(bundleVersion)",
//        "CFBundleShortVersionString": "\(appStoreVersion)",
//        "CFBundleDisplayName": "$(APP_DISPLAY_NAME)", // 앱 이름
//    ]
//    
//    other.forEach { (key: String, value: InfoPlist.Value) in
//        extendedPlist[key] = value
//    }
//    
//    return InfoPlist.extendingDefault(with: extendedPlist)
//}


