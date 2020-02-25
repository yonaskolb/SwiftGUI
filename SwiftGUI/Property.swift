import Foundation
import Runtime

public struct Property: Identifiable, CustomStringConvertible {

    public let typeName: String
    public let propertyInfo: PropertyInfo
    public var typeInfo: TypeInfo
    public let value: Any?

    public var isOptional: Bool { typeInfo.kind == .optional }
    public var name: String { propertyInfo.name }
    public var description: String { id }
    public var id: String { "\(name): \(typeName)" }

    public init(type: Any, propertyInfo: PropertyInfo) throws {
        self.propertyInfo = propertyInfo
        self.typeName = santizedType(of: propertyInfo.type)
        self.value = try propertyInfo.get(from: type)
        self.typeInfo = try Runtime.typeInfo(of: propertyInfo.type)
        if let value = value {
            self.typeInfo = try Runtime.typeInfo(of: Swift.type(of: value))
        }
    }
}
