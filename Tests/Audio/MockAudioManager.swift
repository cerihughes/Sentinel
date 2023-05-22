@testable import Sentinel

class MockAudioManager: AudioManager {
    var playRequests = [SoundFile]()
    var playResponse = true
    func play(soundFile: SoundFile) -> Bool {
        playRequests.append(soundFile)
        return playResponse
    }
}
