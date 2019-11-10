//
//  RGBLEDModel.swift
//  Client
//
//  Created by qing on 2019/11/10.
//  Copyright © 2019 DianQK. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

enum RGBLEDColor: String, Hashable {
    
    case red
    case green
    case blue
    case none
    
    var color: Color {
        switch self {
        case .red:
            return .red
        case .green:
            return .green
        case .blue:
            return .blue
        case .none:
            return .gray
        }
    }
}

class RGBLEDModel: ObservableObject {
        
    @Published var state: RGBLEDColor = .none
    
    static var shared = RGBLEDModel()
    
    func apply(state: RGBLEDColor) {
        clientHandler.send(string: state.rawValue)
    }

}
