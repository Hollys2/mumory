import ProjectDescription
import ProjectDescriptionHelpers



let project = Project(name: "Core",
                      organizationName: "hollys",
                      packages: [],
//                      settings: Settings.settings(configurations: Project.makeConfiguration() ),
                      targets: [Target(name: "Core",
                                       platform: .iOS,
                                       product: .framework,
                                       bundleId: Project.bundleId + ".core",
                                       deploymentTarget: .iOS(targetVersion: Project.iOSTargetVersion, devices: .iphone),
                                       infoPlist: .default,
                                       sources: ["Sources/**"],
//                                       resources: ["Resources/**"],
                                       dependencies: [
//                                        .external(name: "Moya"),
//                                        .external(name: "FirebaseAuth"),
//                                        .external(name: "FirebaseFirestore"),
                                       ]
                                      )
                                
                      ])
