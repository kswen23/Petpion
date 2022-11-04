import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .init(
    name: Layer.data.layerName,
    organizationName: Layer.data.layerName,
    settings: makeConfiguration(),
    targets: makePetpionFrameworkTargets(name: Layer.data.layerName, platform: .iOS, dependencies: [
        .target(name: Layer.domain.layerName)
    ]),
    schemes: [.makeScheme(target: .debug, name: Layer.data.layerName)]
)
