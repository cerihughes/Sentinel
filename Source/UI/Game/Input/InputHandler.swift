import SceneKit

/**
 The game input handler allows experimentation with different input mechanisms. The implementation will be made up of
 a number of UIGestureRecognisers, and its job is to translate gestures into invocations on PlayerOperations.

 The "owning" view will be passed into the addGestureReconisers(view:) call, and these should be enabled / disabled on
 calls to setGestureRecognisersEnabled(_:)
 */

struct Pan {
    let deltaX: Float
    let deltaY: Float
    let finished: Bool
}

protocol InputHandlerDelegate: AnyObject {
    func inputHandlerDidEnterScene(_ inputHandler: InputHandler)
    func inputHandler(_ inputHandler: InputHandler, didPan pan: Pan)
    func inputHandler(_ inputHandler: InputHandler, didMoveToPoint point: GridPoint)
    func inputHandler(_ inputHandler: InputHandler, didSelectFloorNode floorNode: FloorNode)
    func inputHandler(_ inputHandler: InputHandler, didCancelFloorNode floorNode: FloorNode)
    func inputHandler(
        _ inputHandler: InputHandler,
        didBuild item: BuildableItem,
        atPoint point: GridPoint,
        rotation: Float?,
        onFloorNode floorNode: FloorNode
    )
    func inputHandler(_ inputHandler: InputHandler, didAbsorbAtPoint point: GridPoint, onFloorNode floorNode: FloorNode)
}

protocol InputHandler {
    var delegate: InputHandlerDelegate? { get set }
    func addGestureRecognisers(to view: UIView)
    func setGestureRecognisersEnabled(_ isEnabled: Bool)
}
