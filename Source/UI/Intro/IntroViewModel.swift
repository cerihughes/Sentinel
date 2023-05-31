import SceneKit

class IntroViewModel {
    private let audioManager: AudioManager
    private let world = IntroWorld()
    private let terrain: WorldBuilder.Terrain
    private var token: PlaybackToken?

    var scene: SCNScene { terrain.scene }
    var cameraNode: SCNNode { terrain.initialCameraNode }

    init?(audioManager: AudioManager) {
        guard let image = UIImage.create(text: "The Sentinel") else { return nil }
        self.audioManager = audioManager
        let worldBuilder = WorldBuilder(
            terrainGenerator: ImageTerrainGenerator(image: image),
            materialFactory: IntroMaterialFactory(),
            world: world,
            animatable: true
        )
        terrain = worldBuilder.buildTerrain(initialCameraPosition: world.sentinelNode.position.opposite())
    }

    func startAudio() {
        token = audioManager.play(soundFile: .theme)
    }

    func stopAudio() {
        token?.fadeOut(duration: 1)
    }

    func animate() {
        animateCamera()
        animateTerrain()
        animateSentinel()
    }

    private func animateCamera() {
        let initialPosition = terrain.initialCameraNode.position
        terrain.initialCameraNode.position = terrain.terrainNode.position
        let action = SCNAction.move(to: initialPosition, duration: 30)
        action.timingMode = .easeInEaseOut
        terrain.initialCameraNode.runAction(action)
    }

    private func animateTerrain() {
        for slopeNode in terrain.terrainNode.slopeNodes {
            let from = SCNVector3.randomValues(range: 1000)
            let to = slopeNode.position
            slopeNode.position = from

            let action1 = SCNAction.move(to: to.addingRandomValues(in: 100), duration: .random(in: 3.5 ..< 6.5))
            let action2 = SCNAction.move(by: .randomValues(range: 50), duration: .random(in: 2.0 ..< 3.0))
            let action3 = SCNAction.move(by: .randomValues(range: 20), duration: .random(in: 0.2 ..< 1.0))
            let action4 = SCNAction.move(to: to, duration: .random(in: 0.2 ..< 1.5))
            slopeNode.runAction(.sequence([action1, action2, action2.reversed(), action3, action3.reversed(), action4]))
        }
    }

    private func animateSentinel() {
        let rotationAction = SCNAction.rotateBy(x: 0, y: .radiansInCircle / 2, z: 0, duration: 15.0)
        world.sentinelNode.runAction(rotationAction)
    }
}
