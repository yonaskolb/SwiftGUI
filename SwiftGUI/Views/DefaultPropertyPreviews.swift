//
//  DefaultPropertyPreviews.swift
//  SwiftGUI
//
//  Created by Yonas Kolb on 6/3/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import Foundation
import SwiftUI

struct BoolPropertyPreview: PropertyPreview {

    func body(context: PropertyPreviewContext<Bool>) -> some View {
        Group {
            if context.config.editing {
                Toggle("", isOn: context.binding)
            } else {
                Text(context.value.description)
            }
        }
    }
}

struct StringPropertyPreview: PropertyPreview {

    func getConfig(property: Property, config: Config) -> PropertyPreviewConfig {
        PropertyPreviewConfig(canNavigate: true, customView: true)
    }

    func child(context: PropertyPreviewContext<String>) -> some View {
        TextField(context.property.name, text: context.binding)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

struct URLPropertyPreview: PropertyPreview {

    func getConfig(property: Property, config: Config) -> PropertyPreviewConfig {
        PropertyPreviewConfig(canNavigate: true, customView: true)
    }

    func child(context: PropertyPreviewContext<URL>) -> some View {
        let stringBinding = context.binding.map(
            get: { $0.absoluteString },
            set: { URL(string: $0)! }
        )
        return TextField(context.property.name, text: stringBinding)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

struct IntPropertyPreview: PropertyPreview {

    func getConfig(property: Property, config: Config) -> PropertyPreviewConfig {
        PropertyPreviewConfig(canNavigate: config.editing, customView: true)
    }

    func child(context: PropertyPreviewContext<Int>) -> some View {
        let stringBinding = context.binding.map(
            get: { $0.description },
            set: { Int($0) ?? 0 }
        )
        return Group {
            if context.config.editing {
                TextField("", text: stringBinding)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
            } else {
                Text(context.value.description).font(.largeTitle)
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

struct DoublePropertyPreview: PropertyPreview {

    func getConfig(property: Property, config: Config) -> PropertyPreviewConfig {
        PropertyPreviewConfig(canNavigate: config.editing, customView: true)
    }

    func child(context: PropertyPreviewContext<Double>) -> some View {
        let stringBinding = context.binding.map(
            get: { $0.description },
            set: { Double($0) ?? 0 }
        )
        return Group {
            if context.config.editing {
                TextField("", text: stringBinding)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
            } else {
                Text(context.value.description).font(.largeTitle)
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

struct DatePropertyPreview: PropertyPreview {

    typealias Child = EmptyView
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    func getConfig(property: Property, config: Config) -> PropertyPreviewConfig {
        let axis: Axis = config.editing ? .vertical : .horizontal
        return PropertyPreviewConfig(axis: axis)
    }

    func body(context: PropertyPreviewContext<Date>) -> some View {
        Group {
            if context.config.editing {
                DatePicker("", selection: context.binding)
                    .datePickerStyle(DefaultDatePickerStyle())
            } else {
                Text(Self.dateFormatter.string(from: context.value))
            }
        }
    }
}

struct ArrayPropertyPreview: PropertyPreview {

    func getConfig(property: Property, config: Config) -> PropertyPreviewConfig {
        PropertyPreviewConfig(matchType: false, showPropertyPreview: property.value is [Any], customView: true)
    }

    func body(context: PropertyPreviewContext<[Any]>) -> some View {
        Text(context.value.count.description)
    }

    func child(context: PropertyPreviewContext<[Any]>) -> some View {
        ArrayView(array: context.binding)
    }
}

struct DictionaryPropertyPreview: PropertyPreview {

    func getConfig(property: Property, config: Config) -> PropertyPreviewConfig {
        PropertyPreviewConfig(matchType: false, showPropertyPreview: property.value is [AnyHashable: Any])
    }

    func body(context: PropertyPreviewContext<[AnyHashable: Any]>) -> some View {
        Text(context.value.count.description)
    }
}
