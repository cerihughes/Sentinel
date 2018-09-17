import SceneKit

class TimeEngine: NSObject {
    private var timingFunctions: [UUID:TimeEngineData] = [:]

    func add(timeInterval: TimeInterval, function: @escaping (TimeInterval, SCNSceneRenderer) -> Bool) -> UUID {
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
        let function: (TimeInterval, SCNSceneRenderer) -> Bool

        private var lastTimeInterval: TimeInterval = 0

        init(timeInterval: TimeInterval, function: @escaping (TimeInterval, SCNSceneRenderer) -> Bool) {
            self.timeInterval = timeInterval
            self.function = function
            super.init()
        }

        func handle(currentTimeInterval: TimeInterval, renderer: SCNSceneRenderer) {
            if currentTimeInterval - lastTimeInterval >= timeInterval {
                if function(currentTimeInterval, renderer) {
                    self.lastTimeInterval = currentTimeInterval
                }
            }
        }

    }
}
