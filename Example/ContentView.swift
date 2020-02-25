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

    @State var object = TestObject()

    var body: some View {
        NavigationView {
            SwiftView($object)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
