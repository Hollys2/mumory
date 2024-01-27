import ProjectDescription
import ProjectDescriptionHelpers



let extendedInfo: [String: InfoPlist.Value] = [
    "NSAppleMusicUsageDescription" : "음악 추천 시스템 및 재생에 필요합니다."
]
let project = Project(name: "Core",
                      organizationName: "hollys",
                      packages: [],
//                      settings: Settings.settings(configurations: Project.makeConfiguration() ),
                      targets: [Target(name: "Core",
                                       platform: .iOS,
                                       product: .framework,
                                       bundleId: Project.bundleId + ".core",
                                       deploymentTarget: .iOS(targetVersion: Project.iOSTargetVersion, devices: .iphone),
                                       infoPlist: .extendingDefault(with: extendedInfo),
                                       sources: ["Sources/**"],

//                                       resources: ["Resources/**"],
                                       dependencies: [
                                        .external(name: "Moya"),
                                        .external(name: "FirebaseAuth"),
                                        .external(name: "FirebaseFirestore"),
                                        .external(name: "FirebaseStorage"),
                                        .external(name: "KakaoSDKCommon"),
                                        .external(name: "KakaoSDKAuth"),
                                        .external(name: "KakaoSDKUser"),
                                        .external(name: "GTMSessionFetcher")
//                                        .external(name: "GoogleSignIn"),
//                                        .external(name: "GoogleSignInSwift")
                                       ])
                      ])
