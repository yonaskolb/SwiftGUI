//
//  ContentView.swift
//  Example
//
//  Created by Yonas Kolb on 25/2/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import SwiftUI
import SwiftGUI

struct ContentView: View {

    let config: Config
    @State var object = TestObject()
    @State var openObject = false

    var objectDump: String {
        var string = ""
        dump(object, to: &string)
        return string
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Button("Open Object") {
                    self.openObject = true
                }
                Text(objectDump)
                .sheet(isPresented: $openObject) {
                    NavigationView {
                        SwiftView(value: self.$object, config: self.config)
                    }
                }
            }.padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(config: Config())
    }
}
