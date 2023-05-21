import SceneKit

enum PositionalSound: String {
    case buildEnd1 = "BuildEnd1.mp3"
    case buildEnd2 = "BuildEnd2.mp3"
    case buildStart1 = "BuildStart1.mp3"
    case buildStart2 = "BuildStart2.mp3"
    case teleport = "Teleport.mp3"
}

extension SCNNode {
    func play(positionalSound: PositionalSound, waitForCompletion: Bool = false) {
        guard let source = SCNAudioSource(fileNamed: positionalSound.rawValue) else { return }
        runAction(.playAudio(source, waitForCompletion: waitForCompletion))
    }
}
