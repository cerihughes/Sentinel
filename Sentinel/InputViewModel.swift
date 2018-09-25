import SceneKit
import UIKit

enum UserInteraction {
    case tap, longPress
}

class InputViewModel: NSObject {
    private let playerViewModel: PlayerViewModel
    private let opponentsViewModel: OpponentsViewModel
    private let nodeManipulator: NodeManipulator
    private let gestureRecognisers: [UIGestureRecognizer]

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

        longPressRecogniser.addTarget(self, action: #selector(tapGesture(sender:)))
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

    @objc
    func tapGesture(sender: UIGestureRecognizer) {
        guard sender.state != .cancelled else {
            return
        }

        if let sceneView = sender.view as? SCNView, let interaction = interaction(for: sender) {
            let point = sender.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(point, options: [:])
            if process(interaction: interaction, hitTestResults: hitTestResults) {
                // Start the time machine
                opponentsViewModel.timeMachine.start()

                // Toggle the state to "complete" the gesture
                sender.isEnabled = false
                sender.isEnabled = true
            }
        }
    }

    @objc
    func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        let deltaX = Float(translation.x)
        processPan(by: deltaX, finished: sender.state == .ended)
    }

    private func interaction(for sender: UIGestureRecognizer) -> UserInteraction? {
        if sender.isKind(of: UITapGestureRecognizer.self) {
            return .tap
        }

        if sender.isKind(of: UILongPressGestureRecognizer.self) {
            return .longPress
        }

        return nil
    }

    // MARK: Panning

    private func processPan(by x: Float, finished: Bool) {
        let angleDeltaDegrees = x / 10.0
        let angleDeltaRadians = angleDeltaDegrees * Float.pi / 180.0
        nodeManipulator.rotateCurrentSynthoid(by: angleDeltaRadians)

        if finished {
            nodeManipulator.rotateCurrentSynthoid(by: angleDeltaRadians, persist: true)
        }
    }

    // MARK: Tap / Press

    private func process(interaction: UserInteraction, hitTestResults: [SCNHitTestResult]) -> Bool {
        if playerViewModel.hasEnteredScene() {
            if let hitTestResult = hitTestResults.first {
                let node = hitTestResult.node
                if let interactiveNode = node.firstInteractiveParent() {
                    return process(interaction: interaction, node: interactiveNode)
                }
            }
        } else {
            return playerViewModel.enterScene()
        }
        return false
    }


    private func process(interaction: UserInteraction, node: SCNNode) -> Bool {
        let bitmask = node.categoryBitMask
        for interactiveNodeType in interactiveNodeType.allCases {
            if bitmask & interactiveNodeType.rawValue == interactiveNodeType.rawValue {
                return process(interaction: interaction, node: node, interactiveNodeType: interactiveNodeType)
            }
        }
        print("Not processing \(interaction) on \(bitmask)")
        return false
    }

    private func process(interaction: UserInteraction, node: SCNNode, interactiveNodeType: interactiveNodeType) -> Bool {
        var point: GridPoint? = nil
        if let floorNode = node as? FloorNode {
            point = nodeManipulator.point(for: floorNode)
        } else if let floorNode = node.parent as? FloorNode,
            let floorName = floorNode.name,
            floorName == floorNodeName {
            point = nodeManipulator.point(for: floorNode)
        }

        switch (interaction, interactiveNodeType) {
        case (.tap, .floor):
            if let floorNode = node as? FloorNode,
                let point = point {
                return processTap(floorNode: floorNode, point: point)
            }
        case (.tap, .synthoid):
            if let synthoidNode = node as? SynthoidNode {
                playerViewModel.move(to: synthoidNode)
                return true
            }
        case (.longPress, .floor):
            if let floorNode = node as? FloorNode,
                let point = point {
                return processLongPress(floorNode: floorNode, point: point)
            }
        case (.longPress, _):
            if let point = point {
                return processLongPressObject(node: node, point: point, interactiveNodeType: interactiveNodeType)
            }
        default:
            print("Not processing \(interactiveNodeType)")
        }
        return false
    }

    private func processTap(floorNode: FloorNode, point: GridPoint) -> Bool {
        if floorNode.sentinelNode != nil || floorNode.sentryNode != nil {
            return false
        } else if floorNode.treeNode != nil {
            playerViewModel.buildRock(at: point)
        } else if floorNode.rockNodes.count > 0 && floorNode.synthoidNode == nil {
            playerViewModel.buildRock(at: point)
        } else if let synthoidNode = floorNode.synthoidNode {
            playerViewModel.move(to: synthoidNode)
        } else {
            // Empty space - build a rock
            playerViewModel.buildRock(at: point)
        }
        return true
    }

    private func processLongPress(floorNode: FloorNode, point: GridPoint) -> Bool {
        guard floorNode.topmostNode == nil || floorNode.topmostNode is RockNode else {
            return false
        }

        playerViewModel.buildSynthoid(at: point)
        return true
    }

    private func processLongPressObject(node: SCNNode, point: GridPoint, interactiveNodeType: interactiveNodeType) -> Bool {
        if interactiveNodeType == .sentinel {
            playerViewModel.absorbSentinelNode(at: point)
        } else if interactiveNodeType == .sentry {
            playerViewModel.absorbSentryNode(at: point)
        } else if interactiveNodeType == .tree {
            playerViewModel.absorbTreeNode(at: point)
        } else if interactiveNodeType == .rock {
            if let rockNode = node as? RockNode,
                let floorNode = rockNode.floorNode {
                playerViewModel.absorbRockNode(at: point, isFinalRockNode: floorNode.rockNodes.count == 1)
            }
        } else if interactiveNodeType == .synthoid {
            playerViewModel.absorbSynthoidNode(at: point)

        }
        return true
    }

}
