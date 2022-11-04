import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .init(
    name: Layer.presentation.layerName,
    organizationName: Layer.presentation.layerName,
    settings: makeConfiguration(),
    targets: makePetpionFrameworkTargets(name: Layer.presentation.layerName, platform: .iOS, dependencies: [
        .target(name: Layer.domain.layerName)
    ]),
    schemes: [.makeScheme(target: .debug, name: Layer.presentation.layerName)]
)
