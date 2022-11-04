import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .init(
    name: Layer.app.layerName,
    organizationName: Layer.app.layerName,
    settings: makeConfiguration(),
    targets: makePetpionAppTarget(name: Layer.app.layerName, platform: .iOS, dependencies: [
        .target(name: Layer.presentation.layerName)
    ]),
    schemes: [.makeScheme(target: .debug, name: Layer.app.layerName)]
)
