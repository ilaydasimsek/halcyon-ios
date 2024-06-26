import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    lazy var dependencyContainer = {
        return DependencyContainer()
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        configureFirebase()
        configureWindow()
        return true
    }

    func configureFirebase() {
        FirebaseApp.configure()
    }

    func configureWindow() {
        window = UIWindow(frame:UIScreen.main.bounds)    
        let navigationController = NavigationController()

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        appCoordinator = AppCoordinator(navigationController: navigationController,
                                        dependencies: dependencyContainer)
        appCoordinator?.start()
    }
}


