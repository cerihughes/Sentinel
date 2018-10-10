import SceneKit
import UIKit

enum UserInteraction {
    case tap, longPress
}

class BasicInputViewModel: NSObject, InputHandler {
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
        nodeManipulator.rotateCurrentSynthoid(rotationDelta: angleDeltaRadians, elevationDelta: 0.0, persist: finished)
    }

    // MARK: Tap / Press

    private func process(interaction: UserInteraction, hitTestResults: [SCNHitTestResult]) -> Bool {
        if playerViewModel.hasEnteredScene() {
            if let interactiveNode = firstInteractiveNode(for: hitTestResults) {
                return process(interaction: interaction, node: interactiveNode)
            }
        } else {
            return playerViewModel.enterScene()
        }
        return false
    }


    private func process(interaction: UserInteraction, node: SCNNode) -> Bool {
        switch (interaction) {
        case (.tap):
            if let floorNode = node as? FloorNode,
                let point = nodeManipulator.point(for: floorNode) {
                return processTap(floorNode: floorNode, point: point)
            } else if let synthoidNode = node as? SynthoidNode {
                playerViewModel.move(to: synthoidNode)
                return true
            }
        case (.longPress):
            if let floorNode = node as? FloorNode,
                let point = nodeManipulator.point(for: floorNode) {
                return processLongPress(floorNode: floorNode, point: point)
            } else if let floorNode = node.parent as? FloorNode,
                let point = nodeManipulator.point(for: floorNode) {
                return processLongPressObject(node: node, point: point)
            }
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

    private func processLongPressObject(node: SCNNode, point: GridPoint) -> Bool {
        if node is SentinelNode {
            return playerViewModel.absorbSentinelNode(at: point)
        }

        if node is SentryNode {
            return playerViewModel.absorbSentryNode(at: point)
        }

        if node is TreeNode {
            return playerViewModel.absorbTreeNode(at: point)
        }

        if let rockNode = node as? RockNode,
            let floorNode = rockNode.floorNode {
            return playerViewModel.absorbRockNode(at: point, isFinalRockNode: floorNode.rockNodes.count == 1)
        }

        if node is SynthoidNode {
            return playerViewModel.absorbSynthoidNode(at: point)
        }

        return false
    }

}
