import Runes
import Result

//
// CSV (RFC4180)
// https://www.ietf.org/rfc/rfc4180.txt
//

/// Parses _character_-separated values. Default separator is ",".
public func parseCSV(separator: UnicodeScalar = ",", _ str: String) -> Result<[[String]], ParseError>
{
    let p = csv(char(separator)) <* endOfInput() <&> { xss in
        xss.map { xs in
            xs.map { String($0) }
        }
    }

    return parseOnly(p, str.unicodeScalars)
}

// MARK: Private

/// file = record *(CRLF record) [CRLF]
internal func csv(_ sep: Parser<String.UnicodeScalarView, UnicodeScalar>) -> Parser<String.UnicodeScalarView, ArraySlice<ArraySlice<String.UnicodeScalarView>>>
{
    return sepEndBy1(record(sep), lf <|> crlf)
        <&> { (xss: ArraySlice<ArraySlice<String.UnicodeScalarView>>) in

            let (heads, tails) = splitAt(xss.count-1)(xss)
            if let last = tails.last, tails.count == 1 && last == [ "" ] {
                return heads
            }
            else {
                return xss
            }
        }
}

/// record = field *(COMMA field)
internal func record(_ sep: Parser<String.UnicodeScalarView, UnicodeScalar>) -> Parser<String.UnicodeScalarView, ArraySlice<String.UnicodeScalarView>>
{
    return sepBy1(field(sep), sep)
}

/// field = (escaped / non-escaped)
internal func field(_ sep: Parser<String.UnicodeScalarView, UnicodeScalar>) -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    return escaped(sep) <|> nonEscaped
}

/// escaped = DQUOTE *(TEXTDATA / COMMA / CR / LF / 2DQUOTE) DQUOTE
internal func escaped(_ sep: Parser<String.UnicodeScalarView, UnicodeScalar>) -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    return doubleQuote
        *> many(textData <|> sep <|> cr <|> lf <|> (doubleQuote *> doubleQuote))
        <* doubleQuote
}

/// non-escaped = *TEXTDATA
internal let nonEscaped = _nonEscaped()
private func _nonEscaped() -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    return many(textData)
}

/// TEXTDATA =  %x20-21 / %x23-2B / %x2D-7E
internal let textData = _textData()
private func _textData() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy { c in
        isInClosedIntervals(c, 0x20...0x21, 0x23...0x2b, 0x2d...0x7e)
    }
}

/// CRLF = CR LF
internal let crlf = _crlf()
private func _crlf() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return cr *> lf
}

/// LF = %x0A
internal let lf = _lf()
private func _lf() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return char("\n")
}

/// CR = %x0D
internal let cr = _cr()
private func _cr() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return char("\r")
}

/// DQUOTE = %x22
internal let doubleQuote = _doubleQuote()
private func _doubleQuote() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return char("\"")
}

/// COMMA = %x2C
internal let comma = _comma()
private func _comma() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return char(",")
}
