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
    private let isRoot: Bool
    private var name: String
    let typeInfo: TypeInfo
    @Environment(\.showRootNavTitle) var showRootNavTitle

    init(value binding: Binding<Any>, isRoot: Bool = false) {
        self.isRoot = isRoot
        let value = binding.wrappedValue
        name = santizedType(of: value)
        typeInfo = try! Runtime.typeInfo(of: type(of: value))
        self._value = binding
    }

    public var body: some View {
        if !isRoot || showRootNavTitle {
            content
#if os(iOS)
            .navigationBarTitle(Text(name), displayMode: .inline)
#endif
        } else {
            content
        }
    }

    var content: some View {
        Group {
            if typeInfo.kind == .optional {
                OptionalView(value: $value)
            } else if isSimpleType(value) {
                ScrollView {
                    Text(String(describing: value))
                        .padding()
                }
            } else if typeInfo.kind == .struct || typeInfo.kind == .class {
                ObjectView($value, isRoot: isRoot)
            } else if typeInfo.kind == .enum {
                EnumView($value)
            } else {
                Text(String(describing: value))
            }
        }
    }
}

struct RootNavTitleKey: EnvironmentKey {

    static var defaultValue: Bool = true
}

extension EnvironmentValues {

    public var showRootNavTitle: Bool {
        get {
            self[RootNavTitleKey.self]
        }
        set {
            self[RootNavTitleKey.self] = newValue
        }
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
