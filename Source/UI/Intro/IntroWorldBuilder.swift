import SceneKit

struct IntroWorldBuilder {
    struct Built {
        let nodeMap: NodeMap
        let nodeFactory: NodeFactory
        let scene: SCNScene
        let terrainNode: TerrainNode
        let sentinelNode: SentinelNode
        let initialCameraNode: SCNNode
    }
    let terrainGenerator: TerrainGenerator
    let materialFactory: MaterialFactory

    func build() -> Built {
        let grid = terrainGenerator.generate()
        let nodeMap = NodeMap()
        let nodePositioning = grid.createNodePositioning()
        let nodeFactory = NodeFactory(
            nodePositioning: nodePositioning,
            detectionRadius: 0,
            materialFactory: materialFactory
        )

        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)

        let initialCameraNode = nodeFactory.createSynthoidNode(height: 0, viewingAngle: 0.0).cameraNode
        let cameraPosition = SCNVector3(-200.0, 1850, 875)
        initialCameraNode.position = cameraPosition
        initialCameraNode.look(at: terrainNode.position)

        let sentinelNode = SentinelNode(detectionRadius: 0)
        sentinelNode.position = cameraPosition.opposite
        sentinelNode.scale = SCNVector3(75, 75, 75)
        let scene = SCNScene()
        scene.rootNode.addChildNode(sentinelNode)
        scene.rootNode.addChildNode(terrainNode)

        terrainNode.addChildNode(initialCameraNode)

        return .init(
            nodeMap: nodeMap,
            nodeFactory: nodeFactory,
            scene: scene,
            terrainNode: terrainNode,
            sentinelNode: sentinelNode,
            initialCameraNode: initialCameraNode
        )
    }
}

private extension SCNVector3 {
    var opposite: SCNVector3 {
        .init(-x, -y, -z)
    }
}
