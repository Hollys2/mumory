import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(name: "Feature",
                      organizationName: "hollys",
                      packages: [],
//                      settings: Settings.settings(configurations: Project.makeConfiguration() ),
                      targets: [Target(name: "Feature",
                                       platform: .iOS,
                                       product: .framework,
                                       bundleId: Project.bundleId + ".feature",
                                       deploymentTarget: .iOS(targetVersion: Project.iOSTargetVersion, devices: .iphone),
                                       infoPlist: .default,
                                       sources: ["**/Sources/**"],
//                                       resources: ["Resources/**"],
                                       dependencies: [
                                        .project(target: "Core", path: "../Core"),
                                        .external(name: "FirebaseFirestore")
                                       ])
                      ])
