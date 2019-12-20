#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation
import SwiftyGPIO

let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)
let button = gpios[.P14]!
button.direction = .IN
button.onChange { (gpio) in
    print("GPIO Value: \(gpio.value).")
}

RunLoop.main.run()
