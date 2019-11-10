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

class RGBLED {
    let red: GPIO
    let green: GPIO
    let blue: GPIO
    
    enum State: String {
        case red = "red"
        case green = "green"
        case blue = "blue"
        case none = "none"
        
        var name: String {
            return self.rawValue
        }
    }
    
    var state: State = .none {
        didSet {
            self.changeState(self.state)
        }
    }
    
    init(red: GPIO, green: GPIO, blue: GPIO) {
        self.red = red
        self.green = green
        self.blue = blue
        self.setupGPIO()
    }
    
    func setupGPIO() {
        #if os(Linux)
        self.red.direction = .OUT
        self.green.direction = .OUT
        self.blue.direction = .OUT
        #endif
        self.changeState(self.state)
    }
    
    #if os(Linux)
    private func changeState (_ state: State) {
        switch state {
        case .red:
            self.red.value = 1
            self.green.value = 0
            self.blue.value = 0
        case .green:
            self.red.value = 0
            self.green.value = 1
            self.blue.value = 0
        case .blue:
            self.red.value = 0
            self.green.value = 0
            self.blue.value = 1
        case .none:
            self.red.value = 0
            self.green.value = 0
            self.blue.value = 0
        }
    }
    #else
    private func changeState (_ state: State) {
        print("change state to \(state.rawValue)")
    }
    #endif
    
    func switchToNextState() -> State {
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
