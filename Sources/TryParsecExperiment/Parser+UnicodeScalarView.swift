import Foundation


/// MARK: Parser

/// Parses one StringElement that passes `predicate`.
public func satisfy(predicate: StringElement -> Bool) -> Parser<StringElement>.Function {
    return { input in
        if let head = input.first where predicate(head) {
            return .Done(input.dropFirst(), head)
        } else {
            return .Fail(input, [], "satisfy")
        }
    }
}

/// Skips one StringElement that passes `predicate`.
public func skip(predicate: StringElement -> Bool) -> Parser<()>.Function {
    return { input in
        if let head = input.first where predicate(head) {
            return .Done(input.dropFirst(), ())
        } else {
            return .Fail(input, [], "skip")
        }
    }
}

/// Skips zero or more StringElement that passes `predicate`.
public func skipWhile(predicate: StringElement -> Bool) -> Parser<()>.Function {
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
public func take(count: Int) -> Parser<StringContainer>.Function {
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
public func takeWhile(predicate: StringElement -> Bool) -> Parser<StringContainer>.Function {
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
public func char(c: StringElement) -> Parser<StringElement>.Function {
    return satisfy { $0 == c }
}

/// Parses any one StringElement which doesn't match `c`.
public func not(c: StringElement) -> Parser<StringElement>.Function {
    return satisfy { $0 != c }
}

/// Parses given string `str`.
public func string(str: StringContainer) -> Parser<StringContainer>.Function {
    if let head = str.first {
        return char(head) *> { string(str.dropFirst()) } *> { pure(str) }
    } else {
        return pure(StringContainer())
    }
}

private func _string(str: StringContainer, _ f: StringElement -> StringElement) -> Parser<StringContainer>.Function
{
    return { input in
        let strCount = str.count
        let prefix = input.prefix(strCount)
        if prefix.map(f) == str.map(f) {
            let suffix = input.suffixFrom(input.startIndex.advancedBy(strCount))
            return .Done(suffix, prefix)
        }
        else {
            return .Fail(input, [], "_string")
        }
    }
}

/// Parses given ASCII-string `str` with case-insensitive match.
public func asciiCI(str: StringContainer) -> Parser<StringContainer>.Function
{
    return _string(str, { c in
        let value = c.value

        // if `c` is in `"a"..."z"` (lowercase)
        if 97...122 ~= value {
            // transform to uppercase
            return UnicodeScalar(value - 32)  // ord 'a' - ord 'A' = 97 - 65 = 32
        }
        else {
            return c
        }
    })
}

/// Parses one StringElement which `xs` contains.
public func oneOf(xs: StringContainer) -> Parser<StringElement>.Function {
    return satisfy{ xs.contains($0) }
}

/// Parses one StringElement which `xs` doesn't contain.
public func noneOf(xs: StringContainer) -> Parser<StringElement>.Function {
    return satisfy { !xs.contains($0) }
}

/// Parses one digit StringElement which is in `"0"..."9"`.
public let digit = satisfy(isDigit)

/// Parses one StringElement which is in `"0"..."9"` or `"a"..."f"`.
public let hexDigit = satisfy(isHexDigit)

/// Parses one StringElement which is in `"a"..."z"`.
public let lowerAlphabet = satisfy(isLowerAlphabet)

/// Parses one StringElement which is in `"A"..."Z"`.
public let upperAlphabet = satisfy(isUpperAlphabet)

/// Parses one alphabet letter (case-insensitive).
public let alphabet = lowerAlphabet <|> { upperAlphabet }

/// Parses one alphabet (case-insensitive) or digit.
public let alphaNum = alphabet <|> { digit }

/// Parses first StringElement which is in `[" ", "\t", "\n", "\r"]`.
public let space = satisfy(isSpace)

/// Skips zero or more occurrences of `space`.
public let skipSpaces = skipMany(space)

/// Matches either a single newline character '\n',
/// or a carriage return followed by a newline character "\r\n".
public let endOfLine = char("\n") *> { pure(()) } <|> { string("\r\n") *> { pure(()) } }

// MARK: String -> Number

private func _signed<N: SignedNumberType>() -> Parser<N -> N>.Function {
    return char("-") *> { pure(negate) }
        <|> { zeroOrOne(char("+")) *> { pure(id) } }
}

private func _real() -> Parser<Double>.Function {
    return many1(digit) >>- { digits in
        pure(Double(String(digits))!)
    }
}

private func _frac() -> Parser<Double>.Function {
    return (char(".")
        *> { many1(digit) } >>- { digits in
            pure(Double(String(cons("0")(cons(".")(digits))))!)
        }) <|> { pure(0.0) }
}

private func _exp() -> Parser<Int>.Function {
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
private func _number() -> Parser<Double>.Function {
    return { s in { r in { f in { e in s(r + f) * pow(10, Double(e)) } } } }
        <^> _signed()
        <*> { _real() }
        <*> { _frac() }
        <*> { _exp() }
}
