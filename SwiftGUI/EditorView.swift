import SwiftUI
import URLImage
import Runtime

public struct EditorView: View {

    private var name: String
    @Binding private var object: Any
    private var properties: [Property]
    private let typeInfo: TypeInfo

    public init<T>(_ binding: Binding<T>) {
        let anyBinding = binding.map(
        get: { $0 as Any },
        set: { $0 as! T })
        self.init(anyBinding: anyBinding)
    }

    init(anyBinding binding: Binding<Any>) {
        let object = binding.wrappedValue
        self._object = binding
        self.typeInfo = try! Runtime.typeInfo(of: type(of: object))
        name = santizedType(of: object)

        properties = typeInfo.properties.map {
            Property(type: object, propertyInfo: $0)
        }
        print("\n\(name) - \(properties.count) props:\n\t\(properties.map(\.id).joined(separator: "\n\t"))")
    }

    func binding<T>(_ property: PropertyInfo) -> Binding<T> {
        Binding(
            get: { try! property.get(from: self.object) as T },
            set: { try! property.set(value: $0, on: &self.object) }
        )
    }

    func propertyRow<V: View>(_ property: Property, simple: Bool, content: () -> V) -> AnyView {
        let info = (
            Text("\(property.name): ") +
            Text(property.typeName)
                .bold()
        )
        .lineLimit(1)

        if simple {
            return HStack {
                info
                Spacer()
                content()
            }.anyView
        } else {
            return VStack(alignment: .leading) {
                info
                content()
            }.anyView
        }
    }

    func propertyEditor(_ property: Property) -> AnyView {
        switch property.value {
        case is String:
            return propertyRow(property, simple: false) {
                TextField("", text: binding(property.propertyInfo))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        case is Bool:
            return propertyRow(property, simple: true) {
                Toggle("", isOn: binding(property.propertyInfo))
            }
        case is Date:
            return propertyRow(property, simple: false) {
                DatePicker("", selection: binding(property.propertyInfo))
                    .datePickerStyle(DefaultDatePickerStyle())
            }
        case is Int:
            let intBinding = (binding(property.propertyInfo) as Binding<Int>)
                .map(
                    get: { $0.description },
                    set: { Int($0) ?? 0 }
            )
            return propertyRow(property, simple: true) {
                TextField("", text: intBinding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
        case let url as URL:
            if property.name.lowercased().contains("picture") || property.name.lowercased().contains("avatar") {
                let image = URLImage(url) { proxy in
                    proxy.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .navigationBarTitle(property.name)
                return NavigationLink(destination: image) {
                    propertyRow(property, simple: true) {
                        HStack {
                            Spacer()
                            URLImage(url) { proxy in
                                proxy.image
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .aspectRatio(contentMode: .fill)
                                    .border(Color.gray, width: 1)
                            }
                        }
                    }
                }.anyView
            } else {
                let urlBinding = (binding(property.propertyInfo) as Binding<URL>)
                    .map(
                        get: { $0.absoluteString },
                        set: { URL(string: $0)! }
                )
                return propertyRow(property, simple: false) {
                    TextField("", text: urlBinding)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                }
            }
        case let value as [Any]:

            struct ArrayItem: Identifiable {
                let type: String
                let item: Any
                var id: String { type }
            }

            let items = value.map {
                ArrayItem(type: String(describing: $0), item: $0)
            }
            let list = List(items) { item in
                Text(String(describing: item.item)).lineLimit(1)
            }
            .navigationBarTitle(property.id)
            return NavigationLink(destination: list) {
                propertyRow(property, simple: true) {
                    Text(value.count.description)
                }
            }.anyView

        case let value as [String: Any]:
            return propertyRow(property, simple: true) {
                Text(value.count.description)
            }
        default:
            if property.typeInfo.kind == .struct || property.typeInfo.kind == .class {
                let objectBinding = binding(property.propertyInfo) as Binding<Any>
                let editor = EditorView(anyBinding: objectBinding)
                    .navigationBarTitle(property.id)
                return NavigationLink(destination: editor) {
                    propertyRow(property, simple: true) { EmptyView() }
                }.anyView
            } else {
                return propertyRow(property, simple: true) {
                    Text(String(describing: property.value)).lineLimit(1)
                }
            }
        }
    }

    public var body: some View {
        List(properties) { property in
            self.propertyEditor(property)
        }.navigationBarTitle(name)
    }
}

struct EditView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            NavigationView {
                EditorView(.constant(TestObject()))
            }
        }
    }
}
