#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation
import SwiftyGPIO

let switchButtonPin: GPIOName = .P24

let redPin: GPIOName = .P5
let greenPin: GPIOName = .P6
let bluePin: GPIOName = .P12

let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)

class RGB {
    let redGPIO: GPIO
    let greenGPIO: GPIO
    let blueGPIO: GPIO
    
    enum State {
        case red
        case green
        case blue
        case none
    }
    
    var state: State = .none {
        didSet {
            self.changeState(self.state)
        }
    }
    
    init(redGPIO: GPIO, greenGPIO: GPIO, blueGPIO: GPIO) {
        self.redGPIO = redGPIO
        self.greenGPIO = greenGPIO
        self.blueGPIO = blueGPIO
        self.setupGPIO()
    }
    
    func setupGPIO() {
        self.redGPIO.direction = .OUT
        self.greenGPIO.direction = .OUT
        self.blueGPIO.direction = .OUT
        self.changeState(self.state)
    }
    
    private func changeState (_ state: State) {
        switch state {
        case .red:
            self.redGPIO.value = 1
            self.greenGPIO.value = 0
            self.blueGPIO.value = 0
        case .green:
            self.redGPIO.value = 0
            self.greenGPIO.value = 1
            self.blueGPIO.value = 0
        case .blue:
            self.redGPIO.value = 0
            self.greenGPIO.value = 0
            self.blueGPIO.value = 1
        case .none:
            self.redGPIO.value = 0
            self.greenGPIO.value = 0
            self.blueGPIO.value = 0
        }
    }
    
    func switchToNextState() {
        switch state {
        case .red:
            self.state = .green
        case .green:
            self.state = .blue
        case .blue:
            self.state = .none
        case .none:
            self.state = .red
        }
    }
   
}

let rgb = RGB(redGPIO: gpios[redPin]!, greenGPIO: gpios[greenPin]!, blueGPIO: gpios[bluePin]!)

//while true {
//    rgb.switchToNextState()
//    sleep(1)
//}

let switchButtonGPIO = gpios[switchButtonPin]!

switchButtonGPIO.direction = .IN
switchButtonGPIO.onRaising { (gpio) in
    rgb.switchToNextState()
}

print("start")

RunLoop.main.run()
