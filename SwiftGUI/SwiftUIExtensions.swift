import Foundation
import SwiftUI

extension View {

    var anyView: AnyView {
        AnyView(self)
    }
}

extension Binding {

    func map<T>(get: @escaping (Value) -> T, set: @escaping (T) -> Value) -> Binding<T> {
        Binding<T>(
            get: { get(self.wrappedValue) },
            set: { self.wrappedValue = set($0) }
        )
    }
}
