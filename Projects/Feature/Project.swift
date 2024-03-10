import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(name: "Feature",
                      organizationName: "hollys",
                      packages: [],
                      targets: [Target(name: "Feature",
                                       platform: .iOS,
                                       product: .framework,
                                       bundleId: Project.bundleId + ".feature",
                                       deploymentTarget: .iOS(targetVersion: Project.iOSTargetVersion, devices: .iphone),
                                       infoPlist: .default,
                                       sources: ["**/Sources/**"],
                                       resources: ["Resources/**"],
                                       dependencies: [
                                        .project(target: "Core", path: "../Core"),
                                        .project(target: "Shared", path: "../Shared"),
                                       ],
                                       settings: Settings.settings(base: [
                                        "HEADER_SEARCH_PATHS": "$(inherited) $(SRCROOT)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/gtm-session-fetcher/Sources/Core/Public $(SRCROOT)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/realm-swift",
                                        "OTHER_LDFLAGS" : "-ObjC"

                                       ]))
                      ])



