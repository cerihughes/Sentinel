import SpriteKit

/**
 An overlay that renders the "classic" sprite-based energy bar.
 */
class OverlayScene: SKScene {
    private let spriteFactory = SpriteFactory()
    private let energyContainer = SKNode()

    override func sceneDidLoad() {
        scaleMode = .aspectFit
        addChild(energyContainer)
    }

    func updateEnergyUI(energy: Int) {
        energyContainer.removeAllChildren()

        var residualEnergy = energy
        var index = 0
        addSprites(
            for: &residualEnergy,
            at: &index,
            spriteEnergy: sentinelEnergyValue * 4,
            spriteNode: spriteFactory.sentinel4SpriteNode
        )
        addSprites(
            for: &residualEnergy,
            at: &index,
            spriteEnergy: synthoidEnergyValue * 4,
            spriteNode: spriteFactory.synthoid4SpriteNode
        )
        addSprites(
            for: &residualEnergy,
            at: &index,
            spriteEnergy: synthoidEnergyValue,
            spriteNode: spriteFactory.synthoidSpriteNode
        )
        addSprites(
            for: &residualEnergy,
            at: &index,
            spriteEnergy: rockEnergyValue,
            spriteNode: spriteFactory.rockSpriteNode
        )
        addSprites(
            for: &residualEnergy,
            at: &index,
            spriteEnergy: treeEnergyValue,
            spriteNode: spriteFactory.treeSpriteNode
        )
    }

    private func addSprites(for energy: inout Int, at index: inout Int, spriteEnergy: Int, spriteNode: SKSpriteNode) {
        while energy >= spriteEnergy {
            guard let copy = spriteNode.copy() as? SKSpriteNode else { continue }
            copy.position = position(for: index, node: copy)
            energyContainer.addChild(copy)
            energy -= spriteEnergy
            index += 1
        }
    }

    private func position(for index: Int, node: SKSpriteNode) -> CGPoint {
        let xOffset = node.size.width / 2.0
        let yOffset = node.size.height / 2.0
        let x = (node.size.width * CGFloat(index)) + xOffset
        return CGPoint(x: x, y: size.height - yOffset)
    }
}
