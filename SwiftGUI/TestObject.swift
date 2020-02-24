
import Foundation

public struct TestObject {

    public var myBool: Bool = true
    public var myString: String = "hello"
    public var myInt: Int = 5
    public var myDate: Date = Date()
    public var myArray: [String] = ["one", "two"]
    public var myDictionary: [String: Int] = ["one": 1, "two": 2]
    public var myStruct: PreviewStruct = PreviewStruct()
    public var myClass: PreviewClass = PreviewClass()
    public var myURL: URL = URL(string: "http://google.com")!
    public var myAvatarURL: URL = URL(string: "https://randomuser.me/api/portraits/women/10.jpg")!

    public var myOptionalBool: Bool? = true
    public var myOptionalString: String? = "hello"
    public var myOptionalInt: Int? = 5
    public var myOptionalDate: Date? = Date()
    public var myOptionalStruct: PreviewStruct? = PreviewStruct()
    public var myOptionalClass: PreviewClass? = PreviewClass()
    public var myOptionalURL: URL? = URL(string: "http://google.com")
    public var myOptionalAvatarURL: URL? = URL(string: "https://randomuser.me/api/portraits/women/10.jpg")

    public init() {
        
    }
}

public struct PreviewStruct {
    var isCool = true
}

public class PreviewClass {
    var isCool = true
}
