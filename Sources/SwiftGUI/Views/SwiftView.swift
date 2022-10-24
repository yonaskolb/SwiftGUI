//
//  SwiftView.swift
//  SwiftGUI
//
//  Created by Yonas Kolb on 3/3/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import SwiftUI
import Runtime

/// Put inside a NavigationView
public struct SwiftView: View {

    @Binding var value: Any
    private var name: String
    let config: Config

    public init(value binding: Binding<Any>, config: Config = Config()) {
        self._value = binding
        self.name = santizedType(of: binding.wrappedValue)
        self.config = config
    }

    public init<T>(value binding: Binding<T>, config: Config = Config()) {
        let anyBinding = binding.map(
        get: { $0 as Any },
        set: { $0 as! T })
        self._value = anyBinding
        self.name = santizedType(of: binding.wrappedValue)
        self.config = config
    }

    public var body: some View {
        UnknownView(value: $value, isRoot: true)
        .environmentObject(config)
    }

    public func showRootNavTitle(_ show: Bool) -> some View {
       self.environment(\.showRootNavTitle, false)
    }
}

struct SwiftView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                Container(state: TestObject(), config: Config(editing: true))
            }
            Container(state: "Some text. Some text. Some text. Some text. Some text. Some text. Some text. Some text. ")
        }
    }

    struct Container<S>: View {
        @State var state: S
        var config = Config()

        var body: some View {
            SwiftView(value: $state, config: config)
        }
    }
}
