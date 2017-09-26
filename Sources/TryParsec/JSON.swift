// MARK: JSON

public enum JSON
{
    case string(Swift.String)
    case number(Double)
    case bool(Swift.Bool)
    case null
    case array([JSON])
    case object([Swift.String : JSON])
}

// MARK: RawRepresentable

extension JSON: RawRepresentable
{
    public init?(rawValue: Any)
    {
        switch rawValue {
            case let v as Swift.String:
                self = .string(v)
            case let v as DoubleType:
                self = .number(v.double)
            case let v as Swift.Bool:
                self = .bool(v)
            case is ():
                self = .null
            case let v as [JSON]:
                self = .array(v)
            case let v as [Swift.String : JSON]:
                self = .object(v)
            default:
                return nil
        }
    }

    public var rawValue: Any
    {
        switch self {
            case let .string(v): return v
            case let .number(v): return v
            case let .bool(v):   return v
            case .null:          return ""
            case let .array(v):  return v
            case let .object(v): return v
        }
    }
}

// MARK: Equatable

extension JSON: Equatable {}

public func == (lhs: JSON, rhs: JSON) -> Bool
{
    switch (lhs, rhs) {
        case let (.string(l), .string(r)):
            return l == r
        case let (.number(l), .number(r)):
            return l == r
        case let (.bool(l), .bool(r)):
            return l == r
        case (.null, .null):
            return true
        case let (.array(l), .array(r)):
            return l == r
        case let (.object(l), .object(r)):
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
            case let .string(v):    return ".string(\(v))"
            case let .number(v):    return ".number(\(v))"
            case let .bool(v):      return ".bool(\(v))"
            case .null:             return ".null"
            case let .array(v):     return ".array(\(v.description))"
            case let .object(v):    return ".object(\(v.description))"
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
            case let .string(v): return v
            default: return nil
        }
    }

    public var rawNumber: Double?
    {
        switch self {
            case let .number(v): return v
            default: return nil
        }
    }

    public var rawBool: Swift.Bool?
    {
        switch self {
            case let .bool(v): return v
            default: return nil
        }
    }

    public var rawNull: ()?
    {
        switch self {
            case .null: return ()
            default: return nil
        }
    }

    public var rawArray: [JSON]?
    {
        switch self {
            case let .array(v): return v
            default: return nil
        }
    }

    public var rawObject: [Swift.String : JSON]?
    {
        switch self {
            case let .object(v): return v
            default: return nil
        }
    }

    public var jsonString: Swift.String
    {
        switch self {
            case let .string(v):    return "\"\(v)\""
            case let .number(v):    return "\(v)"
            case let .bool(v):      return "\(v)"
            case .null:             return "null"
            case let .array(v):
                let valuesString = v.reduce("") {
                    ($0 == "" ? "" : $0 + ", ") + $1.jsonString
                }
                return "[ " + valuesString + " ]"
            case let .object(v):
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
    public enum ParseError: Error
    {
        case invalidJSONFormat
        case typeMismatched(expected: Swift.String, actual: Swift.String)
        case keyNotFound(Swift.String)
    }
}
