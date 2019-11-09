import SwiftyGPIO

print("hello world")

let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)
var gp = gpios[.P5]!
gp.direction = .OUT
gp.value = 1
