
import Foundation

public struct TestObject {

    public var myBool: Bool = true
    public var myString: String = "hello"
    public var myInt: Int = 5
    public var myDate: Date = Date()
    public var myArray: [String] = ["one", "two"]
    public var myObjectArray: [TestStruct] = [TestStruct(name: "Sarah"), TestStruct(name: "Jade")]
    public var myDictionary: [String: Int] = ["one": 1, "two": 2]
    public var myURL: URL = URL(string: "http://google.com")!
    public var myAvatarURL: URL = URL(string: "https://randomuser.me/api/portraits/women/10.jpg")!
    public var myStruct: TestStruct = TestStruct()
    public var myClass: TestClass = TestClass()
    public var myRawEnum: TestRawEnum = .one
    public var myIntEnum: TestAssociatedEnum = .int(1)
    public var myObjectEnum: TestAssociatedEnum = .object(TestStruct())
    public var myMultiEnum: TestAssociatedEnum = .multi(true, object: TestStruct())

    public var myOptionalBool: Bool? = true
    public var myOptionalString: String? = "hello"
    public var myOptionalInt: Int? = 5
    public var myOptionalDate: Date? = Date()
    public var myOptionalURL: URL? = URL(string: "http://google.com")
    public var myOptionalAvatarURL: URL? = URL(string: "https://randomuser.me/api/portraits/women/10.jpg")
    public var myOptionalStruct: TestStruct? = TestStruct()
    public var myOptionalClass: TestClass? = TestClass()
    public var myOptionalRawEnum: TestRawEnum? = .one

    public var myNilBool: Bool?
    public var myNilString: String?
    public var myNilInt: Int?
    public var myNilDate: Date?
    public var myNilURL: URL?
    public var myNilAvatarURL: URL?
    public var myNilStruct: TestStruct?
    public var myNilClass: TestClass?

    public init() {
        
    }
}

public struct TestStruct: CustomStringConvertible {
    var name: String = "John"
    public var description: String { "name: \(name)" }
}

public class TestClass {
    var name: String = "John"
}

public enum TestRawEnum: Int {
    case one
    case two
}

public enum TestAssociatedEnum {
    case int(Int)
    case object(TestStruct)
    case multi(Bool, object: TestStruct)
}
