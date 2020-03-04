//
//  Renderers.swift
//  SwiftGUI
//
//  Created by Yonas Kolb on 4/3/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import Foundation
import SwiftUI

struct AnyPropertyRenderer {

    var shouldRender: (Context) -> Bool
    var render: (Context) -> AnyView

    init<R: PropertyRenderer>(_ renderer: R) {
        self.shouldRender = renderer.shouldRender
        self.render = { renderer.render(context: $0).anyView }
    }
}

public protocol PropertyRenderer {

    associatedtype Body: View

    func shouldRender(context: Context) -> Bool
    func render(context: Context) -> Body
}

public struct Context {

    public let property: Property
    public let editing: Bool
}
