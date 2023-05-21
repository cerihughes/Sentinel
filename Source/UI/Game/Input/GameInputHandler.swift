import SceneKit

/**
 The game input handler allows experimentation with different input mechanisms. The implementation will be made up of
 a number of UIGestureRecognisers, and its job is to translate gestures into invocations on PlayerOperations.

 The "owning" view will be passed into the addGestureReconisers(view:) call, and these should be enabled / disabled on
 calls to setGestureRecognisersEnabled(_:)
 */
protocol GameInputHandler {
    func addGestureRecognisers(to view: UIView)
    func setGestureRecognisersEnabled(_ isEnabled: Bool)
}
