import Madog

extension Context where T == Navigation {
    func show(_ token: Navigation) {
        change(to: .basic(), tokenData: .single(token))
    }
}
