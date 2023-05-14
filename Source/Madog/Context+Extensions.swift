import Madog

extension Context {
    func showIntro() {
        change(to: .navigation, tokenData: .single(Navigation.intro)) {
            $0.isNavigationBarHidden = true
        }
    }

    func showLevelSummary(token: Navigation) {
        change(to: .basic, tokenData: .single(token))
    }

    func showGame(level: Int) {
        let token = Navigation.game(level: level)
        change(to: .basic, tokenData: .single(token))
    }
}

extension ForwardBackNavigationContext {
    func showLobby() {
        _ = navigateForward(token: Navigation.lobby, animated: true)
    }

    func showLevelSummary(level: Int) {
        let token = Navigation.levelSummary(level: level)
        _ = navigateForward(token: token, animated: true)
    }
}
