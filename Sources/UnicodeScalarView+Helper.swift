extension String.UnicodeScalarView: StringLiteralConvertible
{
    public init(stringLiteral value: String)
    {
        self = value.unicodeScalars
    }

    public init(extendedGraphemeClusterLiteral value: String)
    {
        self = value.unicodeScalars
    }

    public init(unicodeScalarLiteral value: String)
    {
        self = value.unicodeScalars
    }
}

extension String.UnicodeScalarView: ArrayLiteralConvertible
{
    public init(arrayLiteral elements: UnicodeScalar...)
    {
        self.init()
        self.appendContentsOf(elements)
    }
}

extension String.UnicodeScalarView: Equatable {}

public func == (lhs: String.UnicodeScalarView, rhs: String.UnicodeScalarView) -> Bool
{
    return String(lhs) == String(rhs)
}

// MARK: Functions

public func isDigit(c: UnicodeScalar) -> Bool
{
    return "0"..."9" ~= c
}

public func isHexDigit(c: UnicodeScalar) -> Bool
{
    return "0"..."9" ~= c || "a"..."f" ~= c || "A"..."F" ~= c
}

public func isLowerAlphabet(c: UnicodeScalar) -> Bool
{
    return "a"..."z" ~= c
}

public func isUpperAlphabet(c: UnicodeScalar) -> Bool
{
    return "A"..."Z" ~= c
}

public func isAlphabet(c: UnicodeScalar) -> Bool
{
    return isLowerAlphabet(c) || isUpperAlphabet(c)
}

private let _spaces: String.UnicodeScalarView = [ " ", "\t", "\n", "\r" ]

public func isSpace(c: UnicodeScalar) -> Bool
{
    return _spaces.contains(c)
}

/// UnicodeScalar validation using array of `ClosedInterval`.
public func isInClosedIntervals(c: UnicodeScalar, _ closedIntervals: ClosedInterval<UInt32>...) -> Bool
{
    for closedInterval in closedIntervals {
        if closedInterval.contains(c.value) {
            return true
        }
    }
    return false
}

/// Removes head & tail whitespaces.
public func trim(cs: String.UnicodeScalarView) -> String.UnicodeScalarView
{
    return _trim(cs, true, true)
}

/// Removes head whitespace.
public func trimStart(cs: String.UnicodeScalarView) -> String.UnicodeScalarView
{
    return _trim(cs, true, false)
}

/// Removes tail whitespace.
public func trimEnd(cs: String.UnicodeScalarView) -> String.UnicodeScalarView
{
    return _trim(cs, false, true)
}

private func _trim(cs: String.UnicodeScalarView, _ trimsStart: Bool, _ trimsEnd: Bool) -> String.UnicodeScalarView
{
    var startIndex = cs.startIndex
    var endIndex = cs.endIndex.predecessor()

    while trimsStart && isSpace(cs[startIndex]) {
        startIndex = startIndex.successor()
    }

    while trimsEnd && isSpace(cs[endIndex]) {
        endIndex = endIndex.predecessor()
    }

    return cs[startIndex...endIndex]
}
