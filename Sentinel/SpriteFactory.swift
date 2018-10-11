import SpriteKit

/**
 Loads sprites from a texture atlas.
 */
class SpriteFactory: NSObject {
    let textureAtlas = SKTextureAtlas(named: "Sprites.atlas")

    var treeSpriteNode: SKSpriteNode {
        return createSpriteNode(named: "Tree")
    }

    var rockSpriteNode: SKSpriteNode {
        return createSpriteNode(named: "Rock")
    }

    var synthoidSpriteNode: SKSpriteNode {
        return createSpriteNode(named: "Synthoid")
    }

    var synthoid4SpriteNode: SKSpriteNode {
        return createSpriteNode(named: "Synthoid_4")
    }

    var sentinel4SpriteNode: SKSpriteNode {
        return createSpriteNode(named: "Sentinel_4")
    }

    private func createSpriteNode(named textureName: String) -> SKSpriteNode {
        let node = SKSpriteNode(texture: textureAtlas.textureNamed(textureName))
        node.scale(to: CGSize(width: 48, height: 48))
        return node
    }
}
