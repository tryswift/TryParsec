import Runes
import Result

//
// JSON (ECMA-404)
// http://json.org/
//

/// Parses JSON.
public func parseJSON(_ str: String) -> Result<JSON, ParseError>
{
    return parseOnly(json, str.unicodeScalars)
}

/// Helper function to return `.failure` from type-mismatched JSON.
public func typeMismatch<Expected>(_ json: JSON, expected: String) -> Result<Expected, JSON.ParseError>
{
    return .failure(.typeMismatched(expected: expected, actual: json.description))
}

// MARK: Private

internal let json = _json()
private func _json() -> Parser<String.UnicodeScalarView, JSON>
{
    return skipSpaces *> jsonValue <* skipSpaces <* endOfInput()
}

internal let jsonValue = _jsonValue()
private func _jsonValue() -> Parser<String.UnicodeScalarView, JSON>
{
    return jsonString <|> jsonNumber <|> jsonArray <|> jsonObject <|> jsonNull <|> jsonBool
}

internal let jsonNull = _jsonNull()
private func _jsonNull() -> Parser<String.UnicodeScalarView, JSON>
{
    return string("null") *> pure(.null)
}

internal let jsonBool = _jsonBool()
private func _jsonBool() -> Parser<String.UnicodeScalarView, JSON>
{
    return (string("true") *> pure(.bool(true)))
        <|> (string("false") *> pure(.bool(false)))
}

internal let jsonNumber = _jsonNumber()
private func _jsonNumber() -> Parser<String.UnicodeScalarView, JSON>
{
    return number <&> JSON.number
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
private func _stringLiteral() -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    let normalChar = satisfy { $0 != "\\" && $0 != "\""}
    let escapedChar = char("\\")
        *> oneOf(_escapedCharMappingKeys)
        <&> { _escapedCharMapping[$0]! }
    let unicodeChar = string("\\u")
        *> count(4, hexDigit)
        <&> { UnicodeScalar(Int(String($0 as String.UnicodeScalarView), radix: 16)!)! }
    let validChar = normalChar <|> escapedChar <|> unicodeChar

    return char("\"") *> many(validChar) <* char("\"")
}

internal let jsonString = _jsonString()
private func _jsonString() -> Parser<String.UnicodeScalarView, JSON>
{
    return stringLiteral <&> { JSON.string(String($0)) }
}

private func _list<A>(
    _ open: Parser<String.UnicodeScalarView, UnicodeScalar>,
    _ close: Parser<String.UnicodeScalarView, UnicodeScalar>,
    _ element: Parser<String.UnicodeScalarView, A>,
    _ f: @escaping (([A]) -> JSON)
    ) -> Parser<String.UnicodeScalarView, JSON>
{
    return open *>
        (skipSpaces *> (sepBy(element <* skipSpaces, char(",") <* skipSpaces) <&> f))
        <* close
}

internal let jsonArray = _jsonArray()
private func _jsonArray() -> Parser<String.UnicodeScalarView, JSON>
{
    return _list(char("["), char("]"), jsonValue, JSON.array)
}

internal let keyValue = _keyValue()
private func _keyValue() -> Parser<String.UnicodeScalarView, (String.UnicodeScalarView, JSON)>
{
    return { a in { b in (a, b) } }
        <^> stringLiteral
        <*> (skipSpaces *> char(":") *> skipSpaces *> jsonValue)
}

internal let jsonObject = _jsonObject()
private func _jsonObject() -> Parser<String.UnicodeScalarView, JSON>
{
    return _list(char("{"), char("}"), keyValue) { tuples in
        JSON.object(toDict(tuples.map { (String($0.0), $0.1) }))
    }
}
