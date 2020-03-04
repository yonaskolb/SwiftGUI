//
//  EnumView.swift
//  SwiftGUI
//
//  Created by Yonas Kolb on 3/3/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import SwiftUI
import Runtime

struct EnumView: View {

    @Binding var enumValue: Any
    let isRaw: Bool

    init(_ enumValueBinding: Binding<Any>) {
        self._enumValue = enumValueBinding
        let mirror = Mirror(reflecting: enumValueBinding.wrappedValue)
        isRaw = mirror.children.isEmpty
    }

    var body: some View {
        Group {
            if isRaw {
                EnumRawView($enumValue)
            } else {
                EnumAssociatedView($enumValue)
            }
        }
    }
}

private struct EnumRawView: View {

    @Binding var enumValue: Any
    let cases: [String]
    let selectedCase: String

    init(_ enumValueBinding: Binding<Any>) {
        let enumValue = enumValueBinding.wrappedValue
        self._enumValue = enumValueBinding
        let typeInfo = try! Runtime.typeInfo(of: type(of: enumValue))
        precondition(typeInfo.kind == .enum)
        cases = typeInfo.cases.map { $0.name }
        let mirror = Mirror(reflecting: enumValue)
        let children = mirror.children.map { $0 }
        selectedCase = children.first?.label ?? String(describing: enumValue)
    }

    var body: some View {
        List(cases, id: \.self) { enumCase in
            HStack {
                Text(enumCase)
                Spacer()
                if enumCase == self.selectedCase {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.accentColor)
                } else {
                    Image(systemName: "circle").foregroundColor(.gray)
                }
            }
        }
    }
}

private struct EnumAssociatedView: View {

    @Binding var enumValue: Any
    let types: [AssociatedType]
    let singleValue: Any?

    struct AssociatedType {
        let label: String
        let type: Any.Type
        let typeName: String
        let value: Any
        let id: Int
    }

    init(_ enumValueBinding: Binding<Any>) {
        let enumValue = enumValueBinding.wrappedValue
        self._enumValue = enumValueBinding
        let mirror = Mirror(reflecting: enumValue)
        let children = mirror.children.map { $0 }
        precondition(children.count == 1)
        let associatedMirror = Mirror(reflecting: children[0].value)
        if associatedMirror.children.count == 0 {
            singleValue = children[0].value
        } else {
            singleValue = nil
        }
        types = associatedMirror.children.enumerated().map { index, value in
            let label = (value.label ?? "").replacingOccurrences(of: #"\.\d"#, with: "", options: [.regularExpression], range: nil)
            return AssociatedType(
                label: label,
                type: type(of: value.value),
                typeName: santizedType(of: value.value),
                value: value.value,
                id: index)
        }
    }

    var body: some View {
        Group {
            if singleValue != nil {
                UnknownView(value: .constant(singleValue!))
            } else {
                List(types, id: \.id) { type in
                    HStack {
                        (Text(type.label.isEmpty ? "" : "\(type.label): ") +
                        Text(type.typeName).bold())
                        Spacer()
                        Text(String(describing: type.value))
                    }
                    .lineLimit(1)
                    .swiftLink(.constant(type.value)) // TODO: editable
                }
            }
        }
    }
}

struct EnumView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EnumView(.constant(RawEnum.one))
            EnumView(.constant(AssociatedEnum.int(1)))
            EnumView(.constant(AssociatedEnum.object(TestStruct())))
            EnumView(.constant(AssociatedEnum.multi(true, object: TestStruct())))
        }
    }
}
