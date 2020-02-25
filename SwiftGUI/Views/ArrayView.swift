//
//  ArrayView.swift
//  SwiftGUI
//
//  Created by Yonas Kolb on 26/2/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import SwiftUI
import Runtime

struct ArrayView: View {

    @Binding var array: [Any]

    init(array: Binding<[Any]>) {
        self._array = array
    }

    func isLink(_ value: Any) -> Bool {
        switch value {
        case is Int: return false
        case is Double: return false
        case is Bool: return false
        case is String: return false
        case is URL: return false
        default: return true
        }
    }

    var body: some View {
        List(0..<array.count, rowContent: row)
    }

    func row(_ index: Int) -> some View {
        let value = array[index]
        return Group {
            if isLink(value) {
                NavigationLink(destination: ObjectView( self.$array[index])) {
                    Text(String(describing: value)).lineLimit(1)
                }
            } else {
                Text(String(describing: value)).lineLimit(1)
            }
        }
    }
}

struct ArrayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ArrayView(array: .constant([TestStruct(), TestStruct()]))
            ArrayView(array: .constant([1, 2]))
        }
    }
}
