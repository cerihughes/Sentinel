import Madog

extension Context {
    func show(_ token: Navigation) {
        change(to: .basic, tokenData: .single(token))
    }
}
