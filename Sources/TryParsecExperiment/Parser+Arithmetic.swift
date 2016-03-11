import Result

/// Parses simple arithmetic expression.
/// Currently supports: +, -, *, /, (, ), naturalNumber.
public func parseArithmetic(str: String) -> Result<Int, ParseError>
{
    return parseOnly(_expr() <* { endOfInput() }, str.unicodeScalars)
}

private func _symbol(str: StringContainer) -> Parser<StringContainer>.Function
{
    return skipSpaces *> { string(str) } <* { skipSpaces }
}

private func _natural() -> Parser<Int>.Function
{
    return skipSpaces *> { many1(digit) } <* { skipSpaces } <&> { Int(String($0))! }
}

internal let expr = _expr()
private func _expr() -> Parser<Int>.Function
{
    return chainl1(_term(), _symbol("+") *> { pure(+) } <|> { _symbol("-") *> { pure(-) }})
}

internal let term = _term()
private func _term() -> Parser<Int>.Function
{
    return chainl1(_factor(), _symbol("*") *> { pure(*) } <|> { _symbol("/") *> { pure(/) }})
}

internal let factor = _factor()
private func _factor() -> Parser<Int>.Function
{
    return (_symbol("(") *> { _expr() } <* { _symbol(")") }) <|> { _natural() }
}
