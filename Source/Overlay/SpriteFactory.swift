import SpriteKit

/**
 Loads sprites from a texture atlas.
 */
class SpriteFactory {
    let textureAtlas = SKTextureAtlas(named: "Sprites.atlas")

    var treeSpriteNode: SKSpriteNode {
        createSpriteNode(named: "Tree")
    }

    var rockSpriteNode: SKSpriteNode {
        createSpriteNode(named: "Rock")
    }

    var synthoidSpriteNode: SKSpriteNode {
        createSpriteNode(named: "Synthoid")
    }

    var synthoid4SpriteNode: SKSpriteNode {
        createSpriteNode(named: "Synthoid_4")
    }

    var sentinel4SpriteNode: SKSpriteNode {
        createSpriteNode(named: "Sentinel_4")
    }

    private func createSpriteNode(named textureName: String) -> SKSpriteNode {
        let node = SKSpriteNode(texture: textureAtlas.textureNamed(textureName))
        node.scale(to: CGSize(width: 48, height: 48))
        return node
    }
}
