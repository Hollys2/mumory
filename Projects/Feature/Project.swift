import ProjectDescription
import ProjectDescriptionHelpers

let expendedInfo: [String : InfoPlist.Value] = [
    
    "LSApplicationQueriesSchemes" : ["kakaokompassauth"],
    "CFBundleURLTypes" : [
        [
            "CFBundleTypeRole" : "Editor",
            "CFBundleURLName" : "kakao1",
            "CFBundleURLSchemes" : ["kakaoac7735b6f63e81d971e4a58a05994260"]
        ],
        [
            "CFBundleTypeRole" : "Editor",
            "CFBundleURLName" : "kakao2",
            "CFBundleURLSchemes" : ["kakaoac7735b6f63e81d971e4a58a05994260:ouath"]
        ],
        [
            "CFBundleTypeRole" : "Editor",
            "CFBundleURLName" : "fireBase-google",
            "CFBundleURLSchemes" : ["com.googleusercontent.apps.1070391821667-amji34rll9iodc75j6adq918p50nkf6u"]
        ]
    ]
]

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
                                       ])
                      ])



