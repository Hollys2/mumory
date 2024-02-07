import ProjectDescription
import ProjectDescriptionHelpers



let extendedInfo: [String: InfoPlist.Value] = [
    "NSAppleMusicUsageDescription" : "음악 추천 시스템 및 재생에 필요합니다."
]
let project = Project(name: "Core",
                      organizationName: "hollys",
                      packages: [],
                      targets: [Target(name: "Core",
                                       platform: .iOS,
                                       product: .framework,
                                       bundleId: Project.bundleId + ".core",
                                       deploymentTarget: .iOS(targetVersion: Project.iOSTargetVersion, devices: .iphone),
                                       infoPlist: .extendingDefault(with: extendedInfo),
                                       sources: ["Sources/**"],
                                       dependencies: [
                                        .external(name: "Moya"),
                                        .external(name: "FirebaseAuth"),
                                        .external(name: "FirebaseFirestore"),
                                        .external(name: "FirebaseStorage"),
                                        .external(name: "GoogleSignIn"),
                                        .external(name: "GoogleSignInSwift"),
                                        .external(name: "Lottie"),
                                        .external(name: "KakaoSDKUser"),
                                        .external(name: "KakaoSDKAuth"),
                                        .external(name: "FirebaseMessaging")
                                       ],
                                       settings: Settings.settings(base: [
                                        "HEADER_SEARCH_PATHS": "$(inherited) $(PROJECT_DIR)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/gtm-session-fetcher/Sources/Core/Public",
                                        "OTHER_LDFLAGS" : "-ObjC"

                                       ])
                                      )
                      ])

