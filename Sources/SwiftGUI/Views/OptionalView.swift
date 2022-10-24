//
//  File.swift
//  
//
//  Created by Yonas Kolb on 24/10/2022.
//

import Foundation
import SwiftUI

protocol OptionalProtocol {
    func isSome() -> Bool
    func unwrap() -> Any
}

extension Optional : OptionalProtocol {
    func isSome() -> Bool {
        switch self {
            case .none: return false
            case .some: return true
        }
    }

    func unwrap() -> Any {
        switch self {
            case .none: preconditionFailure("trying to unwrap nil")
            case .some(let unwrapped): return unwrapped
        }
    }
}

struct OptionalView: View {

    @Binding var value: Any

    func unwrap(_ value: Any) -> Any {
        guard let optional = value as? OptionalProtocol, optional.isSome() else {
            return value
        }
        return optional.unwrap()
    }

    func isSome(_ value: Any) -> Bool {
        guard let optional = value as? OptionalProtocol else {
            return true
        }
        return optional.isSome()
    }

    public var body: some View {
        if isSome(value) {
            UnknownView(value: Binding<Any>(get: { unwrap(value) }, set: { value = $0 }))
        } else {
            Text("nil")
        }
    }
}
