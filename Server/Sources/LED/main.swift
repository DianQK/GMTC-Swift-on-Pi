#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation
import SwiftyGPIO

let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)
let led = gpios[.P12]!
led.direction = .OUT
led.value = 1



