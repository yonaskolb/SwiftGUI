//
//  SwiftView.swift
//  SwiftGUI
//
//  Created by Yonas Kolb on 3/3/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import SwiftUI
import Runtime

public struct SwiftView: View {

    @Binding var value: Any
    private var name: String
    let config: Config

    public init<T>(value binding: Binding<T>, config: Config = Config()) {
        let anyBinding = binding.map(
        get: { $0 as Any },
        set: { $0 as! T })
        self._value = anyBinding
        self.name = santizedType(of: binding.wrappedValue)
        self.config = config
    }

    public var body: some View {
        UnknownView(value: $value)
        .environmentObject(config)
        .navigationBarTitle(Text(name), displayMode: .inline)
    }
}

struct SwiftView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftView(value: .constant(TestObject()))
    }
}
