import Foundation
@testable import Sentinel

class MockAudioManager: AudioManager {
    var playRequests = [SoundFile]()
    var playResponse = MockPlaybackToken()
    func play(soundFile: SoundFile) -> PlaybackToken? {
        playRequests.append(soundFile)
        return playResponse
    }
}

class MockPlaybackToken: PlaybackToken {
    enum State {
        case playing
        case fadedOut(duration: TimeInterval)
        case stopped
    }

    var state: State?
    func play() {
        state = .playing
    }

    func fadeOut(duration: TimeInterval) {
        state = .fadedOut(duration: duration)
    }

    func stop() {
        state = .stopped
    }
}
