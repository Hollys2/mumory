import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(name: "Core",
                      organizationName: "hollys",
                      packages: [
                       
                      ],
                      targets: [Target(name: "Core",
                                       platform: .iOS,
                                       product: .framework,
                                       bundleId: Project.bundleId + ".core",
                                       deploymentTarget: .iOS(targetVersion: Project.iOSTargetVersion, devices: .iphone),
                                       infoPlist: .default,
                                       sources: ["Sources/**"]
                                      )
                      ])

