import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

private enum Layer: CaseIterable {
  case domain
  case data
  case presentation

  var layerName: String {
    switch self {
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
    
    return .init(
      name: "Petpion",
      platform: platform,
      product: .app,
      bundleId: "com.Petpion",
      deploymentTarget: deploymentTarget,
      infoPlist: .file(path: "Targets/Petpion/Support/Info.plist"),
      sources: ["Targets/Petpion/Sources/**"],
      resources: ["Targets/Petpion/Resources/**"],
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
  settings: makeConfiguration(),
  targets: [
    [makePetpionAppTarget(
      platform: .iOS,
      dependencies: [
        .target(name: Layer.presentation.layerName),
      ])],

    makePetpionFrameworkTargets(
      name: Layer.presentation.layerName,
      platform: .iOS,
      dependencies: [
        .target(name: Layer.domain.layerName),
      ]),
    makePetpionFrameworkTargets(
      name: Layer.data.layerName,
      platform: .iOS,
      dependencies: [
        .target(name: Layer.domain.layerName),
      ]),
    makePetpionFrameworkTargets(
      name: Layer.domain.layerName,
      platform: .iOS,
      dependencies: [
    
      ])
  ].flatMap { $0 }
)
