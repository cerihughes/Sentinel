import SceneKit

enum SoundFile: String {
    case absorbed = "Absorbed.mp3"
    case buildEnd1 = "BuildEnd1.mp3"
    case buildEnd2 = "BuildEnd2.mp3"
    case buildStart1 = "BuildStart1.mp3"
    case buildStart2 = "BuildStart2.mp3"
    case levelEnd = "LevelEnd.mp3"
    case teleport = "Teleport.mp3"
}

extension SCNNode {
    func play(soundFile: SoundFile, waitForCompletion: Bool = false) {
        guard let source = SCNAudioSource(fileNamed: soundFile.rawValue) else { return }
        runAction(.playAudio(source, waitForCompletion: waitForCompletion))
    }
}
