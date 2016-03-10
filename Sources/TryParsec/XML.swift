/// - ToDo: Improve more.
public enum XML
{
    /// Non-empty XML tag with associated values `(tagName, attributes, children)`.
    case Element(String, [Attribute], [XML])

    /// Self-closing XML tag, e.g. `<hr />`.
    case EmptyElement(String, [Attribute])

    /// `<!-- *** -->`
    case Comment(String)

    /// `<!DOCTYPE *** >`
    case DOCTYPE(String)

    /// `<?xml *** ?>`
    case XMLDeclaration(String)

    /// `<? *** ?>`
    case ProcessingInstruction(String)

    /// Text content between opening & closing XML tags.
    case Text(String)

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
        case let (.Element(l), .Element(r)):
            return l.0 == r.0 && l.1 == r.1 && l.2 == r.2
        case let (.EmptyElement(l), .EmptyElement(r)):
            return l.0 == r.0 && l.1 == r.1
        case let (.Comment(l), .Comment(r)):
            return l == r
        case let (.DOCTYPE(l), .DOCTYPE(r)):
            return l == r
        case let (.XMLDeclaration(l), .XMLDeclaration(r)):
            return l == r
        case let (.ProcessingInstruction(l), .ProcessingInstruction(r)):
            return l == r
        case let (.Text(l), .Text(r)):
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
            case let .Element(v, attrs, xmls):  return ".Element(\(v), \(attrs), \(xmls))"
            case let .EmptyElement(v, attrs):   return ".EmptyElement(\(v), \(attrs))"
            case let .Comment(v):               return ".Comment(\(v))"
            case let .DOCTYPE(v):               return ".DOCTYPE(\(v))"
            case let .XMLDeclaration(v):        return ".XMLDeclaration(\(v))"
            case let .ProcessingInstruction(v): return ".ProcessingInstruction(\(v))"
            case let .Text(v):                  return ".Text(\(v))"
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
