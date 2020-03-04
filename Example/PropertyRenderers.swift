//
//  PropertyRenderers.swift
//  Example
//
//  Created by Yonas Kolb on 4/3/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import Foundation
import SwiftGUI
import SwiftUI
import URLImage

struct ImageURLPropertyRenderer: PropertyRenderer {

    func shouldRender(property: Property) -> Bool {
        let imageNames: [String] = [
            "picture",
            "profilepic",
            "avatar",
            "profileimage",
        ]
        let isImageURL = imageNames.contains { property.name.lowercased().contains($0.lowercased()) }
        return isImageURL && property.value is URL
    }

    func render(property: Property, editing: Bool) -> some View {

        let url = property.value as! URL

        let image = URLImage(url) { proxy in
            proxy.image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .navigationBarTitle(property.name)
        let imageView = URLImage(url) { proxy in
            proxy.image
                .resizable()
                .frame(width: 30, height: 30)
                .aspectRatio(contentMode: .fill)
                .border(Color.gray, width: 1)
        }
        return NavigationLink(destination: image) {
            //propertyRow(property, simple: false) {
            Group {
                if editing {
                    HStack {
                        TextField("", text: .constant(url.absoluteString))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                        imageView
                    }
                } else {
                    imageView
                }
            }
        }
    }
}
