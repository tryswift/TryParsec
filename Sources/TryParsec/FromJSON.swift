import Result

// MARK: decode

/// Converts JSON string to `FromJSON` value.
public func decode<FJ: FromJSON>(_ str: String) -> Result<FJ, JSON.ParseError>
{
    return parseOnly(json, str.unicodeScalars)
        .mapError { _ in .invalidJSONFormat }
        .flatMap { FJ.fromJSON($0) }
}

// MARK: FromJSON

public protocol FromJSON
{
    static func fromJSON(_ json: JSON) -> Result<Self, JSON.ParseError>
}

extension JSON: FromJSON
{
    public static func fromJSON(_ json: JSON) -> Result<JSON, JSON.ParseError>
    {
        return .success(json)
    }
}

extension String: FromJSON
{
    public static func fromJSON(_ json: JSON) -> Result<String, JSON.ParseError>
    {
        guard case let .string(v) = json else {
            return typeMismatch(json, expected: "JSON.string")
        }
        return .success(v)
    }
}

// extension DoubleType where Self: FromJSON

extension Int: FromJSON
{
    public static func fromJSON(_ json: JSON) -> Result<Int, JSON.ParseError>
    {
        guard case let .number(v) = json else {
            return typeMismatch(json, expected: "JSON.number")
        }
        return .success(Int(v))
    }
}

extension Float: FromJSON
{
    public static func fromJSON(_ json: JSON) -> Result<Float, JSON.ParseError>
    {
        guard case let .number(v) = json else {
            return typeMismatch(json, expected: "JSON.number")
        }
        return .success(Float(v))
    }
}

extension Double: FromJSON
{
    public static func fromJSON(_ json: JSON) -> Result<Double, JSON.ParseError>
    {
        guard case let .number(v) = json else {
            return typeMismatch(json, expected: "JSON.number")
        }
        return .success(v)
    }
}

extension Bool: FromJSON
{
    public static func fromJSON(_ json: JSON) -> Result<Bool, JSON.ParseError>
    {
        guard case let .bool(v) = json else {
            return typeMismatch(json, expected: "JSON.bool")
        }
        return .success(v)
    }
}

/// - Warning: Nested container is not supported.
extension Array: FromJSON // where Element: FromJSON
{
    public static func fromJSON(_ json: JSON) -> Result<[Element], JSON.ParseError>
    {
        guard case let .array(jsons) = json else {
            return typeMismatch(json, expected: "JSON.array")
        }

        var arr = [Element]()
        for json in jsons {
            // Comment-Out: HKT i.e. `where Element: FromJSON` is required
            // arr.append(Element.fromJSON(json))

            // Warning: casting fails if `Element` is another container
            if let elem = json.rawValue as? Element {
                arr.append(elem)
            }
            else {
                return .failure(.typeMismatched(expected: "\(Element.self)", actual: json.description))
            }
        }
        return .success(arr)
    }
}

/// - Warning: Nested container is not supported.
extension Dictionary: FromJSON // where Key == String, Value: FromJSON
{
    public static func fromJSON(_ json: JSON) -> Result<[Key : Value], JSON.ParseError>
    {
        guard case let .object(jsons) = json else {
            return typeMismatch(json, expected: "JSON.object")
        }

        var dict = [Key : Value]()
        for (key, json) in jsons {

            // NOTE: this guard should not exist because `Key` should always be `String`
            guard let key_ = key as? Key else {
                fatalError("Should never reach here. (Dicitonary.Key is not String)")
            }

            // Comment-Out: HKT i.e. `where Value: FromJSON` is required
            // dict[key_] = Value.fromJSON(json)

            // Warning: casting fails if `Element` is another container
            if let value = json.rawValue as? Value {
                dict[key_] = value
            }
            else {
                return .failure(.typeMismatched(expected: "\(Value.self)", actual: json.description))
            }
        }
        return .success(dict)
    }
}

// MARK: FromJSON helpers

/// Extracts `FromJSON` value for `key` from `json`.
public func !! <FJ: FromJSON>(json: JSON, key: String) -> Result<FJ, JSON.ParseError>
{
    guard case let .object(dict) = json else {
        return typeMismatch(json, expected: "JSON.object")
    }

    if let json = dict[key] {
        return FJ.fromJSON(json)
    }
    else {
        return .failure(.keyNotFound(key))
    }
}

///
/// Extracts `FromJSON` value for `key` from `json`.
///
/// - Note:
/// This is a workaround for `extension Optional`
/// where `Self` and `Wrapped` can't constrain at same time.
///
public func !! <FJ: FromJSON>(json: JSON, key: String) -> Result<FJ?, JSON.ParseError>
{
    guard case let .object(dict) = json else {
        return typeMismatch(json, expected: "JSON.object")
    }

    if let json = dict[key] {
        if json == JSON.null {
            return .success(nil)
        }
        else {
            return FJ.fromJSON(json).map { Optional($0) }
        }
    }
    else {
        return .failure(.keyNotFound(key))
    }
}

/// Optionally extracts `FromJSON` value for `key` from `json`.
public func !? <FJ: FromJSON>(json: JSON, key: String) -> Result<FJ?, JSON.ParseError>
{
    guard case let .object(dict) = json else {
        return typeMismatch(json, expected: "JSON.object")
    }

    if let json = dict[key] {
        return FJ.fromJSON(json).map { Optional($0) }
    }
    else {
        return .success(nil)
    }
}
