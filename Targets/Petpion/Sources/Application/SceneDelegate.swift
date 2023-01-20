import UIKit

import PetpionCore
import PetpionDomain
import PetpionPresentation
import PetpionData


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var coordinator: Coordinator?
    var navigationController: UINavigationController?
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.navigationController = UINavigationController()
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        register()
        
        guard let mainCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "MainCoordinator") else { return }
        coordinator = mainCoordinator
        coordinator?.start()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

private extension SceneDelegate {
    func register() {
        guard let navigationController = navigationController else { return }
        
        DataDIContainer().register()
        DomainDIContainer().register()
        PresentationDIContainer(navigationController: navigationController).register()
        
        
    }
}
