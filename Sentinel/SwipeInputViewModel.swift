import SceneKit
import UIKit

enum SwipeDirection: CaseIterable {
    case up, down, left, right

    var buildableType: BuildableType? {
        switch self {
        case .left:
            return .tree
        case .up:
            return .rock
        case .right:
            return .synthoid
        default:
            return nil
        }
    }
}

enum BuildableType {
    case tree, rock, synthoid
}

enum SwipeState {
    case building(Float)
    case finished(Bool)

    init(scale: Float, finished: Bool) {
        if finished {
            self = .finished(scale == 1.0)
        } else {
            self = .building(scale)
        }
    }
}

fileprivate let threshold: CGFloat = 200.0

class SwipeInputViewModel: NSObject {
    private let playerViewModel: PlayerViewModel
    private let opponentsViewModel: OpponentsViewModel
    private let nodeManipulator: NodeManipulator
    private let gestureRecognisers: [UIGestureRecognizer]

    private var startTapPoint: CGPoint? = nil
    private var floorNode: FloorNode? = nil

    init(playerViewModel: PlayerViewModel, opponentsViewModel: OpponentsViewModel, nodeManipulator: NodeManipulator) {
        self.playerViewModel = playerViewModel
        self.opponentsViewModel = opponentsViewModel
        self.nodeManipulator = nodeManipulator

        let tapRecogniser = UITapGestureRecognizer()
        let longPressRecogniser = UILongPressGestureRecognizer()
        let panRecogniser = UIPanGestureRecognizer()

        self.gestureRecognisers = [tapRecogniser, longPressRecogniser, panRecogniser]
        super.init()

        tapRecogniser.addTarget(self, action: #selector(tapGesture(sender:)))

        longPressRecogniser.addTarget(self, action: #selector(longPressGesture(sender:)))
        longPressRecogniser.isEnabled = false

        panRecogniser.addTarget(self, action: #selector(panGesture(sender:)))
        panRecogniser.isEnabled = false
    }

    func addGestureRecognisers(to view: UIView) {
        for gestureRecogniser in gestureRecognisers {
            view.addGestureRecognizer(gestureRecogniser)
        }
    }

    func enableGestureRecognisers() {
        enableGestureRecognisers(isEnabled: true)
    }

    func disableGestureRecognisers() {
        enableGestureRecognisers(isEnabled: false)
    }

    private func enableGestureRecognisers(isEnabled: Bool) {
        for gestureRecogniser in gestureRecognisers {
            gestureRecogniser.isEnabled = isEnabled
        }
    }

    // MARK: Tap

    @objc
    func tapGesture(sender: UIGestureRecognizer) {
        guard sender.state != .cancelled else {
            return
        }

        if !playerViewModel.hasEnteredScene() {
            _ = playerViewModel.enterScene()
        }
    }

    // MARK: Long Press

    @objc
    func longPressGesture(sender: UILongPressGestureRecognizer) {
        if let sceneView = sender.view as? SCNView {
            let point = sender.location(in: sceneView)
            let state = sender.state

            if state == .began {
                let hitTestResults = sceneView.hitTest(point, options: [:])
                if let floorNode = floorNode(for: hitTestResults) {
                    self.startTapPoint = point
                    self.floorNode = floorNode
                } else {
                    self.startTapPoint = nil
                    self.floorNode = nil

                    // Toggle the state to "cancel" the gesture
                    sender.isEnabled = false
                    sender.isEnabled = true
                }
            } else if state == .changed || state == .ended {
                if let startTapPoint = startTapPoint,
                    let floorNode = floorNode {
                    let swipe = self.swipe(from: startTapPoint, to: point)
                    processSwipe(floorNode: floorNode,
                                 swipeDirection: swipe.direction,
                                 delta: swipe.delta,
                                 finished: state == .ended)
                }
            }
        }
    }

    private func swipe(from point1: CGPoint, to point2: CGPoint ) -> (direction: SwipeDirection, delta: CGFloat) {
        let deltaX = point2.x - point1.x
        let deltaY = point2.y - point1.y
        let absDeltaX = deltaX < 0 ? -deltaX : deltaX
        let absDeltaY = deltaY < 0 ? -deltaY : deltaY

        if absDeltaX > absDeltaY {
            // Horizontal change is greater
            if absDeltaX == deltaX {
                return (.right, absDeltaX)
            } else {
                return (.left, absDeltaX)
            }
        } else {
            // Vertical change is greater
            if absDeltaY == deltaY {
                return (.down, absDeltaY)
            } else {
                return (.up, absDeltaY)
            }
        }
    }

    func floorNode(for hitTestResults: [SCNHitTestResult]) -> FloorNode? {
        if let hitTestResult = hitTestResults.first {
            let node = hitTestResult.node
            if let interactiveNode = node.firstInteractiveParent() {
                if let floorNode = interactiveNode as? FloorNode {
                    return floorNode
                }
                if let placeableNode = interactiveNode as? PlaceableNode,
                    let floorNode = placeableNode.floorNode {
                    return floorNode
                }
            }
        }
        return nil
    }

    private func processSwipe(floorNode: FloorNode, swipeDirection: SwipeDirection, delta: CGFloat, finished: Bool) {
        let scale: Float
        if delta < threshold {
            scale = Float(delta / threshold)
        } else {
            scale = 1.0
        }

        let swipeState = SwipeState(scale: scale, finished: finished)

        switch swipeDirection {
        case .down:
            if let topmostNode = floorNode.topmostNode {
                processAbsorb(placeableNode: topmostNode, swipeState: swipeState)
            }
        default:
            if let buildableType = swipeDirection.buildableType {
                if validBuildSwipeDirections(for: floorNode).contains(swipeDirection) {
                    processBuild(buildableType, floorNode: floorNode, swipeState: swipeState)
                }
            }
        }
    }

    private func validBuildSwipeDirections(for floorNode: FloorNode) -> [SwipeDirection] {
        if let topmostNode = floorNode.topmostNode {
            if topmostNode is RockNode {
                return SwipeDirection.allCases
            } else {
                return []
            }
        }

        return [.left, .up, .right]
    }

    private func buildHeight(for floorNode: FloorNode) -> Int {
        if let topmostNode = floorNode.topmostNode {
            if topmostNode is RockNode {
                return floorNode.rockNodes.count
            }
        }
        return 0
    }

    private func processAbsorb(placeableNode: SCNNode&PlaceableNode, swipeState: SwipeState) {
        switch swipeState {
        case .building(let scale):
            processInProgressAbsorb(placeableNode: placeableNode, scale: scale)
        case .finished(let removeIt):
            processCompleteAbsorb(placeableNode: placeableNode, removeIt: removeIt)
        }
    }

    private func processInProgressAbsorb(placeableNode: SCNNode&PlaceableNode, scale: Float) {
        placeableNode.scaleAllDimensions(by: 1.0 - scale)
    }

    private func processCompleteAbsorb(placeableNode: SCNNode&PlaceableNode, removeIt: Bool) {
        if let floorNode = placeableNode.floorNode {
            // There may be a temporary node lying around if we initially swiped (e.g.) up and then down before releasing the swipe.
            floorNode.temporaryNode?.removeFromParentNode()

            if removeIt,
                let point = nodeManipulator.point(for: floorNode),
                playerViewModel.absorbTopmostNode(at: point) {
                placeableNode.removeFromParentNode()
            } else {
                placeableNode.scaleAllDimensions(by: 1.0, animated: true)
            }
        }
    }

    private func processBuild(_ buildableType: BuildableType, floorNode: FloorNode, swipeState: SwipeState) {
        switch swipeState {
        case .building(let scale):
            processInProgressBuild(buildableType, floorNode: floorNode, scale: scale)
        case .finished(let buildIt):
            processCompleteBuild(buildableType, floorNode: floorNode, buildIt: buildIt)
        }
    }

    private func processInProgressBuild(_ buildableType: BuildableType, floorNode: FloorNode, scale: Float) {
        let temporaryNode: TemporaryNode
        if let node = floorNode.temporaryNode {
            temporaryNode = node
        } else {
            let height = buildHeight(for: floorNode)
            temporaryNode = nodeManipulator.nodeFactory.createTemporaryNode(height: height)
            floorNode.addChildNode(temporaryNode)
        }

        if let existingType = temporaryNode.buildableType, existingType == buildableType {
        } else {
            temporaryNode.contents = createNode(for: buildableType)
        }

        temporaryNode.scaleAllDimensions(by: scale)
    }

    private func processCompleteBuild(_ buildableType: BuildableType, floorNode: FloorNode, buildIt: Bool) {
        if let point = nodeManipulator.point(for: floorNode),
            let temporaryNode = floorNode.temporaryNode {
            temporaryNode.removeFromParentNode(animated: !buildIt)

            if buildIt {
                switch (buildableType) {
                case (.rock):
                    playerViewModel.buildRock(at: point)
                case (.tree):
                    playerViewModel.buildTree(at: point)
                case (.synthoid):
                    playerViewModel.buildSynthoid(at: point)
                }

//                opponentsViewModel.timeMachine.start()
            }
        }
    }

    private func createNode(for buildableType: BuildableType) -> (SCNNode&PlaceableNode) {
        let node: SCNNode&PlaceableNode
        switch buildableType {
        case .tree:
            node = nodeManipulator.nodeFactory.createTreeNode(height: 0)
        case .rock:
            node = nodeManipulator.nodeFactory.createRockNode(height: 0)
        case .synthoid:
            node = nodeManipulator.nodeFactory.createSynthoidNode(height: 0, viewingAngle: 0.0)
        }
        node.position = SCNVector3Make(0, 0, 0)
        return node
    }

    // MARK: Panning

    @objc
    func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        let deltaX = Float(translation.x)
        processPan(by: deltaX, finished: sender.state == .ended)
    }

    private func processPan(by x: Float, finished: Bool) {
        let angleDeltaDegrees = x / 10.0
        let angleDeltaRadians = angleDeltaDegrees * Float.pi / 180.0
        nodeManipulator.rotateCurrentSynthoid(by: angleDeltaRadians)

        if finished {
            nodeManipulator.rotateCurrentSynthoid(by: angleDeltaRadians, persist: true)
        }
    }
}

class TemporaryNode: SCNNode {
    var contents: (SCNNode&PlaceableNode)? {
        didSet {
            for childNode in childNodes {
                childNode.removeFromParentNode()
            }
            if let contents = contents {
                addChildNode(contents)
            }
        }
    }

    var buildableType: BuildableType? {
        if let contents = contents {
            if contents is TreeNode {
                return .tree
            }
            if contents is RockNode {
                return .rock
            }
            if (contents is SynthoidNode) {
                return .synthoid
            }
        }
        return nil
    }
}

extension SCNNode {
    func scaleAllDimensions(by scale: Float) {
        self.scale = SCNVector3Make(scale, scale, scale)
    }

    func scaleAllDimensions(by scale: Float, animated: Bool) {
        if !animated {
            scaleAllDimensions(by: scale)
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3

        scaleAllDimensions(by: scale)

        SCNTransaction.commit()
    }

    func removeFromParentNode(animated: Bool) {
        if animated {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.3
            SCNTransaction.completionBlock = {
                self.removeFromParentNode()
            }

            scaleAllDimensions(by: 0.0)

            SCNTransaction.commit()
        } else {
            removeFromParentNode()
        }
    }
}

fileprivate let temporaryNodeName = "temporaryNodeName"

extension NodeFactory {
    func createTemporaryNode(height: Int) -> TemporaryNode {
        let node = TemporaryNode()
        node.name = temporaryNodeName
        node.position = nodePositioning.calculateObjectPosition(height: height)
        return node
    }
}

extension FloorNode {
    var temporaryNode: TemporaryNode? {
        get {
            return get(name: temporaryNodeName) as? TemporaryNode
        }
        set {
            set(instance: newValue, name: temporaryNodeName)
        }
    }
}
