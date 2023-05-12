import SceneKit

protocol ViewingNode {
    var cameraNode: SCNNode { get }
}

extension ViewingNode {
    func visibleSynthoids(in renderer: SCNSceneRenderer) -> [SynthoidNode] {
        return visibleNodes(in: renderer, type: SynthoidNode.self)
    }

    func visibleRocks(in renderer: SCNSceneRenderer) -> [RockNode] {
        let allRocks = visibleNodes(in: renderer, type: RockNode.self)
        return allRocks.filter { $0.floorNode?.topmostNode == $0 } // only return rocks that have nothing on top of them
    }

    func visibleTreesOnRocks(in renderer: SCNSceneRenderer) -> [TreeNode] {
        let allTrees = visibleNodes(in: renderer, type: TreeNode.self)
        // only return trees that have rocks under them
        return allTrees.filter { $0.floorNode != nil && !$0.floorNode!.rockNodes.isEmpty }
    }

    private func visibleNodes<T: DetectableSCNNode>(in renderer: SCNSceneRenderer, type: T.Type) -> [T] {
        guard let scene = renderer.scene else { return [] }

        let cameraPresentation = cameraNode.presentation
        let frustrumNodes = renderer.nodesInsideFrustum(of: cameraPresentation)
        let interactiveNodes = Set(frustrumNodes.compactMap { $0.findInteractiveParent()?.node })
        return interactiveNodes.compactMap { $0 as? T }
            .filter { self.hasLineOfSight(from: cameraPresentation, to: $0, in: scene) }
    }

    private func hasLineOfSight(from camera: SCNNode, to other: DetectableSCNNode, in scene: SCNScene) -> Bool {
        let worldNode = scene.rootNode
        for detectionNode in other.detectionNodes {
            let startPosition = worldNode.convertPosition(camera.worldPosition, to: nil)
            let endPosition = worldNode.convertPosition(detectionNode.presentation.worldPosition, to: nil)

            let options: [String: Any] = [SCNHitTestOption.searchMode.rawValue: SCNHitTestSearchMode.all.rawValue]
            let hits = worldNode.hitTestWithSegment(from: startPosition, to: endPosition, options: options)
            for hit in hits {
                if let placeableHit = hit.node.firstPlaceableDetectableParent(), placeableHit == other {
                    return true
                }
            }
        }
        return false
    }
}

private extension SCNNode {
    func firstPlaceableDetectableParent() -> DetectableSCNNode? {
        firstPlaceableParent() as? DetectableSCNNode
    }
}
