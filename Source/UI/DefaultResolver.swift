import Madog

class DefaultResolver: Resolver<Navigation> {
    override func serviceProviderFunctions() -> [(ServiceProviderCreationContext) -> ServiceProvider] {
        return [
            DefaultServices.init(context:)
        ]
    }
    override func viewControllerProviderFunctions() -> [() -> ViewControllerProvider<Navigation>] {
        return [
            IntroViewControllerProvider.init,
            LobbyViewControllerProvider.init,
            LevelSummaryViewControllerProvider.init,
            GameViewControllerProvider.init,
            StagingAreaViewControllerProvider.init
        ]
    }
}
