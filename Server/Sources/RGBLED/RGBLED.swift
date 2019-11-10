//
//  RGBLED.swift
//  Server
//
//  Created by qing on 2019/11/9.
//

#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation
import SwiftyGPIO

public class RGBLED {

    let redGPIO: GPIO
    let greenGPIO: GPIO
    let blueGPIO: GPIO
    
    public enum State: String {
        case red = "red"
        case green = "green"
        case blue = "blue"
        case none = "none"
        
        public var name: String {
            return self.rawValue
        }
    }
    
    public var state: State = .none {
        didSet {
            self.changeState(self.state)
        }
    }
    
    public init(redGPIO: GPIO, greenGPIO: GPIO, blueGPIO: GPIO) {
        self.redGPIO = redGPIO
        self.greenGPIO = greenGPIO
        self.blueGPIO = blueGPIO
        self.setupGPIO()
    }
    
    private func setupGPIO() {
        #if os(Linux)
        self.redGPIO.direction = .OUT
        self.greenGPIO.direction = .OUT
        self.blueGPIO.direction = .OUT
        #endif
        self.changeState(self.state)
    }
    
    #if os(Linux)
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
    #else
    private func changeState (_ state: State) {
        print("change state to \(state.rawValue)")
    }
    #endif
   
}

public extension RGBLED {

    @discardableResult func switchToNextState() -> State {
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
        return self.state
    }

}