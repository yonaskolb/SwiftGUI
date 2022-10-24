//
//  UnknownView.swift
//  SwiftGUI
//
//  Created by Yonas Kolb on 4/3/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import Foundation
import SwiftUI
import Runtime

struct UnknownView: View {

    @Binding var value: Any
    private var name: String
    let typeInfo: TypeInfo

    init(value binding: Binding<Any>) {
        let value = binding.wrappedValue
        name = santizedType(of: value)
        typeInfo = try! Runtime.typeInfo(of: type(of: value))
        self._value = binding
    }

    public var body: some View {
        Group {
            if typeInfo.kind == .optional {
                OptionalView(value: $value)
            } else if isSimpleType(value) {
                ScrollView {
                    Text(String(describing: value))
                        .padding()
                }
            } else if typeInfo.kind == .struct || typeInfo.kind == .class {
                ObjectView($value)
            } else if typeInfo.kind == .enum {
                EnumView($value)
            } else {
                Text(String(describing: value))
            }
        }
#if os(iOS)
        .navigationBarTitle(Text(name), displayMode: .inline)
#endif
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

    func swiftLink(_ binding: Binding<Any>, config: Config) -> some View {
        Group {
            if isSimpleType(binding.wrappedValue) {
                self
            } else {
                NavigationLink(destination: UnknownView(value: binding).environmentObject(config)) {
                    self
                }
            }
        }
    }
}
