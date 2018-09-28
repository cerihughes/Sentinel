import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        let floorSize: Float = 10.0
        let levelConfiguration = MainLevelConfiguration(level: 40)
        let nodePositioning = NodePositioning(gridWidth: levelConfiguration.gridWidth,
                                              gridDepth: levelConfiguration.gridDepth,
                                              floorSize: 10.0)
        let nodeFactory = NodeFactory(nodePositioning: nodePositioning,
                                      detectionRadius: levelConfiguration.opponentDetectionRadius * floorSize)

        let world = SpaceWorld(nodeFactory: nodeFactory)
        let viewModel = GameViewModel(levelConfiguration: levelConfiguration, nodeFactory: nodeFactory, world: world)
        let viewController = GameContainerViewController(viewModel: viewModel)

//        let lobbyViewModel = LobbyViewModel()
//        let viewController = LobbyViewController(lobbyViewModel: lobbyViewModel)

//        let viewModel = LevelSummaryViewModel(levelConfiguration: levelConfiguration, nodeFactory: nodeFactory, world: world)
//        let viewController = LevelSummaryViewController(viewModel: viewModel)

        window!.rootViewController = viewController
        window!.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}
