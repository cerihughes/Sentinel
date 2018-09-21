import SceneKit

class TimeEngine: NSObject {
    private var timingFunctions: [UUID:TimeEngineData] = [:]

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
        for data in timingFunctions.values {
            data.handle(currentTimeInterval: currentTimeInterval, renderer: renderer)
        }
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
