import Foundation

/// Parses simple arithmetic expression.
/// Currently supports: +, -, *, /, (, ), naturalNumber.
public func parseArithmetic(str: String) -> Int? {
    return parseOnly(_expr() <* { endOfInput() }, str.unicodeScalars)
}

private func _symbol(str: StringContainer) -> Result<StringContainer>.Parser {
    return skipSpaces *> { string(str) } <* { skipSpaces }
}

private func _natural() -> Result<Int>.Parser {
    return skipSpaces *> { many1(digit) } <* { skipSpaces } <&> { Int(String($0))! }
}

private func _expr() -> Result<Int>.Parser {
    return chainl1(_term(), _symbol("+") *> { pure(+) } <|> { _symbol("-") *> { pure(-) }})
}

private func _term() -> Result<Int>.Parser {
    return chainl1(_factor(), _symbol("*") *> { pure(*) } <|> { _symbol("/") *> { pure(/) }})
}

private func _factor() -> Result<Int>.Parser {
    return (_symbol("(") *> { _expr() } <* { _symbol(")") }) <|> { _natural() }
}
