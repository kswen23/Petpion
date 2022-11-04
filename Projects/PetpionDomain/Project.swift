import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .init(
    name: Layer.domain.layerName,
    organizationName: Layer.domain.layerName,
    settings: makeConfiguration(),
    targets: makePetpionFrameworkTargets(name: Layer.domain.layerName, platform: .iOS, dependencies: [
    ]),
    schemes: [.makeScheme(target: .debug, name: Layer.domain.layerName)]
)
