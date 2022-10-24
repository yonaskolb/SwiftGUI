import SwiftUI
import Runtime

struct ObjectView: View {

    private var name: String
    @Binding private var object: Any
    private var properties: [Property]
    private let typeInfo: TypeInfo

    @EnvironmentObject var config: Config

    init(_ binding: Binding<Any>) {
        let object = binding.wrappedValue
        self._object = binding
        self.typeInfo = try! Runtime.typeInfo(of: type(of: object))
        name = santizedType(of: object)

        properties = typeInfo.properties.compactMap {
            try? Property(type: object, propertyInfo: $0)
        }
    }

    func getPropertyBinding(_ property: Property) -> Binding<Any> {
        Binding(
            get: { try! property.propertyInfo.get(from: self.object) },
            set: { try! property.propertyInfo.set(value: $0, on: &self.object) }
        )
    }

    func propertyRow<V: View>(_ property: Property, axis: Axis = .horizontal, @ViewBuilder content: () -> V) -> some View {

        func info() -> some View {
            (Text("\(property.name): ") + Text(property.typeName).bold())
            .lineLimit(1)
        }

        let contentView = content()
            .disabled(!config.editing)

        return Group {
            if axis == .horizontal {
                HStack {
                    info()
                        .layoutPriority(1)
                    Spacer()
                    contentView
                        .lineLimit(1)
                }
            } else {
                VStack(alignment: .leading) {
                    info()
                    contentView
                }
            }
        }
    }

    func propertyEditor(_ property: Property) -> AnyView {

        func navigation<D: View, C: View>(_ destination: D, @ViewBuilder content: () -> C) -> AnyView {
            let destinationView = destination
                .environmentObject(config)
#if os(iOS)
                .navigationBarTitle(property.name)
#endif
            return NavigationLink(destination: destinationView) {
               content()
                //.navigationBarItems(trailing: editButton)
            }.anyView
        }
        let propertyBinding = getPropertyBinding(property)
        if let preview = config.getPreview(for: property, with: propertyBinding) {
            if preview.config.canNavigate || preview.config.customView {
                if let childView = preview.childView {
                    return navigation(childView) {
                        propertyRow(property, axis: preview.config.axis) {
                            preview.view
                        }
                    }
                } else {
                    return navigation(UnknownView(value: propertyBinding)) {
                        propertyRow(property, axis: preview.config.axis) {
                            preview.view
                        }
                    }
                }
            } else {
                return propertyRow(property, axis: preview.config.axis) {
                    preview.view
                }.anyView
            }
        } else if let value = property.value {
            return navigation(UnknownView(value: propertyBinding)) {
                propertyRow(property) {
                    Text(String(describing: value)).lineLimit(1).anyView
                }
            }
        } else {
            return propertyRow(property) {
                Text("nil").foregroundColor(.gray).anyView
            }.anyView
        }
    }

    var editButton: some View {
        Group {
            if config.allowEditingToggle {
                Button(config.editing ? "View" : "Edit") {
                    withAnimation { self.config.editing.toggle() }
                }
            } else {
                EmptyView()
            }
        }
    }

    var body: some View {
        List(properties) { property in
            self.propertyEditor(property)
        }
#if os(iOS)
        .navigationBarTitle(Text(name), displayMode: .inline)
#endif
        //.navigationBarItems(trailing: editButton)
    }
}

struct EditView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            NavigationView {
                ObjectView(.constant(TestObject()))
                    .environmentObject(Config(editing: true))
            }
        }
    }
}
