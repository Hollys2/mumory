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
                                        
                                       ])
                      ])
