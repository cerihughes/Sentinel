import SceneKit

protocol NodeOperations {
    var currentSynthoidNode: SynthoidNode? {get}

    func rotateAllOpposition(by radians: Float, duration: TimeInterval)
    func rotateCurrentSynthoid(by radiansDelta: Float, persist: Bool)
    func makeSynthoidCurrent(at point: GridPoint)

    func buildTree(at point: GridPoint)
    func buildRock(at point: GridPoint)
    func buildSynthoid(at point: GridPoint, viewingAngle: Float)

    func absorbTree(at point: GridPoint) -> Bool
    func absorbRock(at point: GridPoint, height: Int) -> Bool
    func absorbSynthoid(at point: GridPoint) -> Bool
    func absorbSentry(at point: GridPoint) -> Bool
    func absorbSentinel(at point: GridPoint) -> Bool
}
