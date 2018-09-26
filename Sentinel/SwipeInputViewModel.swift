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
fileprivate let temporaryNodeName = "temporaryNodeName"

class SwipeInputViewModel: NSObject {
    private let playerViewModel: PlayerViewModel
    private let opponentsViewModel: OpponentsViewModel
    private let nodeManipulator: NodeManipulator
    private let gestureRecognisers: [UIGestureRecognizer]

    private var startTapPoint: CGPoint? = nil
    private var floorNode: FloorNode? = nil
    private var buildHeight: Int? = nil

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
                if let buildData = processInitial(hitTestResults: hitTestResults) {
                    self.startTapPoint = point
                    self.floorNode = buildData.floorNode
                    self.buildHeight = buildData.buildHeight
                } else {
                    self.startTapPoint = nil
                    self.floorNode = nil
                    self.buildHeight = nil

                    // Toggle the state to "cancel" the gesture
                    sender.isEnabled = false
                    sender.isEnabled = true
                }
            } else if state == .changed || state == .ended {
                if let startTapPoint = startTapPoint,
                    let floorNode = floorNode,
                    let buildHeight = buildHeight {
                    let swipe = self.swipe(from: startTapPoint, to: point)
                    processSwipe(floorNode: floorNode,
                                 buildHeight: buildHeight,
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

    func processInitial(hitTestResults: [SCNHitTestResult]) -> (floorNode: FloorNode, buildHeight: Int)? {
        if !playerViewModel.hasEnteredScene() {
            _ = playerViewModel.enterScene()
            return nil
        }

        return buildableNode(for: hitTestResults)
    }

    private func buildableNode(for hitTestResults:[SCNHitTestResult]) -> (floorNode: FloorNode, buildHeight: Int)? {
        if let hitTestResult = hitTestResults.first {
            let node = hitTestResult.node
            if let interactiveNode = node.firstInteractiveParent() {
                if let floorNode = interactiveNode as? FloorNode {
                    return (floorNode, 0)
                }
                if let rockNode = interactiveNode as? RockNode,
                    let floorNode = rockNode.floorNode,
                    let index = floorNode.rockNodes.index(of: rockNode) {
                    return (floorNode, index + 1)
                }
            }
        }
        return nil
    }

    private func processSwipe(floorNode: FloorNode, buildHeight: Int, swipeDirection: SwipeDirection, delta: CGFloat, finished: Bool) {
        let scale: Float
        if delta < threshold {
            scale = Float(delta / threshold)
        } else {
            scale = 1.0
        }

        switch swipeDirection {
        case .down:
            return
        default:
            if let buildableType = swipeDirection.buildableType {
                var tweakedBuildHeight = buildHeight
                if validBuildSwipeDirections(for: floorNode, buildHeight: &tweakedBuildHeight).contains(swipeDirection) {
                    let swipeState = SwipeState(scale: scale, finished: finished)
                    processBuild(buildableType, floorNode: floorNode, buildHeight: tweakedBuildHeight, swipeState: swipeState)
                }
            }
        }
    }

    private func validBuildSwipeDirections(for floorNode: FloorNode, buildHeight: inout Int) -> [SwipeDirection] {
        if let topmostNode = floorNode.topmostNode {
            if topmostNode is RockNode {
                buildHeight = floorNode.rockNodes.count
                return SwipeDirection.allCases
            } else {
                return []
            }
        }

        buildHeight = 0
        return [.left, .up, .right]
    }

    private func validAbsorptionHeight(for floorNode: FloorNode, buildHeight: Int) -> Int? {
        return buildHeight
    }

    private func processBuild(_ buildableType: BuildableType, floorNode: FloorNode, buildHeight: Int, swipeState: SwipeState) {
        switch swipeState {
        case .building(let scale):
            processInProgressBuild(buildableType, floorNode: floorNode, buildHeight: buildHeight, scale: scale)
        case .finished(let buildIt):
            processCompleteBuild(buildableType, floorNode: floorNode, buildIt: buildIt)
        }
    }

    private func processInProgressBuild(_ buildableType: BuildableType, floorNode: FloorNode, buildHeight: Int, scale: Float) {
        _ = build(buildableType, on: floorNode, buildHeight: buildHeight, scale: scale)
    }

    private func processCompleteBuild(_ buildableType: BuildableType, floorNode: FloorNode, buildIt: Bool) {
        if let point = nodeManipulator.point(for: floorNode),
            let temporaryNode = temporaryNode(on: floorNode) {
            remove(temporaryNode: temporaryNode, from: floorNode, animated: !buildIt)

            if buildIt {
                switch (buildableType) {
                case (.rock):
                    playerViewModel.buildRock(at: point)
                case (.tree):
                    playerViewModel.buildTree(at: point)
                case (.synthoid):
                    playerViewModel.buildSynthoid(at: point)
                }

                opponentsViewModel.timeMachine.start()
            }
        }
    }

    private func build(_ buildableType: BuildableType, on floorNode: FloorNode, buildHeight: Int, scale: Float) -> TemporaryNode {
        let temporaryNode: TemporaryNode
        if let node = self.temporaryNode(on: floorNode) {
            temporaryNode = node
        } else {
            temporaryNode = nodeManipulator.nodeFactory.createTemporaryNode(height: buildHeight)
            floorNode.addChildNode(temporaryNode)
        }

        if let existingType = temporaryNode.buildableType, existingType == buildableType {
        } else {
            temporaryNode.contents = createNode(for: buildableType)
        }

        temporaryNode.apply(scale: scale)
        return temporaryNode
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

    private func absorb(from floorNode: FloorNode, scale: Float, finished: Bool) {
    }

    private func apply(scale: Float, to node: SCNNode) {
        node.scale = SCNVector3Make(scale, scale, scale)
    }

    private func temporaryNode(on floorNode: FloorNode) -> TemporaryNode? {
        return floorNode.childNode(withName: temporaryNodeName, recursively: false) as? TemporaryNode
    }

    private func remove(temporaryNode: TemporaryNode, from floorNode: FloorNode, animated: Bool) {
        if animated {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.3
            SCNTransaction.completionBlock = {
                temporaryNode.removeFromParentNode()
            }

            apply(scale: 0, to: temporaryNode)

            SCNTransaction.commit()
        } else {
            temporaryNode.removeFromParentNode()
        }
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

    func apply(scale: Float) {
        self.scale = SCNVector3Make(scale, scale, scale)
    }
}

extension NodeFactory {
    func createTemporaryNode(height: Int) -> TemporaryNode {
        let node = TemporaryNode()
        node.name = temporaryNodeName
        node.position = nodePositioning.calculateObjectPosition(height: height)
        return node
    }
}
