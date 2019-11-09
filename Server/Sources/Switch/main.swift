#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation
import SwiftyGPIO

print("hello world")

let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)
var gp = gpios[.P5]!
gp.direction = .OUT

while true {
    gp.value = gp.value == 1 ? 0 : 1
    sleep(1)
}
