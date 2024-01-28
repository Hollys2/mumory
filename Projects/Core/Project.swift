import ProjectDescription
import ProjectDescriptionHelpers



let extendedInfo: [String: InfoPlist.Value] = [
    "NSAppleMusicUsageDescription" : "음악 추천 시스템 및 재생에 필요합니다."
]
let project = Project(name: "Core",
                      organizationName: "hollys",
                      packages: [],
                      settings: Settings.settings(configurations: Project.makeConfiguration()),
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
                                        .external(name: "KakaoSDKCommon"),
                                        .external(name: "KakaoSDKAuth"),
                                        .external(name: "KakaoSDKUser")
                                       ]
                                       ,
                                       settings: .settings(configurations: Project.makeConfiguration())
                                      )
                      ])


func makeFrameworkSettings() -> Settings {
    .settings(
        base: makeFrameworkBaseSettings(),
        configurations: [
            // just an example
            .debug(name: "Debug"),
            .release(name: "AdHoc"),
            .release(name: "Release")
        ]
    )
}

// this is a workaround for named configuration that are different to "Debug" and "Release".
func makeFrameworkBaseSettings() -> SettingsDictionary {
    [
        "FRAMEWORK_SEARCH_PATHS": "$(inherited) $(SYMROOT)/Release$(EFFECTIVE_PLATFORM_NAME)"
    ]
}
//Project.makeConfiguration()

func makeBaseSettings() -> SettingsDictionary {
        SettingsDictionary()
            .swiftOptimizeObjectLifetimes(false)
            .bitcodeEnabled(true)
            .merging([
                "OTHER_LDFLAGS": "-ObjC",
                "PUSH_URL_SCHEME": "fressnapfapp",
                "ALWAYS_SEARCH_USER_PATHS": "NO",
            ])
}

public func makeTargetSettings() -> [String: SettingsDictionary] {
    var settings: [String: SettingsDictionary] = [:]
    let allYourDependencyNames  = ["Core", "Feature"]
    // add all other dependency names here, this is at least what I am doing
    allYourDependencyNames.forEach { dependency in
        settings[dependency] = makeBaseSettings()
        settings[dependency] = [
            "HEADER_SEARCH_PATHS": "Tuist/Dependencies/SwiftPackageManager/.build/checkouts/gtm-session-fetcher/Sources/Core/Public/GTMSessionFetcher"
        ]
    }

    return settings
}
