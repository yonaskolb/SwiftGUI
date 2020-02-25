//
//  Config.swift
//  SwiftGUI
//
//  Created by Yonas Kolb on 26/2/20.
//  Copyright © 2020 Yonas. All rights reserved.
//

import Foundation

public class Config: ObservableObject {

    @Published public var editing: Bool
    @Published public var allowEditingToggle: Bool

    public init(editing: Bool = false, allowEditingToggle: Bool = false) {
        self.editing = editing
        self.allowEditingToggle = allowEditingToggle
    }
}

