//
// JSON (ECMA-404)
// http://json.org/
//

/// Parses JSON.
public func parseJSON(str: String) -> JSON? {
    return parseOnly(json, str.unicodeScalars)
}

/// Helper function to return `.Failure` from type-mismatched JSON.
//public func typeMismatch<Expected>(json: JSON, expected: String) -> Result<Expected, JSON.ParseError>
//{
//    return .Failure(.TypeMismatched(expected: expected, actual: json.description))
//}

// MARK: Private

internal let json = skipSpaces *> jsonValue <* { skipSpaces } <* { endOfInput() }

private func jsonValue() -> Result<JSON>.Parser {
    return jsonString() <|> { jsonNumber() <|> { jsonArray() <|> { jsonObject() <|> { jsonNull() <|> { jsonBool() } } } } }
}

private func jsonNull() -> Result<JSON>.Parser {
    return string("null") *> { pure(.Null) }
}

private func jsonBool() -> Result<JSON>.Parser {
    return (string("true") *> { pure(.Bool(true))} )
        <|> { (string("false") *> { pure(.Bool(false)) }) }
}

private func jsonNumber() -> Result<JSON>.Parser
{
    return number <&> JSON.Number
}

private let _escapedCharMapping: [UnicodeScalar : UnicodeScalar] = [
    "\"" : "\"",
    "\\" : "\\",
    "/" : "/",
    "n" : "\n",
    "r" : "\r",
    "f" : "\u{8}",
    "t" : "\t",
    "b" : "\u{12}"
]
private let _escapedCharMappingKeys = String.UnicodeScalarView(_escapedCharMapping.keys)

/// Parses double-quoted text, e.g. `"123\n456"`.
internal let stringLiteral = _stringLiteral()
private func _stringLiteral() -> Result<StringContainer>.Parser {
    let normalChar = satisfy { $0 != "\\" && $0 != "\""}
    let escapedChar = char("\\")
        *> { oneOf(_escapedCharMappingKeys) }
        <&> { _escapedCharMapping[$0]! }
    let unicodeChar = string("\\u")
        *> { count(4, hexDigit) }
        <&> { UnicodeScalar(Int(String($0), radix: 16)!) }
    let validChar = normalChar <|> { escapedChar <|> { unicodeChar } }

    return char("\"") *> { many(validChar) } <* { char("\"") }
}

private func jsonString() -> Result<JSON>.Parser {
    return stringLiteral <&> { JSON.String(String($0)) }
}

private func _list<A>(
    open: Result<StringElement>.Parser,
    _ close: Result<StringElement>.Parser,
    _ element: Result<A>.Parser,
    _ f: ([A] -> JSON)
    ) -> Result<JSON>.Parser
{
    return open *>
        { (skipSpaces *> { (sepBy(element <* { skipSpaces }, char(",") <* { skipSpaces }) <&> f) }) }
        <* { close }
}

private func jsonArray() -> Result<JSON>.Parser {
    return _list(char("["), char("]"), jsonValue(), JSON.Array)
}

internal let keyValue = _keyValue()
private func _keyValue() -> Result<(String.UnicodeScalarView, JSON)>.Parser {
    return { a in { b in (a, b) } }
        <^> stringLiteral
        <*> { (skipSpaces *> { char(":") } *> { skipSpaces } *> jsonValue ) }
}

private func jsonObject() -> Result<JSON>.Parser
{
    return _list(char("{"), char("}"), keyValue) { tuples in
        JSON.Object(toDict(tuples.map { (String($0.0), $0.1) }))
    }
}
