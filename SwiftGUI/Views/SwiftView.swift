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
    let typeInfo: TypeInfo
    let config: Config

    public init<T>(_ binding: Binding<T>, config: Config = Config()) {
        let value = binding.wrappedValue
        typeInfo = try! Runtime.typeInfo(of: type(of: value))
        self._value = binding.map(
            get: { $0 as Any },
            set: { $0 as! T })
        self.config = config
    }

    public var body: some View {
        Group {
            if typeInfo.kind == .struct || typeInfo.kind == .class {
                ObjectView($value)
            } else if typeInfo.kind == .enum {
                EnumView($value)
            } else {
                Text(String(describing: value))
            }
        }
        .environmentObject(config)
    }
}

struct SwiftView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftView(.constant(TestObject()))
    }
}
