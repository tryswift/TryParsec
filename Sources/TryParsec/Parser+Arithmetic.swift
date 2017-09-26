import Runes
import Result

/// Parses simple arithmetic expression.
/// Currently supports: +, -, *, /, (, ), naturalNumber.
public func parseArithmetic(_ str: String) -> Result<Int, ParseError>
{
    return parseOnly(expr <* endOfInput(), str.unicodeScalars)
}

private func _symbol(_ str: String.UnicodeScalarView) -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    return skipSpaces *> string(str) <* skipSpaces
}

private func _natural() -> Parser<String.UnicodeScalarView, Int>
{
    return skipSpaces *> many1(digit) <* skipSpaces <&> { Int(String($0 as String.UnicodeScalarView))! }
}

internal let expr = _expr()
private func _expr() -> Parser<String.UnicodeScalarView, Int>
{
    return chainl1(term, _symbol("+") *> pure(+) <|> _symbol("-") *> pure(-))
}

internal let term = _term()
private func _term() -> Parser<String.UnicodeScalarView, Int>
{
    return chainl1(factor, _symbol("*") *> pure(*) <|> _symbol("/") *> pure(/))
}

internal let factor = _factor()
private func _factor() -> Parser<String.UnicodeScalarView, Int>
{
    return (_symbol("(") *> expr <* _symbol(")"))
        <|> _natural()
}
