import Result

// MARK: decode

/// Converts JSON string to `FromJSON` value.
public func decode<FJ: FromJSON>(str: String) -> Result<FJ, JSON.ParseError>
{
    return parseOnly(json, str.unicodeScalars)
        .mapError { _ in .InvalidJSONFormat }
        .flatMap { FJ.fromJSON($0) }
}

// MARK: FromJSON

public protocol FromJSON
{
    static func fromJSON(json: JSON) -> Result<Self, JSON.ParseError>
}

extension JSON: FromJSON
{
    public static func fromJSON(json: JSON) -> Result<JSON, JSON.ParseError>
    {
        return .Success(json)
    }
}

extension String: FromJSON
{
    public static func fromJSON(json: JSON) -> Result<String, JSON.ParseError>
    {
        guard case let .String(v) = json else {
            return typeMismatch(json, expected: "JSON.String")
        }
        return .Success(v)
    }
}

// extension DoubleType where Self: FromJSON

extension Int: FromJSON
{
    public static func fromJSON(json: JSON) -> Result<Int, JSON.ParseError>
    {
        guard case let .Number(v) = json else {
            return typeMismatch(json, expected: "JSON.Number")
        }
        return .Success(Int(v))
    }
}

extension Float: FromJSON
{
    public static func fromJSON(json: JSON) -> Result<Float, JSON.ParseError>
    {
        guard case let .Number(v) = json else {
            return typeMismatch(json, expected: "JSON.Number")
        }
        return .Success(Float(v))
    }
}

extension Double: FromJSON
{
    public static func fromJSON(json: JSON) -> Result<Double, JSON.ParseError>
    {
        guard case let .Number(v) = json else {
            return typeMismatch(json, expected: "JSON.Number")
        }
        return .Success(v)
    }
}

extension Bool: FromJSON
{
    public static func fromJSON(json: JSON) -> Result<Bool, JSON.ParseError>
    {
        guard case let .Bool(v) = json else {
            return typeMismatch(json, expected: "JSON.Bool")
        }
        return .Success(v)
    }
}

/// - Warning: Nested container is not supported.
extension Array: FromJSON // where Element: FromJSON
{
    public static func fromJSON(json: JSON) -> Result<[Element], JSON.ParseError>
    {
        guard case let .Array(jsons) = json else {
            return typeMismatch(json, expected: "JSON.Array")
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
                return .Failure(.TypeMismatched(expected: "\(Element.self)", actual: json.description))
            }
        }
        return .Success(arr)
    }
}

/// - Warning: Nested container is not supported.
extension Dictionary: FromJSON // where Key == String, Value: FromJSON
{
    public static func fromJSON(json: JSON) -> Result<[Key : Value], JSON.ParseError>
    {
        guard case let .Object(jsons) = json else {
            return typeMismatch(json, expected: "JSON.Object")
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
                return .Failure(.TypeMismatched(expected: "\(Value.self)", actual: json.description))
            }
        }
        return .Success(dict)
    }
}

// MARK: FromJSON helpers

/// Extracts `FromJSON` value for `key` from `json`.
public func !! <FJ: FromJSON>(json: JSON, key: String) -> Result<FJ, JSON.ParseError>
{
    guard case let .Object(dict) = json else {
        return typeMismatch(json, expected: "JSON.Object")
    }

    if let json = dict[key] {
        return FJ.fromJSON(json)
    }
    else {
        return .Failure(.KeyNotFound(key))
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
    guard case let .Object(dict) = json else {
        return typeMismatch(json, expected: "JSON.Object")
    }

    if let json = dict[key] {
        if json == JSON.Null {
            return .Success(nil)
        }
        else {
            return FJ.fromJSON(json).map { Optional($0) }
        }
    }
    else {
        return .Failure(.KeyNotFound(key))
    }
}

/// Optionally extracts `FromJSON` value for `key` from `json`.
public func !? <FJ: FromJSON>(json: JSON, key: String) -> Result<FJ?, JSON.ParseError>
{
    guard case let .Object(dict) = json else {
        return typeMismatch(json, expected: "JSON.Object")
    }

    if let json = dict[key] {
        return FJ.fromJSON(json).map { Optional($0) }
    }
    else {
        return .Success(nil)
    }
}
