import SceneKit

class ViewController: UIViewController {

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

        let solidMaterial = SCNMaterial()
        solidMaterial.diffuse.contents = UIColor.blue
        solidMaterial.specular.contents = UIColor.darkGray
        solidMaterial.shininess = 0.25

        let tg = TerrainGenerator(width: 32, depth: 24)
        let grid = tg.generate(level: 0)
        let nodeFactory = NodeFactory(sideLength: 10.0)
        let terrainNode = nodeFactory.createTerrainNode(grid: grid)
        terrainNode.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(terrainNode)

        let light = SCNLight()
        light.type = .omni
        light.color = UIColor.white

        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3Make(0, 100, 0)
        scene.rootNode.addChildNode(lightNode)
    }

    private func createGrid() -> Grid {
        let grid = Grid(width: 24, depth: 12)
        grid.build(at: GridPoint(x: 2, z: 2))
        grid.build(at: GridPoint(x: 4, z: 2))
        grid.build(at: GridPoint(x: 3, z: 1))
        grid.build(at: GridPoint(x: 3, z: 3))
        grid.build(at: GridPoint(x: 8, z: 8))
        grid.build(at: GridPoint(x: 8, z: 8))
        grid.build(at: GridPoint(x: 8, z: 8))
        grid.build(at: GridPoint(x: 8, z: 8))
        grid.build(at: GridPoint(x: 8, z: 8))

        return grid
    }
}
