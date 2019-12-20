//
//  LEDButton.swift
//  Client
//
//  Created by qing on 2019/11/10.
//  Copyright © 2019 DianQK. All rights reserved.
//

import SwiftUI
import Combine

struct LEDButton: View {
    
    let color: RGBLEDColor
    
    @EnvironmentObject var model: RGBLEDModel
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundColor(model.state == self.color ? self.color.color : self.color.color.opacity(0.3))
            .onTapGesture {
                self.model.apply(state: self.color)
        }
    }
}

struct LEDButton_Previews: PreviewProvider {
    static var previews: some View {
        LEDButton(color: .red).environmentObject(RGBLEDModel.shared)
    }
}
