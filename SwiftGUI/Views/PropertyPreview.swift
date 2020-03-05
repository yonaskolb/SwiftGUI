//
//  PropertyPreview.swift
//  SwiftGUI
//
//  Created by Yonas Kolb on 5/3/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import SwiftUI

public protocol PropertyPreview {

    associatedtype V: View
    associatedtype Value
    associatedtype Child: View = EmptyView

    func body(context: PropertyPreviewContext<Value>) -> V
    func getConfig(property: Property, config: Config) -> PropertyPreviewConfig
    func child(context: PropertyPreviewContext<Value>) -> Child
}


public struct PropertyPreviewConfig {

    public var matchType: Bool
    public var showPropertyPreview: Bool
    public var canNavigate: Bool
    public var customView: Bool
    public var axis: Axis

    public init(matchType: Bool = true, showPropertyPreview: Bool = true, canNavigate: Bool = false, axis: Axis = .horizontal, customView: Bool = false) {
        self.showPropertyPreview = showPropertyPreview
        self.canNavigate = canNavigate
        self.axis = axis
        self.customView = customView
        self.matchType = matchType
    }
}

public struct PropertyPreviewContext<T> {
    public let property: Property
    public let config: Config
    public let propertyConfig: PropertyPreviewConfig
    public let binding: Binding<T>
    public var value: T { binding.wrappedValue }
}


extension PropertyPreview {

    func getConfig(property: Property, config: Config) -> PropertyPreviewConfig {
        return PropertyPreviewConfig()
    }

    func body(context: PropertyPreviewContext<Value>) -> some View {
        Text(String(describing: context.value)).lineLimit(1)
    }
}

extension PropertyPreview where Child == EmptyView {

    func child(context: PropertyPreviewContext<Value>) -> Child {
        EmptyView()
    }
}

