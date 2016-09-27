#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin
#else
import Glibc
#endif

import Runes

/// Parses one UnicodeScalar that passes `predicate`.
public func satisfy(_ predicate: @escaping (UnicodeScalar) -> Bool) -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return Parser { input in
        if let (head, tail) = uncons(input), predicate(head) {
            return .done(tail, head)
        }
        else {
            return .fail(input, [], "satisfy")
        }
    }
}

/// Skips one UnicodeScalar that passes `predicate`.
public func skip(_ predicate: @escaping (UnicodeScalar) -> Bool) -> Parser<String.UnicodeScalarView, ()>
{
    return Parser { input in
        if let (head, tail) = uncons(input), predicate(head) {
            return .done(tail, ())
        }
        else {
            return .fail(input, [], "skip")
        }
    }
}

/// Skips zero or more UnicodeScalars that passes `predicate`.
public func skipWhile(_ predicate: @escaping (UnicodeScalar) -> Bool) -> Parser<String.UnicodeScalarView, ()>
{
    return Parser { input in
        fix { recur in { input in
            if let (head, tail) = uncons(input), predicate(head) {
                return recur(tail)
            }
            else {
                return .done(input, ())
            }
        }}(input)
    }
}

/// Parses at maximum of `count` UnicodeScalars.
/// - Precondition: `count >= 0`
public func take(_ count: Int) -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    precondition(count >= 0, "`take(count)` requires `count >= 0`.")

    return Parser { input in
        if input.count >= count {
            let (prefix, suffix) = splitAt(count)(input)
            return .done(suffix, prefix)
        }
        else {
            return .fail(input, [], "take(\(count))")
        }
    }
}

/// Parses zero or more UnicodeScalars that passes `predicate`.
public func takeWhile(_ predicate: @escaping (UnicodeScalar) -> Bool) -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    return Parser { input in
        fix { recur in { input, acc in
            if let (head, tail) = uncons(input), predicate(head) {
                return recur((tail, acc + [head]))
            }
            else {
                return .done(input, acc)
            }
        }}((input, String.UnicodeScalarView()))
    }
}

/// Parses any one element.
public let any = _any()
private func _any() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy(const(true))
}

/// Parses one UnicodeScalar matching `c`.
public func char(_ c: UnicodeScalar) -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy { $0 == c }
}

/// Parses any one UnicodeScalar which doesn't match `c`.
public func not(_ c: UnicodeScalar) -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy { $0 != c }
}

/// Parses given string `str`.
public func string(_ str: String.UnicodeScalarView) -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    // Comment-Out: slower
//    return _string(str, id)

    if let (head, tail) = uncons(str) {
        return char(head) *> string(tail) *> pure(str)
    }
    else {
        return pure(String.UnicodeScalarView())
    }
}

private func _string(_ str: String.UnicodeScalarView, _ f: @escaping (UnicodeScalar) -> UnicodeScalar) -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    return Parser { input in
        let strCount = str.count
        let prefix = input.prefix(strCount)
        if prefix.map(f) == str.map(f) {
            let index = input.index(input.startIndex, offsetBy: strCount)
            let suffix = input.suffix(from: index)
            return .done(suffix, prefix)
        }
        else {
            return .fail(input, [], "_string")
        }
    }
}

/// Parses given ASCII-string `str` with case-insensitive match.
public func asciiCI(_ str: String.UnicodeScalarView) -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    return _string(str, { c in
        let value = c.value

        // if `c` is in `"a"..."z"` (lowercase)
        if 97...122 ~= value {
            // transform to uppercase
            return UnicodeScalar(value - 32)!  // ord 'a' - ord 'A' = 97 - 65 = 32
        }
        else {
            return c
        }
    })
}

/// Parses one UnicodeScalar which `xs` contains.
public func oneOf(_ xs: String.UnicodeScalarView) -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy { xs.contains($0) }
}

/// Parses one UnicodeScalar which `xs` doesn't contain.
public func noneOf(_ xs: String.UnicodeScalarView) -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy { !xs.contains($0) }
}

/// Parses one digit UnicodeScalar which is in `"0"..."9"`.
public let digit = _digit()
private func _digit() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy(isDigit)
}

/// Parses one UnicodeScalar which is in `"0"..."9"` or `"a"..."f"`.
public let hexDigit = _hexDigit()
private func _hexDigit() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy(isHexDigit)
}

/// Parses one UnicodeScalar which is in `"a"..."z"`.
public let lowerAlphabet = _lowerAlphabet()
private func _lowerAlphabet() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy(isLowerAlphabet)
}

/// Parses one UnicodeScalar which is in `"A"..."Z"`.
public let upperAlphabet = _upperAlphabet()
private func _upperAlphabet() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy(isUpperAlphabet)
}

/// Parses one alphabet letter (case-insensitive).
public let alphabet = _alphabet()
private func _alphabet() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return lowerAlphabet <|> upperAlphabet
}

/// Parses one alphabet (case-insensitive) or digit.
public let alphaNum = _alphaNum()
private func _alphaNum() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return alphabet <|> digit
}

/// Parses one UnicodeScalar which is in `[" ", "\t", "\n", "\r"]`.
public let space = _space()
private func _space() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy(isSpace)
}

/// Skips zero or more occurrences of `space`.
public let skipSpaces = _skipSpaces()
private func _skipSpaces() -> Parser<String.UnicodeScalarView, ()>
{
    return skipMany(space)
}

/// Matches either a single newline character '\n',
/// or a carriage return followed by a newline character "\r\n".
public let endOfLine = _endOfLine()
private func _endOfLine() -> Parser<String.UnicodeScalarView, ()>
{
    return char("\n") *> pure(())
        <|> string("\r\n") *> pure(())
}

// MARK: String -> Number

private func _signed<N: SignedNumber>() -> Parser<String.UnicodeScalarView, (N) -> N>
{
    return char("-") *> pure(negate)
        <|> zeroOrOne(char("+")) *> pure(id)
}

private func _real() -> Parser<String.UnicodeScalarView, Double>
{
    return many1(digit) >>- { digits in
        pure(Double(String(digits))!)
    }
}

private func _frac() -> Parser<String.UnicodeScalarView, Double>
{
    return (char(".")
        *> many1(digit) >>- { digits in
            pure(Double(String(cons("0")(cons(".")(digits))))!)
        }) <|> pure(0.0)
}

private func _exp() -> Parser<String.UnicodeScalarView, Int>
{
    return (oneOf("eE")
        *> _signed() >>- { doExp in
            many1(digit) >>- { digits in
                pure(doExp(Int(String(digits))!))
            }
        }) <|> pure(0)
}

///
/// Parses a scientific-E-notation number.
///
/// For example:
/// - `parse(number, "-12.5e-1")` will output `-1.25`
///
public let number = _number()
private func _number() -> Parser<String.UnicodeScalarView, Double>
{
    return { s in { r in { f in { e in s(r + f) * pow(10, Double(e)) } } } }
        <^> _signed()
        <*> _real()
        <*> _frac()
        <*> _exp()
}
