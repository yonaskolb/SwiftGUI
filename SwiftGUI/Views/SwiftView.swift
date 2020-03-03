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
    let typeInfo: TypeInfo
    let config: Config

    public init<T>(_ binding: Binding<T>, config: Config = Config()) {
        let anyBinding = binding.map(
        get: { $0 as Any },
        set: { $0 as! T })
        self.init(anyBinding: anyBinding)
    }

    init(anyBinding binding: Binding<Any>, config: Config = Config()) {
        let value = binding.wrappedValue
        name = santizedType(of: value)
        typeInfo = try! Runtime.typeInfo(of: type(of: value))
        self._value = binding
        self.config = config
    }

    public var body: some View {
        Group {
            if isSimpleType(value) {
                Text(String(describing: value))
            } else if typeInfo.kind == .struct || typeInfo.kind == .class {
                ObjectView($value)
            } else if typeInfo.kind == .enum {
                EnumView($value)
            } else {
                Text(String(describing: value))
            }
        }
        .environmentObject(config)
        .navigationBarTitle(Text(name), displayMode: .inline)
    }
}

func isSimpleType(_ value: Any) -> Bool {
    switch value {
    case is Int: return true
    case is Double: return true
    case is Bool: return true
    case is String: return true
    case is URL: return true
    default: return false
    }
}

extension View {

    func swiftLink(_ binding: Binding<Any>) -> some View {
        Group {
            if isSimpleType(binding.wrappedValue) {
                self
            } else {
                NavigationLink(destination: SwiftView(anyBinding: binding)) {
                    self
                }
            }
        }
    }
}

struct SwiftView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftView(.constant(TestObject()))
    }
}
