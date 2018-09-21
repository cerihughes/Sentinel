import SceneKit

protocol NodeOperations {
    func rotateAllOpposition(by radians: Float, duration: TimeInterval)
    func rotateCurrentSynthoid(by radiansDelta: Float, persist: Bool)
    func makeSynthoidCurrent(at point: GridPoint)

    func buildTree(at point: GridPoint)
    func buildRock(at point: GridPoint)
    func buildSynthoid(at point: GridPoint, viewingAngle: Float)
    
    func absorbTree(at point: GridPoint)
    func absorbRock(at point: GridPoint, index: Int)
    func absorbSynthoid(at point: GridPoint)
    func absorbSentry(at point: GridPoint)
    func absorbSentinel(at point: GridPoint)
}
