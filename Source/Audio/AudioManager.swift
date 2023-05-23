import AVFoundation

protocol PlaybackToken {
    func play()
    func fadeOut(duration: TimeInterval)
    func stop()
}

protocol AudioManager {
    @discardableResult
    func play(soundFile: SoundFile) -> PlaybackToken?
}

class DefaultAudioManager: NSObject, AudioManager {
    private var tokens = [URL: PlaybackToken]()
    private let queue = DispatchQueue(label: "players-queue", qos: .userInteractive)

    func play(soundFile: SoundFile) -> PlaybackToken? {
        guard let bundlePath = soundFile.bundlePath else { return nil }
        let url = URL(filePath: bundlePath)
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        player.delegate = self

        let token = DefaultPlaybackToken(player: player)
        queue.async { [weak self] in
            self?.tokens[url] = token
            token.play()
        }
        return token
    }
}

private class DefaultPlaybackToken: PlaybackToken {
    private let player: AVAudioPlayer

    init(player: AVAudioPlayer) {
        self.player = player
    }

    func play() {
        player.play()
    }

    func fadeOut(duration: TimeInterval) {
        player.setVolume(0, fadeDuration: duration)
    }

    func stop() {
        player.stop()
    }
}

extension DefaultAudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let url = player.url else { return }
        queue.async { [weak self] in
            self?.tokens[url] = nil
        }
    }
}

private extension SoundFile {
    var bundlePath: String? {
        let filename = rawValue as NSString
        let resource = filename.deletingPathExtension
        let type = filename.pathExtension
        return Bundle.main.path(forResource: resource, ofType: type)
    }
}
