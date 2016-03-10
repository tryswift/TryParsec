import Foundation


/// MARK: Parser

/// Parses one StringElement that passes `predicate`.
public func satisfy(predicate: StringElement -> Bool) -> Result<StringElement>.Parser {
    return { input in
        if let head = input.first where predicate(head) {
            return .Done(input.dropFirst(), head)
        } else {
            return .Fail(input, [], "satisfy")
        }
    }
}

/// Skips one StringElement that passes `predicate`.
public func skip(predicate: StringElement -> Bool) -> Result<()>.Parser {
    return { input in
        if let head = input.first where predicate(head) {
            return .Done(input.dropFirst(), ())
        } else {
            return .Fail(input, [], "skip")
        }
    }
}

/// Skips zero or more StringElement that passes `predicate`.
public func skipWhile(predicate: StringElement -> Bool) -> Result<()>.Parser {
    return { input in
        fix { recur in { input in
            if let head = input.first where predicate(head) {
                return recur(input.dropFirst())
            } else {
                return .Done(input, ())
            }
        }}(input)
    }
}

/// Parses at maximum of `count` StringElement.
/// - Precondition: `count >= 0`
public func take(count: Int) -> Result<StringContainer>.Parser {
    precondition(count >= 0, "`take(count)` requires `count >= 0`.")

    return { input in
        if input.count >= count {
            let (prefix, suffix) = splitAt(count)(input)
            return .Done(suffix, prefix)
        } else {
            return .Fail(input, [], "take(\(count))")
        }
    }
}

/// Parses zero or more StringElement that passes `predicate`.
public func takeWhile(predicate: StringElement -> Bool) -> Result<StringContainer>.Parser {
    return { input in
        fix { recur in { input, acc in
            if let head = input.first where predicate(head) {
                return recur(input.dropFirst(), acc + [head])
            } else {
                return .Done(input, acc)
            }
        }}(input, StringContainer())
    }
}

/// Parses any one StringElement.
public let any = satisfy(const(true))

/// Parses one StringElement matching `c`.
public func char(c: StringElement) -> Result<StringElement>.Parser {
    return satisfy { $0 == c }
}

/// Parses any one StringElement which doesn't match `c`.
public func not(c: StringElement) -> Result<StringElement>.Parser {
    return satisfy { $0 != c }
}

/// Parses given string `str`.
public func string(str: StringContainer) -> Result<StringContainer>.Parser {
    if let head = str.first {
        return char(head) *> { string(str.dropFirst()) } *> { pure(str) }
    } else {
        return pure(StringContainer())
    }
}

/// Parses one StringElement which `xs` contains.
public func oneOf(xs: StringContainer) -> Result<StringElement>.Parser {
    return satisfy{ xs.contains($0) }
}

/// Parses one StringElement which `xs` doesn't contain.
public func noneOf(xs: StringContainer) -> Result<StringElement>.Parser {
    return satisfy { !xs.contains($0) }
}

/// Parses one digit StringElement which is in `"0"..."9"`.
public let digit = satisfy(isDigit)
public func isDigit(character: StringElement) -> Bool {
    return "0"..."9" ~= character
}

/// Parses one StringElement which is in `"0"..."9"` or `"a"..."f"`.
public let hexDigit = satisfy(isHexDigit)
public func isHexDigit(c: StringElement) -> Bool {
    return "0"..."9" ~= c || "a"..."f" ~= c || "A"..."F" ~= c
}

/// Parses one StringElement which is in `"a"..."z"`.
public let lowerAlphabet = satisfy(isLowerAlphabet)
public func isLowerAlphabet(c: StringElement) -> Bool {
    return "a"..."z" ~= c
}

/// Parses one StringElement which is in `"A"..."Z"`.
public let upperAlphabet = satisfy(isUpperAlphabet)
public func isUpperAlphabet(c: StringElement) -> Bool {
    return "A"..."Z" ~= c
}

/// Parses one alphabet letter (case-insensitive).
public let alphabet = lowerAlphabet <|> { upperAlphabet }

/// Parses one alphabet (case-insensitive) or digit.
public let alphaNum = alphabet <|> { digit }

/// Parses first StringElement which is in `[" ", "\t", "\n", "\r"]`.
public let space = satisfy(isSpace)
public func isSpace(character: StringElement) -> Bool {
    return [" ", "\t", "\n", "\r"].contains(character)
}

/// Skips zero or more occurrences of `space`.
public let skipSpaces = skipMany(space)

/// Matches either a single newline character '\n',
/// or a carriage return followed by a newline character "\r\n".
public let endOfLine = char("\n") *> { pure(()) } <|> { string("\r\n") *> { pure(()) } }

// MARK: String -> Number

private func _signed<N: SignedNumberType>() -> Result<N -> N>.Parser {
    return char("-") *> { pure(negate) }
        <|> { zeroOrOne(char("+")) *> { pure(id) } }
}

private func _real() -> Result<Double>.Parser {
    return many1(digit) >>- { digits in
        pure(Double(String(digits))!)
    }
}

private func _frac() -> Result<Double>.Parser {
    return (char(".")
        *> { many1(digit) } >>- { digits in
            pure(Double(String(cons("0")(cons(".")(digits))))!)
        }) <|> { pure(0.0) }
}

private func _exp() -> Result<Int>.Parser {
    return (oneOf("eE")
        *> { _signed() } >>- { doExp in
            many1(digit) >>- { digits in
                pure(doExp(Int(String(digits))!))
            }
        }) <|> { pure(0) }
}

///
/// Parses a scientific-E-notation number.
///
/// For example:
/// - `parse(number, "-12.5e-1")` will output `-1.25`
///
public let number = _number()
private func _number() -> Result<Double>.Parser {
    return { s in { r in { f in { e in s(r + f) * pow(10, Double(e)) } } } }
        <^> _signed()
        <*> { _real() }
        <*> { _frac() }
        <*> { _exp() }
}
