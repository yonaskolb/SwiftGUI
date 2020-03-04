//
//  Config.swift
//  SwiftGUI
//
//  Created by Yonas Kolb on 26/2/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import Foundation
import SwiftUI

public class Config: ObservableObject {

    @Published public var editing: Bool
    @Published public var allowEditingToggle: Bool

    var propertyRenderers: [AnyPropertyRenderer] = []

    public init(editing: Bool = false, allowEditingToggle: Bool = false) {
        self.editing = editing
        self.allowEditingToggle = allowEditingToggle
    }

    public func addPropertyRenderer<R: PropertyRenderer>(_ renderer: R) {
        propertyRenderers.append(AnyPropertyRenderer(renderer))
    }

    func getPropertyRenderer(for property: Property) -> AnyView? {
        let context = Context(property: property, editing: editing)
        for renderer in propertyRenderers {
            if renderer.shouldRender(context) {
                let view = renderer.render(context)
                return view
            }
        }
        return nil
    }
}
