import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(name: "Shared",
                      organizationName: "hollys",
                      packages: [],
//                      settings: Settings.settings(configurations: Project.makeConfiguration() ),
                      targets: [Target(name: "Shared",
                                       platform: .iOS,
                                       product: .framework,
                                       bundleId: Project.bundleId + ".shared",
                                       deploymentTarget: .iOS(targetVersion: Project.iOSTargetVersion, devices: .iphone),
                                       infoPlist: .default,
                                       sources: ["Sources/**"],
//                                       resources: ["Resources/**"],
                                       dependencies: [
                                        
                                       ])
                      ])
