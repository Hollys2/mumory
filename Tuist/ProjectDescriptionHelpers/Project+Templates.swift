import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {
    /// Helper function to create the Project for this ExampleApp
    public static func app(name: String, platform: Platform, additionalTargets: [String]) -> Project {
        var targets = makeAppTargets(name: name,
                                     platform: platform,
                                     dependencies: additionalTargets.map { TargetDependency.target(name: $0) })
        targets += additionalTargets.flatMap({ makeFrameworkTargets(name: $0, platform: platform) })
        return Project(name: name,
                       organizationName: "tuist.io",
                       targets: targets)
    }
    
    // MARK: - Private
    
    /// Helper function to create a framework target and an associated unit test target
    private static func makeFrameworkTargets(name: String, platform: Platform) -> [Target] {
        let sources = Target(name: name,
                             platform: platform,
                             product: .framework,
                             bundleId: "io.tuist.\(name)",
                             infoPlist: .default,
                             sources: ["Targets/\(name)/Sources/**"],
                             resources: [],
                             dependencies: [])
        let tests = Target(name: "\(name)Tests",
                           platform: platform,
                           product: .unitTests,
                           bundleId: "io.tuist.\(name)Tests",
                           infoPlist: .default,
                           sources: ["Targets/\(name)/Tests/**"],
                           resources: [],
                           dependencies: [.target(name: name)])
        return [sources, tests]
    }
    
    /// Helper function to create the application target and the unit test target.
    private static func makeAppTargets(name: String, platform: Platform, dependencies: [TargetDependency]) -> [Target] {
        let platform: Platform = platform
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen"
        ]
        
        let mainTarget = Target(
            name: name,
            platform: platform,
            product: .app,
            bundleId: "io.tuist.\(name)",
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/\(name)/Sources/**"],
            resources: ["Targets/\(name)/Resources/**"],
            dependencies: dependencies
        )
        
        let testTarget = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "io.tuist.\(name)Tests",
            infoPlist: .default,
            sources: ["Targets/\(name)/Tests/**"],
            dependencies: [
                .target(name: "\(name)")
            ])
        return [mainTarget, testTarget]
    }
}

extension Project {
    public static let bundleId: String = "com.hollys.mumory"
    public static let appStoreVersion: String = "1.0"
    public static let bundleVersion: String = "1.0.0"
    public static let iOSTargetVersion: String = "16.0"
    
    
    public static func makeConfiguration() -> [Configuration] {
        let debug: Configuration = Configuration.debug(name: "Debug", xcconfig: "Configs/Debug.xcconfig")
        let release: Configuration = Configuration.release(name: "Release", xcconfig: "Configs/Release.xcconfig")
        
        return [debug, release]
    }
    
    public static func makeInfoPlist(merging other: [String: InfoPlist.Value] = [:]) -> InfoPlist {
        var extendedPlist: [String: InfoPlist.Value] = [
            //        "UIApplicationSceneManifest": ["UIApplicationSupportMultipleScenes": true],
            "UILaunchScreen": [],
            "UISupportedInterfaceOrientations":
                [
                    "UIInterfaceOrientationPortrait", // 인터페이스 방향을 세로만 지원.
                ],
            "CFBundleVersion": "\(bundleVersion)",
            "CFBundleShortVersionString": "\(appStoreVersion)",
            "CFBundleDisplayName": "$(APP_DISPLAY_NAME)", // 앱 이름
        ]
        
        other.forEach { (key: String, value: InfoPlist.Value) in
            extendedPlist[key] = value
        }
        
        return InfoPlist.extendingDefault(with: extendedPlist)
    }
    
    public static func makeSettings() -> Settings {
        let settings = SettingsDictionary()
        
        return Settings.settings(base: settings,
                                 configurations: [],
                                 defaultSettings: .recommended)
        
    }
}
