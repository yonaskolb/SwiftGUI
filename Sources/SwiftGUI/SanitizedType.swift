import Foundation

public func santizedType(from string: String) -> String {
    return string
        .replacingOccurrences(of: "Array<(.+)>", with: "[$1]", options: [.regularExpression])
        .replacingOccurrences(of: "Array<(.+)>", with: "[$1]", options: [.regularExpression])
        .replacingOccurrences(of: "Array<(.+)>", with: "[$1]", options: [.regularExpression])
        .replacingOccurrences(of: "Dictionary<(.+), (.+)>", with: "[$1: $2]", options: [.regularExpression])
        .replacingOccurrences(of: "Dictionary<(.+), (.+)>", with: "[$1: $2]", options: [.regularExpression])
        .replacingOccurrences(of: "Dictionary<(.+), (.+)>", with: "[$1: $2]", options: [.regularExpression])
        .replacingOccurrences(of: "Optional<(.+)>", with: "$1?", options: [.regularExpression])
        .replacingOccurrences(of: "Optional<(.+)>", with: "$1?", options: [.regularExpression])
        .replacingOccurrences(of: "Optional<(.+)>", with: "$1?", options: [.regularExpression])
}

public func santizedType(of type: Any.Type) -> String {
    return santizedType(from: String(describing: type))
}

public func santizedType(of object: Any) -> String {
    return santizedType(of: type(of: object))
}
