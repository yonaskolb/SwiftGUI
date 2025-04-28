import SwiftUI
import Runtime

struct ObjectView: View {

    private var name: String
    @Binding private var object: Any
    private var properties: [Property]
    private let typeInfo: TypeInfo
    private let isRoot: Bool

    @EnvironmentObject var config: Config
    @Environment(\.showRootNavTitle) var showRootNavTitle
    
    var filteredProperties: [Property] {
        properties.filter {
            config.propertyFilter($0.name) != nil
        }
    }

    init(_ binding: Binding<Any>, isRoot: Bool = false) {
        self.isRoot = isRoot
        let object = binding.wrappedValue
        self._object = binding
        self.typeInfo = try! Runtime.typeInfo(of: type(of: object))
        name = santizedType(of: object)

        properties = typeInfo.properties.compactMap {
            return try? Property(type: object, propertyInfo: $0)
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
            (Text("\(config.propertyFilter(property.name) ?? ""): ") + Text(property.typeName).bold())
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

    func link<D: View, C: View>(_ property: Property, @ViewBuilder destination:  () -> D, @ViewBuilder content: () -> C) -> some View {
        NavigationLink {
            destination()
                .environmentObject(config)
#if os(iOS)
                .navigationBarTitle(property.name)
#endif
        } label: {
            content()
        }
    }

    @ViewBuilder
    func propertyEditor(_ property: Property) -> some View {
        if let preview = config.getPreview(for: property, with: getPropertyBinding(property)) {
            if preview.config.canNavigate || preview.config.customView {
                if let childView = preview.childView {
                    link(property) {
                        childView
                    } content: {
                        propertyRow(property, axis: preview.config.axis) {
                            preview.view
                        }
                    }
                } else {
                    link(property) {
                        UnknownView(value: getPropertyBinding(property))
                    } content: {
                        propertyRow(property, axis: preview.config.axis) {
                            preview.view
                        }
                    }
                }
            } else {
                propertyRow(property, axis: preview.config.axis) {
                    preview.view
                }
            }
        } else if let value = property.value {
            link(property) {
                UnknownView(value: getPropertyBinding(property))
            } content: {
                propertyRow(property) {
                    Text(String(describing: value)).lineLimit(1)
                }
            }
        } else {
            propertyRow(property) {
                Text("nil").foregroundColor(.gray)
            }
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
        if !isRoot || showRootNavTitle {
            list
#if os(iOS)
                .navigationBarTitle(Text(name), displayMode: .inline)
#endif
        } else {
            list
        }
    }

    var list: some View {
        List(filteredProperties) { property in
            self.propertyEditor(property)
        }
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
