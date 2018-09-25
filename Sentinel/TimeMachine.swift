import SceneKit

class TimeMachine: NSObject {
    private var timingFunctions: [UUID:TimeEngineData] = [:]
    private var started = false

    func add(timeInterval: TimeInterval, function: @escaping (TimeInterval, SCNSceneRenderer, Any?) -> Any?) -> UUID {
        let data = TimeEngineData(timeInterval: timeInterval, function: function)
        let token = UUID()
        timingFunctions[token] = data
        return token
    }

    func remove(token: UUID) {
        timingFunctions.removeValue(forKey: token)
    }

    func handle(currentTimeInterval: TimeInterval, renderer: SCNSceneRenderer) {
        guard started else {
            return
        }

        for data in timingFunctions.values {
            data.handle(currentTimeInterval: currentTimeInterval, renderer: renderer)
        }
    }

    func start() {
        started = true
    }

    func stop() {
        started = false
    }

    private class TimeEngineData: NSObject {
        let timeInterval: TimeInterval
        let function: (TimeInterval, SCNSceneRenderer, Any?) -> Any?
        var lastResults: Any? = nil

        private var nextTimeInterval: TimeInterval? = nil

        init(timeInterval: TimeInterval, function: @escaping (TimeInterval, SCNSceneRenderer, Any?) -> Any?) {
            self.timeInterval = timeInterval
            self.function = function
            super.init()
        }

        func handle(currentTimeInterval: TimeInterval, renderer: SCNSceneRenderer) {
            if let nextTimeInterval = nextTimeInterval {
                if currentTimeInterval >= nextTimeInterval {
                    lastResults = function(currentTimeInterval, renderer, lastResults)
                    self.nextTimeInterval = currentTimeInterval + timeInterval
                }
            } else {
                nextTimeInterval = currentTimeInterval // This will fire on the next iteration
            }
        }
    }
}
