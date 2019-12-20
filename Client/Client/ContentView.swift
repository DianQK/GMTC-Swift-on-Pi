//
//  ContentView.swift
//  Client
//
//  Created by dianqk on 2019/11/7.
//  Copyright © 2019 DianQK. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var model = RGBLEDModel.shared
    
    let colors: [RGBLEDColor] = [.red, .green, .blue]
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            HStack(spacing: 15) {
                ForEach(colors, id: \.rawValue) { (color) in
                    LEDButton(color: color)
                        .frame(width: 100, height: 100, alignment: .center)
                }
            }
            LEDButton(color: .none)
                .frame(width: 330, height: 100, alignment: .center)
            Spacer()
        }
        .padding(15)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
