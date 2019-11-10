#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation
import SwiftyGPIO

let buttonPin: GPIOName = .P24

let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)

let buttonGPIO = gpios[buttonPin]!

buttonGPIO.direction = .IN
buttonGPIO.onChange { (gpio) in
    print("GPIO Value: \(gpio.value).")
}

print("DONE")

RunLoop.main.run()
