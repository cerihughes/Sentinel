import SceneKit

class TimeMachine: NSObject {
    private var timingFunctions: [UUID:TimeEngineData] = [:]
    private var started = false

    func add(timeInterval: TimeInterval, function: @escaping (TimeInterval, SCNSceneRenderer, Any?) -> Any?) -> UUID? {
        guard started == false else {
            return nil
        }

        let data = TimeEngineData(timeInterval: timeInterval, function: function)
        let token = UUID()
        timingFunctions[token] = data
        return token
    }

    func remove(token: UUID) {
        guard started == false else {
            return
        }

        timingFunctions.removeValue(forKey: token)
    }

    func handle(currentTimeInterval: TimeInterval, renderer: SCNSceneRenderer) {
        guard started else {
            return
        }

        for data in timingFunctions.values {
            if data.handle(currentTimeInterval: currentTimeInterval, renderer: renderer) {
                // Only run 1 operation per time "slice" - the rest will run in subsequent iterations
                return
            }
        }
    }

    func start() {
        guard started == false else {
            return
        }

        assignInitialOffsets()
        started = true
    }

    func stop() {
        started = false
    }

    private func assignInitialOffsets() {
        let count = timingFunctions.count
        guard count > 0 else {
            return
        }

        let interval: TimeInterval = 1.0 / TimeInterval(count)
        for (i, timingFunction) in timingFunctions.values.enumerated() {
            timingFunction.initialOffset = interval * TimeInterval(i)
        }
    }

    private class TimeEngineData: NSObject {
        let timeInterval: TimeInterval
        let function: (TimeInterval, SCNSceneRenderer, Any?) -> Any?
        var lastResults: Any? = nil
        var initialOffset: TimeInterval = 0.0

        private var nextTimeInterval: TimeInterval? = nil

        init(timeInterval: TimeInterval, function: @escaping (TimeInterval, SCNSceneRenderer, Any?) -> Any?) {
            self.timeInterval = timeInterval
            self.function = function
            super.init()
        }

        func handle(currentTimeInterval: TimeInterval, renderer: SCNSceneRenderer) -> Bool {
            if let nextTimeInterval = nextTimeInterval {
                if currentTimeInterval >= nextTimeInterval {
                    lastResults = function(currentTimeInterval, renderer, lastResults)
                    self.nextTimeInterval = currentTimeInterval + timeInterval
                    return true
                }
            } else {
                nextTimeInterval = currentTimeInterval + initialOffset
            }
            return false
        }
    }
}
