//
//  ContentView.swift
//  Client
//
//  Created by dianqk on 2019/11/7.
//  Copyright © 2019 DianQK. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
//    @State var isOn: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    chatHandler.send(string: "red")
                }) {
                    Text("红").font(.title)
                }
                Spacer()
                Button(action: {
                    chatHandler.send(string: "green")
                }) {
                    Text("绿").font(.title)
                }
                Spacer()
                Button(action: {
                    chatHandler.send(string: "blue")
                }) {
                    Text("蓝").font(.title)
                }
                Spacer()
                Button(action: {
                    chatHandler.send(string: "none")
                }) {
                    Text("关").font(.title)
                }
            }
            HStack {
                Text("温度").font(.title)
                Spacer()
                Text("29").font(.title)
            }
            HStack {
                Text("湿度").font(.title)
                Spacer()
                Text("29").font(.title)
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
