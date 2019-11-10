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
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.model.apply(state: .red)
                }) {
                    Text("红").font(.title).foregroundColor(model.state == RGBLEDState.red ? Color.red : Color.gray)
                }
                Spacer()
                Button(action: {
                    self.model.apply(state: .green)
                }) {
                    Text("绿").font(.title).foregroundColor(model.state == RGBLEDState.green ? Color.green : Color.gray)
                }
                Spacer()
                Button(action: {
                    self.model.apply(state: .blue)
                }) {
                    Text("蓝").font(.title).foregroundColor(model.state == RGBLEDState.blue ? Color.blue : Color.gray)
                }
                Spacer()
                Button(action: {
                    self.model.apply(state: .none)
                }) {
                    Text("关").font(.title).foregroundColor(model.state == RGBLEDState.none ? Color.black : Color.gray)
                }
            }
        }
        .padding(15)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
