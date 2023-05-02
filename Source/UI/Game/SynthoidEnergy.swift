import Combine
import Foundation

protocol SynthoidEnergy {
    var energy: Int { get }
    var energyPublisher: Published<Int>.Publisher { get }
    func adjust(delta: Int)
    func has(energy: Int) -> Bool
}

class SynthoidEnergyMonitor: SynthoidEnergy {
    @Published var energy = 10

    var energyPublisher: Published<Int>.Publisher {
        $energy
    }

    func adjust(delta: Int) {
        energy = max(0, energy + delta)
    }

    func has(energy: Int) -> Bool {
        self.energy > energy
    }
}
