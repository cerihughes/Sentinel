import AVFoundation

protocol AudioManager {
    func play(soundFile: SoundFile) -> Bool
}

class DefaultAudioManager: NSObject, AudioManager {
    private var players = [URL: AVAudioPlayer]()
    private let queue = DispatchQueue(label: "players-queue", qos: .userInteractive)

    func play(soundFile: SoundFile) -> Bool {
        guard let bundlePath = soundFile.bundlePath else { return false }
        let url = URL(filePath: bundlePath)
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return false }
        player.delegate = self

        queue.async { [weak self] in
            self?.players[url] = player
            player.play()
        }
        return true
    }
}

extension DefaultAudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let url = player.url else { return }
        queue.async { [weak self] in
            self?.players[url] = nil
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
