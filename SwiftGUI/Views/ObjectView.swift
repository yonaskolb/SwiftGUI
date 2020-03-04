import SwiftUI
import URLImage
import Runtime

struct ObjectView: View {

    private var name: String
    @Binding private var object: Any
    private var properties: [Property]
    private let typeInfo: TypeInfo

    @EnvironmentObject var config: Config

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    init(_ binding: Binding<Any>) {
        let object = binding.wrappedValue
        self._object = binding
        self.typeInfo = try! Runtime.typeInfo(of: type(of: object))
        name = santizedType(of: object)

        properties = typeInfo.properties.compactMap {
            try? Property(type: object, propertyInfo: $0)
        }
    }

    func binding<T>(_ property: Property) -> Binding<T> {
        Binding(
            get: { try! property.propertyInfo.get(from: self.object) as T },
            set: { try! property.propertyInfo.set(value: $0, on: &self.object) }
        )
    }

    func propertyRow<V: View>(_ property: Property, simple: Bool, @ViewBuilder content: () -> V) -> AnyView {
        let info = (
            Text("\(property.name): ") +
                Text(property.typeName)
                    .bold()
            )
            .lineLimit(1)

        if simple || !config.editing {
            return HStack {
                info
                    .layoutPriority(1)
                Spacer()
                content()
                    .disabled(!config.editing)
                    .lineLimit(1)
            }.anyView
        } else {
            return VStack(alignment: .leading) {
                info
                content()
                    .disabled(!config.editing)
            }.anyView
        }
    }

    func propertyEditor(_ property: Property) -> AnyView {
        if let view = config.getPropertyRenderer(for: property) {
            return view
        }
        switch property.value {
        case let string as String:
            return propertyRow(property, simple: false) {
                if config.editing {
                    TextField("", text: binding(property))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(string)
                }
            }
        case let bool as Bool:
            return propertyRow(property, simple: true) {
                if config.editing {
                    Toggle("", isOn: binding(property))
                } else {
                    Text(bool.description)
                }
            }
        case let date as Date:
            return propertyRow(property, simple: false) {
                if config.editing {
                    DatePicker("", selection: binding(property))
                        .datePickerStyle(DefaultDatePickerStyle())
                } else {
                    Text(Self.dateFormatter.string(from: date))
                }
            }
        case let value as Int:
            let intBinding = (binding(property) as Binding<Int>)
                .map(
                    get: { $0.description },
                    set: { Int($0) ?? 0 }
            )
            return propertyRow(property, simple: true) {
                if config.editing {
                    HStack() {
                        TextField("", text: intBinding)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        HStack(spacing: 2) {
                            Button(action: {
                                try! property.propertyInfo.set(value: (property.propertyInfo.get(from: self.object) as Int) - 1, on: &self.object)
                            }) { Image(systemName: "chevron.down.square") }
                            Button(action: {
                                try! property.propertyInfo.set(value: (property.propertyInfo.get(from: self.object) as Int) + 1, on: &self.object)
                            }) { Image(systemName: "chevron.up.square") }
                        }.font(.system(size: 24))
                    }
                } else {
                    Text(value.description)
                }
            }
        case let url as URL:
            let urlBinding = (binding(property) as Binding<URL>)
                .map(
                    get: { $0.absoluteString },
                    set: { URL(string: $0)! }
            )
            let imageNames: [String] = [
                "picture",
                "profilepic",
                "avatar",
                "profileimage",
            ]
            let isImageURL = imageNames.contains { property.name.lowercased().contains($0.lowercased()) }
            if isImageURL {
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
                    propertyRow(property, simple: false) {
                        if config.editing {
                            HStack {
                                TextField("", text: urlBinding)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.URL)
                                imageView
                            }
                        } else {
                            imageView
                        }
                    }
                }.anyView
            } else {
                return Button(action: { UIApplication.shared.open(url) }) {
                    propertyRow(property, simple: false) {
                        if config.editing {
                            TextField("", text: urlBinding)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.URL)
                        } else {
                            Text(url.absoluteString)
                        }
                    }
                }.anyView
            }
        case let value as [Any]:

            let arrayView = ArrayView(array: binding(property))
            .navigationBarTitle(property.id)
            
            return NavigationLink(destination: arrayView) {
                propertyRow(property, simple: true) {
                    Text(value.count.description)
                }
            }.anyView

        case let value as [String: Any]:
            return propertyRow(property, simple: true) {
                Text(value.count.description)
            }
        default:
            if let value = property.value {
                let nonOptionalBinding = (binding(property) as Binding<Any?>).map(get: { $0.unsafelyUnwrapped }, set: { $0 })

                if property.typeInfo.kind == .struct || property.typeInfo.kind == .class{
                    let view = ObjectView(nonOptionalBinding)
                        .navigationBarTitle(property.id)
                    return NavigationLink(destination: view) {
                        propertyRow(property, simple: true) { EmptyView() }
                    }.anyView
                } else if property.typeInfo.kind == .enum {
                    let view = EnumView(nonOptionalBinding)
                        .navigationBarTitle(property.id)
                        return NavigationLink(destination: view) {
                            propertyRow(property, simple: true) { Text(String(describing: value)).lineLimit(1) }
                        }.anyView
                } else {
                    return propertyRow(property, simple: true) {
                        Text(String(describing: property.value)).lineLimit(1)
                    }
                }
            } else {
                return propertyRow(property, simple: true) {
                    Text(String(describing: property.value)).lineLimit(1)
                }
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
        List(properties) { property in
            self.propertyEditor(property)
        }
        .navigationBarTitle(Text(name), displayMode: .inline)
        .navigationBarItems(trailing: editButton)
    }
}

struct EditView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            NavigationView {
                ObjectView(.constant(TestObject()))
            }
        }
    }
}
