import Madog

class DefaultResolver: Resolver {
    func serviceProviderFunctions() -> [(ServiceProviderCreationContext) -> ServiceProvider] {
        [DefaultServices.init(context:)]
    }

    func viewControllerProviderFunctions() -> [() -> AnyViewControllerProvider<Navigation>] {
        [
            IntroViewControllerProvider.init,
            LobbyViewControllerProvider.init,
            GamePreviewViewControllerProvider.init,
            GameViewControllerProvider.init,
            GameSummaryViewControllerProvider.init
        ] + debugViewControllerProviderFunctions()
    }

    private func debugViewControllerProviderFunctions() -> [() -> AnyViewControllerProvider<Navigation>] {
#if DEBUG
        [StagingAreaViewControllerProvider.init, MultipleOpponentAbsorbViewControllerProvider.init]
#else
        []
#endif
    }
}
