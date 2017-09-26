import Runes
import Result

infix operator >>- : RunesMonadicPrecedenceLeft // redefine

//
// XML 1.0
// https://www.w3.org/TR/xml/
//

/// Parses XML.
public func parseXML(_ str: String) -> Result<[XML], ParseError>
{
    return parseOnly(xmlDocument, str.unicodeScalars)
}

// MARK: Private

/// document ::= prolog element Misc*
internal let xmlDocument = _xmlDocument()
private func _xmlDocument() -> Parser<String.UnicodeScalarView, [XML]>
{
    return { a1 in { a2 in return (a1 ?? []) + a2 }}
        <^> zeroOrOne(prolog) <* skipSpaces
        <*> xmlContent <* skipSpaces <* endOfInput()
}

/// TextDecl ::= '<?xml' VersionInfo? EncodingDecl S? '?>'
internal let xmlDeclaration = _xmlDeclaration()
private func _xmlDeclaration() -> Parser<String.UnicodeScalarView, XML>
{
    return string("<?xml") *> manyTill(any, string("?>"))
        <&> { .xmlDeclaration(String($0 as String.UnicodeScalarView)) }
}

/// doctypedecl ::= '<!DOCTYPE' S Name ( S ExternalID )? S? ( '[' intSubset ']' S? )? '>'
internal let doctype = _doctype()
private func _doctype() -> Parser<String.UnicodeScalarView, XML>
{
    return string("<!DOCTYPE") *> manyTill(any, string(">"))
        <&> { .doctype(String($0 as String.UnicodeScalarView)) }
}

/// Comment ::= '<!--' ( Char - '-' | '-' ( Char - '-' ) )* '-->'
internal let comment = _comment()
private func _comment() -> Parser<String.UnicodeScalarView, XML>
{
    return string("<!--") *> manyTill(any, string("-->"))
        <&> { .comment(String($0 as String.UnicodeScalarView)) }
}

/// - CDSect ::= CDStart CData CDEnd
/// - CDStart ::= '<![CDATA['
/// - CData ::= Char* - ( Char* ']]>' Char* )
/// - CDEnd ::= ']]>'
internal let cdata = _cdata()
private func _cdata() -> Parser<String.UnicodeScalarView, XML>
{
    return string("<![CDATA[") *> manyTill(any, string("]]>"))
        <&> { .text(String($0 as String.UnicodeScalarView)) }
}

/// PI ::= '<?' PITarget ( S ( Char* - ( Char* '?>' Char* ) ) )? '?>'
internal let processingInstruction = _processingInstruction()
private func _processingInstruction() -> Parser<String.UnicodeScalarView, XML>
{
    return string("<?") *> manyTill(any, string("?>"))
        <&> { .processingInstruction(String($0 as String.UnicodeScalarView)) }
}

/// Misc ::= Comment | PI | S
internal let manyMisc = _manyMisc()
private func _manyMisc() -> Parser<String.UnicodeScalarView, [XML]>
{
    return many(skipSpaces *> (comment <|> processingInstruction) <* skipSpaces)
}

/// prolog ::= XMLDecl? Misc* ( doctypedecl Misc* )?
internal let prolog = _prolog()
private func _prolog() -> Parser<String.UnicodeScalarView, [XML]>
{
    let temp = { (a1: XML?) in { (a2: [XML]) in { (a3: [XML]?) in
        return a1.toArray() + a2 + (a3 ?? [])
        }}}
        <^> zeroOrOne(skipSpaces *> xmlDeclaration <* skipSpaces)
    return temp
        <*> manyMisc
        <*> zeroOrOne({ d in { m in ([d] + m)} } <^> doctype <*> manyMisc)
}

/// - element ::= EmptyElemTag | STag content ETag
/// - EmptyElement ::= '<' Name (S Attribute)* S? '/>';
internal let xmlElement = _xmlElement()
private func _xmlElement() -> Parser<String.UnicodeScalarView, XML>
{
    return char("<")
        *> skipSpaces
        *> xmlName
        >>- { (tagName: String.UnicodeScalarView) -> Parser<String.UnicodeScalarView, XML> in
            skipSpaces
                *> many(attribute <* skipSpaces)
                >>- { (attrs: [XML.Attribute]) in
                    skipSpaces
                        *> (string("/>") *> pure(XML.emptyElement(String(tagName), attrs)))
                        <|> (string(">")
                            *> xmlContent >>- { (bodies: [XML]) in
                                _endTag(tagName)
                                    *> skipSpaces
                                    *> pure(XML.element(String(tagName), attrs, bodies))
                            })

                }
        }
}

/// content ::= CharData? ( ( element | Reference | CDSect | PI | Comment ) CharData? )*
internal let xmlContent = _xmlContent()
private func _xmlContent() -> Parser<String.UnicodeScalarView, [XML]>
{
    return many(xmlElement <|> reference <|> cdata <|> processingInstruction <|> comment <|> charData)
}

/// ETag ::= '</' Name S? '>'
private func _endTag(_ tagName: String.UnicodeScalarView) -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    return string("</") *> string(tagName) <* char(">")
}

/// CharData ::= [^<&]* - ( [^<&]* ']]>' [^<&]* )
internal let charData = _charData()
private func _charData() -> Parser<String.UnicodeScalarView, XML>
{
    return many1(noneOf("><&")) <&> { XML.text(String($0 as String.UnicodeScalarView)) }
}

/// Attribute ::= Name Eq AttValue
internal let attribute = _attribute()
private func _attribute() -> Parser<String.UnicodeScalarView, XML.Attribute>
{
    return xmlName >>- { name in
        skipSpaces
            *> char("=")
            *> skipSpaces
            *> attrValue >>- { value in
                pure(XML.Attribute(String(name), String(value)))
            }
    }
}

private func _isNameStartChar(_ c: UnicodeScalar) -> Bool
{
    return c == ":" || c == "_" || isAlphabet(c) || isInClosedIntervals(c, 0x00c0...0x00d6, 0x00d8...0x00f6, 0x00f8...0x02ff, 0x0370...0x037d, 0x037f...0x1fff, 0x200c...0x200d, 0x2070...0x218f, 0x2c00...0x2fef, 0x3001...0xd7ff, 0xf900...0xfdcf, 0xfdf0...0xfffd, 0x10000...0xeffff)
}

internal let nameStartChar = _nameStartChar()
private func _nameStartChar() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy(_isNameStartChar)
}

private func _isNameChar(_ c: UnicodeScalar) -> Bool
{
    return _isNameStartChar(c) || c == "-" || c == "." || isDigit(c) || c == "\u{00b7}" || isInClosedIntervals(c, 0x0300...0x036f, 0x203f...0x2040)
}

internal let nameChar = _nameChar()
private func _nameChar() -> Parser<String.UnicodeScalarView, UnicodeScalar>
{
    return satisfy(_isNameChar)
}

/// Name ::= NameStartChar NameChar*
internal let xmlName = _xmlName()
private func _xmlName() -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    return cons <^> nameStartChar <*> many(nameChar)
}

/// AttValue ::= '"' ( [^<&"] | Reference )* '"' | "'" ( [^<&'] | Reference )* "'"
internal let attrValue = _attrValue()
private func _attrValue() -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    func manyRefsButNoneOf(_ cs: String.UnicodeScalarView) -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
    {
        return many((noneOf(cs) <&> String.UnicodeScalarView.init) <|> entityRef <|> charRef)
            <&> { (xss: [String.UnicodeScalarView]) in xss.reduce("", +) }
    }

    return (char("\"") *> manyRefsButNoneOf("<&\"") <* char("\""))
        <|> (char("'") *> manyRefsButNoneOf("<&'") <* char("'"))
}

/// `&***;` or `&#...;`
/// e.g. © = `&copy;`, `&#xa9;`, `&#169;`.
///
/// Reference ::= EntityRef | CharRef
internal let reference = _reference()
private func _reference() -> Parser<String.UnicodeScalarView, XML>
{
    return (entityRef <|> charRef) <&> { XML.text(String($0)) }
}

/// EntityRef ::= '&' Name ';'
internal let entityRef = _entityRef()
private func _entityRef() -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    return char("&") *> xmlName <* char(";")
        <&> { cons("&")($0) + [";"] }
}

/// CharRef ::= '&#' [0-9]+ ';' | '&#x' [0-9a-fA-F]+ ';'
internal let charRef = _charRef()
private func _charRef() -> Parser<String.UnicodeScalarView, String.UnicodeScalarView>
{
    return string("&#") *>
        (many1(digit) <|> (cons <^> char("x") <*> many1(hexDigit)))
        <* char(";")
        <&> { "&#" as String.UnicodeScalarView + $0 + [";"] }
}
