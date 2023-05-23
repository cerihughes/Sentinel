import SceneKit

class IntroViewModel {
    private let audioManager: AudioManager
    let built: IntroWorldBuilder.Built

    private var token: PlaybackToken?

    init(audioManager: AudioManager) {
        self.audioManager = audioManager
        let worldBuilder = IntroWorldBuilder(
            terrainGenerator: IntroTerrainGenerator(),
            materialFactory: IntroMaterialFactory()
        )
        built = worldBuilder.build()
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
        let initialPosition = built.initialCameraNode.position
        built.initialCameraNode.position = built.terrainNode.position
        let action = SCNAction.move(to: initialPosition, duration: 30)
        action.timingMode = .easeInEaseOut
        built.initialCameraNode.runAction(action)
    }

    private func animateTerrain() {
        for slopeNode in built.terrainNode.slopeNodes {
            let from = SCNVector3.randomValue(range: 1000)
            let to = slopeNode.position
            slopeNode.position = from

            let action1 = SCNAction.move(to: to.randomDelta(in: 100), duration: .random(in: 3.5 ..< 6.5))
            let action2 = SCNAction.move(by: .randomValue(range: 50), duration: .random(in: 2.0 ..< 3.0))
            let action3 = SCNAction.move(by: .randomValue(range: 20), duration: .random(in: 0.2 ..< 1.0))
            let action4 = SCNAction.move(to: to, duration: .random(in: 0.2 ..< 1.5))
            slopeNode.runAction(.sequence([action1, action2, action2.reversed(), action3, action3.reversed(), action4]))
        }
    }

    private func animateSentinel() {
        let rotationAction = SCNAction.rotateBy(x: 0, y: .radiansInCircle / 2, z: 0, duration: 15.0)
        built.sentinelNode.runAction(rotationAction)
    }
}

private extension SCNVector3 {
    static func randomValue(range: Float) -> SCNVector3 {
        .init(
            .random(in: -range ..< range),
            .random(in: -range ..< range),
            .random(in: -range ..< range)
        )
    }

    func randomDelta(in range: Float) -> SCNVector3 {
        .init(
            x + .random(in: -range ..< range),
            y + .random(in: -range ..< range),
            z + .random(in: -range ..< range)
        )
    }
}
