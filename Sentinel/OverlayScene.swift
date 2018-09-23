import SpriteKit

class OverlayScene: SKScene {
    private let spriteFactory = SpriteFactory()
    private let energyContainer = SKNode()

    var energy: Int = 0 {
        didSet {
            updateEnergyUI()
        }
    }

    override func sceneDidLoad() {
        scaleMode = .aspectFit
        addChild(energyContainer)
    }

    func updateEnergyUI() {
        energyContainer.removeAllChildren()

        var residualEnergy = energy
        var index = 0
        addSprites(for: &residualEnergy, at: &index, spriteEnergy: sentinelEnergyValue * 4, spriteNode: spriteFactory.sentinel4SpriteNode)
        addSprites(for: &residualEnergy, at: &index, spriteEnergy: synthoidEnergyValue * 4, spriteNode: spriteFactory.synthoid4SpriteNode)
        addSprites(for: &residualEnergy, at: &index, spriteEnergy: synthoidEnergyValue, spriteNode: spriteFactory.synthoidSpriteNode)
        addSprites(for: &residualEnergy, at: &index, spriteEnergy: rockEnergyValue, spriteNode: spriteFactory.rockSpriteNode)
        addSprites(for: &residualEnergy, at: &index, spriteEnergy: treeEnergyValue, spriteNode: spriteFactory.treeSpriteNode)
    }

    private func addSprites(for energy: inout Int, at index: inout Int, spriteEnergy: Int, spriteNode: SKSpriteNode) {
        while energy >= spriteEnergy {
            let copy = spriteNode.copy() as! SKSpriteNode
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
