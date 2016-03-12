import Result

//
// JSON (ECMA-404)
// http://json.org/
//

/// Parses JSON.
public func parseJSON(str: String) -> Result<JSON, ParseError>
{
    return parseOnly(json, str.unicodeScalars)
}

/// Helper function to return `.Failure` from type-mismatched JSON.
public func typeMismatch<Expected>(json: JSON, expected: String) -> Result<Expected, JSON.ParseError>
{
    return .Failure(.TypeMismatched(expected: expected, actual: json.description))
}

// MARK: Private

internal let json = skipSpaces *> { jsonValue } <* { skipSpaces } <* { endOfInput() }
internal let jsonValue = jsonString <|> { jsonNumber <|> { jsonArray <|> { jsonObject <|> { jsonNull <|> { jsonBool } } } } }

internal let jsonNull = _jsonNull()
private func _jsonNull() -> Parser<JSON>.Function
{
    return string("null") *> { pure(.Null) }
}

internal let jsonBool = _jsonBool()
private func _jsonBool() -> Parser<JSON>.Function
{
    return (string("true") *> { pure(.Bool(true))} )
        <|> { (string("false") *> { pure(.Bool(false)) }) }
}

internal let jsonNumber = _jsonNumber()
private func _jsonNumber() -> Parser<JSON>.Function
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
private func _stringLiteral() -> Parser<StringContainer>.Function
{
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

internal let jsonString = _jsonString()
private func _jsonString() -> Parser<JSON>.Function
{
    return stringLiteral <&> { JSON.String(String($0)) }
}

private func _list<A>(
    open: Parser<StringElement>.Function,
    _ close: Parser<StringElement>.Function,
    _ element: Parser<A>.Function,
    _ f: ([A] -> JSON)
    ) -> Parser<JSON>.Function
{
    return open *>
        { (skipSpaces *> { (sepBy(element <* { skipSpaces }, char(",") <* { skipSpaces }) <&> f) }) }
        <* { close }
}

internal let jsonArray = _jsonArray()
private func _jsonArray() -> Parser<JSON>.Function
{
    return _list(char("["), char("]"), jsonValue, JSON.Array)
}

internal let keyValue = _keyValue()
private func _keyValue() -> Parser<(StringContainer, JSON)>.Function
{
    return { a in { b in (a, b) } }
        <^> stringLiteral
        <*> { (skipSpaces *> { char(":") } *> { skipSpaces } *> { jsonValue }) }
}

internal let jsonObject = _jsonObject()
private func _jsonObject() -> Parser<JSON>.Function
{
    return _list(char("{"), char("}"), keyValue) { tuples in
        JSON.Object(toDict(tuples.map { (String($0.0), $0.1) }))
    }
}
