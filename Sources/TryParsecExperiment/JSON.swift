// MARK: JSON

public enum JSON
{
    case String(Swift.String)
    case Number(Double)
    case Bool(Swift.Bool)
    case Null
    case Array([JSON])
    case Object([Swift.String : JSON])
}

// MARK: RawRepresentable

extension JSON: RawRepresentable
{
    public init?(rawValue: Any)
    {
        switch rawValue {
            case let v as Swift.String:
                self = .String(v)
            case let v as DoubleType:
                self = .Number(v.double)
            case let v as Swift.Bool:
                self = .Bool(v)
            case is ():
                self = .Null
            case let v as [JSON]:
                self = .Array(v)
            case let v as [Swift.String : JSON]:
                self = .Object(v)
            default:
                return nil
        }
    }

    public var rawValue: Any
    {
        switch self {
            case let .String(v): return v
            case let .Number(v): return v
            case let .Bool(v):   return v
            case let .Null(v):   return v
            case let .Array(v):  return v
            case let .Object(v): return v
        }
    }
}

// MARK: Equatable

extension JSON: Equatable {}

public func == (lhs: JSON, rhs: JSON) -> Bool
{
    switch (lhs, rhs) {
        case let (.String(l), .String(r)):
            return l == r
        case let (.Number(l), .Number(r)):
            return l == r
        case let (.Bool(l), .Bool(r)):
            return l == r
        case (.Null, .Null):
            return true
        case let (.Array(l), .Array(r)):
            return l == r
        case let (.Object(l), .Object(r)):
            return l == r
        default:
            return false
    }
}

// MARK: CustomStringConvertible

extension JSON: CustomStringConvertible
{
    public var description: Swift.String
    {
        switch self {
            case let .String(v):    return ".String(\(v))"
            case let .Number(v):    return ".Number(\(v))"
            case let .Bool(v):      return ".Bool(\(v))"
            case .Null:             return ".Null"
            case let .Array(v):     return ".Array(\(v.description))"
            case let .Object(v):    return ".Object(\(v.description))"
        }
    }
}

// MARK: Accessors

extension JSON
{
    public subscript(index: Int) -> JSON?
    {
        return self.rawArray?[index]
    }

    public subscript(key: Swift.String) -> JSON?
    {
        return self.rawObject?[key]
    }

    public var rawString: Swift.String?
    {
        switch self {
            case let .String(v): return v
            default: return nil
        }
    }

    public var rawNumber: Double?
    {
        switch self {
            case let .Number(v): return v
            default: return nil
        }
    }

    public var rawBool: Swift.Bool?
    {
        switch self {
            case let .Bool(v): return v
            default: return nil
        }
    }

    public var rawNull: ()?
    {
        switch self {
            case .Null: return ()
            default: return nil
        }
    }

    public var rawArray: [JSON]?
    {
        switch self {
            case let .Array(v): return v
            default: return nil
        }
    }

    public var rawObject: [Swift.String : JSON]?
    {
        switch self {
            case let .Object(v): return v
            default: return nil
        }
    }

    public var jsonString: Swift.String
    {
        switch self {
            case let .String(v):    return "\"\(v)\""
            case let .Number(v):    return "\(v)"
            case let .Bool(v):      return "\(v)"
            case .Null:             return "null"
            case let .Array(v):
                let valuesString = v.reduce("") {
                    ($0 == "" ? "" : $0 + ", ") + $1.jsonString
                }
                return "[ " + valuesString + " ]"
            case let .Object(v):
                let keyValuesString = v.reduce("") {
                    ($0 == "" ? "\"" : $0 + ", \"") + $1.0 + "\" : " + $1.1.jsonString
                }
                return "{ " + keyValuesString + " }"
        }
    }
}

// MARK: JSON.ParseError

extension JSON
{
    public enum ParseError: ErrorType
    {
        case InvalidJSONFormat
        case TypeMismatched(expected: Swift.String, actual: Swift.String)
        case KeyNotFound(Swift.String)
    }
}
