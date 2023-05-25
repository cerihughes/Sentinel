import Madog

class DefaultResolver: Resolver<Navigation> {
    override func serviceProviderFunctions() -> [(ServiceProviderCreationContext) -> ServiceProvider] {
        [DefaultServices.init(context:)]
    }
    override func viewControllerProviderFunctions() -> [() -> ViewControllerProvider<Navigation>] {
        [
            IntroViewControllerProvider.init,
            LobbyViewControllerProvider.init,
            GamePreviewViewControllerProvider.init,
            GameViewControllerProvider.init,
            GameSummaryViewControllerProvider.init
        ] + debugViewControllerProviderFunctions()
    }

    private func debugViewControllerProviderFunctions() -> [() -> ViewControllerProvider<Navigation>] {
#if DEBUG
        [StagingAreaViewControllerProvider.init, MultipleOpponentAbsorbViewControllerProvider.init]
#else
        []
#endif
    }
}
