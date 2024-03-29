import SceneKit
import UIKit

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

class SwipeInputHandler: InputHandler {
    private let nodeMap: NodeMap
    private let nodeFactory: NodeFactory
    let gestureRecognisers: [UIGestureRecognizer]

    private let hitTestOptions: [SCNHitTestOption: Any]

    private var startTapPoint: CGPoint?
    private var floorNode: FloorNode?

    weak var delegate: InputHandlerDelegate?

    init(nodeMap: NodeMap, nodeFactory: NodeFactory, rootNode: SCNNode) {
        self.nodeMap = nodeMap
        self.nodeFactory = nodeFactory

        hitTestOptions = [
            SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue,
            SCNHitTestOption.rootNode: rootNode
        ]

        let tapRecogniser = UITapGestureRecognizer()
        let doubleTapRecogniser = UITapGestureRecognizer()
        let longPressRecogniser = UILongPressGestureRecognizer()
        let panRecogniser = UIPanGestureRecognizer()

        gestureRecognisers = [tapRecogniser, doubleTapRecogniser, longPressRecogniser, panRecogniser]

        tapRecogniser.addTarget(self, action: #selector(tapGesture(sender:)))

        doubleTapRecogniser.numberOfTapsRequired = 2
        doubleTapRecogniser.addTarget(self, action: #selector(doubleTapGesture(sender:)))

        longPressRecogniser.minimumPressDuration = 0.5
        longPressRecogniser.addTarget(self, action: #selector(longPressGesture(sender:)))
        longPressRecogniser.isEnabled = false

        panRecogniser.addTarget(self, action: #selector(panGesture(sender:)))
        panRecogniser.isEnabled = false
    }

    // MARK: Tap

    @objc
    func tapGesture(sender: UIGestureRecognizer) {
        guard sender.state != .cancelled else { return }
        delegate?.inputHandlerDidEnterScene(self)
    }

    // MARK: Double Tap

    @objc
    func doubleTapGesture(sender: UIGestureRecognizer) {
        guard let sceneView = sender.view as? SCNView else { return }
        let point = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(point, options: hitTestOptions)
        if let interactiveNode = hitTestResults.firstInteractiveNode() {
            processDoubleTap(node: interactiveNode)
        }
    }

    private func processDoubleTap(node: SCNNode) {
        guard
            let synthoidNode = node as? SynthoidNode,
            let floorNode = synthoidNode.floorNode,
            let point = nodeMap.point(for: floorNode)
        else {
            return
        }
        delegate?.inputHandler(self, didMoveToPoint: point)
    }

    // MARK: Long Press

    @objc
    func longPressGesture(sender: UILongPressGestureRecognizer) {
        guard let sceneView = sender.view as? SCNView else { return }

        let point = sender.location(in: sceneView)
        let state = sender.state

        if state == .began {
            let hitTestResults = sceneView.hitTest(point, options: hitTestOptions)
            if let floorNode = floorNode(for: hitTestResults) {
                startTapPoint = point
                self.floorNode = floorNode
                processBuildStart(floorNode: floorNode)
            } else {
                startTapPoint = nil
                floorNode = nil

                // Toggle the state to "cancel" the gesture
                sender.isEnabled = false
                sender.isEnabled = true
            }
        } else if state == .changed || state == .ended {
            if let startTapPoint = startTapPoint, let floorNode {
                if let swipe = Swipe.from(startTapPoint, to: point) {
                    processSwipe(floorNode: floorNode, swipe: swipe, finished: state == .ended)
                } else {
                    // No swipe happened
                    delegate?.inputHandler(self, didCancelFloorNode: floorNode)
                }
            }
        }

        if state == .ended || state == .cancelled || state == .failed, let floorNode {
            processBuildEnd(floorNode: floorNode)
        }
    }

    private func floorNode(for hitTestResults: [SCNHitTestResult]) -> FloorNode? {
        if let interactiveNode = hitTestResults.firstInteractiveNode() {
            if let floorNode = interactiveNode as? FloorNode {
                return floorNode
            }
            if let rockNode = interactiveNode as? RockNode {
                return rockNode.floorNode
            }
        }
        return nil
    }

    private func processSwipe(floorNode: FloorNode, swipe: Swipe, finished: Bool) {
        let scale: Float
        if swipe.delta < Swipe.threshold {
            scale = Float(swipe.delta / Swipe.threshold)
        } else {
            scale = 1.0
        }

        let swipeState = SwipeState(scale: scale, finished: finished)

        switch swipe.direction {
        case .down:
            cancelBuild(floorNode: floorNode)
            processAbsorb(floorNode: floorNode, swipeState: swipeState)
        default:
            cancelAbsorb(floorNode: floorNode)
            if let buildableItem = swipe.direction.buildableItem {
                if validBuildSwipeDirections(for: floorNode).contains(swipe.direction) {
                    processBuild(buildableItem, floorNode: floorNode, swipeState: swipeState)
                } else if finished {
                    // No absorb happened
                    delegate?.inputHandler(self, didCancelFloorNode: floorNode)
                }
            }
        }
    }

    private func validBuildSwipeDirections(for floorNode: FloorNode) -> [Swipe.Direction] {
        if let topmostNode = floorNode.topmostNode {
            if topmostNode is RockNode {
                return Swipe.Direction.allCases
            } else {
                return []
            }
        }

        return [.left, .up, .right]
    }

    private func processAbsorb(floorNode: FloorNode, swipeState: SwipeState) {
        switch swipeState {
        case let .building(scale):
            processInProgressAbsorb(floorNode: floorNode, scale: scale)
        case let .finished(removeIt):
            processCompleteAbsorb(floorNode: floorNode, removeIt: removeIt)
        }
    }

    private func processInProgressAbsorb(floorNode: FloorNode, scale: Float) {
        if let topmostNode = floorNode.topmostNode {
            topmostNode.scaleAllDimensions(by: 1.0 - scale)
        }
    }

    private func processCompleteAbsorb(floorNode: FloorNode, removeIt: Bool) {
        if let topmostNode = floorNode.topmostNode {
            if removeIt, let point = nodeMap.point(for: floorNode) {
                delegate?.inputHandler(self, didAbsorbAtPoint: point, onFloorNode: floorNode)
            } else {
                topmostNode.scaleAllDimensions(by: 1.0, animated: true)
                delegate?.inputHandler(self, didCancelFloorNode: floorNode)
            }
        } else {
            // Nothing to absorb
            delegate?.inputHandler(self, didCancelFloorNode: floorNode)
        }
    }

    private func cancelAbsorb(floorNode: FloorNode) {
        floorNode.topmostNode?.scaleAllDimensions(by: 1.0, animated: true)
    }

    private func processBuild(_ buildableItem: BuildableItem, floorNode: FloorNode, swipeState: SwipeState) {
        switch swipeState {
        case let .building(scale):
            processInProgressBuild(buildableItem, floorNode: floorNode, scale: scale)
        case let .finished(buildIt):
            processCompleteBuild(buildableItem, floorNode: floorNode, buildIt: buildIt)
        }
    }

    private func processBuildStart(floorNode: FloorNode) {
        let height = buildHeight(for: floorNode)
        let selectionNode = nodeFactory.createSelectionNode(height: height)
        floorNode.selectionNode = selectionNode
        delegate?.inputHandler(self, didSelectFloorNode: floorNode)
    }

    private func processInProgressBuild(_ buildableItem: BuildableItem, floorNode: FloorNode, scale: Float) {
        let temporaryNode: TemporaryNode
        if let node = floorNode.temporaryNode {
            temporaryNode = node
        } else {
            let height = buildHeight(for: floorNode)
            temporaryNode = nodeFactory.createTemporaryNode(height: height)
            floorNode.temporaryNode = temporaryNode
        }

        if let existingItem = temporaryNode.buildableItem, existingItem == buildableItem {
        } else {
            temporaryNode.contents = createNode(for: buildableItem)
        }

        temporaryNode.scaleAllDimensions(by: scale)
    }

    private func buildHeight(for floorNode: FloorNode) -> Int {
        if let topmostNode = floorNode.topmostNode {
            if topmostNode is RockNode {
                return floorNode.rockNodes.count
            }
        }
        return 0
    }

    private func processCompleteBuild(_ buildableItem: BuildableItem, floorNode: FloorNode, buildIt: Bool) {
        if let point = nodeMap.point(for: floorNode), let temporaryNode = floorNode.temporaryNode {
            temporaryNode.scaleDownAndRemove(animated: !buildIt)

            if buildIt {
                delegate?.inputHandler(
                    self,
                    didBuild: buildableItem,
                    atPoint: point,
                    rotation: temporaryNode.contents?.rotation.w,
                    onFloorNode: floorNode
                )
            } else {
                // Decided not to build
                delegate?.inputHandler(self, didCancelFloorNode: floorNode)
            }
        }
    }

    private func cancelBuild(floorNode: FloorNode) {
        floorNode.temporaryNode?.scaleDownAndRemove(animated: true)
    }

    private func processBuildEnd(floorNode: FloorNode) {
        floorNode.selectionNode?.removeFromParentNode()
    }

    private func createNode(for buildableItem: BuildableItem) -> PlaceableSCNNode {
        let node: PlaceableSCNNode
        switch buildableItem {
        case .tree:
            node = nodeFactory.createTreeNode(height: 0)
        case .rock:
            node = nodeFactory.createRockNode(height: 0)
        case .synthoid:
            node = nodeFactory.createSynthoidNode(height: 0, viewingAngle: 0.0)
        }
        node.position = SCNVector3Make(0, 0, 0)
        return node
    }

    // MARK: Panning

    @objc
    func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        processPan(by: translation, finished: sender.state == .ended)
    }

    private func processPan(by point: CGPoint, finished: Bool) {
        delegate?.inputHandler(self, didPan: point.createPan(finished: finished))
    }
}

private extension Swipe {
    static let threshold: Float = 200.0
}

private extension Swipe.Direction {
    var buildableItem: BuildableItem? {
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

private class TemporaryNode: SCNNode {
    var contents: PlaceableSCNNode? {
        didSet {
            oldValue?.removeFromParentNode()
            if let contents {
                addChildNode(contents)
            }
        }
    }

    var buildableItem: BuildableItem? {
        if let contents = contents {
            if contents is TreeNode {
                return .tree
            }
            if contents is RockNode {
                return .rock
            }
            if contents is SynthoidNode {
                return .synthoid
            }
        }
        return nil
    }
}

private class SelectionNode: SCNNode {
    override init() {
        super.init()

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        material.specular.contents = UIColor.white

        let sideLength = CGFloat.floorSize
        let box = SCNBox(width: CGFloat(sideLength),
                         height: sideLength / 50,
                         length: CGFloat(sideLength),
                         chamferRadius: sideLength)
        box.firstMaterial = material
        geometry = box
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private let temporaryNodeName = "temporaryNodeName"
private let selectionNodeName = "selectionNodeName"

private extension NodeFactory {
    func createTemporaryNode(height: Int) -> TemporaryNode {
        let node = TemporaryNode()
        node.name = temporaryNodeName
        node.position = nodePositioning.calculateObjectPosition(height: height)
        return node
    }

    func createSelectionNode(height: Int) -> SelectionNode {
        let node = SelectionNode()
        node.name = selectionNodeName
        node.position = nodePositioning.calculateSelectionPosition(height: height)
        return node
    }
}

private extension NodePositioning {
    func calculateSelectionPosition(height: Int = 0) -> SCNVector3 {
        let position = calculateObjectPosition(height: height)
        return SCNVector3Make(
            position.x,
            position.y * 1.1,
            position.z
        )
    }
}

private extension FloorNode {
    var temporaryNode: TemporaryNode? {
        get {
            get(name: temporaryNodeName) as? TemporaryNode
        }
        set {
            set(instance: newValue, name: temporaryNodeName)
        }
    }

    var selectionNode: SelectionNode? {
        get {
            get(name: selectionNodeName) as? SelectionNode
        }
        set {
            set(instance: newValue, name: selectionNodeName)
        }
    }
}

private extension CGPoint {
    func createPan(finished: Bool) -> Pan {
        .init(deltaX: .init(x), deltaY: .init(y), finished: finished)
    }
}
