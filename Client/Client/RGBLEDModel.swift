//
//  RGBLEDModel.swift
//  Client
//
//  Created by qing on 2019/11/10.
//  Copyright © 2019 DianQK. All rights reserved.
//

import Foundation
import Combine

enum RGBLEDState: String {
    case red
    case green
    case blue
    case none
}

class RGBLEDModel: ObservableObject {
        
    @Published var state: RGBLEDState = .none
    
    static var shared = RGBLEDModel()
    
    func apply(state: RGBLEDState) {
        clientHandler.send(string: state.rawValue)
    }

}
