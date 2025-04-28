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
    /// filters a property name. Return nil to filter out property entirely
    @Published public var propertyFilter: (String) -> String?
    
    var propertyPreviews: [PropertyPreviewRenderer] = []
    
    // replaces underscores and removes "$" properties (like "_$observationRegistrar")
    public static func defaultPropertyFilter(property: String) -> String? {
        var name = property
        if name.hasPrefix("_") {
            name = String(name.dropFirst())
        }
        if name.hasPrefix("$") {
            return nil
        }
        return name
    }

    public init(
        editing: Bool = true,
        allowEditingToggle: Bool = false,
        addDefaultProperties: Bool = true,
        propertyFilter: @escaping (String) -> String? = Config.defaultPropertyFilter
    ) {
        self.editing = editing
        self.allowEditingToggle = allowEditingToggle
        self.propertyFilter = propertyFilter
        if addDefaultProperties {
            addDefaultPropertyPreviews()
        }
    }

    public func addDefaultPropertyPreviews() {
        addPropertyPreview(BoolPropertyPreview())
        addPropertyPreview(DatePropertyPreview())
        addPropertyPreview(ArrayPropertyPreview())
        addPropertyPreview(StringPropertyPreview())
        addPropertyPreview(IntPropertyPreview())
        addPropertyPreview(DoublePropertyPreview())
        addPropertyPreview(DictionaryPropertyPreview())
        addPropertyPreview(URLPropertyPreview())
    }

    public func addPropertyPreview<P: PropertyPreview>(_ preview: P) {
        let render: (PropertyPreviewContext<Any>) -> AnyView = { context in
            let binding: Binding<P.Value> = context.binding.map(
                    get: { $0 as! P.Value },
                    set: { $0 }
            )
            let newContext = PropertyPreviewContext(property: context.property, config: context.config, propertyConfig: context.propertyConfig, binding: binding)
            let view = preview.body(context: newContext)
            return view.anyView
        }
        let childRender: (PropertyPreviewContext<Any>) -> AnyView = { context in
            let binding: Binding<P.Value> = context.binding.map(
                    get: { $0 as! P.Value },
                    set: { $0 }
            )
            let newContext = PropertyPreviewContext(property: context.property, config: context.config, propertyConfig: context.propertyConfig, binding: binding)
            return preview.child(context: newContext).anyView
        }
        let typeName = String(describing: P.Value.self)
        let renderer = PropertyPreviewRenderer(getConfig: preview.getConfig, render: render, childRender: childRender, typeName: typeName)
        propertyPreviews.insert(renderer, at: 0)
    }

    public func getPreview(for property: Property, with binding: Binding<Any>) -> PropertyPreviewResult? {
        guard let value = property.value else { return nil }
        let typeName = String(describing: type(of: value))
        for propertyPreview in propertyPreviews {
            let config = propertyPreview.getConfig(property, self)
            let context = PropertyPreviewContext(property: property, config: self, propertyConfig: config, binding: binding)
            let typeMatch = config.matchType ? (typeName == propertyPreview.typeName) : true
            if typeMatch && config.showPropertyPreview {
                let view = propertyPreview.render(context).anyView
                let childView = config.customView ? propertyPreview.childRender(context) : nil
                return PropertyPreviewResult(view: view, config: config, childView: childView)
            }
        }
        return nil
    }
}

public struct PropertyPreviewResult {
    public let view: AnyView
    public let config: PropertyPreviewConfig
    public let childView: AnyView?
}

struct PropertyPreviewRenderer {

    let getConfig: (Property, Config) -> PropertyPreviewConfig
    let render: (PropertyPreviewContext<Any>) -> AnyView
    let childRender: (PropertyPreviewContext<Any>) -> AnyView
    let typeName: String?
}

