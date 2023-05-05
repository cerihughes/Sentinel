import Foundation

/**
 Generates the game Grid from a given LevelConfiguration.

 Levels should be psuedo-random - i.e. they shouldn't be predicatable, but they should be reproducible. The level
 number is used as a kind of "seed" to make sure the same values are returned for the same input every time.

 The LevelGenerator should also make sure this class creates increasingly difficult terrains to play with.
 */
protocol TerrainGenerator {
    func generate() -> Grid
}
