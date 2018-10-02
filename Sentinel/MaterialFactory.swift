import SceneKit

protocol MaterialFactory {
    var floor1Colour: UIColor {get}
    var floor2Colour: UIColor {get}
    var slope1Colour: UIColor {get}
    var slope2Colour: UIColor {get}
}

class MainMaterialFactory: NSObject, MaterialFactory {
    var floor1Colour: UIColor
    var floor2Colour: UIColor
    var slope1Colour: UIColor
    var slope2Colour: UIColor

    init(level: Int) {
        let colourGenerator = ColourGenerator(level: level)
        let hue1 = colourGenerator.nextHue()
        let hue2 = colourGenerator.nextHue()
        let floorSaturation = colourGenerator.nextFloorSaturation()
        let slopeSaturation = colourGenerator.nextSlopeSaturation()

        floor1Colour = UIColor(hue: hue1, saturation: floorSaturation, brightness: floorSaturation, alpha: 1.0)
        floor2Colour = UIColor(hue: hue2, saturation: floorSaturation, brightness: floorSaturation, alpha: 1.0)
        slope1Colour = UIColor(hue: hue1, saturation: slopeSaturation, brightness: slopeSaturation, alpha: 1.0)
        slope2Colour = UIColor(hue: hue2, saturation: slopeSaturation, brightness: slopeSaturation, alpha: 1.0)

        super.init()
    }
}
