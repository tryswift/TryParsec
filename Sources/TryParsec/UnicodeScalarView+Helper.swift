extension String.UnicodeScalarView: ExpressibleByStringLiteral
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

extension String.UnicodeScalarView: ExpressibleByArrayLiteral
{
    public init(arrayLiteral elements: UnicodeScalar...)
    {
        self.init()
        self.append(contentsOf: elements)
    }
}

extension String.UnicodeScalarView: Equatable {}

public func == (lhs: String.UnicodeScalarView, rhs: String.UnicodeScalarView) -> Bool
{
    return String(lhs) == String(rhs)
}

// MARK: Functions

public func isDigit(_ c: UnicodeScalar) -> Bool
{
    return "0"..."9" ~= c
}

public func isHexDigit(_ c: UnicodeScalar) -> Bool
{
    return "0"..."9" ~= c || "a"..."f" ~= c || "A"..."F" ~= c
}

public func isLowerAlphabet(_ c: UnicodeScalar) -> Bool
{
    return "a"..."z" ~= c
}

public func isUpperAlphabet(_ c: UnicodeScalar) -> Bool
{
    return "A"..."Z" ~= c
}

public func isAlphabet(_ c: UnicodeScalar) -> Bool
{
    return isLowerAlphabet(c) || isUpperAlphabet(c)
}

private let _spaces: String.UnicodeScalarView = [ " ", "\t", "\n", "\r" ]

public func isSpace(_ c: UnicodeScalar) -> Bool
{
    return _spaces.contains(c)
}

/// UnicodeScalar validation using array of `ClosedInterval`.
public func isInClosedIntervals(_ c: UnicodeScalar, _ closedIntervals: ClosedRange<UInt32>...) -> Bool
{
    for closedInterval in closedIntervals {
        if closedInterval.contains(c.value) {
            return true
        }
    }
    return false
}

/// Removes head & tail whitespaces.
public func trim(_ cs: String.UnicodeScalarView) -> String.UnicodeScalarView
{
    return _trim(cs, true, true)
}

/// Removes head whitespace.
public func trimStart(_ cs: String.UnicodeScalarView) -> String.UnicodeScalarView
{
    return _trim(cs, true, false)
}

/// Removes tail whitespace.
public func trimEnd(_ cs: String.UnicodeScalarView) -> String.UnicodeScalarView
{
    return _trim(cs, false, true)
}

private func _trim(_ cs: String.UnicodeScalarView, _ trimsStart: Bool, _ trimsEnd: Bool) -> String.UnicodeScalarView
{
    var startIndex = cs.startIndex
    var endIndex = cs.index(before: cs.endIndex)

    print("1")

    while trimsStart && isSpace(cs[startIndex]) {
        print("2")
        startIndex = cs.index(after: startIndex)
    }

    while trimsEnd && isSpace(cs[endIndex]) {
        print(cs[endIndex])
        endIndex = cs.index(before: endIndex)
    }

    return cs[startIndex...endIndex]
}
