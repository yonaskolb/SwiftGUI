//
//  URLImagePropertyPreview.swift
//  Example
//
//  Created by Yonas Kolb on 5/3/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import SwiftUI
import SwiftGUI
import URLImage

struct URLImagePropertyPreview: PropertyPreview {

    func getConfig(property: Property, config: Config) -> PropertyPreviewConfig {
        let imageNames: [String] = [
            "picture",
            "profilepic",
            "avatar",
            "profileimage",
        ]
        let isImageURL = imageNames.contains { property.name.lowercased().contains($0.lowercased()) }
        return PropertyPreviewConfig(showPropertyPreview: isImageURL, customView: true)
    }

    func body(context: PropertyPreviewContext<URL>) -> some View {
        let url = context.value
        
        let imageView = URLImage(url) { proxy in
            proxy.image
                .resizable()
                .frame(width: 30, height: 30)
                .aspectRatio(contentMode: .fill)
                .border(Color.gray, width: 1)
        }

        let stringBinding = context.binding.map(
            get: { $0.absoluteString },
            set: { URL(string: $0)! }
        )

        return Group {

            if context.config.editing {
                HStack {
                    TextField("", text: stringBinding)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                    imageView
                }
            } else {
                imageView
            }
        }
    }

    func child(context: PropertyPreviewContext<URL>) -> some View {
        return URLImage(context.value) { proxy in
            proxy.image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .navigationBarTitle(context.property.name)
    }
}


