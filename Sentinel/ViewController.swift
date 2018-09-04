import SceneKit

class ViewController: UIViewController {

    var terrainIndex = 0
    var terrainNode = SCNNode()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = self.view as? SCNView else {
            return
        }

        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor(white: 0.7, alpha: 1.0)

        let scene = SCNScene()
        sceneView.scene = scene

        createTerrain(in: scene)

        let light = SCNLight()
        light.type = .omni
        light.color = UIColor.white

        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3Make(0, 100, 0)
        scene.rootNode.addChildNode(lightNode)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }

    private func createTerrain(in scene: SCNScene) {
        let tg = TerrainGenerator(width: 32, depth: 25)
        let grid = tg.generate(level: terrainIndex)
        let nodeFactory = NodeFactory(sideLength: 10.0)

        terrainNode = nodeFactory.createTerrainNode(grid: grid)
        terrainNode.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(terrainNode)

        if let sentinelPosition = tg.sentinelPosition, let sentinelPiece = grid.get(point: sentinelPosition) {
            let sentinelNode = nodeFactory.createSentinelNode(grid: grid, piece: sentinelPiece)
            terrainNode.addChildNode(sentinelNode)
        }

        for guardianPosition in tg.guardianPositions {
            if let guardianPiece = grid.get(point: guardianPosition) {
                let guardianNode = nodeFactory.createGuardianNode(grid: grid, piece: guardianPiece)
                terrainNode.addChildNode(guardianNode)
            }
        }

        terrainIndex += 1
    }

    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        guard
            let sceneView = self.view as? SCNView,
            let scene = sceneView.scene
        else {
            return
        }

        terrainNode.removeFromParentNode()

        createTerrain(in: scene)
    }
}
