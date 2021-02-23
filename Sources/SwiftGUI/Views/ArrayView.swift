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
    @EnvironmentObject var config: Config

    init(array: Binding<[Any]>) {
        self._array = array
    }

    var body: some View {
        List(0..<array.count) { index in
            Text(String(describing: self.array[index]))
                .lineLimit(1)
                .swiftLink(self.$array[index], config: config)
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
