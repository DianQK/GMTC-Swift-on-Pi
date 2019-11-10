#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation
import SwiftyGPIO
import RGBLED

let gpios = SwiftyGPIO.GPIOs(for: .RaspberryPi3)
let rgbLED = RGBLED(redGPIO: gpios[.P13]!, greenGPIO: gpios[.P19]!, blueGPIO: gpios[.P26]!)

let button = gpios[.P14]!
button.direction = .IN
button.onChange { (gpio) in
    rgbLED.switchToNextState()
}

RunLoop.main.run()
