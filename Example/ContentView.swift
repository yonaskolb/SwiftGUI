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

    var body: some View {
        NavigationView {
            SwiftView(value: $object, config: config)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(config: Config())
    }
}
