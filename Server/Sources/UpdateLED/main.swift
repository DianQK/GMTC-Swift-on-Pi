#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation
import SwiftyGPIO
import RGBLED

let gpios = SwiftyGPIO.GPIOs(for: .RaspberryPi3)
let rgbLED = RGBLED(red: gpios[.P13]!, green: gpios[.P19]!, blue: gpios[.P26]!)

let button = gpios[.P14]!
button.direction = .IN
button.onRaising { (gpio) in
    rgbLED.switchToNextState()
}

RunLoop.main.run()
