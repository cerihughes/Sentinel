import SceneKit

protocol ViewingNode {
    var cameraNode: SCNNode { get }
}

extension ViewingNode {
    func visibleNodes<T: SCNNode>(in renderer: SCNSceneRenderer, type: T.Type) -> [T] {
        guard let scene = renderer.scene else {
            return []
        }

        let cameraPresentation = cameraNode.presentation
        let frustrumNodes = renderer.nodesInsideFrustum(of: cameraPresentation)
        let interactiveNodes = Set(frustrumNodes.compactMap { $0.findInteractiveParent()?.node })
        let compacted = interactiveNodes.compactMap { $0 as? T }
        return compacted.filter { self.hasLineOfSight(from: cameraPresentation, to: $0, in: scene) }
    }

    private func hasLineOfSight(
        from cameraPresentationNode: SCNNode,
        to otherNode: SCNNode,
        in scene: SCNScene
    ) -> Bool {
        guard let otherDetectableNode = otherNode as? DetectableNode else { return false }

        let worldNode = scene.rootNode
        for otherDetectionNode in otherDetectableNode.detectionNodes {
            let detectionPresentationNode = otherDetectionNode.presentation
            let startPosition = worldNode.convertPosition(cameraPresentationNode.worldPosition, to: nil)
            let endPosition = worldNode.convertPosition(detectionPresentationNode.worldPosition, to: nil)

            let options: [String: Any] = [SCNHitTestOption.searchMode.rawValue: SCNHitTestSearchMode.all.rawValue]
            let hits = worldNode.hitTestWithSegment(from: startPosition, to: endPosition, options: options)
            for hit in hits {
                if let placeableHit = hit.node.firstPlaceableParent() as? SCNNode {
                    if placeableHit == otherNode {
                        return true
                    }
                }
            }
        }
        return false
    }
}
