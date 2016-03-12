// MARK: encode

/// Converts `input` (which conforms to `ToJSON` protocol) to JSON string.
public func encode<TJ: ToJSON>(input: TJ) -> String
{
    return TJ.toJSON(input).jsonString
}

// MARK: ToJSON

public protocol ToJSON
{
    static func toJSON(value: Self) -> JSON
}

extension JSON: ToJSON
{
    public static func toJSON(value: JSON) -> JSON
    {
        return value
    }
}

extension String: ToJSON
{
    public static func toJSON(value: String) -> JSON
    {
        return JSON.String(value)
    }
}

extension Int: ToJSON
{
    public static func toJSON(value: Int) -> JSON
    {
        return JSON.Number(value.double)
    }
}

extension Float: ToJSON
{
    public static func toJSON(value: Float) -> JSON
    {
        return JSON.Number(value.double)
    }
}

extension Double: ToJSON
{
    public static func toJSON(value: Double) -> JSON
    {
        return JSON.Number(value.double)
    }
}

extension Bool: ToJSON
{
    public static func toJSON(value: Bool) -> JSON
    {
        return JSON.Bool(value)
    }
}

/// - Warning: Nested container is not supported.
extension Array: ToJSON // where Element: ToJSON
{
    public static func toJSON(arr: [Element]) -> JSON
    {
        return _reflectToJSON(arr)
    }
}

/// - Warning: Nested container is not supported.
extension Dictionary: ToJSON // where Key == String, Value: ToJSON
{
    public static func toJSON(dict: Dictionary) -> JSON
    {
        return _reflectToJSON(dict)
    }
}

extension Optional /*: ToJSON */ where Wrapped: ToJSON
{
    public static func toJSON(value: Optional) -> JSON
    {
        if let value = value {
            return Wrapped.toJSON(value)
        }
        else {
            return JSON.Null
        }
    }
}

///
/// Workaround for `ToJSON`-container types (Array/Dictionary)
/// to let their elements also behave as `ToJSON` instance by using Mirror (reflection).
///
/// - TODO: Remove this once HKT is supported.
///
private func _reflectToJSON(anyValue: Any) -> JSON
{
    //
    // Comment-Out & Limitation & FIXME:
    //
    // `anyValue` can't be convert to `ToJSON` protocol due to compile error:
    //
    //   "Error: Protocol 'ToJSON' can only be used as a generic constraint because it has Self or associated type requirements"
    //
    // This means, user-custom `ToJSON` instance e.g. `extension NSURL: ToJSON`
    // which is wrapped into some Array/Dictionary container e.g. `let urls: [NSURL]`
    // **can't be treated as `ToJSON` instance** (due to lack of HKT support).
    //
    // Therefore, current `ToJSON` is limited in its usage in Swift 2,
    // so consider using some full-reflection alternatives
    // e.g. https://github.com/inamiy/ToAnyObject for any types.
    //
//    // use user-implemented `toJSON()` if possible
//    if let anyValue = anyValue as? ToJSON {
//        return ToJSON.toJSON(anyValue)
//    }

    let mirror = Mirror(reflecting: anyValue)

    switch mirror.displayStyle {

        case .Some(.Optional):

            return mirror.children.first.map { _reflectToJSON($0.1) } ?? JSON.Null

        //
        // Comment-Out:
        // This should never reach here because subModel (struct or class) must be
        // wrapped with some container (Array/Dictionary) before
        // (`_reflectToJSON()` is used for only those cases).
        //
        // If mirror it, subModel's `toJSON` will never be used.
        //
//        case .Some(.Struct), .Some(.Class):
//
//            var dict = [String : JSON]()
//            for (key, value) in mirror.children {
//                guard let key = key else { continue }
//                dict[key] = _reflectToJSON(value)
//            }
//            return JSON.Object(dict)

        case .Some(.Collection):    // e.g. Array

            let jsons = mirror.children.map { _reflectToJSON($1) }
            return JSON.Array(jsons)

        case .Some(.Dictionary):    // e.g. Dictionary

            var dict: [String : JSON] = [:]
            for (_, keyValue) in mirror.children {

                if let (key, json) = keyValue as? (String, JSON) {
                    dict[key] = json
                }
                // NOTE: ObjC-type-tuple casting i.e. `keyValue as? (String, AnyObject)` doesn't work
                else if let (key, value) = keyValue as? (String, Any) {
                    dict[key] = _reflectToJSON(value)
                }
                else {
                    fatalError("`_reflectToJSON()` failed. (Using ObjC types inside Dictionary? Internal value was \(keyValue).)")
                }
            }
            return JSON.Object(dict)

        default:

            // nearly equivalent to `return ToJSON.toJSON(anyValue)` for primitive types
            switch anyValue {
                case let value as JSON:
                    return value
                case let value as String:
                    return String.toJSON(value)
                case let value as DoubleType:
                    return Double.toJSON(value.double)
                case let value as Bool:
                    return Bool.toJSON(value)
                case is ():
                    return JSON.Null
                default:
                    fatalError("`_reflectToJSON()` failed. (Using custom `ToJSON` instance inside Array/Dictionary? Internal value was \(anyValue).)")
            }
    }

}

// MARK: ToJSON helpers

/// Helper method to convert array of `(key, jsonValue)` to `JSON.Object`.
public func toJSONObject(keyValues: [(String, JSON)]) -> JSON
{
    return JSON.Object(toDict(keyValues))
}

/// Creates key-JSONValue tuple from key-rawValue.
public func ~ <TJ: ToJSON>(key: String, value: TJ) -> (String, JSON)
{
    return (key, TJ.toJSON(value))
}

/// Workaround for `extension Optional`
/// where `Self` and `Wrapped` can't constrain at same time.
public func ~ <TJ: ToJSON>(key: String, value: TJ?) -> (String, JSON)
{
    return (key, Optional.toJSON(value))
}
