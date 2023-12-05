import ProjectDescription

let workspace = Workspace(
  name: "MUMORY",
  projects: [
    "Projects/**"
  ]
)



//import ProjectDescription
//import ProjectDescriptionHelpers
//import MyPlugin
//
//private let bundleId: String = "com.hollys.mumory"
//private let version: String = "0.0.1"
//private let bundleVersion: String = "1"
//private let iOSTargetVersion: String = "15.0"
//private let basePath: String = "Targets/Mumory"
//
//let project = Project(name: "Mumory", // 프로젝트 이름
//                      packages: [],
//                      settings: Settings.settings(configurations: makeConfiguration() ),
//                      targets: [Target(name: "App", // 타겟 이름
//                                       platform: .iOS,
//                                       product: .app,
//                                       bundleId: bundleId,
//                                       deploymentTarget: .iOS(targetVersion: iOSTargetVersion, devices: .iphone),
//                                       //                                       infoPlist: makeInfoPlist(),
////                                       infoPlist: .default,
//                                       infoPlist: makeInfoPlist(),
//                                       sources: ["\(basePath)/Sources/**"],
//                                       resources: ["\(basePath)/Resources/**"],
//                                       settings: makeSettings()
//                                      )
//                      ],
//                      additionalFiles: [
//                        "README.md"
//                      ])
//
//
//private func makeConfiguration() -> [Configuration] {
//    let debug: Configuration = Configuration.debug(name: "Debug", xcconfig: "Configs/Debug.xcconfig")
//    let release: Configuration = Configuration.release(name: "Release", xcconfig: "Configs/Release.xcconfig")
//
//    return [debug, release]
//}
//
//private func makeInfoPlist(merging other: [String: InfoPlist.Value] = [:]) -> InfoPlist {
//    var extendedPlist: [String: InfoPlist.Value] = [
//        "UIApplicationSceneManifest": ["UIApplicationSupportMultipleScenes": true],
//        "UILaunchScreen": [],
//        "UISupportedInterfaceOrientations":
//            [
//                "UIInterfaceOrientationPortrait",
//            ],
//        "CFBundleShortVersionString": "\(version)",
//        "CFBundleVersion": "\(bundleVersion)",
//        "CFBundleDisplayName": "$(APP_DISPLAY_NAME)", // 앱 이름
//    ]
//
//    other.forEach { (key: String, value: InfoPlist.Value) in
//        extendedPlist[key] = value
//    }
//
//    return InfoPlist.extendingDefault(with: extendedPlist)
//}
//
//private func makeSettings() -> Settings {
//    var settings = SettingsDictionary()
//
//    return Settings.settings(base: settings,
//                             configurations: [],
//                             defaultSettings: .recommended)
//
//}



// MARK: - Project

/*
 // Local plugin loaded
 let localHelper = LocalHelper(name: "MyPlugin")

 // Creates our project using a helper function defined in ProjectDescriptionHelpers
 let project = Project.app(name: "Mumory",
 platform: .iOS,
 additionalTargets: ["MumoryKit", "MumoryUI"])
 */
