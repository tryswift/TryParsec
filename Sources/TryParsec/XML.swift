/// - ToDo: Improve more.
public enum XML
{
    /// Non-empty XML tag with associated values `(tagName, attributes, children)`.
    case element(String, [Attribute], [XML])

    /// Self-closing XML tag, e.g. `<hr />`.
    case emptyElement(String, [Attribute])

    /// `<!-- *** -->`
    case comment(String)

    /// `<!DOCTYPE *** >`
    case doctype(String)

    /// `<?xml *** ?>`
    case xmlDeclaration(String)

    /// `<? *** ?>`
    case processingInstruction(String)

    /// Text content between opening & closing XML tags.
    case text(String)

    /// XML attribute,
    /// e.g. `Attribute("target", "_blank")` for `<a target="_blank">`.
    public struct Attribute
    {
        public let name: String
        public let value: String

        public init(_ name: String, _ value: String)
        {
            self.name = name
            self.value = value
        }
    }
}

extension XML: Equatable {}

public func == (lhs: XML, rhs: XML) -> Bool
{
    switch (lhs, rhs) {
        case let (.element(l), .element(r)):
            return l.0 == r.0 && l.1 == r.1 && l.2 == r.2
        case let (.emptyElement(l), .emptyElement(r)):
            return l.0 == r.0 && l.1 == r.1
        case let (.comment(l), .comment(r)):
            return l == r
        case let (.doctype(l), .doctype(r)):
            return l == r
        case let (.xmlDeclaration(l), .xmlDeclaration(r)):
            return l == r
        case let (.processingInstruction(l), .processingInstruction(r)):
            return l == r
        case let (.text(l), .text(r)):
            return l == r
        default:
            return false
    }
}

extension XML: CustomStringConvertible
{
    public var description: Swift.String
    {
        switch self {
            case let .element(v, attrs, xmls):  return ".element(\(v), \(attrs), \(xmls))"
            case let .emptyElement(v, attrs):   return ".emptyElement(\(v), \(attrs))"
            case let .comment(v):               return ".comment(\(v))"
            case let .doctype(v):               return ".doctype(\(v))"
            case let .xmlDeclaration(v):        return ".xmlDeclaration(\(v))"
            case let .processingInstruction(v): return ".processingInstruction(\(v))"
            case let .text(v):                  return ".text(\(v))"
        }
    }
}

// MARK: XML.Attribute

extension XML.Attribute: Equatable {}

public func == (lhs: XML.Attribute, rhs: XML.Attribute) -> Bool
{
    return lhs.name == rhs.name && lhs.value == rhs.value
}

extension XML.Attribute: CustomStringConvertible
{
    public var description: Swift.String
    {
        return ".Attribute(\(self.name), \(self.value))"
    }
}
