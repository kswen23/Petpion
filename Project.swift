import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

private enum Layer: CaseIterable {
    case core
    case domain
    case data
    case presentation
    
    var layerName: String {
        switch self {
        case .core: return "PetpionCore"
        case .domain: return "PetpionDomain"
        case .data: return "PetpionData"
        case .presentation: return "PetpionPresentation"
        }
    }
}

private let deploymentTarget: DeploymentTarget = .iOS(targetVersion: "14.0", devices: [.iphone])

// MARK: - Project

func makePetpionFrameworkTargets(
    name: String,
    platform: Platform,
    dependencies: [TargetDependency]) -> [Target] {
        
        let sources = Target(
            name: name,
            platform: platform,
            product: .framework,
            bundleId: "com.\(name)",
            deploymentTarget: deploymentTarget,
            infoPlist: .default,
            sources: ["Targets/\(name)/Sources/**"],
            resources: [],
            dependencies: dependencies,
            settings: .settings(base: .init()
                .swiftCompilationMode(.wholemodule))
        )
        
        let tests = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "com.\(name)Tests",
            deploymentTarget: deploymentTarget,
            infoPlist: .default,
            sources: ["Targets/\(name)/Tests/**"],
            resources: [],
            dependencies: [
                .target(name: name),
            ]
        )
        
        return [sources, tests]
    }

func makePetpionAppTarget(
    platform: Platform,
    dependencies: [TargetDependency]) -> Target {
        
        let platform = platform
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleVersion": "1",
            "UIUserInterfaceStyle": "Light",
            "UILaunchStoryboardName": "LaunchScreen",
            "UIApplicationSceneManifest": [
                "UIApplicationSupportsMultipleScenes": false,
                "UISceneConfigurations": [
                    "UIWindowSceneSessionRoleApplication": [
                        [
                            "UISceneConfigurationName": "Default Configuration",
                            "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                        ],
                    ]
                ]
            ],
//            "CFBundleURLTypes": ["CFBundleTypeRole": "Editor", "CFBundleURLSchemes": ["kakao1dbd3642db36275e36ccaf9b6556752d"]],
            "KAKAO_API_KEY": "1dbd3642db36275e36ccaf9b6556752d",
            "LSApplicationQueriesSchemes": ["kakaokompassauth", "kakaolink"],
            "NSPhotoLibraryUsageDescription": "사진첩 접근 권한 요청"
        ]
        
        return .init(
            name: "Petpion",
            platform: platform,
            product: .app,
            bundleId: "com.Petpion",
            deploymentTarget: deploymentTarget,
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/Petpion/Sources/**"],
            resources: ["Targets/Petpion/Resources/**"],
            entitlements: "./Petpion.entitlements",
            dependencies: dependencies,
            settings: makeConfiguration()
        )
    }

func makeConfiguration() -> Settings {
    Settings.settings(
        base: [:],
        configurations: [
            .debug(name: .debug),
            .release(name: .release)
        ], defaultSettings: .recommended)
}

let project: Project = .init(
    name: "Petpion",
    organizationName: "Petpion",
    packages: [
        .remote(url: "https://github.com/Swinject/Swinject.git", requirement: .upToNextMajor(from: "2.8.0")),
        .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMajor(from: "10.1.0")),
        .remote(url: "https://github.com/google/gtm-session-fetcher.git", requirement: .upToNextMajor(from: "3.0.0")),
        .remote(url: "https://github.com/Yummypets/YPImagePicker.git", requirement: .upToNextMajor(from: "5.2.0")),
        .remote(url: "https://github.com/guoyingtao/Mantis.git", requirement: .exact("2.3.0")),
        .remote(url: "https://github.com/airbnb/lottie-ios.git"
                ,requirement: .upToNextMajor(from: "4.0.0")),
        .remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .upToNextMajor(from: "2.11.0"))
    ],
    settings: makeConfiguration(),
    targets: [
        [makePetpionAppTarget(
            platform: .iOS,
            dependencies: [
                .target(name: Layer.core.layerName),
                .target(name: Layer.presentation.layerName),
                .target(name: Layer.domain.layerName),
                .target(name: Layer.data.layerName)
            ])],
        
        makePetpionFrameworkTargets(
            name: Layer.core.layerName,
            platform: .iOS,
            dependencies: [
                .package(product: "Swinject")
            ]),
        
        makePetpionFrameworkTargets(
            name: Layer.presentation.layerName,
            platform: .iOS,
            dependencies: [
                .target(name: Layer.core.layerName),
                .target(name: Layer.domain.layerName),
                .package(product: "YPImagePicker"),
                .package(product: "Mantis"),
                .package(product: "Lottie")
            ]),
        makePetpionFrameworkTargets(
            name: Layer.data.layerName,
            platform: .iOS,
            dependencies: [
                .target(name: Layer.core.layerName),
                .target(name: Layer.domain.layerName),
                .package(product: "FirebaseAuth"),
                .package(product: "FirebaseAnalytics"),
                .package(product: "FirebaseFirestore"),
                .package(product: "FirebaseStorage"),
                .package(product: "GTMSessionFetcherFull"),
                .package(product: "KakaoSDKCommon"),
                .package(product: "KakaoSDKAuth"),
                .package(product: "KakaoSDKUser")
            ]),
        makePetpionFrameworkTargets(
            name: Layer.domain.layerName,
            platform: .iOS,
            dependencies: [
                .target(name: Layer.core.layerName)
            ])
    ].flatMap { $0 }
)
