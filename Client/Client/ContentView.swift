//
//  ContentView.swift
//  Client
//
//  Created by dianqk on 2019/11/7.
//  Copyright © 2019 DianQK. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var isOn: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("灯光").font(.title)
                Spacer()
                Button(action: {
                    self.isOn.toggle()
                }) {
                    Text(isOn ? "关闭" : "打开").font(.title)
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
