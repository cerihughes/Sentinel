//
//  SentinelResolver.swift
//  Sentinel
//
//  Created by Ceri Hughes on 30/09/2020.
//

import Madog

class SentinelResolver: Resolver<Navigation> {
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
