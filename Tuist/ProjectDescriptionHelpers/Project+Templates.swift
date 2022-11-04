import ProjectDescription

public enum Layer: CaseIterable {
    case app
    case domain
    case data
    case presentation
    
    public var layerName: String {
        switch self {
        case .app: return "Petpion"
        case .domain: return "PetpionDomain"
        case .data: return "PetpionData"
        case .presentation: return "PetpionPresentation"
        }
    }
}

private let deploymentTarget: DeploymentTarget = .iOS(targetVersion: "14.0", devices: [.iphone])

// MARK: - Project

public func makePetpionFrameworkTargets(
    name: String,
    platform: Platform,
    dependencies: [TargetDependency]) -> [Target] {
        
        let frameworkTarget = Target(
            name: name,
            platform: platform,
            product: .staticFramework,
            bundleId: "com.\(name)",
            deploymentTarget: deploymentTarget,
            infoPlist: .default,
            sources: ["Targets/\(name)/Sources/**"],
            resources: [],
            entitlements: "./Petpion.entitlements",
            dependencies: dependencies
        )
        
        let testTarget = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "com.\(name)Tests",
            deploymentTarget: deploymentTarget,
            infoPlist: .default,
            sources: ["Targets/\(name)/Tests/**"],
            resources: [],
            dependencies: [
                .target(name: name)
            ]
        )
        
        return [frameworkTarget, testTarget]
    }

public func makePetpionAppTarget(
    name: String,
    platform: Platform,
    dependencies: [TargetDependency]) -> [Target] {
        
        let appTarget =  Target(
            name: "\(name)",
            platform: platform,
            product: .app,
            bundleId: "com.\(name)",
            deploymentTarget: deploymentTarget,
            infoPlist: .file(path: "Support/Info.plist"),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: "./Petpion.entitlements",
            dependencies: dependencies
        )
        
        let testTarget = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "com.\(name)Tests",
            deploymentTarget: deploymentTarget,
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [
                .target(name: name)
            ]
        )
        
        return [appTarget, testTarget]
    }

public func makeConfiguration() -> Settings {
    
    return Settings.settings(
        base: [:],
        configurations: [
            .debug(name: .debug),
            .release(name: .release)
        ], defaultSettings: .recommended
    )
}

extension Scheme {
    static func makeScheme(target: ConfigurationName, name: String) -> Scheme {
        return Scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: .targets(
                ["\(name)Tests"],
                configuration: target,
                options: .options(coverage: true, codeCoverageTargets: ["\(name)"])
            ),
            runAction: .runAction(configuration: target),
            archiveAction: .archiveAction(configuration: target),
            profileAction: .profileAction(configuration: target),
            analyzeAction: .analyzeAction(configuration: target)
        )
    }
}
