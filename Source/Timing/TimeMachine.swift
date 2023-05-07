import SceneKit

/**
 SceneKit interacts with the rest of the system with repeated calls to its delegate from the run loop.

 Since a lot of the interactions in The Sentinel are periodic, and follow a regular cadence, I thought it would be
 interesting to route these into an entity that registers different functions along with the time intervals that those
 functions should be fired under. A bit like an NSTimer, but integrated with, and driven by the SceneKit run loop.

 The TimeMachine has been written so that functions aren't all run at the same time: it does this by delaying the
 initial invocation of a function by a small delta, and also by ensuring only 1 function is invoked per invocation
 of the TimeMachine.

 The goal here is to keep a 60/120 fps refresh rate as much as possible by distributing the work as much as possible
 over the run loop.
 */
class TimeMachine {
    private var timingTokens = [UUID]()
    private var timingFunctions = [UUID: TimeEngineData]()
    private var started = false

    func add(timeInterval: TimeInterval, function: @escaping (TimeInterval, SCNSceneRenderer, Any?) -> Any?) -> UUID? {
        guard started == false else { return nil }

        let data = TimeEngineData(timeInterval: timeInterval, function: function)
        let token = UUID()
        timingTokens.append(token)
        timingFunctions[token] = data
        return token
    }

    func remove(token: UUID) {
        guard started == false else { return }

        if let index = timingTokens.firstIndex(of: token) {
            timingTokens.remove(at: index)
        }
        timingFunctions.removeValue(forKey: token)
    }

    func handle(currentTimeInterval: TimeInterval, renderer: SCNSceneRenderer) {
        guard started else { return }

        for token in timingTokens {
            guard let data = timingFunctions[token] else { continue }
            if data.handle(currentTimeInterval: currentTimeInterval, renderer: renderer) {
                // Only run 1 operation per time "slice" - the rest will run in subsequent iterations
                return
            }
        }
    }

    func start() {
        guard started == false else { return }

        started = true
    }

    func stop() {
        started = false
    }

    private class TimeEngineData {
        let timeInterval: TimeInterval
        let function: (TimeInterval, SCNSceneRenderer, Any?) -> Any?
        var lastResults: Any?

        private var nextTimeInterval: TimeInterval = 0.0

        init(timeInterval: TimeInterval, function: @escaping (TimeInterval, SCNSceneRenderer, Any?) -> Any?) {
            self.timeInterval = timeInterval
            self.function = function
        }

        func handle(currentTimeInterval: TimeInterval, renderer: SCNSceneRenderer) -> Bool {
            if currentTimeInterval >= nextTimeInterval {
                lastResults = function(currentTimeInterval, renderer, lastResults)
                nextTimeInterval = currentTimeInterval + timeInterval
                return true
            }
            return false
        }
    }
}
